import 'package:flutter/material.dart';

class MyDivider extends StatelessWidget {
  const MyDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 0.5, thickness: 1, color: Color(0xFFDFDFDF));
  }
}
