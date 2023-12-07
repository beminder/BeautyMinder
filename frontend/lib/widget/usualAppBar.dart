import 'package:flutter/material.dart';

class UsualAppBar extends AppBar {

  final String? text;
  final VoidCallback? onAddPressed;
  final VoidCallback? onMinusPressed;

  UsualAppBar({Key? key, this.text, this.onAddPressed, this.onMinusPressed,})
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
          actions: [
            if(onAddPressed != null)
              IconButton(
                icon: Icon(Icons.add, color: Color(0xffd86a04)),
                onPressed: onAddPressed,
              ),
            if(onMinusPressed != null)
              IconButton(
                icon: Icon(Icons.remove, color: Color(0xffd86a04)),
                onPressed: onMinusPressed,
              ),
          ]
        );
}
