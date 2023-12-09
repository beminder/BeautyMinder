import 'package:flutter/material.dart';

class CommonBottomNavigationBar extends BottomNavigationBar {
  CommonBottomNavigationBar(
      {Key? key, required int currentIndex, required Function(int) onTap})
      : super(
          backgroundColor: Color(0xffffecda),
          key: key,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Color(0xffd86a04),
          currentIndex: currentIndex,
          onTap: onTap,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: '추천',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.business_center),
              label: '파우치',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.check_box),
              label: '루틴',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: '마이',
            ),
          ],
        );
}
