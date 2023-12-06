import 'dart:io';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '/widget/commonAppBar.dart';
import '/dto/user_model.dart';
import '/services/shared_service.dart';
import '/dto/review_request_model.dart';
import '/dto/review_response_model.dart';
import '/services/review_service.dart';

class CosmeticReviewPage extends StatefulWidget {
  final String cosmeticId;

  CosmeticReviewPage({Key? key, required this.cosmeticId}) : super(key: key);

  @override
  _CosmeticReviewPageState createState() => _CosmeticReviewPageState();
}

class _CosmeticReviewPageState extends State<CosmeticReviewPage> {
  List<ReviewResponse> _cosmeticReviews = [];
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  List<PlatformFile>? _imageFiles;
  final TextEditingController _contentController = TextEditingController();
  int _localRating = 3;
  String _warningMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchReviewsForCosmetic(widget.cosmeticId);
  }

  void _fetchReviewsForCosmetic(String cosmeticId) async {
    setState(() => _isLoading = true);
    try {
      var reviews = await ReviewService.getReviewsForCosmetic(cosmeticId);
      User? currentUser = await SharedService.getUser();

      if (currentUser != null) {
        // 사용자가 작성한 리뷰를 맨 위로 이동
        _moveCurrentUserReviewToTop(reviews, currentUser.id);
      }

      setState(() {
        _cosmeticReviews = reviews;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('리뷰 불러오기 실패: $e');
    }
  }

  void _moveCurrentUserReviewToTop(List<ReviewResponse> reviews, String userId) {
    int userReviewIndex = reviews.indexWhere((review) => review.user.id == userId);
    if (userReviewIndex != -1) {
      ReviewResponse userReview = reviews.removeAt(userReviewIndex);
      reviews.insert(0, userReview);
    }
  }


  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        PlatformFile file = PlatformFile(
          name: image.name,
          path: image.path,
          size: await image.length(),
          bytes: await image.readAsBytes(),
        );
        setState(() {
          _imageFiles = [file];
        });
      } else {
        _showSnackBar('이미지가 선택되지 않았습니다');
      }
    } on PlatformException catch (e) {
      log('Unsupported operation : ' + e.toString());
    } catch (e) {
      log(e.toString());
      _showSnackBar('이미지 선택에 실패: $e');
    }
  }

  void _addReview() async {
    _imageFiles = []; // 이미지 목록 초기화
    User? user = await SharedService.getUser();
    if (user != null) {
      // 중복 리뷰 확인
      bool hasReviewed = _cosmeticReviews.any((review) => review.user.id == user.id);
      if (hasReviewed) {
        _showSnackBar('이미 리뷰를 작성하셨습니다.');
        return;
      }
      _showReviewDialog(userId: user.id);
    } else {
      _showSnackBar('리뷰 추가는 로그인이 필수입니다!');
    }
  }


  void _showReviewDialog({required String userId}) {
    _warningMessage = '';
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              title: Text(
                '리뷰 작성',
                style: TextStyle(
                    fontFamily: 'YourCustomFont',
                    fontWeight: FontWeight.bold
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('*실제 사용 확인을 위해 이미지 등록은 필수입니다.'),
                    SizedBox(height: 15,),
                    TextField(
                      controller: _contentController,
                      cursorColor: Color(0xffd77c00),
                      decoration: InputDecoration(
                        hintText: '리뷰를 작성해주세요',
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xffd77c00)),
                        ),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 20),
                    DropdownButton<int>(
                      value: _localRating,
                      items: List.generate(
                        5,
                            (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text('${index + 1} Stars'),
                        ),
                      ),
                      onChanged: (value) {
                        setDialogState(() => _localRating = value!);
                      },
                    ),
                    _buildImagePreview(setDialogState),
                    ElevatedButton(
                      onPressed: () async {
                        await pickImage();
                        setDialogState(() {}); // Update StatefulBuilder state
                      },
                      child: Text('사진 추가'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color(0xfff3bb88),
                      ),
                    ),
                    // 경고 메시지
                    if (_warningMessage.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                          _warningMessage,
                          style: TextStyle(color: Colors.red),
                        ),
                      )

                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('취소',
                    style: TextStyle(color: Color(0xfff3bb88)),),
                ),
                TextButton(
                  onPressed: () async {
                    final String content = _contentController.text;
                    if (content.isEmpty) {
                      setDialogState(() => _warningMessage = '리뷰 내용을 작성해주세요.');
                      return;
                    }

                    if (_imageFiles == null || _imageFiles!.isEmpty) {
                      setDialogState(() => _warningMessage = '리뷰 이미지를 추가해주세요.');
                      return;
                    }

                    // 리뷰 추가 로직
                    ReviewRequest newReviewRequest = ReviewRequest(
                      content: content,
                      rating: _localRating,
                      cosmeticId: widget.cosmeticId,
                    );

                    try {
                      ReviewResponse responseReview = await ReviewService.addReview(
                          newReviewRequest, _imageFiles!);

                      setState(() {

                        _cosmeticReviews.insert(0, responseReview);
                      });

                      Navigator.of(context).pop(); // 다이얼로그 닫기
                      _showSnackBar('리뷰가 추가되었습니다');
                    } catch (e) {
                      _showSnackBar('리뷰 추가 실패: $e');
                    }
                  },
                  child: Text('제출',
                    style: TextStyle(color: Color(0xfff3bb88)),),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Widget _buildReviewList() {
    if (_cosmeticReviews.isEmpty){}
    return Expanded(
      child: ListView.separated(
        itemCount: _cosmeticReviews.length,
        separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey),
        itemBuilder: (context, index) {
          var review = _cosmeticReviews[index];
          return Card(
            elevation: 2,
            margin: EdgeInsets.all(8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              title: Row(
                children: [
                  ...List.generate(5, (starIndex) {
                    return Icon(
                      starIndex < review.rating
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 20,
                    );
                  }),
                  SizedBox(width: 8),
                  Text(
                    '${review.rating} Stars',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.content,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: review.images.map((image) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            image,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                              return SizedBox.shrink();
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 10),
                    if (review.nlpAnalysis.isNotEmpty)
                      Text('바우만분석: ${review.nlpAnalysis}'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }


  // 사진 선택 및 미리보기 위젯
  Widget _buildImagePreview(StateSetter setDialogState) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: _imageFiles?.map((file) {
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.file(
                File(file.path!),
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: IconButton(
                icon: Icon(Icons.remove_circle),
                color: Colors.red,
                onPressed: () {
                  setState(() {
                    _imageFiles!.remove(file);
                  });
                  setDialogState(() {}); // StatefulBuilder의 상태 업데이트
                },
              ),
            ),
          ],
        );
      }).toList() ?? [],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(automaticallyImplyLeading: true,),
      body: Column(
        children: [
          if (_isLoading)
            Expanded(
              child: Center(
                child: SpinKitThreeInOut(
                  color: Color(0xffd86a04),
                  size: 50.0,
                  duration: Duration(seconds: 2),
                ),
              ),
            )
          else
            _buildReviewList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addReview(); // 리뷰 추가 다이얼로그를 여는 버튼으로 변경
        },
        child: Icon(Icons.edit),
        backgroundColor: Color(0xffe7a470),
      ),
    );
  }
}
