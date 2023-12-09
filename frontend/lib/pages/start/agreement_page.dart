
import 'package:flutter/material.dart';

import '../../widget/appBar.dart';

class AgreementPage extends StatefulWidget {
  const AgreementPage({Key? key}) : super(key: key);

  @override
  _AgreementPageState createState() => _AgreementPageState();
}

class _AgreementPageState extends State<AgreementPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UsualAppBar(text: "BeautyMinder 이용약관 동의",),
      backgroundColor: Colors.white,
      body: Text('BeautyMinder 이용약관 동의'),
    );
  }
}
