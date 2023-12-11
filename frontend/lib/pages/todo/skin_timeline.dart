import 'dart:io';

import 'package:beautyminder/widget/appBar.dart';
import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class TimeLine extends StatefulWidget {
  const TimeLine({Key? key}) : super(key: key);

  @override
  State<TimeLine> createState() => _TimeLine();
}

class _TimeLine extends State<TimeLine> {
  final EasyInfiniteDateTimelineController _controller =
      EasyInfiniteDateTimelineController();

  DateTime _focusDate = DateTime.now();
  late DateTime _selectDate;
  List<File> images = []; // File 객체의 리스트로 선언

  @override
  void initState() {
    super.initState();
    getPermission();
    _focusDate = DateTime.now();
    _selectDate = _focusDate;
    _updateImages(_focusDate); // 현재 날짜의 이미지를 로드합니다.
    _selectDate = DateTime.now();
  }

  Future<String> createAlbum(String albumName) async {
    final directory =
        await getApplicationDocumentsDirectory(); // or getExternalStorageDirectory() for external storage
    final albumPath = Directory('${directory.path}/$albumName');

    if (!await albumPath.exists()) {
      await albumPath.create(recursive: true);
    }

    return albumPath.path;
  }

  bool isImageFile(String filePath) {
    return ['.png', '.jpg', '.jpeg', '.bmp', '.gif']
        .any((extension) => filePath.endsWith(extension));
  }

  Future<List<File>> getLocalImages(String selectedDate) async {
    final albumPath = await createAlbum('BeautyMinder');
    final directory = Directory(albumPath);
    List<File> imageFiles = [];

    if (await directory.exists()) {
      var fileList = directory.listSync(); // List all files in the directory
      for (var file in fileList) {
        if (file is File && isImageFile(file.path)) {
          var lastModified = await file.lastModified();
          // 날짜 포맷을 'yyyy-MM-dd' 형식으로 변환
          String fileDate = DateFormat('yyyy-MM-dd').format(lastModified);
          if (fileDate == selectedDate) {
            imageFiles.add(file);
          }
        }
      }
    }

    return imageFiles.reversed.toList();
  }

  void _updateImages(DateTime date) async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    try {
      var newImages = await getLocalImages(formattedDate);
      setState(() {
        images = newImages;
      });
    } catch (e) {
      print(e);
    }
  }

  getPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.photos,
      Permission.accessMediaLocation,
      Permission.storage
    ].request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: CommonAppBar(
        automaticallyImplyLeading: true,
        context: context,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            CalendarTimeline(
              initialDate: _selectDate,
              firstDate: DateTime(2019, 1, 15),
              lastDate: DateTime(2030, 11, 20),
              onDateSelected: (date) => {
                print(date),
                _selectDate = date,
                setState(() {
                  _updateImages(date);
                })
              },
              leftMargin: 20,
              monthColor: Colors.blueGrey,
              dayColor: const Color(0xffd86a04),
              activeDayColor: const Color(0xffffecda),
              activeBackgroundDayColor: const Color(0xffd86a04),
              dotsColor: const Color(0xFF333A47),
              locale: 'en_ISO',
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: images.isNotEmpty
                  ? GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        mainAxisSpacing: 10.0,
                        crossAxisCount: 1,
                      ),
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: Image(
                            image: FileImage(images[index]),
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Text(
                        '기록된 사진이 없습니다.',
                        style: TextStyle(fontSize: 18.0, color: Colors.black54),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
