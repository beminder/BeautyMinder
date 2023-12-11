import 'package:beautyminder/pages/start/login_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:snippet_coder_utils/ProgressHUD.dart';

import '../../services/forget_password_service.dart';
import '../../widget/appBar.dart';
import 'find_password_by_phone.dart';

class FindPasswordByEmailPage extends StatefulWidget {
  const FindPasswordByEmailPage({Key? key}) : super(key: key);

  @override
  State<FindPasswordByEmailPage> createState() =>
      _FindPasswordByEmailPageState();
}

class _FindPasswordByEmailPageState extends State<FindPasswordByEmailPage> {
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
      appBar: UsualAppBar(
        text: "비밀번호 재설정",
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProgressHUD(
              inAsyncCall: isApiCallProcess,
              opacity: 0.3,
              key: UniqueKey(),
              child: Form(
                key: globalFormKey,
                child: _findPwdByEmailUI(context),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _findPwdByEmailUI(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: <Widget>[
          const SizedBox(height: 200), // 여백 추가
          _buildEmailField(), // 이메일 필드
          const SizedBox(height: 50),
          _buildSendButton(),
          const SizedBox(height: 80),
          _buildOrText(),
          const SizedBox(height: 30),
          _buildByPhoneNumText(),
          const SizedBox(height: 20),
          _buildLoginText(),
        ],
      ),
    );
  }

  // 이메일 입력 위젯
  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "이메일 입력",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 5),
        Focus(
            onFocusChange: (hasFocus) {
              setState(() {
                emailIconColor = hasFocus
                    ? const Color(0xffd86a04)
                    : Colors.grey.withOpacity(0.7);
              });
            },
            child: SizedBox(
              height: 60,
              child: TextFormField(
                focusNode: emailFocusNode,
                validator: (val) => val!.isEmpty ? '이메일이 입력되지 않았습니다.' : null,
                onChanged: (val) => email = val,
                obscureText: false,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: "이메일을 입력하세요",
                  hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7)),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xffd86a04), // Change the color as needed
                    ),
                  ),
                  // focusedBorder: OutlineInputBorder(
                  //   borderRadius: BorderRadius.circular(10),
                  //   borderSide: BorderSide(
                  //     color: Color(0xffd86a04), // 클릭 시 테두리 색상 변경
                  //   ),
                  // ),
                ),
              ),
            )),
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
          color: const Color(0xfffe9738), // 버튼 배경색 설정
          borderRadius: BorderRadius.circular(10.0), // 원하는 모양 설정
        ),
        child: const Center(
          child: Text(
            "이메일로 요청",
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
            final response =
                await ForgetPasswordService.requestByEmailWhenForgetPwd(email!);

            if (response == true) {
              print("Here is requestByEmailWhenForgetPwd : ${response}");
              Fluttertoast.showToast(
                msg: "이메일로 요청이 완료되었습니다. 이메일을 확인해주세요.",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            } else {
              // 에러 토스트 메시지
              Fluttertoast.showToast(
                msg: "이메일 전송에 실패하였습니다. 입력된 이메일을 다시 확인해주세요.",
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

  Widget _buildByPhoneNumText() {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.only(left: 25, right: 25),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black, fontSize: 15.0),
            children: <TextSpan>[
              const TextSpan(text: '이메일을 잊어버리셨나요? '),
              TextSpan(
                text: '전화번호로 찾기',
                style: const TextStyle(
                  color: Color(0xffd86a04),
                  fontWeight: FontWeight.bold,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            const FindPasswordByPhoneNumberPage()));
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
                        builder: (context) => const LoginPage()));
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
}
