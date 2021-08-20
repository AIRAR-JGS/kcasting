import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/KCastingAppData.dart';
import 'package:casting_call/main.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:flutter/material.dart';

/*
* 14세 미만 배우 회원가입 완료 클래스
* */
class JoinActorChildComplete extends StatefulWidget {
  @override
  _JoinActorChildComplete createState() => _JoinActorChildComplete();
}

class _JoinActorChildComplete extends State<JoinActorChildComplete>
    with BaseUtilMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  /*
  *  메인위젯
  * */
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          return Future.value(true);
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
                      appBar: CustomStyles.defaultAppBar('가입완료', () {
                        Navigator.pop(context);
                      }),
                      body: Container(
                          padding: EdgeInsets.only(left: 30, right: 30),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                    alignment: Alignment.center,
                                    width: double.infinity,
                                    child: Text('회원가입이 완료되었습니다!',
                                        textAlign: TextAlign.center,
                                        style:
                                            CustomStyles.normal24TextStyle())),
                                Container(
                                    margin:
                                        EdgeInsets.only(top: 30, bottom: 50),
                                    alignment: Alignment.center,
                                    width: double.infinity,
                                    child: Text(
                                        '14세 미만 회원가입의 경우 보호자 인증서류를 검토하는데 최대 1~2일이 소요됩니다.\n서류검토가 끝난 후 서비스 이용이 가능합니다.',
                                        textAlign: TextAlign.center,
                                        style:
                                            CustomStyles.normal14TextStyle())),
                                Container(
                                    height: 50,
                                    width:
                                    (KCastingAppData().isWeb)
                                        ? CustomStyles.appWidth * 0.4
                                        : MediaQuery.of(context).size.width * 0.4,
                                    child: CustomStyles
                                        .greyBorderRound7ButtonStyle("로그인", () {
                                      replaceView(context, MyApp());
                                    }))
                              ])),
                    )))));
  }
}
