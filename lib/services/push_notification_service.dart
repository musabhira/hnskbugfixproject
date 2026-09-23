import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:pocket_mates_app/backend/supabase/supabase.dart';

class PushNotificationService {
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'high_importance_channel';
  static const String channelName = 'High Importance Notifications';
  static const String channelDescription =
      'This channel is used for important notifications, daily missions, and chats.';

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
    channelId,
    channelName,
    description: channelDescription,
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  static const AndroidNotificationDetails _androidNotificationDetails =
      AndroidNotificationDetails(
    channelId,
    channelName,
    channelDescription: channelDescription,
    icon: '@mipmap/launcher_icon',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
  );

  static bool _isInitialized = false;

  /// Main initialization for Local Notifications and Firebase Cloud Messaging
  static Future<void> initialize() async {
    // Skip on unsupported desktop platforms
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux)) {
      debugPrint(
          'PushNotificationService: Skipping on unsupported platform: $defaultTargetPlatform');
      return;
    }

    if (_isInitialized) {
      debugPrint('PushNotificationService: Already initialized.');
      return;
    }

    try {
      // 1. Initialize Firebase Core safely if not yet initialized
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      // 2. Configure Local Timezones for persistent scheduled alarms
      await _configureLocalTimeZone();

      // 3. Initialize Local Notifications Plugin
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/launcher_icon');
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      try {
        await _localNotificationsPlugin.initialize(
          settings: initializationSettings,
          onDidReceiveNotificationResponse: _onNotificationTap,
        );
      } catch (localInitError) {
        debugPrint('PushNotificationService: Local notifications init error: $localInitError');
      }

      // 4. Create Android High Importance Notification Channel
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        try {
          await _localNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.createNotificationChannel(_androidChannel);
        } catch (channelError) {
          debugPrint('PushNotificationService: Channel creation error: $channelError');
        }
      }

      // 5. Access FCM instance
      final FirebaseMessaging fcm = FirebaseMessaging.instance;

      // Request notification permission (Android 13+ POST_NOTIFICATIONS & iOS)
      try {
        NotificationSettings settings = await fcm.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        );
        debugPrint(
            'PushNotificationService: Permission status: ${settings.authorizationStatus}');
      } catch (permError) {
        debugPrint('PushNotificationService: Permission request note: $permError');
      }

      // 6. Register background handler early
      try {
        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      } catch (bgError) {
        debugPrint('PushNotificationService: Background handler note: $bgError');
      }

      // 7. Token management & Supabase sync
      try {
        String? token = await fcm.getToken();
        if (token != null) {
          debugPrint('PushNotificationService: FCM Token: $token');
          await _saveTokenToSupabase(token);
        }
        fcm.onTokenRefresh.listen((newToken) {
          _saveTokenToSupabase(newToken);
        });
      } catch (tokenError) {
        debugPrint('PushNotificationService: FCM Token retrieval note: $tokenError');
      }

      // 8. Subscribe to general broadcast topic for free marketing & announcements
      try {
        await fcm.subscribeToTopic('all_users');
        debugPrint('PushNotificationService: Subscribed to topic all_users');
      } catch (topicError) {
        debugPrint('PushNotificationService: Topic subscription note: $topicError');
      }

      // 9. Foreground notification listener: show heads-up banner when app is open
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('PushNotificationService: Foreground message received: ${message.messageId}');
        RemoteNotification? notification = message.notification;
        if (notification != null && !kIsWeb) {
          _localNotificationsPlugin.show(
            id: notification.hashCode,
            title: notification.title,
            body: notification.body,
            notificationDetails: const NotificationDetails(
              android: _androidNotificationDetails,
              iOS: DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
            payload: message.data['type']?.toString() ?? 'chat',
          );
        }
      });

      // 10. Background tap listener (when app is in background and user clicks notification)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('PushNotificationService: App opened from notification: ${message.data}');
        _handleNotificationPayload(message.data['type']?.toString());
      });

      // 11. Terminated tap listener (when app was closed and launched via notification tap)
      fcm.getInitialMessage().then((RemoteMessage? message) {
        if (message != null) {
          debugPrint(
              'PushNotificationService: App opened from terminated via notification: ${message.data}');
          _handleNotificationPayload(message.data['type']?.toString());
        }
      });

      _isInitialized = true;
      debugPrint('PushNotificationService: Successfully initialized.');
    } catch (e) {
      debugPrint('PushNotificationService initialization error: $e');
    }
  }

  /// Explicitly requests notification permissions on Android and iOS
  /// to trigger the native OS permission prompt immediately.
  static Future<bool> requestPermissionExplicitly() async {
    // Skip on unsupported desktop platforms
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux)) {
      return false;
    }

    bool granted = false;
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      // Request Firebase Messaging permission (iOS & Android)
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      granted = settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
      debugPrint('PushNotificationService: FCM permission status: ${settings.authorizationStatus}');
    } catch (e) {
      debugPrint('PushNotificationService: FCM explicit permission request error: $e');
    }

    try {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        final androidImpl = _localNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        final androidGranted = await androidImpl?.requestNotificationsPermission();
        if (androidGranted != null) granted = androidGranted;
        debugPrint('PushNotificationService: Android local permission: $androidGranted');
      } else if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        final iosImpl = _localNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        final iosGranted = await iosImpl?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        if (iosGranted != null) granted = iosGranted;
        debugPrint('PushNotificationService: iOS local permission: $iosGranted');
      }
    } catch (e) {
      debugPrint('PushNotificationService: Local notification permission request error: $e');
    }

    // Also ensure full initialization is triggered
    try {
      await initialize();
    } catch (_) {}

    return granted;
  }


  /// Configure timezone support safely for repeating daily alarms
  static Future<void> _configureLocalTimeZone() async {
    try {
      tz.initializeTimeZones();
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      final String currentTimeZone = timezoneInfo.identifier;
      tz.setLocalLocation(tz.getLocation(currentTimeZone));
      debugPrint('PushNotificationService: Local timezone configured: $currentTimeZone');
    } catch (e) {
      debugPrint('PushNotificationService: Timezone config warning: $e. Falling back to UTC.');
      try {
        tz.setLocalLocation(tz.getLocation('UTC'));
      } catch (_) {}
    }
  }

  /// Handle local notification tap
  static void _onNotificationTap(NotificationResponse response) {
    debugPrint('PushNotificationService: Local notification tapped: ${response.payload}');
    _handleNotificationPayload(response.payload);
  }

  /// Centralized routing helper for notification taps
  static void _handleNotificationPayload(String? payload) {
    if (payload == null || payload.isEmpty) return;
    try {
      debugPrint('PushNotificationService: Routing for payload: $payload');
      // Payloads can be 'chat', 'mission', etc.
    } catch (e) {
      debugPrint('PushNotificationService: Error handling payload: $e');
    }
  }

  /// Save FCM token to user profile in Supabase
  static Future<void> _saveTokenToSupabase(String token) async {
    try {
      final user = SupaFlow.client.auth.currentUser;
      if (user != null) {
        await SupaFlow.client
            .from('profile')
            .update({'fcm_token': token}).eq('user_id', user.id);
        debugPrint('PushNotificationService: FCM Token synced with Supabase.');
      }
    } catch (e) {
      debugPrint('PushNotificationService: Failed to sync token with Supabase: $e');
    }
  }

  /// Public method to sync token whenever user logs in
  static Future<void> syncCurrentUserToken() async {
    if (kIsWeb) return;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _saveTokenToSupabase(token);
      }
    } catch (e) {
      debugPrint('PushNotificationService: Error syncing user token: $e');
    }
  }

  /// 🌅 Show instant local notification
  static Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (kIsWeb) return;
    try {
      await _localNotificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: _androidNotificationDetails,
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: payload,
      );
    } catch (e) {
      debugPrint('PushNotificationService: Error showing instant notification: $e');
    }
  }

  /// 🌅 Show instant notification when daily mission unlocks
  static Future<void> showMissionUnlockedNotification({required int day}) async {
    await showInstantNotification(
      id: 9000 + day,
      title: '🌅 Day $day Mission Unlocked!',
      body: "Today's daily English challenge is ready for you. Keep your streak alive!",
      payload: 'mission_$day',
    );
  }

  /// ⏰ Schedule a DAILY RECURRING notification that repeats at [hour]:[minute] every day!
  /// Survives app closure and device reboot via Android AlarmManager.
  static Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    if (kIsWeb) return;
    try {
      await _configureLocalTimeZone();

      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // If today's target time has already passed, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      // AndroidScheduleMode.inexactAllowWhileIdle guarantees NO crash on Android 12/14+
      await _localNotificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: const NotificationDetails(
          android: _androidNotificationDetails,
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time, // Repeats daily at specified time
        payload: payload,
      );

      debugPrint(
        'PushNotificationService: Daily recurring notification set [ID $id] at $scheduledDate (repeats daily)',
      );
    } catch (e) {
      debugPrint('PushNotificationService: Error scheduling daily recurring notification: $e');
    }
  }

  /// ⏰ Schedule morning mission reminder (default: 8:30 AM every day)
  static Future<void> scheduleMorningMissionNotification({
    required int day,
    int targetHour = 8,
    int targetMinute = 30,
  }) async {
    await scheduleDailyNotification(
      id: 9000 + day,
      title: '🌅 Day $day Mission Ready!',
      body: "Good morning! Today's daily English challenge is ready. Complete it to keep your streak!",
      hour: targetHour,
      minute: targetMinute,
      payload: 'mission_$day',
    );
  }

  /// Cancel a specific notification
  static Future<void> cancelNotification(int id) async {
    try {
      await _localNotificationsPlugin.cancel(id: id);
    } catch (e) {
      debugPrint('PushNotificationService: Error canceling notification $id: $e');
    }
  }

  /// Cancel all scheduled notifications
  static Future<void> cancelAllNotifications() async {
    try {
      await _localNotificationsPlugin.cancelAll();
    } catch (e) {
      debugPrint('PushNotificationService: Error canceling all notifications: $e');
    }
  }
}

/// Top-level background message handler for FCM
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  } catch (_) {}
  debugPrint("Handling a background message: ${message.messageId}");
}
