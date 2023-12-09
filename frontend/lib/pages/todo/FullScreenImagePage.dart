import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';

class FullScreenImagePage extends StatelessWidget {
  final File imageFile;
  final VoidCallback onDelete;

  FullScreenImagePage({required this.imageFile, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    // 파일의 생성 날짜를 얻는 함수
    Future<String> getFileCreationDate() async {
      var fileStat = await imageFile.stat();
      var formattedDate = DateFormat('yyyy-MM-dd').format(fileStat.changed);
      return formattedDate;
    }

    // 삭제 확인 대화상자를 표시하는 함수
    void showDeleteConfirmationDialog() {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: Text('삭제 확인'),
            content: Text('이 이미지를 정말 삭제하시겠습니까?'),
            actions: <Widget>[
              TextButton(
                child: Text('아니오', style: TextStyle(color: Color(0xffd86a04))),
                onPressed: () {
                  Navigator.of(dialogContext).pop(); // 대화상자 닫기
                },
              ),
              TextButton(
                child: Text('예', style: TextStyle(color: Color(0xffd86a04)),),
                onPressed: () {
                  onDelete(); // 이미지 삭제
                  Navigator.of(dialogContext).pop(); // 대화상자 닫기
                },
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xffffecda),
        iconTheme: IconThemeData(color: Color(0xffd86a04)),
        title: FutureBuilder<String>(
          future: getFileCreationDate(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
              return Text("${snapshot.data!}", style: TextStyle(color: Color(0xffd86a04)));
            } else {
              return Text("Loading...");
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Color(0xffd86a04)),
            onPressed: showDeleteConfirmationDialog, // 삭제 확인 대화상자 표시
          ),
        ],
      ),
      body: Center(
        child: PhotoView(
          backgroundDecoration: BoxDecoration(color: Colors.white),
          imageProvider: FileImage(File(imageFile.path)),
        ),
      ),
    );
  }
}
