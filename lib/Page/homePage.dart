import 'package:admin/Service/admin_Service.dart';
import 'package:admin/models/review_response_model.dart';
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
    body: TextButton(onPressed: () async{
      //adminService.kickUser('token@test');
      // List<ReviewPageResponse> result =
       final result = await adminService.getAllReviews(page++);
      //final result = await adminService.getFilteredReviews();
       //final  result = await adminService.updateReviewStatus('654356e19e8ae29a336ccced', 'approved');
      print("result.value : ${result.value?[0].toString()}");
      //print("result : ${result}");
    }, child: Text('kick'),),
  );
  }
}