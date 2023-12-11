import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:beautyminder_dashboard/Service/admin_service.dart' as admin;
import 'package:beautyminder_dashboard/Service/api_service.dart' as api;
import '../../constants.dart';
import '../../dto/user_model.dart';
import '../../models/review_response_model.dart';
import '../main/components/header.dart';
import '../main/components/side_menu.dart';

class ReviewScreen extends StatefulWidget {
  @override
  _ReviewScreen createState() => _ReviewScreen();
}

class _ReviewScreen extends State<ReviewScreen> {
  late Future<api.Result<User>> futureUserProfile;
  List<ReviewResponse> reviews = [];
  ScrollController _scrollController = ScrollController();
  int currentPage = 0;
  bool isFetching = false;

  @override
  void initState() {
    super.initState();
    futureUserProfile = api.APIService.getUserProfile();
    _fetchReviews();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !isFetching) {
      _fetchReviews();
    }
  }

  Future<void> _fetchReviews() async {
    if (isFetching) return;

    setState(() {
      isFetching = true;
    });

    final result = await admin.AdminService.getAllReviews(currentPage);
    if (result.isSuccess && result.value != null) {
      setState(() {
        reviews.addAll(result.value!); // 현재 reviews 리스트에 새로운 리뷰를 추가
        currentPage++;
        isFetching = false;
      });
    } else {
      // Handle error or no data case
      setState(() {
        isFetching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideMenu(),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          primary: false,
          padding: EdgeInsets.all(defaultPadding),
          child: Column(
            children: [
              FutureBuilder(
                future: futureUserProfile,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final userProfileResult = snapshot.data;
                    return Header(
                      headTitle: "Review",
                      userProfileResult: userProfileResult,
                    );
                  }
                },
              ),
              SizedBox(height: defaultPadding),
              _buildReviewList(),
            ],
          ),
        ),
      ),
    );
  }

  // 리뷰를 차단하는 함수
  Future<void> _blockReview(String reviewId) async {
    final result =
        await admin.AdminService.updateReviewStatus(reviewId, 'denied');
    if (result.isSuccess) {
      setState(() {
        reviews.removeWhere((review) => review.id == reviewId);
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("리뷰를 차단했습니다.")));
    } else {
      // 에러 처리
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("리뷰 차단에 실패했습니다.")));
    }
  }

  Widget _buildReviewList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: reviews.length + (isFetching ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < reviews.length) {
          final review = reviews[index];
          return Card(
            color: secondaryColor,
            child: ListTile(
              leading: review.images.isNotEmpty
                  ? Image.network(review.images.first ?? '')
                  : Image.asset('assets/images/noImg.jpg' ?? ''),
              title: Text(review.content),
              subtitle: Text('Rating: ${review.rating}'),
              trailing: IconButton(
                icon: Icon(Icons.disabled_visible),
                onPressed: () => _blockReview(review.id),
              ),
            ),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }
}
