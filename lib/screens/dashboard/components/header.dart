import 'package:admin/controllers/MenuAppController.dart';
import 'package:admin/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';

class Header extends StatelessWidget {
  const Header({
    Key? key, required this.headTitle,
  }) : super(key: key);

  final String headTitle;

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
        // Expanded(child: SearchField()),
        ProfileCard()
      ],
    );
  }
}

// class ProfileCard extends StatelessWidget {
//   const ProfileCard({
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return PopupMenuButton<String>(
//       itemBuilder: (context) => [
//         PopupMenuItem<String>(
//           value: 'editProfile',
//           child: ListTile(
//             leading: Icon(Icons.edit),
//             title: Text('회원정보 수정'),
//           ),
//         ),
//         PopupMenuItem<String>(
//           value: 'logout',
//           child: ListTile(
//             leading: Icon(Icons.logout),
//             title: Text('로그아웃'),
//           ),
//         ),
//       ],
//       child: Container(
//         margin: EdgeInsets.only(left: defaultPadding),
//         padding: EdgeInsets.symmetric(
//           horizontal: defaultPadding,
//           vertical: defaultPadding / 2,
//         ),
//         decoration: BoxDecoration(
//           color: secondaryColor,
//           borderRadius: const BorderRadius.all(Radius.circular(10)),
//           border: Border.all(color: Colors.white10),
//         ),
//         child: Row(
//           children: [
//             Icon(
//               Icons.person,
//               size: 35,
//               color: Colors.white,
//             ),
//             if (!Responsive.isMobile(context))
//               Padding(
//                 padding:
//                 const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
//                 child: Text("이름"),
//               ),
//             Icon(Icons.keyboard_arrow_down),
//           ],
//         ),
//       ),
//       onSelected: (value) {
//         if (value == 'editProfile') {
//           // Navigator.push(
//           //   context,
//           //   MaterialPageRoute(builder: (context) => ProfileScreen()),
//           // );
//         } else if (value == 'logout') {
//           // Implement logout logic here
//         }
//       },
//     );
//   }
// }
///
class ProfileCard extends StatelessWidget {
  const ProfileCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                child: Text("이름"),
              ),
            Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
      onSelected: (value) {
        if (value == 'editProfile') {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => ProfileScreen()),
          // );
          context.read<MenuAppController>().setSelectedScreen('profile');
        } else if (value == 'logout') {
          // Implement logout logic here
        }
      },
    );
  }
}
