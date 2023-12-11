// 사진을 전체 화면으로 보여주는 페이지를 정의합니다.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';

class FullScreenImagePage extends StatelessWidget {
  final File imageFile;
  final VoidCallback onDelete;

  const FullScreenImagePage({super.key, required this.imageFile, required this.onDelete});

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
            title: const Text('삭제 확인'),
            content: const Text('이 이미지를 정말 삭제하시겠습니까?'),
            actions: <Widget>[
              TextButton(
                child: const Text('아니오', style: TextStyle(color: Color(0xffd86a04))),
                onPressed: () {
                  Navigator.of(dialogContext).pop(); // 대화상자 닫기
                },
              ),
              TextButton(
                child: const Text('예', style: TextStyle(color: Color(0xffd86a04)),),
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
        backgroundColor: const Color(0xffffecda),
        iconTheme: const IconThemeData(color: Color(0xffd86a04)),
        title: FutureBuilder<String>(
          future: getFileCreationDate(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
              return Text(snapshot.data!, style: const TextStyle(color: Color(0xffd86a04)));
            } else {
              return const Text("Loading...");
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Color(0xffd86a04)),
            onPressed: showDeleteConfirmationDialog, // 삭제 확인 대화상자 표시
          ),
        ],
      ),
      body: Center(
        child: PhotoView(
          backgroundDecoration: const BoxDecoration(color: Colors.white),
          imageProvider: FileImage(File(imageFile.path)),
        ),
      ),
    );
  }
}
