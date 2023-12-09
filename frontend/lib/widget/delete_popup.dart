import 'dart:async';

import 'package:beautyminder/services/api_service.dart';
import 'package:flutter/material.dart';

import 'delete_dialog.dart';

Future<bool> deletePopUp({
  required String title,
  required BuildContext context,
  required String id,
  required Function callback,
  String? subTitle,
  String? okBtnText,
  String? noBtnText,
}) {
  Completer<bool> completer = Completer();
  showDialog(
    context: context,
    builder: (context) => DeleteDialog(
      onBarrierTap: () {
        completer.complete(false);
        Navigator.of(context).pop();
      },
      title: title,
      body: subTitle,
      buttons: [
        DeleteDialogButton(
          onTap: () {
            completer.complete(false);
            Navigator.of(context).pop();
          },
          text: noBtnText ?? "취소",
          backgroundColor: const Color(0xFFF5F5F5),
          textColor: Colors.black,
        ),
        DeleteDialogButton(
          onTap: () async {
            completer.complete(true);

            await APIService.deleteReview(id);
            callback();
            Navigator.of(context).pop();
          },
          text: okBtnText ?? "삭제",
          backgroundColor: Colors.orange,
          textColor: Colors.white,
        ),
      ],
    ),
  );

  return completer.future;
}
