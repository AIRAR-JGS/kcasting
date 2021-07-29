import 'dart:async';
import 'dart:io';

import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/view/user/common/JoinSelectType.dart';
import 'package:casting_call/src/view/user/common/SelfAuth.dart';
import 'package:flutter/material.dart';

//import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:webview_flutter/webview_flutter.dart';

/*
*  본인인증 웹뷰
* */
class AuthWebView extends StatefulWidget {
  @override
  _AuthWebView createState() => _AuthWebView();
}

class _AuthWebView extends State<AuthWebView> with BaseUtilMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  String selectedUrl =
      'https://k-casting.com/nice/checkplusSafe/checkplus_main.php';

  Set<JavascriptChannel> jsChannels;

  @override
  Future<void> initState() {
    super.initState();

    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();

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

  /*
  *  메인위젯
  * */
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
                  return WebView(
                      initialUrl: selectedUrl,
                      javascriptMode: JavascriptMode.unrestricted,
                      javascriptChannels: jsChannels,
                      debuggingEnabled: true,
                      onWebViewCreated: (WebViewController webViewController) {
                        _controller.complete(webViewController);
                      },
                      onProgress: (int progress) {
                        print("WebView is loading (progress : $progress%)");
                      },
                      navigationDelegate: (NavigationRequest request) {
                        if (request.url
                            .startsWith('https://www.youtube.com/')) {
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

/*
import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/view/user/common/JoinSelectType.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

*/
/*
*  법인 조회
* */ /*

class AuthWebView extends StatefulWidget {
  @override
  _AuthWebView createState() => _AuthWebView();
}

class _AuthWebView extends State<AuthWebView> with BaseUtilMixin {
  // Instance of WebView plugin

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  String selectedUrl =
      'https://k-casting.com/nice/checkplusSafe/checkplus_main.php';

  final Set<JavascriptChannel> jsChannels = [
    JavascriptChannel(
        name: 'KCastingAuth',
        onMessageReceived: (JavascriptMessage message) {
          print(message.message);
        }),
    JavascriptChannel(
        name: 'Alert',
        onMessageReceived: (JavascriptMessage message) {

        }),
    
  ].toSet();

  final flutterWebViewPlugin = FlutterWebviewPlugin();

  @override
  Future<void> initState() {
    super.initState();

    flutterWebViewPlugin.onStateChanged.listen((viewState) async {
      if (viewState.type == WebViewState.finishLoad) {
        flutterWebViewPlugin.evalJavascript(js);
      }
    });
  }

  */
/*
  *  메인위젯
  * */ /*

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
                  return WebviewScaffold(
                      
                      url: selectedUrl,
                      javascriptChannels: jsChannels,
                      enableAppScheme: true,
                      mediaPlaybackRequiresUserGesture: false,
                      withZoom: true,
                      withJavascript: true,
                      withLocalStorage: true,
                      hidden: true,
                      initialChild: Container(
                          alignment: Alignment.center,
                          child: CircularProgressIndicator()),
                      bottomNavigationBar: BottomAppBar(
                          child: Row(children: <Widget>[
                        IconButton(
                            icon: const Icon(Icons.arrow_back_ios),
                            onPressed: () {
                              flutterWebViewPlugin.goBack();
                            }),
                        IconButton(
                            icon: const Icon(Icons.arrow_forward_ios),
                            onPressed: () {
                              flutterWebViewPlugin.goForward();
                            }),
                        IconButton(
                            icon: const Icon(Icons.autorenew),
                            onPressed: () {
                              flutterWebViewPlugin.reload();
                            })
                      ])));
                }))));
  }
}
*/
