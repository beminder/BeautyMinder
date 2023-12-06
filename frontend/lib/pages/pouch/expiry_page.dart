import 'package:beautyminder/pages/pouch/search_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../dto/cosmetic_expiry_model.dart';
import '../../dto/cosmetic_model.dart';
import '../../services/api_service.dart';
import '../../services/expiry_service.dart';
import '../../pages/pouch/flutter_notification.dart';
import '../../services/search_service.dart';
import '../../widget/commonBottomNavigationBar.dart';
import 'cosmeticExpiryDetailCard.dart';
import '../home/home_page.dart';
import '../my/my_page.dart';
import '../recommend/recommend_bloc_screen.dart';
import '../todo/todo_page.dart';
import 'expiry_edit_dialog.dart';
import 'expiry_input_dialog.dart';

class CosmeticExpiryPage extends StatefulWidget {
  @override
  _CosmeticExpiryPageState createState() => _CosmeticExpiryPageState();
}

class _CosmeticExpiryPageState extends State<CosmeticExpiryPage> {
  int _currentIndex = 1;
  List<CosmeticExpiry> expiries = [];
  bool isLoading = true;

  void updateCosmeticExpiryFromDialog(CosmeticExpiry updatedExpiry, int index) {
    setState(() {
      expiries[index] = updatedExpiry;
    });
  }

  String formatDate(DateTime? date) {
    if (date == null) return '입력되지 않음'; // 날짜가 null인 경우 처리
    return DateFormat('yyyy-MM-dd').format(date); // 날짜를 'yyyy-MM-dd' 형식으로 변환
  }

  @override
  void initState() {
    super.initState();
    _loadExpiryData();
  }

