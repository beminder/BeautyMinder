import 'package:admin/responsive.dart';
import 'package:admin/screens/dashboard/components/my_fields.dart';
import 'package:flutter/material.dart';

import '../../Service/api_service.dart';
import '../../constants.dart';
import '../main/components/header.dart';

import 'components/chart.dart';
import 'package:admin/Service/admin_Service.dart' as admin;

class DashboardScreen extends StatelessWidget {

  Future<admin.Result<double>> getUsageCPU() async {
    try {
      final result = await admin.adminService.getUsageCPU();
      print("usage: ${result.value}");
      return result; // 'admin.Result<double>' 타입으로 반환
    } catch (error) {
      print("Error: $error");
      // 에러 처리에 대한 적절한 Result 반환 필요
      return admin.Result.failure("Error occurred while fetching CPU usage.");
    }
  }

  Future<admin.Result<double>> getUsage1M() async {
    try {
      final result = await admin.adminService.getAverage1M();
      print("usage: ${result.value}");
      return result; // 'admin.Result<double>' 타입으로 반환
    } catch (error) {
      print("Error: $error");
      // 에러 처리에 대한 적절한 Result 반환 필요
      return admin.Result.failure("Error occurred while fetching CPU usage.");
    }
  }

  Future<admin.Result<double>> getUpTime() async {
    try {
      final result = await admin.adminService.getUpTime();
      return result; // 'admin.Result<double>' 타입으로 반환
    } catch (error) {
      return admin.Result.failure(
          "Error occurred while fetching server uptime.");
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      headTitle: "Dashboard",
                      userProfileResult:
                          userProfileResult, // Pass userProfileResult
                    );
                  }
                },
              ),
              // Header(headTitle: "Dashboard",),
              SizedBox(height: MediaQuery.of(context).size.height*0.05,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05, vertical: MediaQuery.of(context).size.height*0.05),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!Responsive.isMobile(context))
                      Expanded(
                        flex: 10,
                        child: FutureBuilder<admin.Result<double>>(
                          future: getUpTime(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError ||
                                !snapshot.hasData ||
                                snapshot.data!.value == null) {
                              return Text('No server uptime data available');
                            } else {
                              final upTimeInSeconds = snapshot.data!.value!;
                              final hours = upTimeInSeconds ~/ 3600;
                              final minutes = (upTimeInSeconds % 3600) ~/ 60;

                              return Container(
                                width: MediaQuery.of(context).size.width/4,
                                height: MediaQuery.of(context).size.height*0.7,
                                decoration: BoxDecoration(
                                  color: secondaryColor,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: Colors.white54),
                                ),
                                padding: EdgeInsets.all(defaultPadding),
                                child: Column(
                                  children: [
                                    SizedBox(height: 135),
                                    Text(
                                      "서버 가동 시간",
                                      style: TextStyle(fontSize: 24),
                                    ),
                                    SizedBox(height: 60),
                                  Text(
                                    "${hours}시간 ${minutes}분",
                                    style: TextStyle(fontSize: 30, color: Colors.white54),
                                  )
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    Expanded(
                      flex: 1,
                      child: SizedBox(height: MediaQuery.of(context).size.width*0.05,),
                    ),
                    if (!Responsive.isMobile(context))
                      Expanded(
                        flex: 10,
                        child: FutureBuilder<admin.Result<double>>(
                          future: getUsage1M(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (!snapshot.hasData ||
                                snapshot.data!.value == null) {
                              // 데이터가 없거나 value가 null일 경우
                              return Text('No CPU usage data available');
                            } else {
                              return Container(
                                width: MediaQuery.of(context).size.width/4,
                                height: MediaQuery.of(context).size.height*0.7,
                                decoration: BoxDecoration(
                                  color: secondaryColor,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: Colors.white54),
                                ),
                                padding: EdgeInsets.all(defaultPadding),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "서버 1분 가용량",
                                      style: TextStyle(fontSize: 24),
                                    ),
                                    SizedBox(height: 10),
                                    Chart(
                                      Usage: snapshot.data!.value!,
                                      color: Colors.red,
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    Expanded(
                      flex: 1,
                      child: SizedBox(height: MediaQuery.of(context).size.width*0.05,),
                    ),
                    if (!Responsive.isMobile(context))
                      Expanded(
                        flex: 10,
                        child: FutureBuilder<admin.Result<double>>(
                          future: getUsageCPU(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (!snapshot.hasData ||
                                snapshot.data!.value == null) {
                              // 데이터가 없거나 value가 null일 경우
                              return Text('No CPU usage data available');
                            } else {
                              return Container(
                                width: MediaQuery.of(context).size.width/4,
                                height: MediaQuery.of(context).size.height*0.7,
                                decoration: BoxDecoration(
                                  color: secondaryColor,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: Colors.white54),
                                ),
                                padding: EdgeInsets.all(defaultPadding),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "CPU 사용량",
                                      style: TextStyle(fontSize: 24),
                                    ),
                                    SizedBox(height: 10),
                                    Chart(
                                      Usage: snapshot.data!.value!,
                                      color: Color(0xFF2697FF),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}