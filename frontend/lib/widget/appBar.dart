import 'package:beautyminder/pages/recommend/recommend_bloc_screen.dart';
import 'package:flutter/material.dart';

class CommonAppBar extends AppBar {
  CommonAppBar({Key? key, required bool automaticallyImplyLeading, BuildContext? context})
      : super(
          key: key,
          backgroundColor: Color(0xffffecda),
          automaticallyImplyLeading: automaticallyImplyLeading,
          elevation: 0,
          centerTitle: false,
          title: const Text(
            "BeautyMinder",
            style: TextStyle(color: Color(0xffd86a04), fontWeight: FontWeight.bold),
          ),
          iconTheme: const IconThemeData(
            color: Color(0xffd86a04),
          ),
          leading: automaticallyImplyLeading == true
              ? IconButton(
                  onPressed: () => Navigator.of(context!).pop(true),
                  icon: Icon(Icons.arrow_back_ios),
                )
              : null
        );
}

class RecCommonAppBar extends AppBar {
  RecCommonAppBar({Key? key, required bool automaticallyImplyLeading, BuildContext? context})
      : super(
    key: key,
    backgroundColor: Color(0xffffecda),
    automaticallyImplyLeading: automaticallyImplyLeading,
    elevation: 0,
    centerTitle: false,
    title: const Text(
      "BeautyMinder",
      style: TextStyle(color: Color(0xffd86a04), fontWeight: FontWeight.bold),
    ),
    iconTheme: const IconThemeData(
      color: Color(0xffd86a04),
    ),
    leading: automaticallyImplyLeading == true
        ? IconButton(
      onPressed: () => Navigator.of(context!).pop(true),
      icon: Icon(Icons.arrow_back_ios),
    )
        : null,
    // 여기에 actions 속성 추가
    actions: <Widget>[
      IconButton(
        icon: Icon(Icons.refresh),
        onPressed: () {
          Navigator.of(context!).pushReplacement(MaterialPageRoute(
              builder: (context) => RecPage()));
        },
      ),
    ],
  );
}

class BaumannTestAppBar extends AppBar {
  BaumannTestAppBar({Key? key})
      : super(
    key: key,
    backgroundColor: Color(0xffffecda),
    elevation: 0,
    centerTitle: false,
    title: const Text(
      "바우만 테스트 페이지",
      style: TextStyle(color: Color(0xffd86a04), fontWeight: FontWeight.bold),
    ),
    iconTheme: const IconThemeData(
      color: Color(0xffd86a04),
    ),
  );
}

class HomepageAppBar extends AppBar {
  final List<Widget> actions;

  HomepageAppBar({Key? key, required this.actions, bool automaticallyImplyLeading = false})
      : super(
    key: key,
    automaticallyImplyLeading: automaticallyImplyLeading,
    backgroundColor: Color(0xffffecda),
    elevation: 0,
    centerTitle: false,
    title: const Text(
      "BeautyMinder",
      style: TextStyle(color: Color(0xffd86a04), fontWeight: FontWeight.bold),
    ),
    iconTheme: const IconThemeData(
      color: Color(0xffd86a04),
    ),
    actions: actions,
  );
}


class MyAppBar extends AppBar {
  final VoidCallback? onBack;
  final BuildContext context;

  MyAppBar({Key? key, this.onBack, required this.context, bool automaticallyImplyLeading = false})
      : super(
    key: key,
    automaticallyImplyLeading: automaticallyImplyLeading,
    backgroundColor: Color(0xffffecda),
    elevation: 0,
    centerTitle: false,
    title: const Text(
      "BeautyMinder",
      style: TextStyle(color: Color(0xffd86a04), fontWeight: FontWeight.bold),
    ),
    iconTheme: const IconThemeData(
      color: Color(0xffd86a04),
    ),
    leading: IconButton(
      onPressed: () {
        if (onBack != null) {
          onBack!();
        } else {
          Navigator.pop(context, true);
        }
      },
      icon: Icon(Icons.arrow_back_ios),
    ),
  );
}


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


class SearchAppBar extends AppBar {
  final Widget title;
  final VoidCallback? onBack;
  final BuildContext context; // Add this line

  SearchAppBar({Key? key, required this.title, this.onBack, required this.context})
      : super(
    key: key,
    backgroundColor: Color(0xffffecda),
    elevation: 0,
    centerTitle: false,
    title: title,
    iconTheme: IconThemeData(
      color: Color(0xffd86a04),
    ),
    leading: IconButton(
      onPressed: () {
        if (onBack != null) {
          onBack!();
        } else {
          Navigator.pop(context, true);
        }
      },
      icon: Icon(Icons.arrow_back_ios),
    ),
  );
}

