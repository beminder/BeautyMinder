import 'package:beautyminder/pages/my/widgets/center_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../dto/review_response_model.dart';
import 'delete_popup.dart';
import 'update_dialog.dart';

class ReviewCard extends StatelessWidget {
  final ReviewResponse review;
  final VoidCallback updateParentVariable;

  const ReviewCard({
    super.key,
    required this.review,
    required this.updateParentVariable,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 0),
      padding: const EdgeInsets.only(left: 20, right: 0, top: 0, bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width / 2.2,
                child: Text(
                  review.cosmetic.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit,
                          color: Colors.orange, size: 18),
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder: (context) => UpdateDialog(
                            onBarrierTap: () {
                              Navigator.of(context).pop();
                            },
                            title: review.cosmetic.name,
                            review: review,
                            callback: updateParentVariable,
                          ),
                        );
                      },
                      color: Colors.orange,
                      iconSize: 15, // Adjust size as needed
                    ),
                    // SizedBox(width: 5),
                    IconButton(
                      icon: const Icon(Icons.delete,
                          color: Colors.orange, size: 18),
                      onPressed: () async {
                        final ok = await deletePopUp(
                          context: context,
                          title: '정말 삭제하시겠습니까?',
                          callback: updateParentVariable,
                          id: review.id,
                        );
                      },
                      color: Colors.orange,
                      iconSize: 15, // Adjust size as needed
                    ),
                  ],
                ),
              )
            ],
          ),
          Row(
            children: [
              ...List.generate(5, (starIndex) {
                return Icon(
                  starIndex < review.rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 20,
                );
              }),
              const SizedBox(width: 8),
              Text(
                '${review.rating} Stars',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 20),
            child: Text(
              review.content,
              textAlign: TextAlign.justify,
            ),
          ),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: review.images.map((image) {
              return GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => CenterImage(image: image),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0), // 모서리를 둥글게 처리
                  child: CachedNetworkImage(
                    imageUrl: image,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover, // 이미지가 공간을 가득 채우도록 조정
                    errorWidget: (context, url, error) =>
                    const SizedBox.shrink(),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
