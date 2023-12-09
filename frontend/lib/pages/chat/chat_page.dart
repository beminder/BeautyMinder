import 'dart:async';
import 'dart:io' show Platform;

import 'package:beautyminder/widget/appBar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config.dart';
import '../../services/shared_service.dart';
import '../../widget/custom_willpop.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late InAppWebViewController webViewController;

  String api = "http://${Config.apiURL}${Config.chatAPI}";
  bool isApiCallProcess = false;
  bool isLoading = true;

  late final accessToken;
  late final refreshToken;


  @override
  void initState() {
    super.initState();
    _getTokens();
  }

  Future<void> _getTokens() async {

    if (isApiCallProcess) {
      return;
    }

    setState(() {
      isLoading = true;
      isApiCallProcess = true;
    });

    try {
      final loadedAccessToken = await SharedService.getAccessToken();
      final loadedRefreshToken = await SharedService.getRefreshToken();

      setState(() {
        accessToken = loadedAccessToken;
        refreshToken = loadedRefreshToken;
      });

    } catch (e) {
      print('An error occurred : $e');
    }
    finally {
      setState(() {
        isLoading = false;
        isApiCallProcess = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: SpinKitThreeInOut(
          color: Color(0xffd86a04),
          size: 50.0,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      if (kIsWeb) {
        launchUrl(Uri.parse(api));
        return const Text("Web opened");
      } else {
        return Scaffold(
          appBar: CommonAppBar(
            automaticallyImplyLeading: true,
            context: context,
          ),
          body: _buildWebView(context),
        );
      }
    }
  }

  Widget _buildWebView(BuildContext context) {
    CookieManager cookieManager = CookieManager.instance();

    return Platform.isAndroid
        ? WillPopScope(
            onWillPop: () => _goBack(context),
            child: _createInAppWebView(cookieManager),
          )
        : CustomWillPopScope(
            canPop: true,
            action: () => _goBack(context),
            child: _createInAppWebView(cookieManager),
          );
  }

  InAppWebView _createInAppWebView(CookieManager cookieManager) {
    return InAppWebView(
      // ... common InAppWebView setup ...
      onWebViewCreated: (controller) {
        webViewController = controller;
      },
      initialUrlRequest: URLRequest(
        url: Uri.parse(api),
        headers: {"Authorization": "Bearer $accessToken"},
      ),
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        var request = navigationAction.request;
        var url = request.url;
        var isUrlMatching = url != null &&
            url.host.contains('ec2') &&
            url.path.contains('/chat');

        // set the cookie
        await cookieManager.setCookie(
          url: url!,
          name: "Access-Token",
          value: accessToken.toString(),
        );
        if (Platform.isIOS && isUrlMatching && request.headers != null) {
          return NavigationActionPolicy.ALLOW;
        }

        if (isUrlMatching) {
          request.headers = {"Authorization": "Bearer $accessToken"};
          controller.loadUrl(urlRequest: request);
          return NavigationActionPolicy.CANCEL;
        }
        // always allow  all the other requests
        return NavigationActionPolicy.ALLOW;
      },
      initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            useShouldOverrideUrlLoading: true, // URL 로딩 제어
            javaScriptEnabled: true, // 자바스크립트 실행 여부
            javaScriptCanOpenWindowsAutomatically: true, // 팝업 여부
          ),
          ios:
              IOSInAppWebViewOptions(allowsBackForwardNavigationGestures: true),
          // 안드로이드 옵션
          android: AndroidInAppWebViewOptions(
            useHybridComposition: true, // 하이브리드 사용을 위한 안드로이드 웹뷰 최적화
          )),
    );
  }

  Future<bool> _goBack(BuildContext context) async {
    if (await webViewController.canGoBack()) {
      var result =
      await webViewController.evaluateJavascript(source: "quit()") as bool;
      return Future.value(!result);
    }
    return Future.value(false);
  }
}