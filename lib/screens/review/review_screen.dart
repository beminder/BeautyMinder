import 'package:flutter/material.dart';

import '../../Service/api_service.dart';
import '../../constants.dart';
import '../../dto/user_model.dart';
import '../dashboard/components/header.dart';

class ReviewScreen extends StatelessWidget {
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
                  print("&&&& : ${snapshot}");
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final userProfileResult = snapshot.data;
                    print("&&&&0 : $userProfileResult");
                    return Header(
                      headTitle: "Review",
                      userProfileResult: userProfileResult, // Pass userProfileResult
                    );
                  }
                },
              ),
              // Header(headTitle: "Review",),
              SizedBox(height: defaultPadding),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Text('Review Page'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
