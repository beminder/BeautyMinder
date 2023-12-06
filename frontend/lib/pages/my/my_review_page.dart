import 'package:beautyminder/dto/review_model.dart';
import 'package:beautyminder/pages/my/widgets/review_card.dart';
import 'package:beautyminder/services/api_service.dart';
import 'package:beautyminder/widget/commonAppBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:beautyminder/pages/my/widgets/my_page_header.dart';

class MyReviewPage extends StatefulWidget {
  const MyReviewPage({super.key});

  @override
  State<MyReviewPage> createState() => _MyReviewPageState();
}

class _MyReviewPageState extends State<MyReviewPage> {
  List<dynamic>? reviews;
  bool isLoading = true;

  void updateParentVariable() {
    getReviews();
  }

  @override
  void initState() {
    super.initState();
    getReviews();
  }

  getReviews() async {
    try {
      final info = await APIService.getReviews();
      setState(() {
        reviews = info.value;
        isLoading = false;
      });
    } catch (e) {
      print('error is $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        automaticallyImplyLeading: true,
        context: context,
      ),
      body: _body(),
    );
  }

  Widget _body() {
    return isLoading
        ? const SpinKitThreeInOut(
            color: Color(0xffd86a04),
            size: 50.0,
            duration: Duration(seconds: 2),
          )
        : Column(
            children: [
              const Padding(
                // 제목을 가운데로 조정하기 위한 Padding
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: MyPageHeader('내가 쓴 리뷰'),
              ),
              Expanded(
                child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: reviews?.length ?? 0,
                    itemBuilder: (context, index) {
                      final reviewJson = reviews?[index];
                      final review = ReviewModel.fromJson(reviewJson);
                      return ReviewCard(
                        review: review,
                        updateParentVariable: updateParentVariable,
                      );
                    },
                  ),
                ),
            ],
          );
  }
}
