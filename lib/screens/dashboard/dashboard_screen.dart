import 'package:beautyminder_dashboard/Service/admin_service.dart' as admin;
import 'package:beautyminder_dashboard/responsive.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../service/api_service.dart';
import '../main/components/header.dart';
import 'components/chart.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Stream<admin.Result<double>> cpuUsageStream;
  late Stream<admin.Result<double>> usage1MStream;
  late Stream<admin.Result<double>> upTimeStream;

  @override
  void initState() {
    super.initState();
    cpuUsageStream = Stream.periodic(Duration(seconds: 5)).asyncMap((_) async {
      return await getUsageCPU();
    });

    usage1MStream = Stream.periodic(Duration(seconds: 5)).asyncMap((_) async {
      return await getUsage1M();
    });

    // 1초마다 안함, 서버 건강 생각해서
    upTimeStream = Stream.periodic(Duration(seconds: 5)).asyncMap((_) async {
      return await getUpTime();
    });
  }

  @override
  void dispose() {
    super.dispose();
    // If you are using a StreamController, remember to close it here
  }

  Future<admin.Result<double>> getUsageCPU() async {
    try {
      final result = await admin.AdminService.getUsageCPU();
      return result; // 'admin.Result<double>' 타입으로 반환
    } catch (error) {
      print("Error: $error");
      // 에러 처리에 대한 적절한 Result 반환 필요
      return admin.Result.failure("Error occurred while fetching CPU usage.");
    }
  }

  Future<admin.Result<double>> getUsage1M() async {
    try {
      final result = await admin.AdminService.getAverage1M();
      return result; // 'admin.Result<double>' 타입으로 반환
    } catch (error) {
      print("Error: $error");
      // 에러 처리에 대한 적절한 Result 반환 필요
      return admin.Result.failure("Error occurred while fetching CPU usage.");
    }
  }

  Future<admin.Result<double>> getUpTime() async {
    try {
      final result = await admin.AdminService.getUpTime();
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
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.05,
                    vertical: MediaQuery.of(context).size.height * 0.05),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!Responsive.isMobile(context))
                      Expanded(
                        flex: 10,
                        child: StreamBuilder<admin.Result<double>>(
                          stream: upTimeStream,
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
                              final seconds = (upTimeInSeconds % 60).toInt();

                              return ServerRunningTimeWidget(
                                  hours: hours,
                                  minutes: minutes,
                                  seconds: seconds);
                            }
                          },
                        ),
                      ),
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: MediaQuery.of(context).size.width * 0.05,
                      ),
                    ),
                    if (!Responsive.isMobile(context))
                      Expanded(
                        flex: 10,
                        child: StreamBuilder<admin.Result<double>>(
                          stream: usage1MStream,
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
                              return Server1MCapWidget(snapshot);
                            }
                          },
                        ),
                      ),
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: MediaQuery.of(context).size.width * 0.05,
                      ),
                    ),
                    if (!Responsive.isMobile(context))
                      Expanded(
                        flex: 10,
                        child: StreamBuilder<admin.Result<double>>(
                          stream: cpuUsageStream,
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
                              return CpuUsageWidget(snapshot);
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

class ServerRunningTimeWidget extends StatelessWidget {
  const ServerRunningTimeWidget({
    super.key,
    required this.hours,
    required this.minutes,
    required this.seconds,
  });

  final int hours;
  final int minutes;
  final int seconds;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 4,
      height: MediaQuery.of(context).size.height * 0.7,
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
            "$hours시간 $minutes분 $seconds초",
            style: TextStyle(fontSize: 30, color: Colors.white54),
          )
        ],
      ),
    );
  }
}

class Server1MCapWidget extends StatelessWidget {
  final AsyncSnapshot<admin.Result<double>> snapshot;

  const Server1MCapWidget(this.snapshot, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 4,
      height: MediaQuery.of(context).size.height * 0.7,
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
            usage: snapshot.data!.value!,
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}

class CpuUsageWidget extends StatelessWidget {
  final AsyncSnapshot<admin.Result<double>> snapshot;

  const CpuUsageWidget(this.snapshot, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 4,
      height: MediaQuery.of(context).size.height * 0.7,
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
            usage: snapshot.data!.value!,
            color: Color(0xFF2697FF),
          ),
        ],
      ),
    );
  }
}
