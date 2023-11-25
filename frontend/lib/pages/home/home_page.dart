import 'package:beautyminder/dto/keywordRank_model.dart';
import 'package:beautyminder/globalVariable/globals.dart';
import 'package:beautyminder/pages/baumann/baumann_history_page.dart';
import 'package:beautyminder/pages/baumann/baumann_result_page.dart';
import 'package:beautyminder/pages/my/my_favorite_page.dart';
import 'package:beautyminder/pages/todo/todo_page.dart';
import 'package:beautyminder/services/keywordRank_service.dart';
import 'package:beautyminder/widget/homepageAppBar.dart';
import 'package:beautyminder/widget/searchAppBar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:marquee/marquee.dart';
import '../../dto/baumann_result_model.dart';
import '../../dto/cosmetic_expiry_model.dart';
import '../../dto/user_model.dart';
import '../../services/api_service.dart';
import '../../services/baumann_service.dart';
import '../../services/expiry_service.dart';
import '../../services/home_service.dart';
import '../../services/shared_service.dart';
import '../../services/todo_service.dart';
import '../../dto/todo_model.dart';
import '../../widget/commonAppBar.dart';
import '../../widget/commonBottomNavigationBar.dart';
import '../baumann/baumann_test_start_page.dart';
import '../chat/chat_page.dart';
import '../my/my_page.dart';
import '../pouch/expiry_page.dart';
import '../recommend/recommend_bloc_screen.dart';
import '../search/search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.user}) : super(key: key);

  // final dynamic responseData;
  final User? user;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 2;
  bool isApiCallProcess = false;

  List<CosmeticExpiry> expiries = [];
  List favorites = [];

  bool isLoading = true;

  // late Future<HomePageResult<User>> userInfo;

  // late Future<Result<List<Todo>>> futureTodoList;

  @override
  void initState() {
    super.initState();
    _loadExpiries();
    _getfavorites();
    // futureTodoList = TodoService.getAllTodos();
  }

  Future<void> _loadExpiries() async {
    try {
      expiries = await ExpiryService.getAllExpiries();
      // Force a rebuild of the UI after fetching data
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('An error occurred while loading expiries: $e');
    }
  }

  Future<void> _getfavorites() async {
    try {
      final info = await APIService.getFavorites();
      setState(() {
        favorites = info.value!;
        isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Here is Home Page : ${widget.user?.id}");
    print("Here is Home Page : ${widget.user}");

    return Scaffold(
      appBar: HomepageAppBar(actions: <Widget>[
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () async {
            // 이미 API 호출이 진행 중인지 확인
            if (isApiCallProcess) {
              return;
            }
            // API 호출 중임을 표시
            setState(() {
              isApiCallProcess = true;
            });
            try {
              final result = await KeywordRankService.getKeywordRank();
              final result2 = await KeywordRankService.getProductRank();

              print('fdsfd keyword rank : ${result.value}');
              print('dkdkd product rank : ${result2.value}');

              if (result.isSuccess) {
                // SearchPage로 이동하고 가져온 데이터를 전달합니다.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchPage(
                      data: result.value!,
                      data2: result2.value!,
                    ),
                  ),
                );
              } else {
                // API 호출 실패를 처리합니다.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchPage(
                      data: null,
                      data2: null,
                    ),
                  ),
                );
              }
            } catch (e) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchPage(data: null, data2: null),
                ),
              );
            } finally {
              // API 호출 상태를 초기화합니다.
              setState(() {
                isApiCallProcess = false;
              });
            }
          },
        ),
      ]),
      body: SingleChildScrollView(
        child: _homePageUI(),
      ),
      bottomNavigationBar: _underNavigation(),
    );
  }

  Widget _homePageUI() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          SizedBox(height: 40,),
          _invalidProductBtn(),
          SizedBox(height: 20,),
          Row(
            children: <Widget>[
              _favoriteProductBtn(),
              SizedBox(width: 30,),
              Column(
                // mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  _personalSkinTypeBtn(),
                  SizedBox(height: 25,),
                  _chatBtn(),
                ],
              )
            ],
          ),
          SizedBox(height: 20,),
          _todoListBtn(),
          // _label()
        ],
      ),
    );
  }

  Widget _invalidProductBtn() {
    final screenWidth = MediaQuery.of(context).size.width;

    return ElevatedButton(
      onPressed: () async {
        if (isApiCallProcess) {
          return;
        }
        setState(() {
          isApiCallProcess = true;
        });
        try {
          // List<CosmeticExpiry> newExpiries = await ExpiryService.getAllExpiries();

          // print("This is Valid Button in Home Page : ${newExpiries}");
          // print("asdsa : ${newExpiries.isNotEmpty}");
          // print("aa : ${newExpiries.length}");

          // setState(() {
          //   expiries = newExpiries; // 상태 업데이트
          // });

          Navigator.of(context).push(MaterialPageRoute(builder: (context) => CosmeticExpiryPage()));
        } catch (e) {
          // Handle the error case
          print('An error occurred: $e');
        }
        finally {
          // API 호출 상태를 초기화합니다.
          setState(() {
            isApiCallProcess = false;
          });
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xffffb876),
        // 버튼의 배경색을 검정색으로 설정
        foregroundColor: Colors.white,
        // 버튼의 글씨색을 하얀색으로 설정
        elevation: 0,
        // 그림자 없애기
        minimumSize: Size(screenWidth, 200.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0), // 모서리를 더 둥글게 설정
        ),
      ),
      child: Align(
        alignment: Alignment.topLeft,
        // child: Text("유통기한 임박 화장품"),
        child: (expiries.isNotEmpty && expiries.length != 0)
            ? Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "유통기한 임박 화장품 ",
                          style: TextStyle(
                            // fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 15,
                        ),
                      ],
                    ),
                    _buildExpiryInfo(),
                  ],
                ),
              )
            : Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "유통기한 임박 화장품 ",
                          style: TextStyle(
                            // fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 15,
                        ),
                      ],
                    ),
                    _buildDefaultText(),
                  ],
                ),
              )
      ),
    );
  }

  Widget _buildExpiryInfo() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: expiries.take(3).map((expiry) {
          DateTime now = DateTime.now();
          DateTime expiryDate = expiry.expiryDate ?? DateTime.now();
          Duration difference = expiryDate.difference(now);
          bool isDatePassed = difference.isNegative;
          // Customize this part according to your expiry model
          return Container(
            margin: EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Display your image here, you can use Image.network or Image.asset
                // Example: Image.network(expiry.imageUrl ?? 'fallback_image_url', width: 50, height: 50),
                // Example: Image.asset('assets/images/sample_image.png', width: 50, height: 50),
                // Replace 'expiry.imageUrl' with the actual field in your expiry model
                SizedBox(height: 10,),
                Container(
                  width: 95,
                  height: 95,
                  decoration: BoxDecoration(
                    color: Colors.grey, // 네모 박스의 색상
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: (expiry.imageUrl != null)
                      ? Image.network(
                    expiry.imageUrl!,
                    width: 10,
                    height: 10,
                    fit: BoxFit.cover,
                  )
                      : Image.asset('assets/images/noImg.jpg', fit: BoxFit.cover,)// 이미지가 없는 경우
                ),
                SizedBox(height: 10,),
                // Display D-day or any other information here
                Text(isDatePassed ? 'D+${difference.inDays.abs() + 1}' : 'D-${difference.inDays}'),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }


  Widget _buildDefaultText() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 5),
          Text(
            "등록된 화장품이 없습니다.\n화장품 등록하기",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }



  Widget _favoriteProductBtn() {
    final screenWidth = MediaQuery.of(context).size.width / 2 - 40;

    return ElevatedButton(
      onPressed: () {
        // Navigator.of(context)
        //     .push(MaterialPageRoute(builder: (context) => const RecPage()));
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const MyFavoritePage()));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xffffecda),
        // 버튼의 배경색을 검정색으로 설정
        foregroundColor: Color(0xffff820e),
        // 버튼의 글씨색을 하얀색으로 설정
        elevation: 0,
        // 그림자 없애기
        minimumSize: Size(screenWidth, 200.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0), // 모서리를 더 둥글게 설정
        ),
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: (favorites.isNotEmpty && favorites.length != 0)
            ? Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "즐겨찾기 제품 ",
                    style: TextStyle(
                      // fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 15,
                  ),
                ],
              ),
              SizedBox(height: 15,),
              _buildFavoriteText(),
            ],
          ),
        )
        : Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "즐겨찾기 제품 ",
                    style: TextStyle(
                      // fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 15,
                  ),
                ],
              ),
              _buildFavoriteDefaultText(),
            ],
          ),
        )

      ),
    );
  }

  Widget _buildFavoriteText(){
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: favorites.take(3).map((item) {
          return Container(
            margin: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 10,),
                Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.grey, // 네모 박스의 색상
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child:
                    (item['images'][0] != null)
                        ? Image.network(
                      item['images'][0],
                      width: 10,
                      height: 10,
                      fit: BoxFit.cover,
                    )
                        :
                    Image.asset('assets/images/noImg.jpg', fit: BoxFit.cover,)// 이미지가 없는 경우
                ),
                SizedBox(width: 10,),
                Container(
                  width: MediaQuery.of(context).size.width / 2 - 120,
                  child: Text(
                    item['name'],
                    style: TextStyle(fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
  }

  Widget _buildFavoriteDefaultText() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 5),
          Text(
            "즐겨찾기된 화장품이 없습니다.\n화장품 등록하기",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _personalSkinTypeBtn() {
    final screenWidth = MediaQuery.of(context).size.width / 2 - 30;
    BaumResult<List<BaumannResult>> result =
        BaumResult<List<BaumannResult>>.success([]);

    return ElevatedButton(
      onPressed: () async {
        // 이미 API 호출이 진행 중인지 확인
        if (isApiCallProcess) {
          return;
        }
        // API 호출 중임을 표시
        setState(() {
          isApiCallProcess = true;
        });
        try {
          result = await BaumannService.getBaumannHistory();

          print("This is Baumann Button in Home Page : ${result.value}");

          if (result.isSuccess && result.value!.isNotEmpty) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    BaumannHistoryPage(resultData: result.value)));
            print("This is BaumannButton in HomePage2 : ${result.value}");
          } else {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => BaumannStartPage()));
            print("This is Baumann Button in Home Page2 : ${result.isSuccess}");
          }
        } catch (e) {
          // Handle the error case
          print('An error occurred: $e');
        } finally {
          // API 호출 상태를 초기화합니다.
          setState(() {
            isApiCallProcess = false;
          });
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xfffe9738),
        // 버튼의 배경색을 검정색으로 설정
        foregroundColor: Colors.white,
        // 버튼의 글씨색을 하얀색으로 설정
        elevation: 0,
        // 그림자 없애기
        minimumSize: Size(screenWidth, 90.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0), // 모서리를 더 둥글게 설정
        ),
        // padding: EdgeInsets.zero,
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "내 피부 타입 ",
                    style: TextStyle(
                      // fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 15,
                    // Add any other styling properties as needed
                  ),
                ],
              ),
              SizedBox(height: 5),
              Text((result.value != null) ? "${widget.user?.baumann}" : "테스트하기",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chatBtn() {
    final screenWidth = MediaQuery.of(context).size.width / 2 - 30;

    return ElevatedButton(
      onPressed: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => ChatPage()));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xffffd1a6),
        // 버튼의 배경색을 검정색으로 설정
        foregroundColor: Color(0xffd86a04),
        // 버튼의 글씨색을 하얀색으로 설정
        elevation: 0,
        // 그림자 없애기
        minimumSize: Size(screenWidth, 90.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0), // 모서리를 더 둥글게 설정
        ),
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "소통방 가기 ",
              style: TextStyle(
                // fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 15,
              // Add any other styling properties as needed
            ),
          ],
        ),
      ),
    );
  }

  Widget _todoListBtn() {
    final screenWidth = MediaQuery.of(context).size.width;

    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CalendarPage()));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xffe7e4e1),
        // 버튼의 배경색을 검정색으로 설정
        foregroundColor: Color(0xffff820e),
        // 버튼의 글씨색을 하얀색으로 설정
        elevation: 0,
        // 그림자 없애기
        minimumSize: Size(screenWidth, 200.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0), // 모서리를 더 둥글게 설정
        ),
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text("오늘의 루틴"),
      ),
    );
  }

  Widget _underNavigation() {
    return CommonBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          // 페이지 전환 로직 추가
          if (index == 0) {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => const RecPage()));
          }
          else if (index == 1) {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => CosmeticExpiryPage()));
          }
          // else if (index == 2) {
          //   Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomePage()));
          // }
          else if (index == 3) {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CalendarPage()));
          } else if (index == 4) {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => const MyPage()));
          }
        });
  }
}
