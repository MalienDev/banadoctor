import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

import '../models/rendez_vous.dart';
import 'api_service.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final ApiService _apiService;
  final String? Function()? getAuthToken;

  NotificationService({required ApiService apiService, this.getAuthToken}) 
      : _apiService = apiService;

  // Initialize notifications
  Future<void> initialize() async {
    // Request permission for iOS
    if (Platform.isIOS) {
      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        provisional: false,
        sound: true,
      );
    }

    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        // Handle notification tap when app is in foreground
      },
    );
    
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
        _onNotificationTap(details.payload);
      },
    );

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleForegroundMessage(message);
    });

    // Handle notification tap when app is in background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _onNotificationTap(message.data['payload']);
    });

    // Get initial message if app was terminated
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _onNotificationTap(initialMessage.data['payload']);
    }

    // Register device token with backend
    await _registerDeviceToken();
  }


  // Register device token with backend
  Future<void> _registerDeviceToken() async {
    try {
      // Get the token each time the app loads
      String? token = await _firebaseMessaging.getToken();
      
      if (token != null) {
        // Get device ID (using device_info_plus package would be better)
        String deviceId = '';
        if (Platform.isAndroid) {
          deviceId = await _getAndroidDeviceId();
        } else if (Platform.isIOS) {
          deviceId = await _getIosDeviceId();
        }
        
        // Register with backend
        await _apiService.registerDeviceToken(token, deviceId);
      }
      
      // Handle token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) async {
        String deviceId = '';
        if (Platform.isAndroid) {
          deviceId = await _getAndroidDeviceId();
        } else if (Platform.isIOS) {
          deviceId = await _getIosDeviceId();
        }
        await _apiService.registerDeviceToken(newToken, deviceId);
      });
    } catch (e) {
      debugPrint('Error registering device token: $e');
    }
  }

  // Handle background messages
  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // Initialize Firebase if needed
    await Firebase.initializeApp();
    
    // Show local notification
    final notification = message.notification;
    if (notification != null) {
      final androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        channelDescription: 'This channel is used for important notifications.',
        importance: Importance.max,
        priority: Priority.high,
      );
      
      final iOSPlatformChannelSpecifics = DarwinNotificationDetails();
      
      final platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );
      
      await FlutterLocalNotificationsPlugin().show(
        notification.hashCode,
        notification.title,
        notification.body,
        platformChannelSpecifics,
        payload: message.data['payload'],
      );
    }
  }

  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    
    if (notification != null) {
      _showLocalNotification(
        title: notification.title,
        body: notification.body,
        payload: message.data['payload'],
      );
    }
  }

  // Show local notification
  Future<void> _showLocalNotification({
    String? title,
    String? body,
    String? payload,
  }) async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    const iOSPlatformChannelSpecifics = DarwinNotificationDetails();
    
    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    
    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // Unique ID
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  // Handle notification tap
  void _onNotificationTap(String? payload) {
    // Handle navigation based on payload
    // Example: payload could be a route like '/appointment/123'
    if (payload != null && payload.isNotEmpty) {
      // Use a navigation service or global key to navigate
      debugPrint('Notification tapped with payload: $payload');
      // Example: navigatorKey.currentState?.pushNamed(payload);
    }
  }

  // Send appointment reminder
  Future<void> scheduleAppointmentReminder(RendezVous appointment) async {
    final scheduledTime = appointment.startTime.subtract(const Duration(hours: 1));
    
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'appointment_reminders',
      'Appointment Reminders',
      channelDescription: 'Reminders for upcoming appointments',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    final iOSPlatformChannelSpecifics = DarwinNotificationDetails();
    
    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      appointment.id.hashCode,
      'Rappel: Rendez-vous avec Dr. ${appointment.doctor.lastName}',
      'Vous avez un rendez-vous à ${appointment.startTime.hour}:${appointment.startTime.minute.toString().padLeft(2, '0')}',
      scheduledTime.toLocal(),
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: '/appointment/${appointment.id}',
    );
  }

  // Cancel scheduled notification
  Future<void> cancelScheduledNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  // Get device ID (simplified - in production, use device_info_plus package)
  Future<String> _getAndroidDeviceId() async {
    // In a real app, use device_info_plus package to get real device ID
    return 'android_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<String> _getIosDeviceId() async {
    // In a real app, use device_info_plus package to get real device ID
    return 'ios_${DateTime.now().millisecondsSinceEpoch}';
  }
}
