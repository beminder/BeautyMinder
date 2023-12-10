import 'package:flutter/material.dart';

import '../../Service/api_service.dart';
import '../../constants.dart';
import '../../dto/user_model.dart';
import '../dashboard/components/header.dart';

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
                      userProfileResult: userProfileResult, // Pass userProfileResult
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
                  return Container(
                    width: MediaQuery.of(context).size.width/2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('아이디'),
                            Spacer(),
                            Text('${userProfileResult?.id}' ?? '정보 없음')
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('이메일'),
                            Spacer(),
                            Text('${userProfileResult?.email}' ?? '정보 없음')
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('닉네임'),
                            Spacer(),
                            Text('${userProfileResult?.nickname}' ?? '정보 없음')
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('전화번호'),
                            Spacer(),
                            Text('${userProfileResult?.phoneNumber}' ?? '정보 없음')
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('생성 시각'),
                            Spacer(),
                            Text('${userProfileResult?.createdAt}' ?? '정보 없음')
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
