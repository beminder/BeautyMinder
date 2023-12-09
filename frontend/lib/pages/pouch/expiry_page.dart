import 'package:beautyminder/pages/pouch/search_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  int _notificationDays = 30;

  void updateCosmeticExpiryFromDialog(CosmeticExpiry updatedExpiry, int index) {
    setState(() {
      expiries[index] = updatedExpiry;
    });
  }

  String formatDate(DateTime? date) {
    if (date == null) return '입력되지 않음'; // 날짜가 null인 경우 처리
    return DateFormat('yyyy-MM-dd').format(date); // 날짜를 'yyyy-MM-dd' 형식으로 변환
  }



  Future<void> _loadNotificationSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationDays = prefs.getInt('notificationDays') ?? 30;
    });
  }


  Future<void> _saveNotificationSetting(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notificationDays', days);
  }

// 알림 설정 다이얼로그
  void _showNotificationSettingDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('알림 설정'),
          content: DropdownButtonFormField<int>(
            value: _notificationDays,
            items: [30, 60, 90].map((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text('$value 일 전'),
              );
            }).toList(),
            onChanged: (int? newValue) {
              if (newValue != null) {
                _saveNotificationSetting(newValue).then((_) {
                  setState(() {
                    _notificationDays = newValue;
                  });
                });
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadNotificationSetting();
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
        var notifyTime = FlutterLocalNotification.makeDateForExpiry(expiryDate, _notificationDays);

        if (notifyTime != null) {
          FlutterLocalNotification.showNotification_time(
              "유통기한 알림",
              "${expiry.productName}의 유통기한이 ${_notificationDays}일 이내입니다!",
              notifyTime,
              i // 고유한 ID
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
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: _showNotificationSettingDialog,
            ),
          ]),
      body: isLoading
          ? Center(
        child: SpinKitThreeInOut(
          color: Color(0xffd86a04),
          size: 50.0,
          duration: Duration(seconds: 2),
        ),
      ) : _selectUI(),
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

  Widget _selectUI() {
    if(expiries.isNotEmpty && expiries.length != 0) {
      return GridView.builder(
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
                        style: (difference.inDays+1<=100) ?
                        TextStyle(fontSize: 15, color: Colors.deepOrangeAccent, fontWeight: FontWeight.bold)
                            : TextStyle(fontSize: 15, color: Colors.black54, fontWeight: FontWeight.bold)
                    ),
                  ],
                ),
              ),

            ),
          );
        },
      );
    }
    else {
      return Center(
        child: Text(
          "등록된 화장품이 없습니다.\n보유하신 제품을 등록해주세요.",
          style: TextStyle(color: Colors.grey, fontSize: 18),
          textAlign: TextAlign.center,
        ),
      );
    }
  }
}