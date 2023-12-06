import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../dto/cosmetic_model.dart';
import '../../dto/vision_response_dto.dart';
import '../../services/ocr_service.dart';

class ExpiryInputDialog extends StatefulWidget {
  final Cosmetic cosmetic;

  ExpiryInputDialog({required this.cosmetic});

  @override
  _ExpiryInputDialogState createState() => _ExpiryInputDialogState();
}

class _ExpiryInputDialogState extends State<ExpiryInputDialog> {
  bool isOpened = false;
  bool isLoading = false;

  //DateTime expiryDate = DateTime.now().add(Duration(days: 365));
  DateTime? expiryDate = DateTime.now();
  DateTime? openedDate = DateTime.now(); // 개봉 날짜 기본값

  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> _selectDate(BuildContext context,
      {bool isExpiryDate = true}) async {

    Locale myLocale = Localizations.localeOf(context);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isExpiryDate ? expiryDate : openedDate) ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      locale: myLocale,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.orange,
            hintColor: Colors.orange,
            colorScheme: ColorScheme.light(primary: Colors.orange),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange, // Button text color
              ),
            ),
            textTheme: TextTheme(
              headline4: TextStyle(
                fontFamily: 'YourFontFamily',
                fontSize: 20.0,
                color: Colors.black,
              ),
              button: TextStyle(
                fontFamily: 'YourFontFamily',
                color: Colors.orange,
              ),
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isExpiryDate) {
          expiryDate = picked;
        } else {
          openedDate = picked;
        }
      });
    }
  }

  // OCR 페이지로 이동하고 결과를 받아오는 함수
  Future<void> _navigateAndProcessOCR(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      setState((){
        isLoading = true;
      });
      // 이미지 자르기
      CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9
          ],
          uiSettings: [
            AndroidUiSettings(
                toolbarTitle: 'Crop Image',
                toolbarColor: Colors.orange,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.original,
                lockAspectRatio: false),
            IOSUiSettings(
              title: 'Crop Image',
            )
          ]
      );

      if (croppedFile != null) {
        final file = File(croppedFile.path);
        final fileName = file.path.split('/').last;
        final fileSize = await file.length();
        final fileBytes = await file.readAsBytes();

        try {
          // OCR 서비스 호출
          final response = await OCRService.selectAndUploadImage(PlatformFile(
            name: fileName,
            bytes: fileBytes,
            size: fileSize,
            path: croppedFile.path,
          ));

          if (response != null) {
            // OCR 결과 처리
            final VisionResponseDTO result = VisionResponseDTO.fromJson(response);
            final expiryDateFromOCR = DateFormat('yyyy-MM-dd').parse(result.data);

            setState(() {
              isLoading = false;
              expiryDate = expiryDateFromOCR;
            });
          }
        } catch (e) {
          setState(() {
            isLoading = false; // 로딩 종료
          });
          // 오류 처리
          _showErrorDialog("이미지 인식에 실패하였습니다.");
        }
      }
    } else {
      _showErrorDialog("이미지가 선택되지 않았습니다.");
    }
  }

  // 에러 메시지를 보여주는 함수
  void _showErrorDialog(String message) {
    print("error in OCR : $message");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3.0),
        ),
        title: Text(
          '오류',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          '$message',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        actions: [
          Container(
            width: 70,
            height: 30,
            child: TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: Color(0xffdc7e00),
                foregroundColor: Colors.white,
                side: BorderSide(color: Color(0xffdc7e00)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
              child: Text('확인'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  // 유통기한 선택 방법을 선택하는 다이얼로그를 표시하는 함수
  void _showExpiryDateChoiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        title: Text(
          '유통기한 입력 방법 선택',
          style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 24,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.edit),
              title: Text(
                '직접 입력',
                style: TextStyle(
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              onTap: () {
                Navigator.of(context).pop();
                _selectDate(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text(
                '카메라로 촬영',
                style: TextStyle(
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              onTap: () {
                Navigator.of(context).pop();
                _navigateAndProcessOCR(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_album),
              title: Text(
                '앨범에서 선택',
                style: TextStyle(
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              onTap: () {
                Navigator.of(context).pop();
                _navigateAndProcessOCR(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      titlePadding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 50.0),
      title: Text(
        '제품 정보를 입력해주세요',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
      content: isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          strokeWidth: 5.0,
        ),
      )
          : Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(
              '제품명',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            trailing: Container(
              width: 150,
              child: Text(
                '${widget.cosmetic.name}',
                style: TextStyle(
                  fontSize: 18,
                ),
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          ListTile(
            title: Text(
              '브랜드',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            trailing: Container(
              width: 150,
              child: Text(
                '${widget.cosmetic.brand}',
                style: TextStyle(
                  fontSize: 18,
                ),
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          SwitchListTile(
            title: Text(
              '개봉 여부',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            value: isOpened,
            onChanged: (bool value) {
              setState(() {
                isOpened = value;
                if (!isOpened) {
                  openedDate = null;
                }
              });
            },
            activeColor: Colors.white,
            activeTrackColor: Colors.orange,
          ),
          ListTile(
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '유통기한',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                Spacer(),// 조절 가능한 간격
                Text(
                  expiryDate != null
                      ? formatDate(expiryDate!)
                      : '유통기한 선택',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            trailing: Icon(Icons.calendar_today),
            onTap: () => _showExpiryDateChoiceDialog(),
          ),
          if (isOpened)
            ListTile(
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '개봉일',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  Spacer(),// 조절 가능한 간격
                  Text(
                    openedDate != null
                        ? formatDate(openedDate!)
                        : '개봉일 선택',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, isExpiryDate: false),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop([isOpened, expiryDate, openedDate]),
          child: Text(
            '등록',
            style: TextStyle(
                color: Colors.orange,
                fontSize: 20,
                fontWeight: FontWeight.bold
            ),
          ),
          style: TextButton.styleFrom(foregroundColor: Colors.orange),
        ),
      ],
    );
  }
}
