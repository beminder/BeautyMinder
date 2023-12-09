import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CenterImage extends StatelessWidget {
  final String image;

  const CenterImage({
    super.key,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: CachedNetworkImage(
        imageUrl: image,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => const SizedBox.shrink(),
      ),
    );
  }
}