  void _loadExpiryData() async {
    setState(() {
      isLoading = true; // 로딩 시작
    });

    try {
      final expiryData = await ExpiryService.getAllExpiries();
      DateTime now = DateTime.now();
      var futures = <Future>[];

      for (var i = 0; i < expiryData.length; i++) {
        var expiry = expiryData[i];

        futures.add(
            SearchService.searchCosmeticsByName(expiry.productName).then((cosmetics) {
              if (cosmetics.isNotEmpty) {
                expiry.imageUrl = cosmetics.first.images.isNotEmpty
                    ? cosmetics.first.images.first
                    : null;
              }
            }).catchError((e) {
              print("Error loading cosmetic data for ${expiry.productName}: $e");
            })
        );

        DateTime expiryDate = expiry.expiryDate ?? DateTime.now();
        int daysUntilExpiry = expiryDate.difference(now).inDays;

        if (daysUntilExpiry == 0) {
          FlutterLocalNotification.showNotification_time(
              "유통기한 알림",
              "${expiry.productName}의 유통기한이 오늘까지입니다!",
              FlutterLocalNotification.makeDateForExpiry(expiryDate),
              i
          );
        }
      }

      await Future.wait(futures);

      setState(() {
        expiries = expiryData;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading cosmetic expiries: $e");
      setState(() {
        isLoading = false;
      });
    }
  }


  void _deleteExpiry(String expiryId, int index) async {
    try {
      await ExpiryService.deleteExpiry(expiryId);
      setState(() {
        expiries.removeAt(index); // 로컬 목록에서 해당 항목 제거
      });
    } catch (e) {
      // 에러 처리
      print("Error deleting expiry: $e");
    }
  }

  void _addCosmetic() async {
    final Cosmetic? selectedCosmetic = await showDialog<Cosmetic>(
      context: context,
      builder: (context) => CosmeticSearchWidget(),
    );
    if (selectedCosmetic != null) {
      final List<dynamic>? expiryInfo = await showDialog<List<dynamic>>(
        context: context,
        builder: (context) => ExpiryInputDialog(cosmetic: selectedCosmetic),
      );
      if (expiryInfo != null) {
        final bool opened = expiryInfo[0] as bool;
        final DateTime expiryDate = expiryInfo[1] as DateTime;
        final DateTime? openedDate = expiryInfo[2] as DateTime?;

        final CosmeticExpiry newExpiry = CosmeticExpiry(
          productName: selectedCosmetic.name,
          expiryDate: expiryDate,
          opened: opened,
          openedDate: openedDate,
          brandName: selectedCosmetic.brand,
          cosmeticId: selectedCosmetic.id,
        );
        final CosmeticExpiry addedExpiry =
        await ExpiryService.createCosmeticExpiry(newExpiry);

        setState(() {
          expiries.add(addedExpiry);
          _loadExpiryData();
        });
      }
    }
  }

  void _editExpiry(CosmeticExpiry expiry, int index) async {
    print("***Before updating: ${expiry.opened}");
    final CosmeticExpiry? updatedExpiry = await showDialog<CosmeticExpiry>(
      context: context,
      builder: (context) => ExpiryEditDialog(
        expiry: expiry,
        onUpdate: (updated) {
          setState(() {
            expiries[index] = updated;
          });
        },
      ),
    );

    if (updatedExpiry != null) {
      try {
        final CosmeticExpiry updated =
        await ExpiryService.updateExpiry(expiry.id!, updatedExpiry);
        setState(() {
          expiries[index] = updated;
        });
      } catch (e) {
        print("Error updating expiry: $e");
      }
    }
  }

  void _showCosmeticDetailsCard(CosmeticExpiry cosmetic, int index) {
    showDialog(
      context: context,
      builder: (context) => ExpiryContentCard(
        cosmetic: cosmetic,
        onDelete: () {
          print("onDelete callback called");
          _deleteExpiry(cosmetic.id!, index);
        },
        onEdit: () {
          print("onEdit callback called");
          _editExpiry(cosmetic, index);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color(0xffffecda),
          elevation: 0,
          centerTitle: false,
          title: const Text(
            "BeautyMinder",
            style: TextStyle(color: Color(0xffd86a04), fontWeight: FontWeight.bold),
          ),
          iconTheme: const IconThemeData(
            color: Color(0xffd86a04),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: _addCosmetic,
            ),
          ]),
      body: Stack(
        children: [
          Opacity(
            opacity: isLoading ? 0.5 : 1.0, // 로딩 중일 때 투명도를 낮춤
            child: expiries.isEmpty
                ? Center(child: Text("등록된 화장품이 없습니다!")) // 비어있을 때의 메시지
                :GridView.builder(
              padding: EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.85,
              ),
              itemCount: expiries.length,
              itemBuilder: (context, index) {
                final cosmetic = expiries[index];

                DateTime now = DateTime.now();
                DateTime expiryDate = cosmetic.expiryDate ?? DateTime.now();
                Duration difference = expiryDate.difference(now);
                bool isDatePassed = difference.isNegative;

                return GestureDetector(
                  onTap: () {
                    _showCosmeticDetailsCard(cosmetic, index);
                  },
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    color: Color(0xffffffff),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 이미지 표시
                          cosmetic.imageUrl != null
                              ? Image.network(cosmetic.imageUrl!,
                              width: 120, height: 120, fit: BoxFit.cover)
                              : Image.asset('assets/images/noImg.jpg',
                              width: 120, height: 120, fit: BoxFit.cover),
                          SizedBox(height: 8,),
                          // 제품 이름
                          Text(
                            cosmetic.productName,
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold
                            ),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: 10,),

                          // D-Day
                          isDatePassed ?
                          Text(
                            'D+${difference.inDays.abs()}',
                            style: TextStyle(fontSize: 15, color: Colors.deepOrangeAccent, fontWeight: FontWeight.bold),
                          ) : Text(
                              'D-${difference.inDays+1}',
                              style: (difference.inDays+1<=30) ?
                              TextStyle(fontSize: 15, color: Colors.deepOrangeAccent, fontWeight: FontWeight.bold)
                                  : TextStyle(fontSize: 15, color: Colors.black54, fontWeight: FontWeight.bold)
                          ),
                        ],
                      ),
                    ),

                  ),
                );
              },
            ),
          ),
          isLoading
              ? Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
          )
              : Container(), // 로딩이 아닐 때는 빈 컨테이너 표시
        ],
      ),
      bottomNavigationBar: CommonBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) async {
          // 페이지 전환 로직 추가
          if (index == 0) {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => RecPage()));
          } else if (index == 2) {
            final userProfileResult = await APIService.getUserProfile();
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => HomePage(user: userProfileResult.value)));
          } else if (index == 3) {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => CalendarPage()));
          } else if (index == 4) {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => const MyPage()));
          }
        },
      ),
    );
  }
}