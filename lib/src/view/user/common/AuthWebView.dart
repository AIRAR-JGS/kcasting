import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/view/user/common/JoinSelectType.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

/*
*  법인 조회
* */
class AuthWebView extends StatefulWidget {
  @override
  _AuthWebView createState() => _AuthWebView();
}

class _AuthWebView extends State<AuthWebView> with BaseUtilMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  String selectedUrl = 'https://www.airar.co.kr/kcastingTestPage.html';

  final Set<JavascriptChannel> jsChannels = [
    JavascriptChannel(
        name: 'KCastingAuth',
        onMessageReceived: (JavascriptMessage message) {
          print(message.message);
        }),
  ].toSet();

  final flutterWebViewPlugin = FlutterWebviewPlugin();

  @override
  Future<void> initState() {
    super.initState();
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
                appBar: CustomStyles.defaultAppBar('법인 조회', () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => JoinSelectType()),
                  );
                }),
                body: Builder(builder: (BuildContext context) {
                  return WebviewScaffold(
                      url: selectedUrl,
                      javascriptChannels: jsChannels,
                      mediaPlaybackRequiresUserGesture: false,
                      withZoom: true,
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
