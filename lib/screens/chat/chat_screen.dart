import 'dart:convert';

import 'package:beautyminder_dashboard/Service/admin_service.dart';
import 'package:flutter/material.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

import '../../Service/api_service.dart';
import '../../Service/shared_service.dart';
import '../../config.dart';
import '../../constants.dart';
import '../main/components/header.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _nicknameController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Key for the form

  final String _url = Uri.https(Config.apiURL, Config.webSocket).toString();
  late StompClient stompClient;

  bool isApiCallProcess = false;
  bool isLoading = true;

  late String? accessToken;
  late String? refreshToken;

  List<String> userList = [];

  Future<void> _getTokens() async {
    if (isApiCallProcess) {
      return;
    }

    setState(() {
      isLoading = true;
      isApiCallProcess = true;
    });

    try {
      final loadedAccessToken = await SharedService.getAccessToken();
      final loadedRefreshToken = await SharedService.getRefreshToken();

      setState(() {
        accessToken = loadedAccessToken;
        refreshToken = loadedRefreshToken;
      });
    } catch (e) {
      print('An error occurred : $e');
    } finally {
      setState(() {
        isLoading = false;
        isApiCallProcess = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getTokens().then((_) {
      stompClient = StompClient(
        config: StompConfig.sockJS(
          url: _url,
          onConnect: onConnect,
          beforeConnect: () async {
            print('waiting to connect...');
            await Future.delayed(const Duration(milliseconds: 200));
            print('connecting...');
          },
          onDebugMessage: (dynamic error) => {print('$error')},
          onWebSocketError: (dynamic error) => {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('웹소켓 연결에 실패 했습니다. 다시 시도 해주세요.'),
              ),
            )
          },
          stompConnectHeaders: {'access-token': '$accessToken'},
          webSocketConnectHeaders: {'access-token': '$accessToken'},
        ),
      );
      stompClient.activate();
    });
  }

  void onConnect(StompFrame frame) {
    // Subscribe to get the current and updated list of users
    stompClient.subscribe(
      destination: Config.webSocketUserList,
      callback: (frame) {
        List<String> currentUsers = List<String>.from(json.decode(frame.body!));

        setState(() {
          userList = currentUsers;
        });
      },
    );
  }

  Future<void> kickUser(String kickoutUserNickname) async {
    try {
      final response = await AdminService.kickUser(kickoutUserNickname);
      if (response.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('사용자 ($kickoutUserNickname)를 강제 퇴장시키는 데 성공하였습니다.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '사용자 ($kickoutUserNickname)를 강제 퇴장시키는 데 실패하였습니다. 입력하신 이메일을 다시 확인해주세요.'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('서버가 원활하지 않습니다. 잠시 후 다시 시도해주세요.'),
        ),
      );
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
            mainAxisAlignment: MainAxisAlignment.center,
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
                      userProfileResult:
                          userProfileResult, // Pass userProfileResult
                    );
                  }
                },
              ),
              // Header(headTitle: "Chat"),
              SizedBox(height: defaultPadding),
              Center(
                child: Form(
                  key: _formKey, // Assign the key to the form
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width / 3,
                            child: TextFormField(
                              controller: _nicknameController,
                              decoration: InputDecoration(
                                hintText: "강제 퇴장시킬 사용자의 이메일을 입력하세요.",
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                              ),
                              validator: (val) => val!.isEmpty
                                  ? '필드가 비어있습니다. 강제 퇴장 시킬 사용자의 이메일을 입력하세요.'
                                  : null,
                            ),
                          ),
                          SizedBox(width: 20),
                          ElevatedButton(
                              onPressed: () async {
                                // Validate the form before performing any action
                                if (_formKey.currentState!.validate()) {
                                  print("퇴장: ${_nicknameController.text}");
                                  String kickoutUserNickname =
                                      _nicknameController.text;
                                  kickUser(kickoutUserNickname);
                                }
                              },
                              child: Text("퇴장"),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: secondaryColor)),
                        ],
                      ),
                      SizedBox(height: defaultPadding),
                      Divider(),
                      // Text("실시간 채팅방 유저 리스트", style: TextStyle(color: Colors.white54),),
                      Container(
                        // height: MediaQuery.of(context).size.height*0.5,
                        height: 500,
                        child: Expanded(
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
  }
}
