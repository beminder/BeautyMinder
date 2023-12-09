import 'dart:developer';
import 'dart:io';

import 'package:beautyminder/dto/review_request_model.dart';
import 'package:beautyminder/services/review_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../dto/review_response_model.dart';
import 'default_dialog.dart';

class UpdateDialog extends StatefulWidget {
  const UpdateDialog({
    super.key,
    this.icon,
    required this.onBarrierTap,
    required this.title,
    this.body,
    this.caption,
    required this.review,
    required this.callback,
  });

  final Widget? icon;
  final String title;
  final String? body;
  final String? caption;
  final Function() onBarrierTap;
  final ReviewResponse review;
  final Function() callback;

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  final _contentController = TextEditingController();

  late ReviewResponse review;
  late int _localRating;

  List<PlatformFile>? _imageFiles;

  Future<void> getImages() async {
    try {
      final imagePicker = ImagePicker();
      final XFile? pickedImage =
      await imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        final size = await pickedImage.length();

        final file = PlatformFile(
          name: pickedImage.name,
          path: pickedImage.path,
          size: size,
        );

        setState(() {
          _imageFiles = [file];
        });
      }
    } on PlatformException catch (e) {
      log('Unsupported operation' + e.toString());
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();

    review = widget.review;
    _localRating = review.rating;
    _contentController.text = review.content;
  }

  @override
  void dispose() {
    _contentController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onBarrierTap();
      },
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              constraints: const BoxConstraints(maxWidth: (305)),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular((10)),
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, 4),
                      blurRadius: 4,
                      spreadRadius: 0,
                      color: Colors.black.withOpacity(0.08),
                    )
                  ]),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),
                  const Row(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(),
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: (19),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: _contentController,
                          decoration: const InputDecoration(
                            hintText: 'Enter your review here',
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 15),
                        Container(
                          alignment: Alignment.center,
                          child: Column(
                            children: [
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
                                  if (value != null) {
                                    setState(() {
                                      _localRating = value;
                                    });
                                  }
                                },
                              ),
                              if (_imageFiles != null)
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.file(
                                        File(_imageFiles!.first.path!),
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      right: -10,
                                      top: -10,
                                      child: IconButton(
                                        icon: const Icon(Icons.remove_circle),
                                        color: Colors.red,
                                        onPressed: () {
                                          setState(() {
                                            _imageFiles = null;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.orange)),
                                onPressed: getImages,
                                child: const Text('사진 선택'),
                              ),
                            ],
                          ),
                        ),
                        if (widget.caption != null) ...[
                          const SizedBox(height: 20),
                          Text(
                            widget.caption ?? '',
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              height: 1.3,
                              color: Colors.grey,
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: UpdateDialogButton(
                            onTap: () async {
                              Navigator.of(context).pop();
                            },
                            text: "취소",
                            backgroundColor: const Color(0xFFF5F5F5),
                            textColor: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: UpdateDialogButton(
                            onTap: () async {
                              final bool result = await _updateReview();
                              if (result) {
                                Navigator.of(context).pop();
                              }
                            },
                            text: "수정",
                            backgroundColor: Colors.orange,
                            textColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _updateReview() async {
    final String content = _contentController.text;

    if (content.isEmpty) {
      await _showDialog(
        title: '리뷰가 입력 되지 않았습니다.',
        body: '변경하시려면 리뷰를 입력해주세요.',
      );

      return false;
    } else {
      final newReviewRequest = ReviewRequest(
        content: content,
        rating: _localRating, // 여기에서 _localRating 사용
        cosmeticId: review.cosmetic.id,
        imagesToDelete: review.images,
      );

      try {
        // 기존 리뷰 수정 로직
        await ReviewService.updateReview(
            review.id, newReviewRequest, _imageFiles ?? []);
        widget.callback();
      } catch (e) {
        // _showSnackBar('Failed to add/update review: $e');
      }
      return true;
    }
  }

  Future<void> _showDialog({
    required String title,
    required String body,
  }) async {
    await showDialog(
      context: context,
      builder: (context) {
        return DefaultDialog(
          onBarrierTap: () => Navigator.pop(context),
          title: title,
          body: body,
          buttons: [
            DefaultDialogButton(
              onTap: () => Navigator.pop(context),
              text: '확인',
              backgroundColor: const Color(0xFFFF820E),
              textColor: Colors.white,
            )
          ],
        );
      },
    );
  }
}

class UpdateDialogButton extends StatelessWidget {
  const UpdateDialogButton(
      {super.key,
        required this.onTap,
        required this.text,
        required this.backgroundColor,
        required this.textColor});
  final Function() onTap;
  final String text;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: (50),
        padding: const EdgeInsets.symmetric(horizontal: (20)),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular((10)),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
