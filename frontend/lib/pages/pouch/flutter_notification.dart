
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io';

import '../pages/pouch/expiry_page.dart';

class FlutterLocalNotification {
  FlutterLocalNotification._();

  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Add a GlobalKey for navigation
  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();

  static init() async {
    if (Platform.isAndroid) {
      var status = await Permission.ignoreBatteryOptimizations.status;
      if (!status.isGranted) {
        await Permission.ignoreBatteryOptimizations.request();
      }
    }

    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await requestNotificationPermission();

    AndroidInitializationSettings androidInitializationSettings =
    const AndroidInitializationSettings('mipmap/ic_launcher');

    DarwinInitializationSettings iosInitializationSettings =
    const DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    InitializationSettings initializationSettings = InitializationSettings(
        android: androidInitializationSettings, iOS: iosInitializationSettings);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) async {
          _navigateToRoutinePage(); // Call the navigation function
        });
  }

  static requestNotificationPermission() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static void _navigateToRoutinePage() {
    // Use the navigatorKey to navigate
    navigatorKey.currentState?.push(MaterialPageRoute(
      builder: (context) => CosmeticExpiryPage(), // Replace with your actual page
    ));
  }

  static Future<void> showNotification() async {
    print("1111");
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails('channel id', 'channel name',
        channelDescription: 'channel description',
        importance: Importance.max,
        priority: Priority.max,
        showWhen: false);

    const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: DarwinNotificationDetails(badgeNumber: 1));

    await flutterLocalNotificationsPlugin.show(
        0, 'test title', 'test body', notificationDetails);

  }
  //유통기한 날짜 함수
  static makeDateForExpiry(DateTime expiryDate) {
    var seoul = tz.getLocation('Asia/Seoul');
    var now = tz.TZDateTime.now(seoul);
    tz.TZDateTime when;

    if (expiryDate.isAtSameMomentAs(DateTime(now.year, now.month, now.day))) {
      when = now.add(Duration(seconds: 15));
    } else {
      when = tz.TZDateTime(seoul, expiryDate.year, expiryDate.month, expiryDate.day);
    }

    return when;
  }


  static Future<void> showNotification_time(
      String title, String description, tz.TZDateTime date, int id) async {
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails('channel id', 'channel name',
        channelDescription: 'channel description',
        importance: Importance.max,
        priority: Priority.max,
        showWhen: false);

    const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: DarwinNotificationDetails(badgeNumber: 1));

    flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        description,
        date,
        //tz.TZDateTime.now(tz.local).add(Duration(seconds: 5)),
        //makeDate(15, 40, 00),
        NotificationDetails(
            android: androidNotificationDetails,
            iOS: DarwinNotificationDetails(badgeNumber: 1)),
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime);
  }

  static makeDate(int hour, int min, int sec) {
    var seoul = tz.getLocation('Asia/Seoul');

    var now = tz.TZDateTime.now(seoul);
    tz.TZDateTime when =
    tz.TZDateTime(seoul, now.year, now.month, now.day, hour, min, sec);
    print("now : ${now.toString()}");
    if (when.isBefore(now)) {
      print("내일로 설정");
      return when.add(Duration(days: 1));
    } else {
      print("오늘로 설정");
      print(when.toString());
      return when;
    }
  }
}
