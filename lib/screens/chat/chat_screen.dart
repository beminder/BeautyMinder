import 'dart:async';
import 'dart:convert';

import 'package:admin/constants.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

import '../../Service/api_service.dart';
import '../../Service/dio_client.dart';
import '../../config.dart';
import '../dashboard/components/header.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // final String _url = '/ws/chat';

  final String _url = 'http://ec2-43-202-92-163.ap-northeast-2.compute.amazonaws.com:8080/ws/chat';
  late StompClient stompClient;

  List<String> userList = [];

  @override
  void initState() {
    super.initState();
    print("ˆˆ1");
    stompClient = StompClient(
      config: StompConfig.sockJS(
        url: _url,
        onConnect: onConnect,
        beforeConnect: () async {
          print('waiting to connect...');
          await Future.delayed(const Duration(milliseconds: 200));
          print('connecting...');
        },
        onDebugMessage: (dynamic error) => {
          print('$error')
        },
        onWebSocketError: (dynamic error) =>
        {
          Fluttertoast.showToast(
            msg: "웹소켓 연결에 실패했습니다. 다시 시도해주세요. $error",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
          )
        },
        stompConnectHeaders: {
          'access-token':
          'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJiZWF1dHltaW5kZXIiLCJpYXQiOjE3MDIxODI5ODgsImV4cCI6MTcwMjI2OTM4OCwic3ViIjoiYmVtaW5kZXJAYWRtaW4iLCJpZCI6IjY1NzNmZWJjNWJkOWJjMWZkNDRkZGE5YiJ9.h-tZY13HhSTOFMSXqtuI86MmBBrBlZBZm8SA-YskmXk'
        },
        webSocketConnectHeaders: {
          'access-token':
          'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJiZWF1dHltaW5kZXIiLCJpYXQiOjE3MDIxODI5ODgsImV4cCI6MTcwMjI2OTM4OCwic3ViIjoiYmVtaW5kZXJAYWRtaW4iLCJpZCI6IjY1NzNmZWJjNWJkOWJjMWZkNDRkZGE5YiJ9.h-tZY13HhSTOFMSXqtuI86MmBBrBlZBZm8SA-YskmXk'
        },
      ),
    );
    stompClient.activate();
    print("ˆˆ2");
  }

  void onConnect(StompFrame frame) {
    print("ˆˆ3");
    // Subscribe to get the current and updated list of users
    stompClient.subscribe(
      destination: '/topic/room/currentUsers',
      callback: (frame)
      {
        List<String> currentUsers = List<String>.from(json.decode(frame.body!));

        setState(() {
          userList = currentUsers;
        });
      },);
  }

  Future<void> kickUser(String username) async {
    // final accessToken = await SharedService.getAccessToken();
    // final refreshToken = await SharedService.getRefreshToken();
    print("ˆˆ4");

    final headers = {
      'Authorization': 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJiZWF1dHltaW5kZXIiLCJpYXQiOjE3MDIxODI5ODgsImV4cCI6MTcwMjI2OTM4OCwic3ViIjoiYmVtaW5kZXJAYWRtaW4iLCJpZCI6IjY1NzNmZWJjNWJkOWJjMWZkNDRkZGE5YiJ9.h-tZY13HhSTOFMSXqtuI86MmBBrBlZBZm8SA-YskmXk'
    };

    final url = Uri.http(Config.apiURL, Config.kickUserAPI).toString();
    try {
      final response = await DioClient.sendRequest(
          'POST', url, body: {"username": username}, headers: headers);

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "User $username kicked successfully");
        print("ˆˆ5");
      } else {
        print("ˆˆ6");
        Fluttertoast.showToast(msg: "Failed to kick user $username");
      }
    } catch (e) {
      print("ˆˆ7");
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

// Timer.periodic(const Duration(seconds: 10), (_) {
  //   stompClient.send(
  //     destination: '/app/test/endpoints',
  //     body: json.encode({'a': 123}),
  //   );
  // });

  // @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //     home: Scaffold(
  //       backgroundColor: bgColor,
  //       body: SafeArea(
  //         child: SingleChildScrollView(
  //           primary: false,
  //           padding: EdgeInsets.all(defaultPadding),
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               FutureBuilder(
  //                 future: APIService.getUserProfile(),
  //                 builder: (context, snapshot) {
  //                   if (snapshot.connectionState == ConnectionState.waiting) {
  //                     return CircularProgressIndicator();
  //                   } else if (snapshot.hasError) {
  //                     return Text('Error: ${snapshot.error}');
  //                   } else {
  //                     final userProfileResult = snapshot.data;
  //                     return Header(
  //                       headTitle: 'Chat',
  //                       userProfileResult: userProfileResult, // Pass userProfileResult
  //                     );
  //                   }
  //                 },
  //               ),
  //               // ListView.builder(
  //               //   itemCount: userList.length,
  //               //   itemBuilder: (context, index) {
  //               //     return ListTile(
  //               //       title: Text(userList[index]),
  //               //       onTap: () => kickUser(userList[index]),
  //               //     );
  //               //   },
  //               // ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

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
                      headTitle: "Chat",
                      userProfileResult: userProfileResult, // Pass userProfileResult
                    );
                  }
                },
              ),
              // Header(headTitle: "Review",),
              SizedBox(height: defaultPadding),
              Container(
                height: 500,
                child:
                  Expanded(
                    flex: 5,
                    child: ListView.builder(
                      itemCount: userList.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(userList[index]),
                          onTap: () => kickUser(userList[index]),
                        );
                      },
                    ),
                  ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    stompClient.deactivate();
    super.dispose();
    print("ˆˆ9");
  }
}