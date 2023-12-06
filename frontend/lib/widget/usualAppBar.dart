import 'package:flutter/material.dart';

class UsualAppBar extends AppBar {

  final String? text;

  UsualAppBar({Key? key, this.text})
      : super(
          key: key,
          backgroundColor: Color(0xffffecda),
          elevation: 0,
          centerTitle: false,
          title: text != null ?
            Text(
              text,
              style: TextStyle(color: Color(0xffd86a04), fontWeight: FontWeight.bold),
            )
            : Text(
                "BeautyMinder",
                style: TextStyle(color: Color(0xffd86a04), fontWeight: FontWeight.bold),
              ),
          iconTheme: const IconThemeData(
            color: Color(0xffd86a04),
          ),
        );
}
