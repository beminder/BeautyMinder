// import 'package:admin/Service/admin_Service.dart';
// import 'package:flutter/material.dart';
// import '../../Service/api_service.dart';
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
//   final _formKey = GlobalKey<FormState>(); // Key for the form
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
//                       headTitle: "Chat",
//                       userProfileResult: userProfileResult, // Pass userProfileResult
//                     );
//                   }
//                 },
//               ),
//               // Header(headTitle: "Chat"),
//               SizedBox(height: defaultPadding),
//               Center(
//                 child: Form(
//                   key: _formKey, // Assign the key to the form
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Container(
//                             width: MediaQuery.of(context).size.width / 3,
//                             child: TextFormField(
//                               controller: _nicknameController,
//                               decoration: InputDecoration(
//                                 hintText: "강제 퇴장시킬 사용자의 이메일을 입력하세요.",
//                                 enabledBorder: OutlineInputBorder(
//                                   borderSide: BorderSide(color: Colors.grey),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderSide: BorderSide(color: Colors.grey),
//                                 ),
//                               ),
//                               validator: (val) => val!.isEmpty
//                                   ? '필드가 비어있습니다. 강제 퇴장 시킬 사용자의 이메일을 입력하세요.'
//                                   : null,
//                             ),
//                           ),
//                           SizedBox(width: 20),
//                           ElevatedButton(
//                             onPressed: () async {
//                               // Validate the form before performing any action
//                               if (_formKey.currentState!.validate()) {
//                                 print("퇴장: ${_nicknameController.text}");
//                                 String kickoutUserNickname = _nicknameController.text;
//                                 try {
//                                   final response = await adminService.kickUser(kickoutUserNickname);
//                                   if (response.isSuccess) {
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       SnackBar(
//                                         content: Text('사용자(${kickoutUserNickname})를 강제 퇴장시키는 데 성공하였습니다.'),
//                                       ),
//                                     );
//                                   } else {
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       SnackBar(
//                                         content: Text('사용자(${kickoutUserNickname})를 강제 퇴장시키는 데 실패하였습니다. 입력하신 이메일을 다시 확인해주세요.'),
//                                       ),
//                                     );
//                                   }
//                                 } catch (e) {
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     SnackBar(
//                                       content: Text('서버가 원활하지 않습니다. 잠시 후 다시 시도해주세요.'),
//                                     ),
//                                   );
//                                 }
//
//                               }
//                             },
//                             child: Text("퇴장"),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: defaultPadding),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }