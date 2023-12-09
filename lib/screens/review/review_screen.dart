import 'package:flutter/material.dart';

import '../../constants.dart';
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
              Header(headTitle: "Review",),
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
