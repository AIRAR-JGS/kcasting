import 'dart:io';

import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/view/user/actor/JoinActorAdult.dart';
import 'package:casting_call/src/view/user/actor/JoinActorChildParentAgree.dart';
import 'package:casting_call/src/view/user/common/AuthWebView.dart';
import 'package:casting_call/src/view/user/common/JoinSelectType.dart';
import 'package:flutter/material.dart';
import 'package:webviewx/webviewx.dart' as webViewX;

import '../../../../KCastingAppData.dart';

/*
*  개인 본인인증
* */
class SelfAuth extends StatefulWidget {
  final String authRes;
  final String authName;
  final String authPhone;
  final String authBirth;
  final String authGender;
  final String memberType;

  const SelfAuth(
      {Key key,
      this.authRes,
      this.authName,
      this.authPhone,
      this.authBirth,
      this.authGender,
      this.memberType})
      : super(key: key);

  @override
  _SelfAuth createState() => _SelfAuth();
}

class _SelfAuth extends State<SelfAuth> with BaseUtilMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  bool _isUpload = false;

  String _authComplete; // before, success, fail
  String _authRes;
  String _authName;
  String _authPhone;
  String _authBirth;
  String _authGender;
  String _memberType;

  String _title = '';
  String _msg = '';
  String _retVal = '';

  webViewX.WebViewXController webViewController;

  void dispose() {
    webViewController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _authRes = widget.authRes;
    _authName = widget.authName;
    _authPhone = widget.authPhone;
    _authBirth = widget.authBirth;
    _authGender = widget.authGender;
    _memberType = widget.memberType;

    if (_memberType == 'A') {
      _title = "본인인증";
      _msg =
          '배우 회원은 오디션 지원 및 계약 시 실명과 연락처 정보가 필요합니다.\n\n따라서 배우회원가입을 하시려면 본인인증을 해주셔야 합니다.\n\n실명과 연락처 정보는 대면면접 일정안내 또는 계약서 작성 이외의 다른 용도로 사용되지 않습니다.';
    } else {
      _title = "법정대리인 본인인증";
      _msg = '14세 미만 가입자는 법정대리인의 인증절차가 필요합니다. 법정대리인의 본인인증 절차를 진행해 주세요.';
    }

    if (_authComplete == "TRUE") {
      showSnackBar(context, "본인인증이 완료되었습니다.");
    } else if (_authComplete == "FALSE") {
      showSnackBar(context, "본인인증에 실패하였습니다. 다시 시도해 주세요.");
    }
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
            child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                    width: KCastingAppData().isWeb
                        ? CustomStyles.appWidth
                        : double.infinity,
                    child: Scaffold(
                        key: _scaffoldKey,
                        appBar: CustomStyles.defaultAppBar('본인 인증', () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => JoinSelectType()),
                          );
                        }),
                        body: Builder(builder: (BuildContext context) {
                          return Stack(children: [
                            Container(
                                child: Column(children: [
                              Expanded(
                                  flex: 1,
                                  child: SingleChildScrollView(
                                      child: Container(
                                          padding: EdgeInsets.only(
                                              top: 30, bottom: 50),
                                          child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                    margin: EdgeInsets.only(
                                                        bottom: 30),
                                                    alignment: Alignment.center,
                                                    child: Text(_title,
                                                        style: CustomStyles
                                                            .normal24TextStyle())),
                                                Visibility(
                                                    child: Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 15,
                                                                right: 15),
                                                        margin: EdgeInsets.only(
                                                            bottom: 30),
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(_msg,
                                                            style: CustomStyles
                                                                .normal16TextStyle())),
                                                    visible: _authRes == ''
                                                        ? true
                                                        : false),
                                                Visibility(
                                                    child: Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 15,
                                                                right: 15),
                                                        margin: EdgeInsets.only(
                                                            bottom: 30),
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                            '본인인증이 완료되었습니다!\n회원가입을 진행해 주세요.',
                                                            style: CustomStyles
                                                                .normal16TextStyle())),
                                                    visible: _authRes == 'TRUE'
                                                        ? true
                                                        : false),
                                                Visibility(
                                                    child: Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 15,
                                                                right: 15),
                                                        margin: EdgeInsets.only(
                                                            bottom: 30),
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                            '본인인증에 실패하였습니다. 다시 시도해 주세요.',
                                                            style: CustomStyles
                                                                .normal16TextStyle())),
                                                    visible: _authRes == 'FALSE'
                                                        ? true
                                                        : false)
                                              ])))),
                              Visibility(
                                  child: Container(
                                      height: 50,
                                      width: double.infinity,
                                      child: CustomStyles
                                          .lightGreyBGSquareButtonStyle(
                                              '본인인증하기', () {
                                        bool isWeb;
                                        try {
                                          if (Platform.isAndroid ||
                                              Platform.isIOS) {
                                            isWeb = false;
                                          } else {
                                            isWeb = true;
                                          }
                                        } catch (e) {
                                          isWeb = true;
                                        }

                                        if (isWeb) {
                                          showDialog(context: context,
                                              barrierDismissible: false,
                                              builder: (BuildContext _context){
                                            return AlertDialog(

                                              title: Text('본인인증'),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    margin : EdgeInsets.only( bottom: 20),
                                                    child: Icon(Icons.lock, color: Colors.grey,size: 90,),
                                                  ),
                                                  Container(
                                                    alignment: Alignment.center,
                                                    width: 400,
                                                    margin : EdgeInsets.only(bottom: 20),
                                                    child: Text('휴대폰 본인 인증을 마치고 완료 버튼을 눌러주세요.'),
                                                  ),
                                                  _buildWebViewX(),
                                                  CustomStyles
                                                      .lightGreyBGSquareButtonStyle('본인인증 완료', () {
                                                    _callPlatformIndependentJsMethod();
                                                    returnToJoinPageWeb(_retVal, _context);
                                                  })
                                                ],
                                              ),
                                            );
                                          });
                                        } else {
                                          replaceView(
                                              context,
                                              AuthWebView(
                                                  memberType: _memberType));
                                        }
                                      })),
                                  visible: _authRes == 'TRUE' ? false : true),
                              Visibility(
                                  child: Container(
                                      height: 50,
                                      width: double.infinity,
                                      child: CustomStyles
                                          .lightGreyBGSquareButtonStyle(
                                              '배우 회원가입', () {
                                        if (_memberType == 'A') {
                                          replaceView(
                                              context,
                                              JoinActorAdult(
                                                  authName: _authName,
                                                  authPhone: _authPhone,
                                                  authBirth: _authBirth,
                                                  authGender: _authGender));
                                        } else {
                                          replaceView(
                                              context,
                                              JoinActorChildParentAgree(
                                                  authName: _authName,
                                                  authPhone: _authPhone,
                                                  authBirth: _authBirth,
                                                  authGender: _authGender));
                                        }
                                      })),
                                  visible: _authRes == 'TRUE' ? true : false)
                            ])),
                            Visibility(
                                child: Container(
                                    color: Colors.black38,
                                    alignment: Alignment.center,
                                    child: CircularProgressIndicator()),
                                visible: _isUpload)
                          ]);
                        }))))));
  }

  Future<void> _callPlatformIndependentJsMethod() async {
    try {
      await webViewController.callJsMethod('platformSpecificMethod', []);
    } catch (e) {
        print(e);
    }
  }

  Future<void> _callPlatformIndependentJsMethodCloseWindow() async {
    try {
      await webViewController.callJsMethod('closeWin', []);
    } catch (e) {
        print(e);
    }
  }

  Widget _buildWebViewX() {
    final initialContent =
        '<html>'
        '<script>'
        'var openWin;'
        'openWin = window.open("https://k-casting.com/nice/checkplusSafe/checkplus_main.php", "popupChk", "width=500, height=550, fullscreen=no, menubar=no, status=no, toolbar=no, titlebar=yes, scrollbar=no, left = 200, top = 200");'

        'var dataaa = "null";'
        'function resultSuccess(data){ console.log(data); dataaa = data; }'
        '</script>'
        '</html>';

    return webViewX.WebViewX(
      key: const ValueKey('webviewx'),
      initialContent: initialContent,
      initialSourceType: webViewX.SourceType.html,
      height: 10,
      width: 10,
      onWebViewCreated: (controller) => webViewController = controller,
      jsContent: const {
        webViewX.EmbeddedJsContent(
            js: "function platformSpecificMethod() { dartCallback(dataaa) }"
        ),
        webViewX.EmbeddedJsContent(
            js: "function closeWin() { openWin.close(); }"
        ),
      },
      dartCallBacks: {
        webViewX.DartCallback(
          name: 'dartCallback',
          callBack: (msg){
            _retVal = msg;
          },
        )
      },
      webSpecificParams: const webViewX.WebSpecificParams(
        printDebugInfo: true,
      ),
      mobileSpecificParams: const webViewX.MobileSpecificParams(
        androidEnableHybridComposition: true,
      ),
      navigationDelegate: (navigation) {
        debugPrint(navigation.content.sourceType.toString());
        return webViewX.NavigationDecision.navigate;
      },
    );
  }

  void returnToJoinPageWeb(String result, BuildContext _context) {
    if(result != 'null'){
      List<String> resArr = result.split('|');
      // print('In returnToJoinPage, result is $resArr');

      String authRes = resArr[0];
      String authName = resArr[1];
      String authPhone = resArr[2];
      String authBirth = resArr[3];
      String authGender = resArr[4];

      if(resArr[0] == 'TRUE'){
        replaceView(
            context,
            SelfAuth(
                authRes: authRes,
                authName: authName,
                authPhone: authPhone,
                authBirth: authBirth,
                authGender: authGender,
                memberType: _memberType));
      }else{
        showSnackBar(context, '본인 인증을 다시 시도해주세요');
        _callPlatformIndependentJsMethodCloseWindow();
        Navigator.pop(_context);

      }
    }else{
      showSnackBar(context, '본인 인증을 다시 시도해주세요');
      _callPlatformIndependentJsMethodCloseWindow();
      Navigator.pop(_context);
    }
  }
}
