import 'package:flutter/material.dart';

import '../../Service/api_service.dart';
import '../../constants.dart';
import '../../dto/user_model.dart';
import '../main/components/header.dart';
import '../start/splash_screen.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // return Text('Chat Page');
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          primary: false,
          padding: EdgeInsets.all(defaultPadding),
          child: Column(
            children: [
              FutureBuilder(
                future: APIService.getUserProfile(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final userProfileResult = snapshot.data;
                    return Header(
                      headTitle: "Profile",
                      userProfileResult:
                          userProfileResult, // Pass userProfileResult
                    );
                  }
                },
              ),
              // Header(headTitle: "Profile"),
              SizedBox(height: defaultPadding),
              FutureBuilder<Result<User>>(
                future: APIService.getUserProfile(),
                builder: (context, snapshot) {
                  final userProfileResult = snapshot.data?.value;
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 1.5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(
                                userProfileResult?.profileImage ?? ''),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '아이디',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Spacer(),
                              Text(
                                '${userProfileResult?.id}' ?? '정보 없음',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          Spacer(),
                          Divider(
                            color: Colors.white,
                            thickness: 0.5,
                            endIndent: 5,
                          ),
                          Spacer(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '이메일',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Spacer(),
                              Text(
                                '${userProfileResult?.email}' ?? '정보 없음',
                                style: Theme.of(context).textTheme.titleMedium,
                              )
                            ],
                          ),
                          Spacer(),
                          Divider(
                            color: Colors.white,
                            thickness: 0.5,
                            endIndent: 5,
                          ),
                          Spacer(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '닉네임',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Spacer(),
                              Text(
                                '${userProfileResult?.nickname}' ?? '정보 없음',
                                style: Theme.of(context).textTheme.titleMedium,
                              )
                            ],
                          ),
                          Spacer(),
                          Divider(
                            color: Colors.white,
                            thickness: 0.5,
                            endIndent: 5,
                          ),
                          Spacer(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '전화번호',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Spacer(),
                              Text(
                                '${userProfileResult?.phoneNumber}' ?? '정보 없음',
                                style: Theme.of(context).textTheme.titleMedium,
                              )
                            ],
                          ),
                          Spacer(),
                          Divider(
                            color: Colors.white,
                            thickness: 0.5,
                            endIndent: 5,
                          ),
                          Spacer(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '생성 시각',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Spacer(),
                              Text(
                                '${userProfileResult?.createdAt}' ?? '정보 없음',
                                style: Theme.of(context).textTheme.titleMedium,
                              )
                            ],
                          ),
                          Spacer(),
                          Divider(
                            color: Colors.white,
                            thickness: 0.5,
                            endIndent: 5,
                          ),
                          Spacer(),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: InkWell(
                  onTap: () async {
                    try {
                      final logoutResponse = await APIService.logout();
                      if (logoutResponse.isSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('로그아웃에 성공하였습니다.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SplashScreen()),
                        );
                      } else {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('로그아웃에 실패하였습니다.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    } catch (e) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('오류가 발생했습니다. 잠시 후 다시 시도해주세요.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(vertical: 13),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        color: secondaryColor),
                    child: Text(
                      '로그아웃',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
