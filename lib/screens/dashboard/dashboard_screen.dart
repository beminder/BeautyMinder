import 'package:admin/responsive.dart';
import 'package:admin/screens/dashboard/components/my_fields.dart';
import 'package:flutter/material.dart';

import '../../Service/api_service.dart';
import '../../constants.dart';
import '../main/components/header.dart';

import 'components/chart.dart';
import 'components/recent_files.dart';
import 'components/storage_details.dart';
import 'package:admin/Service/admin_Service.dart' as admin;

class DashboardScreen extends StatelessWidget {
  // Future<double?> getUsageCPU() async {
  //   try {
  //     final result = await admin.adminService.getUsageCPU();
  //     print("usage: ${result.value}");
  //     return result.value;
  //   } catch (error) {
  //     print("Error: $error");
  //   }
  // }

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
              SizedBox(height: defaultPadding),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        // MyFiles(),
                        //  SizedBox(height: defaultPadding),
                        FutureBuilder<admin.Result<double>>(
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
                              final uptimeHours = snapshot.data!.value!;
                              return Column(
                                children: [
                                  Text("서버 가동 시간",
                                      style: TextStyle(fontSize: 40)),
                                  SizedBox(height:100),

                                  Text(
                                    "${uptimeHours.toStringAsFixed(2)} hours",
                                    style: TextStyle(fontSize: 50, color: Colors.grey),
                                  )
                                ],
                              );
                            }
                          },
                        ),
                        //RecentFiles(),
                      ],
                    ),
                  ),
                  if (!Responsive.isMobile(context))
                    Expanded(
                      flex: 4,
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
                            // value가 null이 아닌 경우
                            return Column(
                              children: [
                                Text(
                                  "서버 1분 가용량",
                                  style: TextStyle(fontSize: 40),
                                ),
                                SizedBox(height: 50),
                                Chart(
                                  Usage: snapshot.data!.value!,
                                  color: Colors.red,
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ),
                  if (!Responsive.isMobile(context))
                    SizedBox(width: defaultPadding),
                  // On Mobile means if the screen is less than 850 we don't want to show it
                  if (!Responsive.isMobile(context))
                    Expanded(
                      flex: 4,
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
                            // value가 null이 아닌 경우
                            return Column(
                              children: [
                                Text(
                                  "CPU 사용량",
                                  style: TextStyle(fontSize: 40),
                                ),
                                SizedBox(height: 50),
                                Chart(
                                  Usage: snapshot.data!.value!,
                                  color: Color(0xFF2697FF),
                                ),
                              ],
                            );
                          }
                        },
                      ),
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
