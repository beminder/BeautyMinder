import 'package:beautyminder/pages/home/home_page.dart';
import 'package:beautyminder/widget/commonAppBar.dart';
import 'package:beautyminder/widget/usualAppBar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:snippet_coder_utils/ProgressHUD.dart';

import '../../dto/login_request_model.dart';
import '../../services/api_service.dart';

class FindPasswordByPhoneNumberPage extends StatefulWidget {
  const FindPasswordByPhoneNumberPage({Key? key}) : super(key: key);

  @override
  _FindPasswordByPhoneNumberPageState createState() => _FindPasswordByPhoneNumberPageState();
}

class _FindPasswordByPhoneNumberPageState extends State<FindPasswordByPhoneNumberPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(automaticallyImplyLeading: true),
      backgroundColor: Colors.white,
      body: Text('비밀번호를 잊으셨나요? 전화번호로 비밀번호 찾기'),
    );
  }

}
