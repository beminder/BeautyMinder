import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomWillPopScope extends StatelessWidget {
  const CustomWillPopScope({
    required this.child,
    this.canPop = true,
    Key? key,
    required this.action,
  }) : super(key: key);

  final Widget child;
  final bool canPop;
  final VoidCallback action;

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.velocity.pixelsPerSecond.dx < 0 ||
            details.velocity.pixelsPerSecond.dx > 0) {
          if (canPop) {
            action();
          }
        }
      },
      child: WillPopScope(
        onWillPop: () async {
          if (canPop) {
            action(); // 사용자 정의 함수 실행
            return true; // 화면을 떠날 수 있음
          }
          return false; // 화면을 떠나지 못함
        },
        child: child, // 현재 화면의 자식 위젯
      ),
    )
        : WillPopScope(
      onWillPop: () async {
        if (canPop) {
          action(); // 사용자 정의 함수 실행
          return true; // 화면을 떠날 수 있음
        }
        return false; // 화면을 떠나지 못함
      },
      child: child, // 현재 화면의 자식 위젯
    );;
  }
}
