import 'package:admin/Service/admin_Service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class homePage extends StatefulWidget{
  const homePage({Key? key}) : super(key: key);

  @override
  _homePage createState() => _homePage();

}

class _homePage extends State<homePage>{
  int page = 0;

  @override
  Widget build(BuildContext context){
  return Scaffold(
    body: TextButton(onPressed: () {
      //adminService.kickUser('token@test');
      adminService.getAllReviews(page++);
    }, child: Text('kick'),),
  );
  }
}