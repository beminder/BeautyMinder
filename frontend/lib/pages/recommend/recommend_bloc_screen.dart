import 'package:beautyminder/Bloc/RecommendPageBloc.dart';
import 'package:beautyminder/State/RecommendState.dart';
import 'package:beautyminder/event/RecommendPageEvent.dart';
import 'package:beautyminder/pages/product/product_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../services/api_service.dart';
import '../../widget/commonAppBar.dart';
import '../../widget/commonBottomNavigationBar.dart';
import '../../widget/homepageAppBar.dart';
import '../baumann/baumann_test_start_page.dart';
import '../home/home_page.dart';
import '../my/my_page.dart';
import '../pouch/expiry_page.dart';
import '../todo/todo_page.dart';

class RecPage extends StatefulWidget {
  const RecPage({Key? key}) : super(key: key);

  @override
  _RecPage createState() => _RecPage();
}

class _RecPage extends State<RecPage> {
  int _currentIndex = 0;

  String result = '';

  GlobalKey bottomNavigationKey = GlobalKey();

  bool isAll = true;
  bool isSkincare = false;
  bool isCleansing = false;
  bool isSuncare = false;
  bool isBase = false;

  late List<bool> isSelected = [
    isAll,
    isSkincare,
    isCleansing,
    isSuncare,
    isBase
  ];

  String? toggleSelect(int value) {
    isAll = false;
    isSkincare = false;
    isCleansing = false;
    isSuncare = false;
    isBase = false;

    if (value == 0) {
      isAll = true;
      setState(() {
        isSelected = [isAll, isSkincare, isCleansing, isSuncare, isBase];
      });
      print("toggleSelect : null");
      return "전체";
    } else if (value == 1) {
      isSkincare = true;
      setState(() {
        isSelected = [isAll, isSkincare, isCleansing, isSuncare, isBase];
      });
      return "스킨케어";
    } else if (value == 2) {
      isCleansing = true;
      setState(() {
        isSelected = [isAll, isSkincare, isCleansing, isSuncare, isBase];
      });
      return "클렌징";
    } else if (value == 3) {
      isSuncare = true;
      setState(() {
        isSelected = [isAll, isSkincare, isCleansing, isSuncare, isBase];
      });
      return "선케어";
    } else {
      isBase = true;
      setState(() {
        isSelected = [isAll, isSkincare, isCleansing, isSuncare, isBase];
      });
      return "베이스/프라이머";
    }
  }

  @override
  void initState() {
    isSelected = [isAll, isSkincare, isCleansing, isSuncare, isBase];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RecommendPageBloc()..add(RecommendPageInitEvent()),
      child: Scaffold(
          appBar:  HomepageAppBar(
            actions: [
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => RecPage()),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Container(height: 30),
              BlocBuilder<RecommendPageBloc, RecommendState>(
                  builder: (context, state) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    toggleButtonsTheme: ToggleButtonsThemeData(
                        selectedColor: Color(0xffd86a04),
                        selectedBorderColor: Color(0xffd86a04)),
                  ),
                  child: Container(
                    height: 30,
                    child: ToggleButtons(
                      isSelected: [
                        isAll,
                        isSkincare,
                        isCleansing,
                        isSuncare,
                        isBase
                      ],
                      onPressed: (int index) {
                        print({"index : $index"});
                        toggleSelect(index);
                        context.read<RecommendPageBloc>().add(
                              RecommendPageCategoryChangeEvent(
                                  category: toggleSelect(index)),
                            );
                      },
                      // fillColor: Color(0xffffecda),
                      fillColor: Colors.white,
                      children: const [
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                          child: Text('전체', style: TextStyle(fontSize: 15)),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                          child: Text('스킨케어', style: TextStyle(fontSize: 15)),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                          child: Text('클렌징', style: TextStyle(fontSize: 15)),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                          child: Text('선케어', style: TextStyle(fontSize: 15)),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                          child: Text('베이스', style: TextStyle(fontSize: 15)),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              Container(
                height: 20,
              ),
              Expanded(child: RecPageImageWidget())
            ],
          ),
          bottomNavigationBar: Container(
            child: CommonBottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (int index) async {
                // 페이지 전환 로직 추가
                if (index == 1) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => CosmeticExpiryPage()));
                } else if (index == 2) {
                  final userProfileResult = await APIService.getUserProfile();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          HomePage(user: userProfileResult.value)));
                } else if (index == 3) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const CalendarPage()));
                } else if (index == 4) {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const MyPage()));
                }
              },
            ),
          )),
    );
  }
}

