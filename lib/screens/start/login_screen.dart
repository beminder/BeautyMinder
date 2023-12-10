import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snippet_coder_utils/ProgressHUD.dart';

import '../../Service/api_service.dart';
import '../../constants.dart';
import '../../dto/login_request_model.dart';
import '../main/main_screen.dart';

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
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Load the checkbox state
    setState(() {
      rememberEmail = prefs.getBool('rememberEmail') ?? false;
    });

    // Load the email field text if the checkbox is checked
    if (rememberEmail) {
      setState(() {
        email = prefs.getString('email') ?? '';
        emailController.text = email ?? '';
      });
    }
  }

  void savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Save the checkbox state
    prefs.setBool('rememberEmail', rememberEmail);

    // Save the email field text if the checkbox is checked
    if (rememberEmail) {
      prefs.setString('email', email ?? '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login'),backgroundColor: secondaryColor,),
      backgroundColor: bgColor,
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
          _buildLoginButton(context), // 로그인 버튼

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
                style: TextStyle(color: Colors.white),
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
              style: TextStyle(color: Colors.white),
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

//  로그인 버튼
  Widget _buildLoginButton(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return InkWell(
      child: Container(
        width: screenWidth, // 원하는 너비 설정
        height: 50, // 원하는 높이 설정
        decoration: BoxDecoration(
          color: secondaryColor, // 버튼 배경색 설정
          borderRadius: BorderRadius.circular(5.0), // 원하는 모양 설정
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MainScreen(),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('로그인에 실패하였습니다. 이메일과 비밀번호를 다시 확인해주세요.'),
                ),
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
