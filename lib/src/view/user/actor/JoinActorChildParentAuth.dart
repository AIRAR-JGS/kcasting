import 'package:casting_call/res/CustomStyles.dart';
import 'package:flutter/material.dart';

/*
* 14세 미만 배우 회원가입 시 보호자 인증 서류 제출하기
* */
class JoinActorChildParentAuth extends StatefulWidget {
  @override
  _JoinActorChildParentAuth createState() => _JoinActorChildParentAuth();
}

class _JoinActorChildParentAuth extends State<JoinActorChildParentAuth> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  /*
  * 메인 위젯
  * */
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          return Future.value(true);
        },
        child: Theme(
            data: CustomStyles.defaultTheme(),
            child: Scaffold(
                key: _scaffoldKey,
                appBar: CustomStyles.defaultAppBar('보호자 인증', () {
                  Navigator.pop(context);
                }),
                body: Container(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                      Expanded(
                          flex: 1,
                          child: Container(
                              padding: EdgeInsets.only(left: 30, right: 30),
                              child: Column(children: [
                                Container(
                                    margin: EdgeInsets.only(top: 30),
                                    alignment: Alignment.center,
                                    width: double.infinity,
                                    child: Text('보호자 인증',
                                        textAlign: TextAlign.center,
                                        style:
                                            CustomStyles.normal24TextStyle())),
                                Container(
                                    margin: EdgeInsets.only(top: 30),
                                    width: double.infinity,
                                    child: Text(
                                        '서류검토를 위해서 회원가입이 최대 1-2일 지연될 수 있습니다.',
                                        textAlign: TextAlign.start,
                                        style:
                                            CustomStyles.normal14TextStyle())),
                                Container(
                                  margin: EdgeInsets.only(top: 30),
                                  width: double.infinity,
                                  child: Text('제출가능한 서류',
                                      textAlign: TextAlign.start,
                                      style: CustomStyles.normal16TextStyle()),
                                ),
                                Container(
                                    margin: EdgeInsets.only(top: 10),
                                    width: double.infinity,
                                    child: Text('법적대리인의 주민등록등본, 건강보험증, 가족관계증명서',
                                        textAlign: TextAlign.start,
                                        style:
                                            CustomStyles.normal14TextStyle()))
                              ]))),
                      Container(
                          height: 50,
                          width: double.infinity,
                          child: CustomStyles.lightGreyBGSquareButtonStyle(
                              '제출하기', () {
                            Navigator.pop(context);
                          }))
                    ])))));
  }
}
