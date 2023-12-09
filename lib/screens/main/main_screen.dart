import 'package:admin/controllers/MenuAppController.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/chat/chat_screen.dart';
import 'package:admin/screens/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../profile/profile_screen.dart';
import '../review/review_screen.dart';
import 'components/side_menu.dart';

class MainScreen extends StatelessWidget {
  final Map<String, Widget> _screens = {
    'dashboard': DashboardScreen(),
    'review': ReviewScreen(),
    'chat' : ChatScreen(),
    'profile': ProfileScreen(),
  };

  String _selectedScreen = 'dashboard'; // Default screen

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
                // default flex = 1
                // and it takes 1/6 part of the screen
                child: SideMenu(),
              ),
            Expanded(
              // It takes 5/6 part of the screen
              flex: 5,
              child: _screens[context.watch<MenuAppController>().selectedScreen] ?? Container(),
            ),
          ],
        ),
      ),
    );
  }
}
