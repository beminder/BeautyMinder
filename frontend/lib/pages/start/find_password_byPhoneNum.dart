import 'package:beautyminder/pages/start/login_page.dart';
import 'package:beautyminder/pages/start/register_page.dart';
import 'package:beautyminder/widget/usualAppBar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:snippet_coder_utils/ProgressHUD.dart';

import '../../services/forget_password_service.dart';

class FindPasswordByPhoneNumberPage extends StatefulWidget {
  const FindPasswordByPhoneNumberPage({Key? key}) : super(key: key);

  @override
  _FindPasswordByPhoneNumberPageState createState() => _FindPasswordByPhoneNumberPageState();
}

class _FindPasswordByPhoneNumberPageState extends State<FindPasswordByPhoneNumberPage> {

  final GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();

  Color emailIconColor = Colors.grey.withOpacity(0.7);
  FocusNode emailFocusNode = FocusNode();
  String? email;
  bool isApiCallProcess = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UsualAppBar(text: "비밀번호 재설정",),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProgressHUD(
              child: Form(
                key: globalFormKey,
                child: _findPwdByEmailUI(context),
              ),
              inAsyncCall: isApiCallProcess,
              opacity: 0.3,
              key: UniqueKey(),
            )
          ],
        ),
      ),
    );
  }

  Widget _findPwdByEmailUI(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: <Widget>[
          SizedBox(height: 200), // 여백 추가
          _buildPhoneNumberField(), // 이메일 필드
          SizedBox(height: 50),
          _buildSendButton(),
          SizedBox(height: 50),
          _buildOrText(),
          SizedBox(height: 50),
          _buildRegisterText(),
          SizedBox(height: 50),
          _buildLoginText(),
        ],
      ),
    );
  }

  // 전화번호 입력 위젯
  Widget _buildPhoneNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "전화번호 입력",
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
                validator: (val) {
                  if (val!.isEmpty) {
                    return '전화번호가 입력되지 않았습니다.';
                  }
                  else if(!isValidPhoneNumber(val)) {
                    return '전화번호 형식을 다시 확인해주세요. ex) 01011112222';
                  }
                  return null;
                },
                onChanged: (val) => email = val,
                obscureText: false,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: "전화번호를 입력하세요.('-'없이 입력해주세요.)",
                  hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7)),
                  // prefixIcon: Icon(
                  //   Icons.phone_android,
                  //   color: emailIconColor,
                  // ),
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
            "전화번호로 요청",
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
            final response = await ForgetPasswordService.requestByPhoneNumWhenForgetPwd(email!);

            if (response == true) {
              print("Here is requestByEmailWhenForgetPwd : ${response}");
              Fluttertoast.showToast(
                msg: "메세지로 요청이 완료되었습니다. 메세지를 확인해주세요.",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            } else {
              // 에러 토스트 메시지
              Fluttertoast.showToast(
                msg: "메세지 전송에 실패하였습니다. 입력된 전화번호를 다시 확인해주세요.",
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

  // OR 텍스트
  Widget _buildOrText() {
    return const Center(
      child: Text(
        "OR",
        style: TextStyle(
          fontSize: 15,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildRegisterText() {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.only(left: 25, right: 25),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black, fontSize: 15.0),
            children: <TextSpan>[
              const TextSpan(text: '등록된 계정이 없으신가요? '),
              TextSpan(
                text: '회원가입 하기',
                style: const TextStyle(
                  color: Color(0xffd86a04),
                  fontWeight: FontWeight.bold,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            RegisterPage()));
                  },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginText() {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.only(left: 25, right: 25),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black, fontSize: 15.0),
            children: <TextSpan>[
              const TextSpan(text: '로그인 페이지로 이동하실 건가요? '),
              TextSpan(
                text: '로그인 하기',
                style: const TextStyle(
                  color: Color(0xffd86a04),
                  fontWeight: FontWeight.bold,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            LoginPage()));
                  },
              ),
            ],
          ),
        ),
      ),
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

  bool isValidPhoneNumber(String input) {
    final RegExp regex = RegExp(r'^010\d{8}$');
    return regex.hasMatch(input);
  }

}
