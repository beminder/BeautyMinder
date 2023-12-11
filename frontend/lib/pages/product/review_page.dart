import 'dart:io';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../../services/search_service.dart';
import '../../widget/appBar.dart';
import '/dto/user_model.dart';
import '/services/shared_service.dart';
import '/dto/review_request_model.dart';
import '/dto/review_response_model.dart';
import '/services/review_service.dart';

class CosmeticReviewPage extends StatefulWidget {
  final String cosmeticId;
  final void Function(double)? onReviewAdded;

  CosmeticReviewPage({Key? key, required this.cosmeticId, this.onReviewAdded}) : super(key: key);

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
  int _currentPage = 0;
  int _totalPages = 0;
  List productDetails = [];
  double updateAverageRating = 0.0;
  User? _currentUser;


  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
    _fetchReviewsForCosmetic(widget.cosmeticId, _currentPage);
  }

  void _fetchCurrentUser() async {
    _currentUser = await SharedService.getUser();
    setState(() {});
  }


  void _fetchReviewsForCosmetic(String cosmeticId, int pageNumber) async {
    setState(() => _isLoading = true);
    try {
      ReviewPageResponse reviewPageResponse = await ReviewService.getReviewsForCosmetic(cosmeticId, pageNumber);
      final loadedCosmeticInfo = await SearchService.searchCosmeticById(cosmeticId);

      if (_currentUser != null) {
        // 사용자가 작성한 리뷰를 맨 위로 이동
        _moveCurrentUserReviewToTop(reviewPageResponse.reviews, _currentUser!.id);
      }

      setState(() {
        _cosmeticReviews = reviewPageResponse.reviews;
        _totalPages = reviewPageResponse.totalPages;
        _currentPage = reviewPageResponse.number;
        _isLoading = false;
        productDetails = loadedCosmeticInfo ?? [];
        updateAverageRating = loadedCosmeticInfo.first.averageRating ?? 0.0;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('리뷰 불러오기 실패하였습니다');
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
      _showSnackBar('이미지 선택에 실패하였습니다');
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
      _showSnackBar('리뷰 추가는 로그인이 필수입니다.');
    }
  }

  // Future<void> _editReview(ReviewResponse review) async {
  //   TextEditingController _editContentController = TextEditingController(text: review.content);
  //   int _editRating = review.rating;
  //   List<PlatformFile>? _editImageFiles = []; // 이미지 파일을 저장할 리스트
  //
  //   // 이미지 선택 함수
  //   Future<void> _pickEditImage() async {
  //     final ImagePicker _picker = ImagePicker();
  //     final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
  //
  //     if (image != null) {
  //       PlatformFile file = PlatformFile(
  //         name: image.name,
  //         path: image.path,
  //         size: await image.length(),
  //         bytes: await image.readAsBytes(),
  //       );
  //       _editImageFiles?.add(file);
  //     }
  //   }
  //
  //   // Show edit dialog
  //   await showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: Text('Edit Review'),
  //         content: SingleChildScrollView(
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               TextField(
  //                 controller: _editContentController,
  //                 decoration: InputDecoration(labelText: 'Review'),
  //                 maxLines: 3,
  //               ),
  //               DropdownButton<int>(
  //                 value: _editRating,
  //                 items: List.generate(5, (index) => DropdownMenuItem(value: index + 1, child: Text('${index + 1} Stars'))),
  //                 onChanged: (value) => _editRating = value!,
  //               ),
  //               // 이미지 추가 버튼
  //               ElevatedButton(
  //                 onPressed: _pickEditImage,
  //                 child: Text('Add Image'),
  //               ),
  //               // 이미지 미리보기
  //               ...(_editImageFiles ?? []).map((file) => Image.file(File(file.path!))),
  //             ],
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             child: Text('Cancel'),
  //             onPressed: () => Navigator.of(context).pop(),
  //           ),
  //           TextButton(
  //             child: Text('Update'),
  //             onPressed: () async {
  //               ReviewRequest updatedRequest = ReviewRequest(
  //                 content: _editContentController.text,
  //                 rating: _editRating,
  //                 cosmeticId: review.cosmetic.id,
  //               );
  //               try {
  //                 // Call the update service
  //                 await ReviewService.updateReview(review.id, updatedRequest, _editImageFiles);
  //                 _fetchReviewsForCosmetic(widget.cosmeticId, _currentPage); // Refresh the list
  //                 Navigator.of(context).pop();
  //               } catch (e) {
  //                 // Handle errors, e.g., show a snackbar
  //               }
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  Future<void> _deleteReview(ReviewResponse review) async {
    try {
      log('리뷰 삭제 시도: ${review.id}');
      await ReviewService.deleteReview(review.id);
      log('리뷰 삭제 성공: ${review.id}');

      _fetchReviewsForCosmetic(widget.cosmeticId, _currentPage);
    } catch (e) {
      log('리뷰 삭제 실패: $e');
      _showSnackBar('리뷰 삭제에 실패하였습니다.');
    }
  }



  String parseAndFormatBaumannAnalysis(String nlpAnalysis) {
    RegExp exp = RegExp(r'([ODRSPNTW]): (\d\.\d)');
    var matches = exp.allMatches(nlpAnalysis);
    List<String> formattedItems = [];

    for (var match in matches) {
      String key = match.group(1)!;
      double value = double.parse(match.group(2)!) * 100;
      formattedItems.add('${key}: ${value.toStringAsFixed(0)}%');
    }

    return formattedItems.join(', ');
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
                      child: Text(_imageFiles != null && _imageFiles!.isNotEmpty ? '사진 변경' : '사진 추가'),
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
                  // onPressed: () => Navigator.of(context).pop(),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
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

                    // if (_imageFiles == null || _imageFiles!.isEmpty) {
                    //   setDialogState(() => _warningMessage = '리뷰 이미지를 추가해주세요.');
                    //   return;
                    // }
                    // 리뷰 추가 로직
                    ReviewRequest newReviewRequest = ReviewRequest(
                      content: content,
                      rating: _localRating,
                      cosmeticId: widget.cosmeticId,
                    );

                    try {
                      ReviewResponse responseReview = await ReviewService.addReview(
                          newReviewRequest, _imageFiles ?? []);
                      final loadedCosmeticInfo = await SearchService.searchCosmeticById(widget.cosmeticId);

                      double newAverageRating = loadedCosmeticInfo.first.averageRating ?? 0.0;

                      setState(() {
                        _cosmeticReviews.insert(0, responseReview);
                        updateAverageRating = newAverageRating;
                      });

                      Navigator.of(context).pop(updateAverageRating); // 다이얼로그 닫기
                      widget.onReviewAdded!(newAverageRating);
                      _showSnackBar('리뷰가 추가되었습니다');
                    } catch (e) {
                      _showSnackBar('리뷰 추가 실패하였습니다.:$e');
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
    return Expanded(
      child: ListView.separated(
        itemCount: _cosmeticReviews.length,
        separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey),
        itemBuilder: (context, index) {
          var review = _cosmeticReviews[index];
          bool isUserReview = _currentUser != null && review.user.id == _currentUser!.id;
          String baumannString = parseAndFormatBaumannAnalysis(review.nlpAnalysis);
          return Card(
            elevation: 2,
            margin: EdgeInsets.all(8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Column(
                children: [
            ListTile(
            // leading: Padding(padding:EdgeInsets.symmetric(horizontal: 10),child:Icon(Icons.person)), // 사용자 아이콘을 표시합니다.
            title: Padding(padding:EdgeInsets.symmetric(horizontal: 10),child:Text(review.user.email)), // 사용자 이름을 표시합니다.
            subtitle: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                children: [
                  ...List.generate(5, (starIndex) {
                    return Icon(
                      starIndex < review.rating ? Icons.star : Icons.star_border,
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
            ),
          ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        review.content,
                        style: TextStyle(fontSize: 16),
                      ),
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
                    if (isUserReview) // Show edit/delete only for user's reviews
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // IconButton(
                          //   icon: Icon(Icons.edit),
                          //   onPressed: () => _editReview(review), // Implement this method
                          // ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteReview(review), // Implement this method
                          ),
                        ],
                      ),
                    SizedBox(height: 10),
                    if (review.nlpAnalysis.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.all(20.0), // 여기서 원하는 패딩 값을 설정하세요.
                        child: Text(
                          '바우만 분석: $baumannString',
                          style: TextStyle(fontSize: 12),
                          softWrap: true, // 필요에 따라 줄바꿈
                        ),
                      ),
                  ],
                ),
              ),
            ]
            ),
          );
        },
      ),
    );
  }

  // 리뷰페이지 넘기기
  Widget _buildPaginationControls() {
    return _totalPages != 0
      ? Padding(
      padding: EdgeInsets.fromLTRB(5, 10, 5, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: _currentPage > 0
                ? () => _fetchReviewsForCosmetic(widget.cosmeticId, _currentPage - 1)
                : null,
          ),
          Text('Page ${_currentPage + 1} of $_totalPages'),
          IconButton(
            icon: Icon(Icons.arrow_forward_ios),
            onPressed: _currentPage < _totalPages - 1
                ? () => _fetchReviewsForCosmetic(widget.cosmeticId, _currentPage + 1)
                : null,
          ),
        ],
      ),
    ) : Padding(
          padding: EdgeInsets.fromLTRB(5, 10, 5, 20),
          child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: _currentPage > 0
              ? () => _fetchReviewsForCosmetic(widget.cosmeticId, _currentPage - 1)
                  : null,
            ),
            Text('Page ${_currentPage + 1} of 1'),
            IconButton(
              icon: Icon(Icons.arrow_forward_ios),
              onPressed: _currentPage < _totalPages - 1
              ? () => _fetchReviewsForCosmetic(widget.cosmeticId, _currentPage + 1)
                  : null,
            ),
          ],
        )
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
              right: -10,
              top: -10,
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
      appBar: MyAppBar(
        automaticallyImplyLeading: true,
        context: context,
        onBack: () {
          print('Custom back button pressed');
          Navigator.pop(context, productDetails);
        },
      ),
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
            if(_cosmeticReviews.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "해당 제품의 리뷰가 존재하지 않습니다.\n리뷰를 등록해주세요.",
                        style: TextStyle(color: Colors.grey, fontSize: 18),
                        textAlign: TextAlign.center,
                      )
                    ],
                  )
                )
              )

            else
              _buildReviewList(),
          _buildPaginationControls(),

        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addReview(); // 리뷰 추가 다이얼로그를 여는 버튼으로 변경
        },
        child: Icon(Icons.edit),
        backgroundColor: Color(0xffd86a04),
      ),
    );
  }
}
