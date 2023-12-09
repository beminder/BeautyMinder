import 'dart:async';

import 'package:flutter/material.dart';

import 'default_dialog.dart';

Future<bool> popUp({
  required String title,
  required BuildContext context,
  String? subTitle,
  String? okBtnText,
  String? noBtnText,
}) {
  Completer<bool> completer = Completer();
  showDialog(
    context: context,
    builder: (context) => DefaultDialog(
      onBarrierTap: () {
        completer.complete(false);
        Navigator.of(context).pop();
      },
      title: title,
      body: subTitle,
      buttons: [
        DefaultDialogButton(
          onTap: () {
            completer.complete(false);
            Navigator.of(context).pop();
          },
          text: noBtnText ?? "닫기",
          backgroundColor: const Color(0xFFF5F5F5),
          textColor: Colors.black,
        ),
        DefaultDialogButton(
          onTap: () {
            completer.complete(true);
            Navigator.of(context).pop();
          },
          text: okBtnText ?? "확인",
          backgroundColor: Colors.orange,
          textColor: Colors.white,
        ),
      ],
    ),
  );

  return completer.future;
}
