import 'package:beautyminder_dashboard/controllers/menu_app_controller.dart';
import 'package:beautyminder_dashboard/responsive.dart';
import 'package:beautyminder_dashboard/screens/chat/chat_screen.dart';
import 'package:beautyminder_dashboard/screens/dashboard/dashboard_screen.dart';
import 'package:beautyminder_dashboard/screens/review/filtered_Review_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../profile/profile_screen.dart';
import '../review/review_screen.dart';
import 'components/side_menu.dart';

class MainScreen extends StatelessWidget {
  final Map<String, Widget> _screens = {
    'dashboard': DashboardScreen(),
    'review': ReviewScreen(),
    'filtered review': filteredReviewScreen(),
    'chat': ChatScreen(),
    'profile': ProfileScreen(),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: context.read<MenuAppController>().scaffoldKey,
      drawer: SideMenu(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // We want this side menu only for large screen
            if (Responsive.isDesktop(context))
              Expanded(
                child: SideMenu(),
              ),
            Expanded(
              // It takes 5/6 part of the screen
              flex: 5,
              //MenuAppController에서 시작페이지 변경 가능
              child:
                  _screens[context.watch<MenuAppController>().selectedScreen] ??
                      Container(),
            ),
          ],
        ),
      ),
    );
  }
}
