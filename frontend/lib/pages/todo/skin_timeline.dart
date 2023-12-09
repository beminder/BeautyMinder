import 'package:beautyminder/widget/appBar.dart';
import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:local_image_provider/device_image.dart';
import 'package:local_image_provider/local_image.dart';
import 'package:local_image_provider/local_image_provider.dart' as lip;
import 'package:permission_handler/permission_handler.dart';

class timeLine extends StatefulWidget {
  const timeLine({Key? key}) : super(key: key);

  @override
  _timeLine createState() => _timeLine();
}

class _timeLine extends State<timeLine> {
  final EasyInfiniteDateTimelineController _controller =
      EasyInfiniteDateTimelineController();

  DateTime _focusDate = DateTime.now();
  late DateTime _selectDate;


  @override
  void initState() {
    super.initState();
    getPermission();
    _focusDate = DateTime.now();
    _selectDate = _focusDate;
    _updateImages(_focusDate); // 현재 날짜의 이미지를 로드합니다.
    _selectDate = DateTime.now();
  }

  List<LocalImage> images = [];

  Future<List<LocalImage>> getLocalImages(String pickedDate) async {
    lip.LocalImageProvider imageProvider = lip.LocalImageProvider();
    bool hasPermission = await imageProvider.initialize();
    if (hasPermission) {
      // 최근 이미지 100개 가져오기
      List<LocalImage> images = await imageProvider.findLatest(100);

      // pickedDate를 DateTime 객체로 파싱
      DateTime parsedPickedDate = DateTime.parse(pickedDate);

      // 해당 날짜에 생성되고, 'Skinrecord' 문자열을 포함하는 이미지만 필터링
      List<LocalImage> filteredImages = images.where((image) {
        DateTime? imageDate = DateTime.parse(image.creationDate!);
        if (imageDate == null) return false;

        // 날짜와 'Skinrecord' 문자열을 모두 확인
        return imageDate.year == parsedPickedDate.year &&
            imageDate.month == parsedPickedDate.month &&
            imageDate.day == parsedPickedDate.day &&
            image.fileName!.contains('Skinrecord');
      }).toList();

      return filteredImages;
    } else {
      throw '이미지에 접근할 권한이 없습니다.';
    }
  }

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

  void _updateImages(DateTime date) async {
    String formattedDate =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    try {
      var newImages = await getLocalImages(formattedDate);
      setState(() {
        images = newImages;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: CommonAppBar(automaticallyImplyLeading: true, context: context,),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            // EasyInfiniteDateTimeLine(
            //   controller: _controller,
            //   activeColor: Color(0xffd86a04),
            //   firstDate: DateTime(2023),
            //   focusDate: _focusDate,
            //   lastDate: DateTime(2023, 12, 31),
            //   onDateChange: (selectedDate) {
            //     _updateImages(selectedDate);
            //     setState(() {
            //       _focusDate = selectedDate;
            //       _selectDate = selectedDate;
            //       print(_selectDate);
            //     });
            //   },
            // ),
            CalendarTimeline(
              initialDate: _selectDate,
              firstDate: DateTime(2019, 1, 15),
              lastDate: DateTime(2030, 11, 20),
              onDateSelected: (date) => {print(date),
                _selectDate = date,
                setState(() {
                  _updateImages(date);
                })
              },
              leftMargin: 20,
              monthColor: Colors.blueGrey,
              dayColor: Color(0xffd86a04),
              activeDayColor: Color(0xffffecda),
              activeBackgroundDayColor: Color(0xffd86a04),
              dotsColor: Color(0xFF333A47),
              locale: 'en_ISO',
            ),
            SizedBox(
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
                      image: DeviceImage(images[index]),
                      fit: BoxFit.cover,
                    ),
                  );
                },
              )
                  : Center(
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
