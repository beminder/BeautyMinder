// import 'package:beautyminder/pages/baumann/baumann_history_page.dart';
//
// import 'package:beautyminder/pages/todo/todo_page.dart';
// import 'package:beautyminder/services/Cosmetic_Recommend_Service.dart';
// import 'package:beautyminder/services/keywordRank_service.dart';
// import 'package:beautyminder/widget/homepageAppBar.dart';
// import 'package:flutter/cupertino.dart';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:intl/intl.dart';
// import '../../dto/baumann_result_model.dart';
// import '../../dto/cosmetic_expiry_model.dart';
// import '../../dto/todo_model.dart';
// import '../../dto/user_model.dart';
// import '../../services/baumann_service.dart';
// import '../../services/expiry_service.dart';
// import '../../services/search_service.dart';
//
// import '../../services/todo_service.dart';
// import '../../widget/bottomNavigationBar.dart';
// import '../baumann/baumann_test_start_page.dart';
// import '../chat/chat_page.dart';
// import '../my/my_page.dart';
// import '../my/user_info_page.dart';
// import '../pouch/expiry_page.dart';
// import '../recommend/recommend_bloc_screen.dart';
// import '../search/search_page.dart';
//
// class HomePage extends StatefulWidget {
//   const HomePage({Key? key, required this.user}) : super(key: key);
//
//   // final dynamic responseData;
//   final User? user;
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   final int _currentIndex = 2;
//   bool isApiCallProcess = false;
//   bool isLoading = true;
//
//   List<CosmeticExpiry> expiries = [];
//   List recommends = [];
//   Todo? todayTodos;
//   List<BaumannResult> baumannresultList = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _getAllNeeds();
//   }
//
//   //필요한 서비스 호출
//   Future<void> _getAllNeeds() async {
//     // 이미 API 호출이 진행 중인지 확인
//     if (isApiCallProcess) {
//       return;
//     }
//     // API 호출 중임을 표시
//     setState(() {
//       isLoading = true;
//       isApiCallProcess = true;
//     });
//
//     try {
//       //유통기한
//       List<CosmeticExpiry> loadedExpiries = await ExpiryService.getAllExpiries();
//       for (var expiry in loadedExpiries) {
//         try {
//           // 예시: productName을 이용하여 관련 이미지 URL 검색
//           var cosmetic = await SearchService.searchCosmeticsByName(expiry.productName);
//           if (cosmetic.isNotEmpty) {
//             expiry.imageUrl = cosmetic.first.images.isNotEmpty
//                 ? cosmetic.first.images.first
//                 : null;
//           }
//           expiries = loadedExpiries;
//         } catch (e) {
//           print("Error loading image for ${expiry.productName}: $e");
//         }
//       }
//
//       //추천제품
//       final loadedRecommends = await CosmeticSearchService.getAllCosmetics();
//
//       //루틴
//       String todayFormatted = DateFormat('yyyy-MM-dd').format(DateTime.now());
//       final loadedTodos = await TodoService.getTodoOf();
//
//       //바우만
//       final loadedBaumannResult = await BaumannService.getBaumannHistory();
//
//       setState(() {
//         expiries = loadedExpiries ?? [];
//         recommends = loadedRecommends.value ?? [];
//         todayTodos = loadedTodos.value ?? null;
//         baumannresultList = loadedBaumannResult.value ?? [];
//       });
//
//     } catch (e) {
//       print('An error occurred while loading expiries: $e');
//     } finally {
//       setState(() {
//         isLoading = false;
//         isApiCallProcess = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     print("hihi this is homePage : ${widget.user?.baumann}");
//     return Scaffold(
//       appBar: HomepageAppBar(actions: <Widget>[
//         IconButton(
//           icon: Icon(Icons.search),
//           onPressed: () async {
//             // 이미 API 호출이 진행 중인지 확인
//             if (isApiCallProcess) {
//               return;
//             }
//             // API 호출 중임을 표시
//             setState(() {
//               isApiCallProcess = true;
//             });
//             try {
//               final result = await KeywordRankService.getKeywordRank();
//               final result2 = await KeywordRankService.getProductRank();
//
//               if (result.isSuccess) {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => SearchPage(
//                       data: result.value!,
//                       data2: result2.value!,
//                     ),
//                   ),
//                 );
//               } else {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => SearchPage(
//                       data: null,
//                       data2: null,
//                     ),
//                   ),
//                 );
//               }
//             } catch (e) {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => SearchPage(data: null, data2: null),
//                 ),
//               );
//             } finally {
//               // API 호출 상태를 초기화합니다.
//               setState(() {
//                 isApiCallProcess = false;
//               });
//             }
//           },
//         ),
//       ]),
//       body: Center(
//         child: isApiCallProcess || isLoading
//             ? SpinKitThreeInOut(
//           color: Color(0xffd86a04),
//           size: 50.0,
//           duration: Duration(seconds: 2),
//         )
//             : SingleChildScrollView(
//           child: _homePageUI(),
//         ),
//       ),
//       bottomNavigationBar: _underNavigation(),
//     );
//   }
//
//   Widget _homePageUI() {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 25, vertical: 30),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: <Widget>[
//           _invalidProductBtn(),
//           SizedBox(
//             height: 20,
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: <Widget>[
//               _recommendProductBtn(),
//               Spacer(),
//               Column(
//                 // mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: <Widget>[
//                   _personalSkinTypeBtn(),
//                   SizedBox(
//                     height: 25,
//                   ),
//                   _chatBtn(),
//                 ],
//               )
//             ],
//           ),
//           SizedBox(
//             height: 20,
//           ),
//           _routineBtn(),
//         ],
//       ),
//     );
//   }
//
//
//   //유통기한
//   Widget _invalidProductBtn() {
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     return ElevatedButton(
//       onPressed: () {
//         if (isApiCallProcess) {
//           return;
//         }
//         setState(() {
//           isApiCallProcess = true;
//         });
//         try {
//           Navigator.of(context).push(
//               MaterialPageRoute(builder: (context) => CosmeticExpiryPage()));
//         } catch (e) {
//           print('An error occurred: $e');
//         }
//         finally {
//           setState(() {
//             isApiCallProcess = false;
//           });
//         }
//       },
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Color(0xffffb876),
//         foregroundColor: Colors.white,
//         elevation: 0,
//         minimumSize: Size(screenWidth, 200.0),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10.0), // 모서리를 더 둥글게 설정
//         ),
//       ),
//       child: Align(
//           alignment: Alignment.topLeft,
//           child: Center(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       "유통기한 임박 화장품 ",
//                       style: TextStyle(
//                         // fontWeight: FontWeight.bold,
//                         fontSize: 18,
//                       ),
//                     ),
//                     Icon(
//                       Icons.arrow_forward_ios,
//                       size: 15,
//                     ),
//                   ],
//                 ),
//                 _selectExpiryScreen(),
//               ],
//             ),
//           )
//       ),
//     );
//   }
//
//   Widget _selectExpiryScreen() {
//     if (!isApiCallProcess && !isLoading) {
//       if (expiries != null && expiries.isNotEmpty && expiries.length != 0) {
//         return _buildExpiryInfo();
//       } else {
//         return _buildDefaultText();
//       }
//     } else {
//       return SpinKitCircle(color: Colors.white, duration: Duration(seconds: 3),);
//     }
//   }
//
//   Widget _buildExpiryInfo() {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: expiries.take(10).map((expiry) {
//           DateTime now = DateTime.now();
//           DateTime expiryDate = expiry.expiryDate ?? DateTime.now();
//           Duration difference = expiryDate.difference(now);
//           bool isDatePassed = difference.isNegative;
//           // Customize this part according to your expiry model
//           return Container(
//             margin: EdgeInsets.all(8.0),
//             child: Column(
//               children: [
//                 SizedBox(
//                   height: 10,
//                 ),
//                 Container(
//                     width: 95,
//                     height: 95,
//                     decoration: BoxDecoration(
//                       color: Colors.grey, // 네모 박스의 색상
//                       borderRadius: BorderRadius.circular(8.0),
//                     ),
//                     child: (expiry.imageUrl != null)
//                         ? Image.network(
//                       expiry.imageUrl!,
//                       width: 10,
//                       height: 10,
//                       fit: BoxFit.cover,
//                     )
//                         : Image.asset(
//                       'assets/images/noImg.jpg',
//                       fit: BoxFit.cover,
//                     ) // 이미지가 없는 경우
//                 ),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 // Display D-day or any other information here
//                 Text(
//                   isDatePassed
//                       ? 'D+${difference.inDays.abs()}'
//                       : 'D-${difference.inDays+1}',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
//
//   Widget _buildDefaultText() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           SizedBox(height: 5),
//           Container(
//             height: 130,
//             alignment: Alignment.center,
//             child: Text(
//               "등록된 화장품이 없습니다.\n화장품 등록하기",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               textAlign: TextAlign.center,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//
//
//   //추천 버튼
//   Widget _recommendProductBtn() {
//     final screenWidth = MediaQuery.of(context).size.width / 2 - 40;
//
//     return ElevatedButton(
//       onPressed: () {
//         Navigator.of(context)
//             .push(MaterialPageRoute(builder: (context) => const RecPage()));
//       },
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Color(0xffffecda),
//         foregroundColor: Color(0xffff820e),
//         elevation: 0,
//         minimumSize: Size(screenWidth, 200.0),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10.0), // 모서리를 더 둥글게 설정
//         ),
//       ),
//       child: Align(
//           alignment: Alignment.topLeft,
//           child: Center(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       "추천 제품 ",
//                       style: TextStyle(
//                         // fontWeight: FontWeight.bold,
//                         fontSize: 18,
//                       ),
//                     ),
//                     Icon(
//                       Icons.arrow_forward_ios,
//                       size: 15,
//                     ),
//                   ],
//                 ),
//                 SizedBox(
//                   height: 15,
//                 ),
//                 _selectRecommendScreen(),
//               ],
//             ),
//           )
//       ),
//     );
//   }
//
//   Widget _selectRecommendScreen() {
//     if (!isApiCallProcess && !isLoading) {
//       if (recommends != null && recommends.isNotEmpty && recommends.length != 0) {
//         return _buildRecommendText();
//       } else {
//         return _buildRecommendDefaultText();
//       }
//     } else {
//       return SpinKitCircle(color: Colors.white, duration: Duration(seconds: 3),);
//     }
//   }
//
//   Widget _buildRecommendText() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: recommends.take(1).map((item) {
//         return Container(
//           // margin: EdgeInsets.all(8.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               CircleAvatar(
//                 radius: 50, // Adjust the radius as needed
//                 backgroundColor: Colors.grey,
//                 backgroundImage: (item.images[0] != null)
//                     ? NetworkImage(item.images[0])
//                     : AssetImage('assets/images/noImg.jpg') as ImageProvider,
//               ),
//               SizedBox(height: 10),
//               Container(
//                 alignment: Alignment.center,
//                 width: MediaQuery.of(context).size.width / 2 - 100,
//                 child: Text(
//                   item.name,
//                   style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
//                   overflow: TextOverflow.ellipsis,
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             ],
//           ),
//         );
//       }).toList(),
//     );
//   }
//
//   Widget _buildRecommendDefaultText() {
//     return Center(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           SizedBox(height: 5),
//           Text(
//             "피부 타입 테스트를\n진행해주세요.",
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
//
//
//   //피부타입 버튼
//   Widget _personalSkinTypeBtn() {
//     final screenWidth = MediaQuery.of(context).size.width / 2 - 30;
//
//     return ElevatedButton(
//       onPressed: () {
//         if (baumannresultList.isNotEmpty) {
//           Navigator.of(context).push(MaterialPageRoute(
//               builder: (context) =>
//                   BaumannHistoryPage(resultData: baumannresultList)));
//         } else {
//           Navigator.of(context).push(
//               MaterialPageRoute(builder: (context) => BaumannStartPage()));
//         }
//       },
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Color(0xfffe9738),
//         foregroundColor: Colors.white,
//         elevation: 0,
//         minimumSize: Size(screenWidth, 90.0),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10.0), // 모서리를 더 둥글게 설정
//         ),
//       ),
//       child: Align(
//         alignment: Alignment.topLeft,
//         child: Center(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     "내 피부 타입 ",
//                     style: TextStyle(
//                       // fontWeight: FontWeight.bold,
//                       fontSize: 18,
//                     ),
//                   ),
//                   Icon(
//                     Icons.arrow_forward_ios,
//                     size: 15,
//                   ),
//                 ],
//               ),
//               SizedBox(height: 5),
//               Text((baumannresultList.isEmpty) ? "테스트하기":"${baumannresultList.last.baumannType}",
//                   style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   //소통방 버튼
//   Widget _chatBtn() {
//     final screenWidth = MediaQuery.of(context).size.width / 2 - 30;
//
//     return ElevatedButton(
//       onPressed: () {
//         Navigator.of(context)
//             .push(MaterialPageRoute(builder: (context) => ChatPage()));
//       },
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Color(0xffffd1a6),
//         foregroundColor: Color(0xffd86a04),
//         elevation: 0,
//         minimumSize: Size(screenWidth, 90.0),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10.0), // 모서리를 더 둥글게 설정
//         ),
//       ),
//       child: Align(
//         alignment: Alignment.topLeft,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               "소통방 가기 ",
//               style: TextStyle(
//                 // fontWeight: FontWeight.bold,
//                 fontSize: 18,
//               ),
//             ),
//             Icon(
//               Icons.arrow_forward_ios,
//               size: 15,
//               // Add any other styling properties as needed
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//
//   //오늘의 루틴 버튼
//   Widget _routineBtn() {
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     return ElevatedButton(
//       onPressed: () {
//         Navigator.of(context)
//             .push(MaterialPageRoute(builder: (context) => CalendarPage()));
//       },
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Color(0xffe7e4e1),
//         foregroundColor: Color(0xffff820e),
//         elevation: 0,
//         minimumSize: Size(screenWidth, 200.0),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10.0), // 모서리를 더 둥글게 설정
//         ),
//       ),
//       child: Align(
//           alignment: Alignment.topLeft,
//           child: Center(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       "오늘의 루틴 확인하기 ",
//                       style: TextStyle(
//                         // fontWeight: FontWeight.bold,
//                         fontSize: 18,
//                       ),
//                     ),
//                     Icon(
//                       Icons.arrow_forward_ios,
//                       size: 15,
//                     ),
//                   ],
//                 ),
//                 _selectTodocreen(),
//               ],
//             ),
//           )
//       ),
//     );
//   }
//
//   Widget _selectTodocreen() {
//     if (!isApiCallProcess && !isLoading) {
//       if (todayTodos != null && todayTodos?.tasks != null && todayTodos!.tasks.isNotEmpty && todayTodos!.tasks.length != 0) {
//         return _buildTodoText();
//       } else {
//         return _buildTodoDefaultText();
//       }
//     } else {
//       return SpinKitCircle(color: Colors.white, duration: Duration(seconds: 3),);
//     }
//   }
//
//   Widget _buildTodoText() {
//     print("hello this is 2: ${todayTodos}");
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Container(
//           height: 120,
//           margin: EdgeInsets.all(8.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center, // 세로축을 기준으로 중앙 정렬
//             children: [
//               Container(
//                 width: MediaQuery.of(context).size.width / 2 - 50,
//                 child: todayTodos != null && todayTodos!.tasks.isNotEmpty
//                     ? Column(
//                   children: todayTodos!.tasks
//                       .take(3)
//                       .map((task) => Column(
//                     children: [
//                       Text(
//                         task.description,
//                         style: TextStyle(
//                             color: Colors.black, fontSize: 18),
//                       ),
//                       SizedBox(height: 10)
//                     ],
//                   ))
//                       .toList(),
//                 )
//                     : _buildTodoDefaultText(),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//
//   Widget _buildTodoDefaultText() {
//     return Center(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           SizedBox(height: 5),
//           Container(
//             height: 130,
//             alignment: Alignment.center,
//             child: Text(
//               "등록된 루틴이 없습니다.\n화장품 사용 루틴 등록하기",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
//               textAlign: TextAlign.center,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _underNavigation() {
//     return CommonBottomNavigationBar(
//         currentIndex: _currentIndex,
//         onTap: (int index) {
//           // 페이지 전환 로직 추가
//           if (index == 0) {
//             Navigator.of(context)
//                 .push(MaterialPageRoute(builder: (context) => const RecPage()));
//           } else if (index == 1) {
//             Navigator.of(context).push(
//                 MaterialPageRoute(builder: (context) => CosmeticExpiryPage()));
//
//           } else if (index == 3) {
//             Navigator.of(context).push(
//                 MaterialPageRoute(builder: (context) => const CalendarPage()));
//           } else if (index == 4) {
//             Navigator.of(context)
//                 .push(MaterialPageRoute(builder: (context) => const MyPage()));
//           }
//         });
//   }
// }
