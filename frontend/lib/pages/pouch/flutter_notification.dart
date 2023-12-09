
import 'package:beautyminder/pages/pouch/expiry_page.dart';
import 'package:beautyminder/pages/todo/todo_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:io';

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

    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
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

  // 유통기한 날짜
  static makeDateForExpiry(DateTime expiryDate, int daysBefore) {
    var now = tz.TZDateTime.now(tz.local);
    var notifyDate = tz.TZDateTime(tz.local, expiryDate.year, expiryDate.month, expiryDate.day).subtract(Duration(days: daysBefore));

    if (now.isAfter(notifyDate)) {
      // 이미 지난 날짜에 대한 알림은 즉시 설정
      return now.add(Duration(seconds: 30));
    } else if (now.isBefore(notifyDate.subtract(Duration(days: daysBefore)))) {
      // 사용자가 설정한 일수보다 유통기한이 더 많이 남은 경우 알림 설정하지 않음
      return null;
    } else {
      // 유통기한이 사용자가 설정한 일수 이내인 경우 알림 설정
      return notifyDate;
    }
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
