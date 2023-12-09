import 'package:admin/screens/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../controllers/MenuAppController.dart';
import '../../chat/chat_screen.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            // child: Image.asset("assets/images/logo.png", height: 20, width: 20,),
            child: Center(
              child: Text('BeautyMinder'),
            )
          ),
          DrawerListTile(
            title: "Dashboard",
            svgSrc: "assets/icons/menu_dashboard.svg",
            press: () {
              // Navigator.pop(context); // Close the Drawer
              context.read<MenuAppController>().setSelectedScreen('dashboard');
              // Navigator.pushNamed(context, '/dashboard');

            },
          ),
          DrawerListTile(
            title: "Review",
            svgSrc: "assets/icons/menu_tran.svg",
            press: () {
              // Navigator.pop(context); // Close the Drawer
              context.read<MenuAppController>().setSelectedScreen('review');
              // Navigator.pushNamed(context, '/review');
            },
          ),
          DrawerListTile(
            title: "Chat",
            svgSrc: "assets/icons/menu_task.svg",
            press: () {
              // Navigator.pop(context); // Close the Drawer
              context.read<MenuAppController>().setSelectedScreen('chat');
              // Navigator.pushNamed(context, '/chat');
            },
          ),
          // DrawerListTile(
          //   title: "Chat",
          //   svgSrc: "assets/icons/menu_doc.svg",
          //   press: () {},
          // ),
          DrawerListTile(
            title: "Profile",
            svgSrc: "assets/icons/menu_profile.svg",
            press: () {
              // Navigator.pop(context); // Close the Drawer
              context.read<MenuAppController>().setSelectedScreen('profile');
              // Navigator.pushNamed(context, '/profile');
            },
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
  }) : super(key: key);

  final String title, svgSrc;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: SvgPicture.asset(
        svgSrc,
        colorFilter: ColorFilter.mode(Colors.white54, BlendMode.srcIn),
        height: 16,
      ),
      title: Text(
        title,
        style: TextStyle(color: Colors.white54),
      ),
    );
  }
}
