import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/view/user/common/Login.dart';
import 'package:flutter/material.dart';

import 'FindPWAuth.dart';

/*
* 비밀번호 찾기
* */
class FindPW extends StatefulWidget {
  @override
  _FindPW createState() => _FindPW();
}

class _FindPW extends State<FindPW> with BaseUtilMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  final _txtFieldID = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  /*
  *메인 위젯
  *  */
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          replaceView(context, Login());
          return Future.value(false);
        },
        child: Theme(
            data: CustomStyles.defaultTheme(),
            child: Scaffold(
                key: _scaffoldKey,
                appBar: CustomStyles.defaultAppBar('비밀번호 찾기', () {
                  replaceView(context, Login());
                  return Future.value(false);
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
                                    child: Text('비밀번호 찾기',
                                        textAlign: TextAlign.center,
                                        style:
                                            CustomStyles.normal24TextStyle())),
                                Container(
                                  margin: EdgeInsets.only(top: 30),
                                  width: double.infinity,
                                  child: Text('비밀번호를 찾고자 하는 아이디를 입력해 주세요.',
                                      textAlign: TextAlign.center,
                                      style: CustomStyles.normal14TextStyle()),
                                ),
                                Container(
                                    margin: EdgeInsets.only(top: 30),
                                    child:
                                        CustomStyles.greyBorderRound7TextField(
                                            _txtFieldID, '아이디'))
                              ]))),
                      Container(
                          height: 50,
                          width: double.infinity,
                          child: CustomStyles.lightGreyBGSquareButtonStyle('다음',
                              () {
                            replaceView(context, FindPWAuth());
                          }))
                    ])))));
  }
}
