import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../controllers/MenuAppController.dart';


class SideMenu extends StatelessWidget {
  const SideMenu({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectedScreen = context.watch<MenuAppController>().selectedScreen;

    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            // child: Image.asset("assets/images/logo.png", height: 20, width: 20,),
            child: Center(
              child: Text('BeautyMinder', style: TextStyle(fontSize: 20),),
            )
          ),
          DrawerListTile(
            title: "Dashboard",
            svgSrc: "assets/icons/menu_dashboard.svg",
            press: () {
              context.read<MenuAppController>().setSelectedScreen('dashboard');
            },
            selected: selectedScreen == 'dashboard',
          ),
          DrawerListTile(
            title: "Review",
            svgSrc: "assets/icons/menu_tran.svg",
            press: () {
              context.read<MenuAppController>().setSelectedScreen('review');
            },
            selected: selectedScreen == 'review',
          ),
          DrawerListTile(
            title: "Chat",
            svgSrc: "assets/icons/menu_task.svg",
            press: () {
              context.read<MenuAppController>().setSelectedScreen('chat');
            },
            selected: selectedScreen == 'chat',
          ),
          DrawerListTile(
            title: "Profile",
            svgSrc: "assets/icons/menu_profile.svg",
            press: () {
              context.read<MenuAppController>().setSelectedScreen('profile');
            },
            selected: selectedScreen == 'profile',
          ),
        ],
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    // For selecting those three line once press "Command+D"
    required this.title,
    required this.svgSrc,
    required this.press,
    required this.selected,
  }) : super(key: key);

  final String title, svgSrc;
  final VoidCallback press;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: SvgPicture.asset(
        svgSrc,
        colorFilter: ColorFilter.mode(
            selected ? Colors.white : Colors.white54, BlendMode.srcIn),
        height: 16,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: selected ? Colors.white : Colors.white54,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal
        ),
      ),
    );
  }
}
