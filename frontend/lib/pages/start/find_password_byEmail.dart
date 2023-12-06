import 'package:beautyminder/pages/home/home_page.dart';
import 'package:beautyminder/widget/commonAppBar.dart';
import 'package:beautyminder/widget/usualAppBar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:snippet_coder_utils/ProgressHUD.dart';

import '../../dto/login_request_model.dart';
import '../../services/api_service.dart';

class FindPasswordByEmailPage extends StatefulWidget {
  const FindPasswordByEmailPage({Key? key}) : super(key: key);

  @override
  _FindPasswordByEmailPageState createState() => _FindPasswordByEmailPageState();
}

class _FindPasswordByEmailPageState extends State<FindPasswordByEmailPage> {

  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();

  Color emailIconColor = Colors.grey.withOpacity(0.7);
  FocusNode emailFocusNode = FocusNode();
  String? email;
  String? password;
  bool isApiCallProcess = false;


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UsualAppBar(text: "비밀번호 재설정"),
      backgroundColor: Colors.white,
      body: _findPwdByEmailUI(context),
    );
  }

  Widget _findPwdByEmailUI(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: <Widget>[
          SizedBox(height: 200), // 여백 추가
          _buildEmailField(), // 이메일 필드
          _buildSendButton(),
        ],
      ),
    );
  }

  // 이메일 입력 위젯
  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "이메일 입력",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 5),
        Focus(
            onFocusChange: (hasFocus) {
              setState(() {
                emailIconColor = hasFocus ? Color(0xffd86a04) : Colors.grey.withOpacity(0.7);
              });
            },
            child: Container(
              height: 60,
              child: TextFormField(
                focusNode: emailFocusNode,
                validator: (val) => val!.isEmpty ? '이메일이 입력되지 않았습니다.' : null,
                onChanged: (val) => email = val,
                obscureText: false,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: "이메일을 입력하세요",
                  hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7)),
                  prefixIcon: Icon(
                    Icons.person,
                    color: emailIconColor,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Color(0xffd86a04), // 클릭 시 테두리 색상 변경
                    ),
                  ),
                ),
              ),
            )
        ),
      ],
    );
  }


  // 전송 버튼
  Widget _buildSendButton() {
    double screenWidth = MediaQuery.of(context).size.width;

    return InkWell(
      child: Container(
        width: screenWidth, // 원하는 너비 설정
        height: 50, // 원하는 높이 설정
        decoration: BoxDecoration(
          color: Color(0xfffe9738), // 버튼 배경색 설정
          borderRadius: BorderRadius.circular(10.0), // 원하는 모양 설정
        ),
        child: Center(
          child: Text(
            "로그인",
            style: TextStyle(
              color: Colors.white, // 텍스트 색상 설정
              fontSize: 18, // 텍스트 크기 설정
            ),
          ),
        ),
      ),
      onTap: () async {
        if (validateAndSave()) {
          setState(() {
            isApiCallProcess = true;
          });
          try {
            // 로그인 API 호출
            final model = LoginRequestModel(email: email, password: password);
            final result = await APIService.login(model);

            if (result.value == true) {
              final userProfileResult = await APIService.getUserProfile();
              print("Here is LoginPage : ${userProfileResult.value}");
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      HomePage(user: userProfileResult.value)));
            } else {
              // 에러 토스트 메시지
              Fluttertoast.showToast(
                msg: "로그인에 실패하였습니다. 이메일과 비밀번호를 다시 확인해주세요.",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            }
          } finally {
            setState(() {
              isApiCallProcess = false;
            });
          }
        }
      },
    );
  }

  bool validateAndSave() {
    final form = globalFormKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }
}
