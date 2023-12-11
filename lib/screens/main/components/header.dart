import 'package:beautyminder_dashboard/Service/api_service.dart';
import 'package:beautyminder_dashboard/controllers/menu_app_controller.dart';
import 'package:beautyminder_dashboard/responsive.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../start/splash_screen.dart';

class Header extends StatelessWidget {
  const Header({
    Key? key,
    required this.headTitle,
    required this.userProfileResult,
  }) : super(key: key);

  final String headTitle;
  final dynamic userProfileResult;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!Responsive.isDesktop(context))
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: context.read<MenuAppController>().controlMenu,
          ),
        if (!Responsive.isMobile(context))
          Text(
            headTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        if (!Responsive.isMobile(context))
          Spacer(flex: Responsive.isDesktop(context) ? 2 : 1),
        ProfileCard(userProfileResult: userProfileResult),
      ],
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    Key? key,
    required this.userProfileResult,
  }) : super(key: key);

  final dynamic userProfileResult;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: secondaryColor,
      offset: Offset(0, 60),
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'editProfile',
          child: ListTile(
            leading: Icon(
              Icons.edit,
              color: Colors.white54,
            ),
            title: Text(
              '프로필 정보',
              style: TextStyle(color: Colors.white54),
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'logout',
          child: ListTile(
            leading: Icon(
              Icons.logout,
              color: Colors.white54,
            ),
            title: Text(
              '로그아웃',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          onTap: () async {
            try {
              final logoutResponse = await APIService.logout();
              if (logoutResponse.isSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('로그아웃에 성공하였습니다.'),
                    duration: Duration(seconds: 2),
                  ),
                );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SplashScreen()),
                );
              } else {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('로그아웃에 실패하였습니다.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            } catch (e) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('오류가 발생했습니다. 잠시 후 다시 시도해주세요.'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
        ),
      ],
      child: Container(
        margin: EdgeInsets.only(left: defaultPadding),
        padding: EdgeInsets.symmetric(
          horizontal: defaultPadding,
          vertical: defaultPadding / 2,
        ),
        decoration: BoxDecoration(
          color: secondaryColor,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Icon(
              Icons.person,
              size: 35,
              color: Colors.white,
            ),
            if (!Responsive.isMobile(context))
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
                child: Text("${userProfileResult.value?.nickname}"),
              ),
            Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
      onSelected: (value) {
        if (value == 'editProfile') {
          context.read<MenuAppController>().setSelectedScreen('profile');
        } else if (value == 'logout') {
          // Implement logout logic here
        }
      },
    );
  }
}
