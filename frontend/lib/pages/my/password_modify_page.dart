import 'package:beautyminder/pages/my/widgets/default_dialog.dart';
import 'package:beautyminder/pages/my/widgets/my_divider.dart';
import 'package:beautyminder/pages/my/widgets/my_page_header.dart';
import 'package:beautyminder/pages/my/widgets/pop_up.dart';
import 'package:beautyminder/services/api_service.dart';
import 'package:beautyminder/services/shared_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../dto/user_model.dart';
import '../../widget/commonAppBar.dart';

class PasswordModifyPage extends StatefulWidget {
  const PasswordModifyPage({super.key});

  @override
  State<PasswordModifyPage> createState() => _PasswordModifyPageState();
}

class _PasswordModifyPageState extends State<PasswordModifyPage> {
  User? user;
  bool isLoading = true;

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    getUserInfo();
  }

  Future<void> getUserInfo() async {
    try {
      final info = await SharedService.loginDetails();
      setState(() {
        user = info?.user;
        isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CommonAppBar(
          automaticallyImplyLeading: true,
          context: context,
        ),
        body: isLoading
            ? const SpinKitThreeInOut(
          color: Color(0xffd86a04),
          size: 50.0,
          duration: Duration(seconds: 2),
        )
            : Form(
          key: _formKey,
          child: Stack(
            children: [
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: SingleChildScrollView(
                    child: Column(children: [
                      const MyPageHeader('비밀번호 변경'),
                      const SizedBox(height: 20),
                      UserInfoProfile(
                        nickname: user!.nickname ?? user!.email,
                        profileImage: user!.profileImage ?? '',
                      ),
                      const SizedBox(height: 20),
                      const MyDivider(),
                      UserInfoEditItem(
                        title: '현재 비밀번호',
                        controller: _currentPasswordController,
                        // formKey: _formKey,
                      ),
                      UserInfoEditItem(
                        title: '변경할 비밀번호',
                        controller: _newPasswordController,
                        // formKey: _formKey,
                      ),
                      UserInfoEditItem(
                        title: '비밀번호 재확인',
                        controller: _confirmPasswordController,
                        // formKey: _formKey,
                      ),
                      const SizedBox(height: 150),
                    ]),
                  )),
              Positioned(
                bottom: 50, // 원하는 위치에 배치
                left: 10, // 원하는 위치에 배치
                right: 10, // 원하는 위치에 배치
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFFFFF),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  5.0), // 적절한 값을 선택하세요
                            ),
                            side: const BorderSide(
                                width: 1.0, color: Color(0xfffe9738)),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('취소',
                              style: TextStyle(
                                  color: Color(0xfffe9738), fontSize: 18)),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xfffe9738),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  5.0), // 적절한 값을 선택하세요
                            ),
                          ),
                          onPressed: _updatePassword,
                          child: const Text(
                            '수정',
                            style: TextStyle(
                                color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
    );
  }

  Future<void> _updatePassword() async {

    //텍스트 필드가 비워져 있을 떄
    if (!_formKey.currentState!.validate()) {
      return;
    }

    //새 비밀번호와 재확인 비밀번호가 일치하지 않을 때
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('비밀번호가 일치하지 않습니다. 비밀번호를 확인해주세요.'),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    //현재 비밀번호와 새 비밀번호가 같을 때
    if (_currentPasswordController.text == _newPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('현재 비밀번호와 동일합니다. 새로운 비밀번호를 입력해주세요.'),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    final ok = await popUp(
      title: '비밀번호를 수정하시겠습니까?',
      context: context,
    );
    if (ok) {
      final result = await APIService.updatePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      await _resultDialog(result.isSuccess);

      if (result.isSuccess) {
        _goBack();
      }
    }
  }

  Future<void> _resultDialog(bool isSuccess) async {
    isSuccess
        ? await showDialog(
      context: context,
      builder: (context) {
        return DefaultDialog(
          onBarrierTap: () => Navigator.pop(context),
          title: '비밀번호가 변경되었습니다',
          body: '이전 화면으로 이동합니다',
          buttons: [
            DefaultDialogButton(
              onTap: () => Navigator.pop(context),
              text: '확인',
              backgroundColor: const Color(0xfffe9738),
              textColor: Colors.white,
            )
          ],
        );
      },
    )
        : showDialog(
      context: context,
      builder: (context) {
        return DefaultDialog(
          onBarrierTap: () => Navigator.pop(context),
          title: '비밀번호 변경에 실패하였습니다',
          body: '현재 비밀번호를 확인해주세요',
          buttons: [
            DefaultDialogButton(
              onTap: () => Navigator.pop(context),
              text: '확인',
              backgroundColor: const Color(0xfffe9738),
              textColor: Colors.white,
            )
          ],
        );
      },
    );
  }

  void _goBack() {
    Navigator.pop(context);
  }
}

class UserInfoProfile extends StatelessWidget {
  final String nickname;
  final String? profileImage;
  final VoidCallback? onTap;

  const UserInfoProfile({
    Key? key,
    required this.nickname,
    required this.profileImage,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          profileImage == null
              ? const Icon(
            Icons.camera_alt,
            size: 50,
            color: Colors.grey,
          )
              : CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(profileImage!),
          ),
          const SizedBox(height: 10),
          Text(
            nickname,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class UserInfoEditItem extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  // final GlobalKey<FormState> formKey;

  const UserInfoEditItem(
      {super.key, required this.title, required this.controller});

  String? _validator(String? value) {
    if (value == null || value.isEmpty) {
      return '해당 항목이 입력되지 않았습니다.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, color: Color(0xFF868383)),
              textAlign: TextAlign.left,
            ),
          ),
          Flexible(
              child: TextFormField(
                controller: controller,
                validator: _validator,
                decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xfffe9738)),
                  ),
                ),
              )
          ),
        ],
      ),
    );
  }
}
