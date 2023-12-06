
import 'dart:io';

import 'package:beautyminder/pages/todo/todo_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_image_provider/device_image.dart';
import 'package:local_image_provider/local_image.dart';
import 'package:local_image_provider/local_image_provider.dart' as lip;

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../widget/commonAppBar.dart';
import '../../widget/commonBottomNavigationBar.dart';
import '../my/my_page.dart';
import '../pouch/expiry_page.dart';
import '../recommend/recommend_bloc_screen.dart';
import 'FullScreenImagePage.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class skinAlbumPage extends StatefulWidget {
  const skinAlbumPage({Key? key}) : super(key: key);

  @override
  _skinAlbumPage createState() => _skinAlbumPage();
}

class _skinAlbumPage extends State<skinAlbumPage> {
  String selectedFilter = "all";
  String title = '전체';

  getPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.photos,
      Permission.accessMediaLocation,
      Permission.storage
    ].request();

    print("statuses[Permission.camera] : ${statuses[Permission.camera]}");
    print("Permission.photos : ${statuses[Permission.photos]}");
    print(
        "Permission.accessMediaLocation : ${statuses[Permission.accessMediaLocation]}");
    print("Permission.storage : ${statuses[Permission.storage]}");
  }

  List<LocalImage> images = [];
  String filter = "all"; // 이미지 목록을 저장할 상태 변수

  @override
  void initState() {
    super.initState();
    getPermission();
    _updateImages(); // 초기 이미지 목록 로드
  }

  void _updateImages() async {
    // 이미지 목록을 갱신하는 메서드
    try {
      var newImages = await getLocalImages();
      setState(() {
        images = newImages;
      });
    } catch (e) {
      print(e);
    }
  }


  Future<List<LocalImage>> getLocalImages() async {
    tz.initializeTimeZones(); // 시간대 데이터 초기화
    var seoul = tz.getLocation('Asia/Seoul'); // 서울 시간대 객체 생성

    lip.LocalImageProvider imageProvider = lip.LocalImageProvider();
    bool hasPermission = await imageProvider.initialize();
    if (!hasPermission) {
      throw '이미지에 접근할 권한이 없습니다.';
    }

    List<LocalImage> images = filter == 'all'
        ? await imageProvider.findLatest(365)
        : await imageProvider.findLatest(50);

    List<LocalImage> filteredImages = images
        .where((image) => image.fileName!.contains('Skinrecord'))
        .toList();

    DateTime now = tz.TZDateTime.now(seoul); // 현재 시간을 KST로 설정
    return filteredImages.where((image) {
      DateTime utcImageDate = DateTime.parse(image.creationDate!);
      tz.TZDateTime kstImageDate = tz.TZDateTime.from(utcImageDate, seoul); // 이미지 생성 시간을 KST로 변환

      switch (filter) {
        case 'Today':
          title = '오늘';
          return kstImageDate.year == now.year &&
              kstImageDate.month == now.month &&
              kstImageDate.day == now.day;
        case 'This Week':
          title = '이번 주';
          DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          return kstImageDate.isAfter(startOfWeek) &&
              kstImageDate.isBefore(now.add(Duration(days: 1)));
        case 'This Month':
          title = '이번 달';
          return kstImageDate.year == now.year && kstImageDate.month == now.month;
        default: // 'All'
          title = '전체';
          return true;
      }
    }).toList();
  }


  // Future<List<LocalImage>> getLocalImages() async {
  //   lip.LocalImageProvider imageProvider = lip.LocalImageProvider();
  //   bool hasPermission = await imageProvider.initialize();
  //   print("hasPermission : ${hasPermission}");
  //   if (hasPermission) {
  //     // 최근 이미지 30개 가져오기
  //     List<LocalImage> images;
  //
  //     if (filter == 'all') {
  //       images = images = await imageProvider.findLatest(365);
  //     } else {
  //       images = images = await imageProvider.findLatest(50);
  //     }
  //
  //     List<LocalImage> filteredImages = images.where((image) {
  //       return image.fileName!.contains('Skinrecord');
  //     }).toList();
  //
  //     DateTime now = DateTime.now();
  //     return filteredImages.where((image) {
  //       DateTime? imageDate = DateTime.parse(image.creationDate!);
  //       if (imageDate == null) return false;
  //
  //       // KST로 변환
  //       tz.TZDateTime kstTime = tz.TZDateTime.from(imageDate, tz.getLocation('Asia/Seoul'));
  //
  //       switch (filter) {
  //         case 'Today':
  //           title = '오늘';
  //           return imageDate.year == now.year &&
  //               imageDate.month == now.month &&
  //               imageDate.day == now.day;
  //         case 'This Week':
  //           title = '이번 주';
  //           DateTime startOfWeek =
  //               now.subtract(Duration(days: now.weekday - 1));
  //           return imageDate.isAfter(startOfWeek) &&
  //               imageDate.isBefore(now.add(Duration(days: 1)));
  //         case 'This Month':
  //           title = '이번 달';
  //           return imageDate.year == now.year && imageDate.month == now.month;
  //         default: // 'All'
  //           title = '전체';
  //           return true;
  //       }
  //     }).toList();
  //   } else {
  //     throw '이미지에 접근할 권한이 없습니다.';
  //     print('이미지에 접근할 권한이 없습니다.');
  //   }
  // }

  Widget _filterButton(String title, String filterValue) {
    return TextButton(
      onPressed: () {
        setState(() {
          filter = filterValue;
          _updateImages();
        });
      },
      style: TextButton.styleFrom(
          backgroundColor:
              filter == filterValue ? Color(0xffd86a04) : Color(0xffffecda)),
      child: Text(
        title,
        style: TextStyle(
            color: filter == filterValue ? Colors.white : Color(0xffd86a04)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: CommonAppBar(automaticallyImplyLeading: true, context: context,),
      body: FutureBuilder<List<LocalImage>>(
        future: getLocalImages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }

          if (snapshot.hasData && snapshot.data?.length != 0) {
            print("snapshot.hasData : ${snapshot.hasData}");
            print("snapshot.data : ${snapshot.data}");
            print(snapshot.data![0].creationDate);
            return Column(
              children: [
                SizedBox(
                  height: 150,
                  child: Center(
                    child: Text(title,
                        style: TextStyle(
                            fontSize: 50.0, color: Color(0xffb4b4b4))),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _filterButton('전체', 'all'),
                    _filterButton('이번 달', 'This Month'),
                    _filterButton('이번 주', 'This Week'),
                    _filterButton('오늘', 'Today'),
                  ],
                ),
                Expanded(
                  child: GridView.count(
                    padding: EdgeInsets.zero,
                    crossAxisCount: 4,
                    mainAxisSpacing: 5.0,
                    crossAxisSpacing: 5,
                    childAspectRatio: 1, // 셀의 종횡비를 1:1로 설정
                    children: snapshot.data!
                        .map((e) => GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FullScreenImagePage(
                                      image: e,
                                    ),
                                  ),
                                );
                              },
                              child: AspectRatio(
                                aspectRatio: 1, // 종횡비 (예: 1은 정사각형)
                                child: Image(
                                    image: DeviceImage(e), fit: BoxFit.cover),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            );
          }else if(snapshot.data?.length == 0){
            return Center(
              child: Text("기록된 사진이 없습니다. \n사진을 기록해주요.", style: TextStyle(fontSize: 30, color: Colors.grey),textAlign: TextAlign.center),
            );
          }

          // Handle the case where there's no data
          return Center(child: Text('No images found'));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        //foregroundColor: Color(0xffffecda),
        backgroundColor: Color(0xffd86a04),
        onPressed: () {
          _takePhoto();
        },
        label: Text('사진 촬영'),
        icon: Icon(Icons.camera_alt_outlined),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      //floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat ,
    );
  }

  void _takePhoto() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      // 임시 파일 가져오기
      final tempImageFile = File(pickedFile.path);

      // 문서 디렉토리 경로 얻기
      final directory = await getApplicationDocumentsDirectory();

      // 새로운 파일명 생성 (예: Skinrecord_<timestamp>.jpg)
      String newFileName = 'Skinrecord_${DateTime.now()}.jpg';
      final newFilePath = path.join(directory.path, newFileName);

      // 파일을 새 경로와 이름으로 이동
      final newImageFile = await tempImageFile.copy(newFilePath);

      print("새로운 사진이 저장된 경로: ${newImageFile.path}");
      // 선택적: GallerySaver를 사용하여 갤러리에도 저장
      GallerySaver.saveImage(newImageFile.path);

      _updateImages();
    }
  }
}
