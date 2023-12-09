import 'dart:io';

import 'package:beautyminder/pages/todo/todo_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../widget/appBar.dart';
import '../../widget/bottomNavigationBar.dart';
import '../my/my_page.dart';
import '../pouch/expiry_page.dart';
import '../recommend/recommend_bloc_screen.dart';
import 'FullScreenImagePage.dart';

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

  // List<LocalImage> images = [];
  List<File> images = [];
  String filter = "전체"; // 이미지 목록을 저장할 상태 변수

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

  Future<List<File>> getLocalImages() async {
    final albumPath = await createAlbum('BeautyMinder');
    final directory = Directory(albumPath);
    List<File> imageFiles = [];

    if (await directory.exists()) {
      var fileList = directory.listSync(); // List all files in the directory
      for (var file in fileList) {
        if (file is File && isImageFile(file.path)) {
          var lastModified = await file.lastModified();
          if (_isFileInFilter(lastModified)) {
            imageFiles.add(file);
          }
        }
      }
    }

    return imageFiles.reversed.toList();
  }

  bool _isFileInFilter(DateTime lastModified) {
    var now = DateTime.now();
    switch (filter) {
      case '전체':
        return true;
      case '이번 달':
        return lastModified.year == now.year && lastModified.month == now.month;
      case '이번 주':
        // 현재 주의 시작과 끝을 계산합니다.
        var weekStart = now.subtract(Duration(days: now.weekday - 1));
        var weekEnd = weekStart.add(Duration(days: 6));
        return lastModified.isAfter(weekStart) &&
            lastModified.isBefore(weekEnd);
      case '오늘':
        return lastModified.year == now.year &&
            lastModified.month == now.month &&
            lastModified.day == now.day;
      default:
        return true;
    }
  }

  bool isImageFile(String filePath) {
    return ['.png', '.jpg', '.jpeg', '.bmp', '.gif']
        .any((extension) => filePath.endsWith(extension));
  }

  Widget _filterButton(String filterValue) {
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
        filterValue,
        style: TextStyle(
            color: filter == filterValue ? Colors.white : Color(0xffd86a04)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: CommonAppBar(
        automaticallyImplyLeading: true,
        context: context,
      ),
      body: FutureBuilder<List<File>>(
        future: getLocalImages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }

          if (snapshot.hasData && snapshot.data?.length != 0) {
            return Column(
              children: [
                SizedBox(
                  height: 150,
                  child: Center(
                    child: Text(filter,
                        style: TextStyle(
                            fontSize: 50.0, color: Color(0xffb4b4b4))),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _filterButton('전체'),
                    _filterButton('이번 달'),
                    _filterButton('이번 주'),
                    _filterButton('오늘'),
                  ],
                ),
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 5.0,
                      crossAxisSpacing: 5,
                      childAspectRatio: 1,
                    ),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      File imageFile = snapshot.data![index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FullScreenImagePage(
                                      imageFile: imageFile,
                                      onDelete: () async {
                                        await imageFile.delete();
                                        _updateImages();
                                        Navigator.pop(context);
                                      })));
                        },
                        child: Image.file(
                          imageFile,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          } else if (snapshot.data?.length == 0) {
            return Center(
              child: Text("기록된 사진이 없습니다.\n사진을 촬영해주세요.",
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                  textAlign: TextAlign.center),
            );
          }

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

  Future<String> createAlbum(String albumName) async {
    final directory =
        await getApplicationDocumentsDirectory(); // or getExternalStorageDirectory() for external storage
    print("directory : ${directory}");
    final albumPath = Directory('${directory.path}/$albumName');
    print("albumPath: ${albumPath}");

    if (!await albumPath.exists()) {
      await albumPath.create(recursive: true);
    }

    return albumPath.path;
  }

  void _takePhoto() async {
    createAlbum("beautyminder");
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      String albumPath = await createAlbum('BeautyMinder');
      // 임시 파일 가져오기
      final tempImageFile = File(pickedFile.path);

      // 문서 디렉토리 경로 얻기
      final directory = await getApplicationDocumentsDirectory();

      String newFileName = 'Skinrecord_${DateTime.now()}.jpg';
      final newFilePath = path.join(albumPath, newFileName);
      print("저장 경로 : ${newFilePath}");

      // 파일을 새 경로와 이름으로 이동
      final newImageFile = await tempImageFile.copy(newFilePath);

      print("새로운 사진이 저장된 경로: ${newImageFile.path}");
      // 선택적: GallerySaver를 사용하여 갤러리에도 저장
      GallerySaver.saveImage(newImageFile.path);

      _updateImages();
    }
  }
}
