import 'package:flutter/material.dart';
import '../../constants.dart';
import '../dashboard/components/header.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _nicknameController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Key for the form

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
              Header(headTitle: "Chat"),
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
                                hintText: "강제 퇴장시킬 사용자의 닉네임을 입력하세요.",
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                              ),
                              validator: (val) => val!.isEmpty
                                  ? '필드가 비어있습니다. 강제 퇴장 시킬 사용자의 닉네임을 입력하세요.'
                                  : null,
                            ),
                          ),
                          SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: () {
                              // Validate the form before performing any action
                              if (_formKey.currentState!.validate()) {

                                print("퇴장: ${_nicknameController.text}");
                              }
                            },
                            child: Text("퇴장"),
                          ),
                        ],
                      ),
                      SizedBox(height: defaultPadding),
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
}


// import 'package:flutter/material.dart';
// import '../../constants.dart';
// import '../dashboard/components/header.dart';
//
// class ChatScreen extends StatefulWidget {
//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> {
//   TextEditingController _nicknameController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           primary: false,
//           padding: EdgeInsets.all(defaultPadding),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Header(headTitle: "Chat"),
//               SizedBox(height: defaultPadding),
//               Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Container(
//                           width: MediaQuery.of(context).size.width / 5,
//                           child: TextFormField(
//                             controller: _nicknameController,
//                             decoration: InputDecoration(
//                               hintText: "강제 퇴장시킬 사용자의 닉네임을 입력하세요.",
//                               enabledBorder: OutlineInputBorder(
//                                 borderSide: BorderSide(color: Colors.grey),
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 borderSide: BorderSide(color: Colors.grey),
//                               ),
//                             ),
//                             validator: (val) => val!.isEmpty
//                                 ? '필드가 비어있습니다. 강제 퇴장 시킬 사용자의 닉네임을 입력하세요.'
//                                 : null,
//                           ),
//                         ),
//                         SizedBox(width: 20),
//                         ElevatedButton(
//                           onPressed: () {
//                             // Validate the form before performing any action
//                             if (Form.of(context)!.validate()) {
//                               // Implement the action for the "퇴장" button
//                               // For now, let's print the entered nickname to the console
//                               print("퇴장: ${_nicknameController.text}");
//                             }
//                           },
//                           child: Text("퇴장"),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: defaultPadding),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

