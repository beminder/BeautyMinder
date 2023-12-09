import 'package:beautyminder/services/shared_service.dart';
import 'package:flutter/material.dart';

class NotificationSettingDialog extends StatefulWidget {
  @override
  _NotificationSettingDialogState createState() =>
      _NotificationSettingDialogState();
}

class _NotificationSettingDialogState extends State<NotificationSettingDialog> {
  bool pushSwitchValue = false;
  bool lockScreenSwitchValue = false;

  @override
  void initState() {
    super.initState();
    readData();
  }

  Future<void> readData() async {
    try {
      bool pushStorageValue = await SharedService.getBool('pushOn');
      bool lockScreenStorageValue = await SharedService.getBool('lockScreen');

      setState(() {
        pushSwitchValue = pushStorageValue;
        lockScreenSwitchValue = lockScreenStorageValue;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> writeData(String key, String value) async {
    try {
      await SharedService.storage.write(key: key, value: value);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        '알림 설정',
        style: TextStyle(
            fontSize: 20,
            fontFamily: 'NanumGothic',
            fontWeight: FontWeight.w700),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '푸시 알림',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontFamily: 'NanumGothic',
                  fontWeight: FontWeight.w400,
                ),
              ),
              Switch(
                value: pushSwitchValue,
                onChanged: (value) {
                  setState(() {
                    writeData('pushOn', value.toString());
                    pushSwitchValue = value;
                  });
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '잠금화면에서 보기',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontFamily: 'NanumGothic',
                  fontWeight: FontWeight.w400,
                ),
              ),
              Switch(
                value: lockScreenSwitchValue,
                onChanged: (value) {
                  setState(() {
                    writeData('lockScreen', value.toString());
                    lockScreenSwitchValue = value;
                  });
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'D -',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontFamily: 'NanumGothic',
                  fontWeight: FontWeight.w400,
                ),
              ),
              DdayDropDownMenu(),
              Text(
                '일 남았을 때 알림',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontFamily: 'NanumGothic',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Close'),
        ),
      ],
    );
  }
}

class DdayDropDownMenu extends StatefulWidget {
  const DdayDropDownMenu({super.key});

  @override
  State<DdayDropDownMenu> createState() => _DdayDropDownMenuState();
}

class _DdayDropDownMenuState extends State<DdayDropDownMenu> {
  String dropdownValue = '3';

  @override
  initState() {
    super.initState();
    readData();
  }

  Future<void> readData() async {
    try {
      String dropdownStorageValue =
          await SharedService.getString('d-day') ?? '3';

      setState(() {
        dropdownValue = dropdownStorageValue;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> writeData(String key, String value) async {
    try {
      await SharedService.storage.write(key: key, value: value);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      menuMaxHeight: MediaQuery.of(context).size.height * 0.3,
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      style: const TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontFamily: 'NanumGothic',
        fontWeight: FontWeight.w400,
      ),
      underline: Container(
        height: 2,
        color: Colors.black,
      ),
      onChanged: (String? newValue) {
        setState(() {
          writeData('d-day', newValue ?? '3');
          dropdownValue = newValue!;
        });
      },
      items: <String>[
        '3',
        '5',
        '7',
        '10',
        '15',
        '20',
        '30',
        '60',
        '90',
        '120',
        '180',
        '365'
      ].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Center(child: Text(value)),
        );
      }).toList(),
    );
  }
}