String keywordsToString(List<String> keywords) {
  return keywords.join(', ');
}

class RecPageImageWidget extends StatefulWidget {
  @override
  _RecPageImageWidget createState() => _RecPageImageWidget();
}

class _RecPageImageWidget extends State<RecPageImageWidget> {
  bool isAll = true;
  bool isSkincare = false;
  bool isCleansing = false;
  bool isSuncare = false;
  bool isBase = false;

  late List<bool> isSelected = [
    isAll,
    isSkincare,
    isCleansing,
    isSuncare,
    isBase
  ];

  int _currentIndex = 1;

  String? toggleSelect(int value) {
    isAll = false;
    isSkincare = false;
    isCleansing = false;
    isSuncare = false;
    isBase = false;

    if (value == 0) {
      isAll = true;
      setState(() {
        isSelected = [isAll, isSkincare, isCleansing, isSuncare, isBase];
      });
      print("toggleSelect : null");
      return "전체";
    } else if (value == 1) {
      isSkincare = true;
      setState(() {
        isSelected = [isAll, isSkincare, isCleansing, isSuncare, isBase];
      });
      return "스킨케어";
    } else if (value == 2) {
      isCleansing = true;
      setState(() {
        isSelected = [isAll, isSkincare, isCleansing, isSuncare, isBase];
      });
      return "클렌징";
    } else if (value == 3) {
      isSuncare = true;
      setState(() {
        isSelected = [isAll, isSkincare, isCleansing, isSuncare, isBase];
      });
      return "선케어";
    } else {
      isBase = true;
      setState(() {
        isSelected = [isAll, isSkincare, isCleansing, isSuncare, isBase];
      });
      return "베이스/프라이머";
    }
  }

  @override
  void initState() {
    isSelected = [isAll, isSkincare, isCleansing, isSuncare, isBase];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: BlocBuilder<RecommendPageBloc, RecommendState>(
        builder: (context, state) {
      if (state is RecommendInitState || state is RecommendDownloadedState) {
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 100,
          child: GestureDetector(
            child: SpinKitThreeInOut(
              color: Color(0xffd86a04),
              size: 50.0,
              duration: Duration(seconds: 2),
            ),
          ),
        );
      } else if (state is RecommendErrorState) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Text(
                '추천 가능한 제품이 없습니다.\n바우만 피부 테스트를 진행해주세요.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xffd86a04)),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (contextx) => BaumannStartPage()));
                },
                child: Text(
                  "바우만 테스트",
                  style: TextStyle(color: Colors.white),
                ))
          ],
        );
      } else {
        return ListView.separated(
            shrinkWrap: true,
            itemBuilder: (context, index) {
              {
                return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ProductDetailPage(
                          searchResults: state.recCosmetics![index],
                        ),
                      ));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                color: const Color.fromRGBO(71, 71, 71, 1),
                                child: state.recCosmetics != null &&
                                        state.recCosmetics![index].images !=
                                            null &&
                                        state.recCosmetics![index].images!
                                            .isNotEmpty
                                    ? Image.network(
                                        state.recCosmetics![index].images![0],
                                        fit: BoxFit.cover,
                                      )
                                    : Container(),
                              ),
                              Expanded(
                                  child: Container(
                                height: 100,
                                color: const Color.fromRGBO(0, 0, 0, 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _textForm(state.recCosmetics![index].name),
                                    _textForm(keywordsToString(
                                        state.recCosmetics![index].keywords!)),
                                  ],
                                ),
                              ))
                            ],
                          ),
                          if (index + 1 == state.recCosmetics!.length) ...[]
                        ],
                      ),
                    ));
              }
            },
            separatorBuilder: (context, index) {
              return Divider(
                height: 20,
                thickness: 1,
                indent: 10,
                endIndent: 10,
                color: Colors.grey,
              );
            },
            itemCount: state.recCosmetics!.length);
      }
    }));
  }

  Padding _textForm(String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, left: 12),
      child: Text(
        content,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }
}
