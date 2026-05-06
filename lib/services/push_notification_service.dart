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
      // 1. Android Notification Channel setup
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.max,
      );

      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        await _localNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(channel);
      }

      // 2. Initialize Local Notifications
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings();
      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _localNotificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          // Handle notification tap
        },
      );

      // Access FCM only after potential Firebase initialization
      final FirebaseMessaging fcm = FirebaseMessaging.instance;

      // 3. Request permissions
      NotificationSettings settings = await fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted permission');
      }

      // 4. Token management
      String? token = await fcm.getToken();
      if (token != null) {
        debugPrint('FCM Token: $token');
        await _saveTokenToSupabase(token);
      }

      fcm.onTokenRefresh.listen(_saveTokenToSupabase);

      // 5. Handling messages
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;

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
                icon: '@mipmap/ic_launcher',
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
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}
  debugPrint("Handling a background message: ${message.messageId}");
}
