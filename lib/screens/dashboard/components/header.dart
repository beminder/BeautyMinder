import 'package:admin/Service/api_service.dart';
import 'package:admin/controllers/MenuAppController.dart';
import 'package:admin/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../Service/admin_Service.dart';
import '../../../constants.dart';
import '../../../dto/user_model.dart';
import '../../start/splash_screen.dart';

class Header extends StatelessWidget {
  const Header({
    Key? key, required this.headTitle, required this.userProfileResult,
  }) : super(key: key);

  final String headTitle;
  final dynamic userProfileResult;

  @override
  Widget build(BuildContext context) {
    print("&&&&1 : $userProfileResult");
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
    Key? key, required this.userProfileResult,
  }) : super(key: key);

  final dynamic userProfileResult;

  @override
  Widget build(BuildContext context) {
    final user = userProfileResult.value;
    print("**** : $user");
    return PopupMenuButton<String>(
      offset: Offset(0, 60), // 이 부분을 조절하여 원하는 위치로 이동할 수 있습니다.
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'editProfile',
          child: ListTile(
            leading: Icon(Icons.edit),
            title: Text('회원정보 수정'),
          ),
        ),
        PopupMenuItem<String>(
          value: 'logout',
          child: ListTile(
            leading: Icon(Icons.logout),
            title: Text('로그아웃'),
          ),
          onTap: () async {
            try {
              final logoutResponse = await APIService.logout();
              if(logoutResponse.isSuccess) {
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
              }
              else {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('로그아웃에 실패하였습니다.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            }
            catch (e) {
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
