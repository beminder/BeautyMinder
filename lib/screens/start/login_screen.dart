import 'package:admin/Page/homePage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snippet_coder_utils/ProgressHUD.dart';

import '../../Service/api_service.dart';
import '../../dto/login_request_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isApiCallProcess = false;
  bool hidePassword = true;
  final GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  String? email;
  String? password;

  FocusNode emailFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();

  Color emailIconColor = Colors.grey.withOpacity(0.7);
  Color passwordIconColor = Colors.grey.withOpacity(0.7);

  bool rememberEmail = false;

  TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  void loadPreferences() async {
    print("This is loadPreferences");
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Load the checkbox state
    setState(() {
      rememberEmail = prefs.getBool('rememberEmail') ?? false;
    });

    // Load the email field text if the checkbox is checked
    if (rememberEmail) {
      print("This is loadPreferences = rememberEmail : $rememberEmail");
      setState(() {
        email = prefs.getString('email') ?? '';
        emailController.text = email ?? '';
      });
    }
    print("This is loadPreferences - email : $email");
  }

  void savePreferences() async {
    print("This is savePreferences");
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Save the checkbox state
    prefs.setBool('rememberEmail', rememberEmail);

    // Save the email field text if the checkbox is checked
    if (rememberEmail) {
      print("This is savePreferences = rememberEmail : $rememberEmail");
      prefs.setString('email', email ?? '');
      print("This is savePreferences = email : $email");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      backgroundColor: Colors.black54,
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProgressHUD(
              child: Form(
                key: globalFormKey,
                child: _loginUI(context),
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

  // 로그인 UI
  Widget _loginUI(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: <Widget>[
          SizedBox(height: 200), // 여백 추가
          _buildEmailField(), // 이메일 필드

          SizedBox(height: 30), // 여백 추가
          _buildPasswordField(), // 비밀번호 필드

          SizedBox(height: 30),
          _checkboxRememberEmail(),

          SizedBox(height: 80), // 여백 추가
          _buildLoginButton(), // 로그인 버튼

        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "이메일 입력",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 5),
        Focus(
            onFocusChange: (hasFocus) {
              setState(() {
                emailIconColor =
                    hasFocus ? Colors.white : Colors.grey.withOpacity(0.7);
              });
            },
            child: Container(
              height: 60,
              child: TextFormField(
                controller: emailController,
                // initialValue: email,
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
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white, // Change the color as needed
                    ),
                  ),
                ),
              ),
            )),
      ],
    );
  }

// Update _buildPasswordField method
  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "비밀번호 입력",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 5),
        Focus(
          onFocusChange: (hasFocus) {
            setState(() {
              passwordIconColor =
                  hasFocus ? Colors.white : Colors.grey.withOpacity(0.7);
            });
          },
          child: Container(
            height: 60,
            child: TextFormField(
              // initialValue: '1234',
              focusNode: passwordFocusNode,
              validator: (val) => val!.isEmpty ? '비밀번호가 입력되지 않았습니다.' : null,
              onChanged: (val) => password = val,
              obscureText: hidePassword,
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: "비밀번호를 입력하세요",
                hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7)),
                prefixIcon: Icon(
                  Icons.lock,
                  color: passwordIconColor,
                ),
                suffixIcon: InkWell(
                  onTap: () {
                    setState(() {
                      hidePassword = !hidePassword;
                    });
                  },
                  child: Icon(
                    hidePassword ? Icons.visibility_off : Icons.visibility,
                    color: hidePassword
                        ? Colors.grey.withOpacity(0.7)
                        : Colors.white,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white, // Change the color as needed
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _checkboxRememberEmail() {
    return Row(
      children: [
        Checkbox(
          value: rememberEmail,
          onChanged: (value) {
            setState(() {
              rememberEmail = value!;
            });
          },
          activeColor: Colors.white54,
        ),
        Text("이메일 기억하기"),
      ],
    );
  }

  // 로그인 버튼
  Widget _buildLoginButton() {
    double screenWidth = MediaQuery.of(context).size.width;

    return InkWell(
      child: Container(
        width: screenWidth, // 원하는 너비 설정
        height: 50, // 원하는 높이 설정
        decoration: BoxDecoration(
          color: Colors.white54, // 버튼 배경색 설정
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
              savePreferences();
              final userProfileResult = await APIService.getUserProfile();
              print("Here is LoginPage : ${userProfileResult.value}");

              // Instead of using Navigator.of(context).push directly,
              // use Navigator.pushReplacement to replace the login page in the stack
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => FutureBuilder(
                    // Use FutureBuilder to show a loading spinner until the data is loaded
                    future: Future.delayed(
                        Duration(seconds: 2), () => userProfileResult.value),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Scaffold(
                          body: Center(
                            child: SpinKitThreeInOut(
                              color: Color(0xffd86a04),
                              size: 50.0,
                              duration: Duration(seconds: 2),
                            ),
                          ),
                        );
                      } else {
                        // Once data is loaded, navigate to the home page

                        return homePage();
                        //return DashboardScreen();
                          //DashboardScreen();
                      }
                    },
                  ),
                ),
              );
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

  // 비밀번호 찾기
  Widget _buildForgetPassword() {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.only(left: 25, right: 25),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black, fontSize: 15.0),
            children: <TextSpan>[
              const TextSpan(text: '비밀번호를 잊어버리셨나요? '),
              TextSpan(
                text: '비밀번호 찾기',
                style: const TextStyle(
                  color: Color(0xffd86a04),
                  fontWeight: FontWeight.bold,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    // Navigator.of(context).push(MaterialPageRoute(
                    //     builder: (context) =>
                    //         FindPasswordByEmailPage()));
                  },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 입력 유효성 검사
  bool validateAndSave() {
    final form = globalFormKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }
}
