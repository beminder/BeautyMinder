import 'package:beautyminder_dashboard/constants.dart';
import 'package:beautyminder_dashboard/controllers/menu_app_controller.dart';
import 'package:beautyminder_dashboard/screens/chat/chat_screen.dart';
import 'package:beautyminder_dashboard/screens/dashboard/dashboard_screen.dart';
import 'package:beautyminder_dashboard/screens/main/main_screen.dart';
import 'package:beautyminder_dashboard/screens/profile/profile_screen.dart';
import 'package:beautyminder_dashboard/screens/review/filtered_Review_screen.dart';
import 'package:beautyminder_dashboard/screens/review/review_screen.dart';
import 'package:beautyminder_dashboard/screens/start/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => MenuAppController(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BeautyMinder Admin',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: bgColor,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
            .apply(bodyColor: Colors.white),
        canvasColor: secondaryColor,
      ),
      // home: MultiProvider(
      //   providers: [
      //     ChangeNotifierProvider(
      //       create: (context) => MenuAppController(),
      //     ),
      //   ],
      //   child: SplashScreen(),
      //   //LoginScreen(),
      //   //MainScreen(),
      // ),
      home: SplashScreen(),
      routes: {
        '/main': (context) => MainScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/review': (context) => ReviewScreen(),
        '/Filtered Review': (context) => filteredReviewScreen(),
        '/chat': (context) => ChatScreen(),
        '/profile': (context) => ProfileScreen(),
      },
    );
  }
}
