// 사진을 전체 화면으로 보여주는 페이지를 정의합니다.
import 'package:beautyminder/widget/appBar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:local_image_provider/device_image.dart';
import 'package:local_image_provider/local_image.dart';
import 'package:photo_view/photo_view.dart';

class FullScreenImagePage extends StatelessWidget {
  final LocalImage image;

  const FullScreenImagePage({Key? key, required this.image}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(automaticallyImplyLeading: true, context: context,),
      body: Container(
        child: PhotoView(
          imageProvider: DeviceImage(image),
        ),
      ),
    );
  }
}