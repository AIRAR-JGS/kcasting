import 'dart:async';

import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/view/user/common/JoinSelectType.dart';
import 'package:casting_call/src/view/user/common/SelfAuth.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

class AuthWebView extends StatefulWidget {
  @override
  _AuthWebView createState() => _AuthWebView();
}

class _AuthWebView extends State<AuthWebView> with BaseUtilMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  WebViewPlusController _controller;
  double _height = 1;

  String selectedUrl =
      'https://k-casting.com/nice/checkplusSafe/checkplus_main.php';

  Set<JavascriptChannel> jsChannels;

  @override
  Future<void> initState() {
    super.initState();

    //if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();

    jsChannels = [
      JavascriptChannel(
          name: 'KCastingAuth',
          onMessageReceived: (JavascriptMessage message) {
            print(message.message);

            returnToJoinPage(message.message);
          })
    ].toSet();
  }

  void returnToJoinPage(String result) {
    List<String> resArr = result.split('|');

    String authRes = resArr[0];
    String authName = resArr[1];
    String authPhone = resArr[2];
    String authBirth = resArr[3];
    String authGender = resArr[4];

    replaceView(
        context,
        SelfAuth(
            authRes: authRes,
            authName: authName,
            authPhone: authPhone,
            authBirth: authBirth,
            authGender: authGender,
            memberType: 'A'));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          // 로그인 페이지 이동
          return Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => JoinSelectType()),
          );
        },
        child: Theme(
            data: CustomStyles.defaultTheme(),
            child: Scaffold(
                key: _scaffoldKey,
                appBar: CustomStyles.defaultAppBar('본인인증', () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => JoinSelectType()),
                  );
                }),
                body: Builder(builder: (BuildContext context) {
                  return WebViewPlus(
                      initialUrl: selectedUrl,
                      javascriptMode: JavascriptMode.unrestricted,
                      javascriptChannels: jsChannels,
                      debuggingEnabled: true,
                      allowsInlineMediaPlayback: true,
                      onWebViewCreated: (webViewController) {
                        this._controller = webViewController;
                      },
                      onProgress: (int progress) {
                        print("WebView is loading (progress : $progress%)");
                      },
                      navigationDelegate: (NavigationRequest request) {
                        if (request.url
                            .startsWith('https://itunes.apple.com')) {
                          print('blocking navigation to $request}');
                          return NavigationDecision.prevent;
                        }
                        if (request.url.startsWith('niceipin2')) {
                          print('blocking navigation to $request}');
                          return NavigationDecision.prevent;
                        }
                        print('allowing navigation to $request');
                        return NavigationDecision.navigate;
                      },
                      onPageStarted: (String url) {
                        print('Page started loading: $url');
                      },
                      onPageFinished: (String url) {
                        print('Page finished loading: $url');
                      },
                      gestureNavigationEnabled: true);
                }))));
  }
}
