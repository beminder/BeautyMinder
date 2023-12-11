import 'package:beautyminder/pages/baumann/baumann_test_start_page.dart';
import 'package:beautyminder/pages/baumann/watch_result_page.dart';
import 'package:beautyminder/services/baumann_service.dart';
import 'package:flutter/material.dart';

import '../../dto/baumann_result_model.dart';
import '../../services/api_service.dart';
import '../../widget/appBar.dart';
import '../home/home_page.dart';

class BaumannHistoryPage extends StatelessWidget {
  final List<BaumannResult>? resultData;

  const BaumannHistoryPage({Key? key, required this.resultData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          _baumannHistoryUI(),
          _divider(),
          Stack(
            children: [
              Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: AnimatedTrainText(),
                ),
              ),
              Row(
                children: [
                  const Spacer(),
                  _retestButton(context),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: _baumannHistoryListView(),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        // padding: EdgeInsets.symmetric(vertical: 50, horizontal: 20),
        padding: const EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 50),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              final userProfileResult = await APIService.getUserProfile();
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HomePage(
                          user: userProfileResult.value,
                        )),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffe58731),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            child: const Text(
              '홈으로 가기',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _baumannHistoryUI() {
    return const Align(
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 30,
          ),
          Padding(
            padding: EdgeInsets.only(left: 20),
            child: Text(
              "바우만 피부 타입 결과",
              style: TextStyle(
                color: Color(0xFF868383),
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _baumannHistoryListView() {
    return ListView.builder(
      itemCount: resultData?.length ?? 0,
      itemBuilder: (context, index) {
        final result = resultData![index];
        final isEven = index.isEven;

        return Column(
          children: [
            const SizedBox(height: 5),
            _resultButton(context, result, isEven),
          ],
        );
      },
    );
  }

  // Future<void> _deleteAndNavigate(
  //     BuildContext context, List<BaumannResult>? resultData) async {
  //   // Assuming you are handling the deletion of the correct resultData somewhere
  //   if (resultData != null && resultData.isNotEmpty) {
  //     final userProfileResult = await APIService.getUserProfile();
  //     await BaumannService.deleteBaumannHistory(resultData[0].id);
  //
  //     // Navigate to HomePage
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => HomePage(user: userProfileResult.value),
  //       ),
  //     );
  //   }
  // }

  Widget _resultButton(
      BuildContext context, BaumannResult result, bool isEven) {
    Color buttonColor = isEven ? Colors.white : const Color(0xffffca97);
    Color textColor = isEven ? Colors.black : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Dismissible(
        key: UniqueKey(),
        direction: DismissDirection.endToStart,
        // Set direction to right-to-left
        background: Container(
          color: Colors.red,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: AlignmentDirectional.centerEnd,
          child: const Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
        confirmDismiss: (direction) async {
          bool deletionConfirmed = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("정말로 삭제하시겠습니까?"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false); // 삭제 취소
                    },
                    child: const Text("취소"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true); // 삭제 진행
                    },
                    child: const Text("삭제"),
                  ),
                ],
              );
            },
          );
          if (deletionConfirmed) {
            bool deletionSuccessful = false;

            try {
              final deletionResult =
                  await BaumannService.deleteBaumannHistory(result.id);
              if (deletionResult == "Success to Delete") {
                deletionSuccessful = true;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("삭제되었습니다."),
                  ),
                );
              } else {
                deletionSuccessful = false;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("삭제에 실패했습니다."),
                  ),
                );
              }

              // 삭제가 성공적으로 이루어졌을 때만 resultData에서 제거
              if (deletionSuccessful) {
                resultData?.remove(result);
              }
              return deletionSuccessful; // 항목이 성공적으로 삭제되었을 때만 true 반환
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("삭제하는 데 오류가 발생했습니다."),
                ),
              );
            }
          } else {
            return false; // 삭제가 취소되었을 때는 false 반환
          }
        },

        child: Container(
          height: 100,
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => WatchResultPage(resultData: result)));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              side: const BorderSide(color: Color(0xffffca97)),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('피부타입: ${result.baumannType}',
                        style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(width: 16),
                    Text('일시: ${result.date}',
                        style: TextStyle(color: textColor, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _retestButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.topRight,
        child: SizedBox(
          height: 30,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => BaumannStartPage(),
              ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffefefef), // Background color
              elevation: 0, // color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0), // Rounded corners
                side: const BorderSide(color: Colors.blueGrey),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.all(0.0),
              child: Text(
                '다시 테스트하기',
                style: TextStyle(
                  color: Colors.blueGrey, // Text color
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _divider() {
    return const Divider(
      height: 20,
      thickness: 1,
      indent: 20,
      endIndent: 20,
      color: Colors.grey,
    );
  }
}

//글씨 애니메이션
class AnimatedTrainText extends StatefulWidget {
  const AnimatedTrainText({super.key});

  @override
  State<AnimatedTrainText> createState() => _AnimatedTrainTextState();
}

class _AnimatedTrainTextState extends State<AnimatedTrainText>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    _animation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: const Offset(-1, 0),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.linear,
      ),
    );

    _animationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: const Text(
        "* 결과 삭제를 원하실 경우 좌측으로 슬라이드 해주세요",
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
