import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';

class PushNotificationService {
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Firebase Messaging does not support Windows/Linux
    if (kIsWeb) {
      // Web is supported
    } else if (defaultTargetPlatform == TargetPlatform.windows || 
               defaultTargetPlatform == TargetPlatform.linux) {
      debugPrint('PushNotificationService: Skipping initialization on unsupported platform: $defaultTargetPlatform');
      return;
    }

    try {
      // Ensure Firebase is initialized before proceeding
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      // 1. Initialize Local Notifications FIRST before calling platform specific methods
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/launcher_icon');
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings();
      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      try {
        await _localNotificationsPlugin.initialize(
          settings: initializationSettings,
          onDidReceiveNotificationResponse: (NotificationResponse response) {
            // Handle notification tap
          },
        );
      } catch (localInitError) {
        debugPrint('PushNotificationService: Local notifications init note: $localInitError');
      }

      // 2. Android Notification Channel setup
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        try {
          const AndroidNotificationChannel channel = AndroidNotificationChannel(
            'high_importance_channel',
            'High Importance Notifications',
            description: 'This channel is used for important notifications.',
            importance: Importance.max,
          );
          await _localNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.createNotificationChannel(channel);
        } catch (channelError) {
          debugPrint('PushNotificationService: Notification channel note: $channelError');
        }
      }

      // Access FCM only after potential Firebase initialization
      final FirebaseMessaging fcm = FirebaseMessaging.instance;

      // 3. Request permissions safely
      try {
        NotificationSettings settings = await fcm.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );

        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          debugPrint('PushNotificationService: User granted permission');
        }
      } catch (permError) {
        debugPrint('PushNotificationService: Permission request note: $permError');
      }

      // 4. Token management safely
      try {
        String? token = await fcm.getToken();
        if (token != null) {
          debugPrint('PushNotificationService: FCM Token: $token');
          await _saveTokenToSupabase(token);
        }

        fcm.onTokenRefresh.listen(_saveTokenToSupabase);
      } catch (tokenError) {
        debugPrint('PushNotificationService: FCM Token retrieval note: $tokenError');
      }

      // 5. Handling messages
      try {
        FirebaseMessaging.onBackgroundMessage(
            _firebaseMessagingBackgroundHandler);
      } catch (bgError) {
        debugPrint('PushNotificationService: Background handler registration note: $bgError');
      }

      try {
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          RemoteNotification? notification = message.notification;

          if (notification != null && !kIsWeb) {
            _localNotificationsPlugin.show(
              id: notification.hashCode,
              title: notification.title,
              body: notification.body,
              notificationDetails: const NotificationDetails(
                android: AndroidNotificationDetails(
                  'high_importance_channel',
                  'High Importance Notifications',
                  channelDescription: 'This channel is used for important notifications.',
                  icon: '@mipmap/launcher_icon',
                  importance: Importance.max,
                  priority: Priority.high,
                ),
                iOS: DarwinNotificationDetails(
                  presentAlert: true,
                  presentBadge: true,
                  presentSound: true,
                ),
              ),
            );
          }
        });
      } catch (msgError) {
        debugPrint('PushNotificationService: onMessage listener note: $msgError');
      }
    } catch (e) {
      debugPrint('PushNotificationService initialization error: $e');
    }
  }

  static Future<void> _saveTokenToSupabase(String token) async {
    final user = SupaFlow.client.auth.currentUser;
    if (user != null) {
      try {
        await SupaFlow.client
            .from('profile')
            .update({'fcm_token': token}).eq('user_id', user.id);
        debugPrint('FCM Token successfully synced with Supabase');
      } catch (e) {
        debugPrint('Failed to sync token with Supabase: $e');
      }
    }
  }

  /// 🌅 Show instant notification when daily mission unlocks
  static Future<void> showMissionUnlockedNotification({required int day}) async {
    if (kIsWeb) return;
    try {
      await _localNotificationsPlugin.show(
        id: 9000 + day,
        title: '🌅 Day $day Mission Unlocked!',
        body: "Today's daily English challenge is ready for you. Keep your streak alive!",
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription: 'This channel is used for important notifications.',
            icon: '@mipmap/launcher_icon',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error showing mission unlock notification: $e');
    }
  }

  /// ⏰ Schedule or set morning reminder (e.g., 8:30 AM) when next mission is ready
  static void scheduleMorningMissionNotification({
    required int day,
    int targetHour = 8,
    int targetMinute = 30,
  }) {
    if (kIsWeb) return;
    try {
      final now = DateTime.now();
      var target = DateTime(now.year, now.month, now.day, targetHour, targetMinute);
      if (target.isBefore(now)) {
        target = target.add(const Duration(days: 1));
      }
      final delay = target.difference(now);
      Timer(delay, () {
        showMissionUnlockedNotification(day: day);
      });
      debugPrint('Scheduled morning mission notification for Day $day at $target (in ${delay.inMinutes} mins)');
    } catch (e) {
      debugPrint('Error scheduling morning notification: $e');
    }
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}
  debugPrint("Handling a background message: ${message.messageId}");
}
