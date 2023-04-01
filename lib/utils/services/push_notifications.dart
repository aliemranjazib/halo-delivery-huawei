//import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_hms_gms_availability/flutter_hms_gms_availability.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:haloapp/main.dart';
import 'dart:io';

class PushNotificationsManager {
  PushNotificationsManager._();

  factory PushNotificationsManager() => _instance;

  static final PushNotificationsManager _instance =
      PushNotificationsManager._();

//  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  bool _initialized = false;

  Future<void> init() async {
//    if (!_initialized) {
//      // For iOS request permission first.
//      _firebaseMessaging.requestPermission();
//      FirebaseMessaging.onMessage.listen((message) {
//        // if (Platform.isAndroid) {
//        _showNotification(
//            0, message.notification.title, message.notification.body, '');
//        // } else {
//        //   _showNotification(0, message.notification.title,
//        //       message['aps']['alert']['body'], '');
//        // }
//      });
//
//      try{
//        // For testing purposes print the Firebase Messaging token
//        String token = await _firebaseMessaging.getToken();
//        print("FirebaseMessaging token: $token");
//
//        if (token != null) {
//          _initialized = true;
//        }
//      }catch(e){
//        print(e);
//      }
//
//    }
  }

  Future<String> getFCMToken() async {
//    if(await FlutterHmsGmsAvailability.isGmsAvailable){
//      String token = await _firebaseMessaging.getToken();
//      print("FCMToken: "+token);
//      return token;
//    }
    return "";
  }

  Future<void> _showNotification(
    int notificationId,
    String notificationTitle,
    String notificationContent,
    String payload, {
    String channelId = '1',
    String channelTitle = 'New Notification',
    String channelDescription = 'New notification',
    Priority notificationPriority = Priority.high,
    Importance notificationImportance = Importance.max,
  }) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      channelId,
      channelTitle,
      channelDescription,
      playSound: true,
      importance: notificationImportance,
      priority: notificationPriority,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      notificationId,
      notificationTitle,
      notificationContent,
      platformChannelSpecifics,
      payload: payload,
    );
  }
}
