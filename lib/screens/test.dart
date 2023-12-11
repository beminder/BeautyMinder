import 'package:beautyminder_dashboard/Service/admin_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class test extends StatelessWidget{

  // 별도의 비동기 함수를 만듭니다.
  Future<void> fetchAndPrint1M() async {
    try {
      final result = await AdminService.getAverage1M();
      print("usage: ${result.value}");
    } catch (error) {
      print("Error: $error");
    }
  }

  // 별도의 비동기 함수를 만듭니다.
  Future<void> fetchAndPrintupTime() async {
    try {
      final result = await AdminService.getUpTime();
      print("usage: ${result.value}");
    } catch (error) {
      print("Error: $error");
    }
  }

  // 별도의 비동기 함수를 만듭니다.
  Future<void> fetchAndPrintCpuUsage() async {
    try {
      final result = await AdminService.getUsageCPU();
      print("usage: ${result.value}");
    } catch (error) {
      print("Error: $error");
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: TextButton(onPressed: fetchAndPrint1M,
        child: Text("hello"),
      ),
    );
  }
}