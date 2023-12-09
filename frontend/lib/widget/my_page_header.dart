import 'package:flutter/material.dart';

class MyPageHeader extends StatelessWidget {
  final String text;

  const MyPageHeader(
    this.text, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 37),
        Text(
          text,
          style: const TextStyle(fontSize: 15, color: Color(0xFF868383)),
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 2),
        const Divider(height: 1, thickness: 1, color: Color(0xFFADABAB)),
      ],
    );
  }
}
