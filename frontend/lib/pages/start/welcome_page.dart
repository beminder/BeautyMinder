import 'dart:async';

import 'package:beautyminder/pages/start/splash_page.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1500), () {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const SplashPage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          // Add a gradient or image background here
          gradient: LinearGradient(
            colors: [Color(0xffffe6be), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Center(
          child: AnimatedOpacity(
            opacity: 1.0,
            duration: Duration(milliseconds: 500),
            child: AppTitle(),
          ),
        ),
      ),
    );
  }
}

class AppTitle extends StatelessWidget {
  const AppTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: const TextSpan(
        text: 'Beauty',
        style: TextStyle(
          fontFamily: 'Oswald',
          fontSize: 40,
          fontWeight: FontWeight.w700,
          color: Color(0xfffe9738),
        ),
        children: [
          TextSpan(
            text: 'Minder',
            style: TextStyle(fontSize: 40),
          ),
        ],
      ),
    );
  }
}
