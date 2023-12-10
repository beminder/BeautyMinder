import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:admin/Service/admin_Service.dart' as admin;
import 'package:admin/Service/api_service.dart' as api;
import '../../constants.dart';
import '../../dto/user_model.dart';
import '../../models/review_response_model.dart';
import '../dashboard/components/header.dart';
import '../main/components/side_menu.dart';

class filteredReviewScreen extends StatefulWidget {
  @override
  _ReviewScreen createState() => _ReviewScreen();
}

class _ReviewScreen extends State<filteredReviewScreen> {
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
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !isFetching) {
      //_fetchReviews();
    }
  }


  Future<void> _fetchReviews() async {
    if (isFetching) return;

    setState(() {
      isFetching = true;
    });

    final result = await admin.adminService.getFilteredReviews();
    if (result.isSuccess && result.value != null) {
      setState(() {

        reviews.addAll(result.value!); // 현재 reviews 리스트에 새로운 리뷰를 추가
        print("reviews length : ${reviews.length}");
        print("reviews : ${reviews}");
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
  Future<void> _approveReview(String reviewId) async {
    final result = await admin.adminService.updateReviewStatus(reviewId, 'approved');
    if (result.isSuccess) {
      setState(() {
        reviews.removeWhere((review) => review.id == reviewId);
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("리뷰 필터링을 해제했습니다.")));
    } else {
      // 에러 처리
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("리뷰 필터링 해제에 실패했습니다.")));
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
                  ? Image.network(review.images.first)
                  : Icon(Icons.camera_alt_outlined),
              title: Text(review.content),
              subtitle: Text('Rating: ${review.rating}'),
              trailing: IconButton(
                icon: Icon(Icons.preview),
                onPressed: () => _approveReview(review.id),
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
