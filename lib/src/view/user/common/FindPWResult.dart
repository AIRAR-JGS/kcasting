import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/view/user/common/FindPWAuth.dart';
import 'package:casting_call/src/view/user/common/Login.dart';
import 'package:flutter/material.dart';

/*
* 비밀번호 재설정
* */
class FindPWResult extends StatefulWidget {
  @override
  _FindPWResult createState() => _FindPWResult();
}

class _FindPWResult extends State<FindPWResult> with BaseUtilMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  final _txtFieldPW = TextEditingController();
  final _txtFieldPWCheck = TextEditingController();

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
          replaceView(context, FindPWAuth());
          return Future.value(false);
        },
        child: Theme(
            data: CustomStyles.defaultTheme(),
            child: Scaffold(
                key: _scaffoldKey,
                appBar: CustomStyles.defaultAppBar('비밀번호 재설정', () {
                  replaceView(context, FindPWAuth());
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
                                    child: Text('비밀번호 재설정',
                                        textAlign: TextAlign.center,
                                        style:
                                            CustomStyles.normal24TextStyle())),
                                Container(
                                    margin: EdgeInsets.only(top: 30),
                                    width: double.infinity,
                                    child: Text('새로운 비밀번호를 입력해 주세요.',
                                        textAlign: TextAlign.center,
                                        style:
                                            CustomStyles.normal14TextStyle())),
                                Container(
                                    margin: EdgeInsets.only(top: 30),
                                    alignment: Alignment.centerLeft,
                                    child: Text('비밀번호',
                                        style:
                                            CustomStyles.normal14TextStyle())),
                                Container(
                                    margin: EdgeInsets.only(top: 5),
                                    child: CustomStyles
                                        .greyBorderRound7PWDTextField(
                                            _txtFieldPW,
                                            '대문자, 소문자, 숫자 조합으로 가능합니다.')),
                                Container(
                                    margin: EdgeInsets.only(top: 15),
                                    alignment: Alignment.centerLeft,
                                    child: Text('비밀번호 확인',
                                        style:
                                            CustomStyles.normal14TextStyle())),
                                Container(
                                    margin: EdgeInsets.only(top: 5),
                                    child: CustomStyles
                                        .greyBorderRound7PWDTextField(
                                            _txtFieldPWCheck,
                                            '비밀번호를 한번 더 입력해 주세요.'))
                              ]))),
                      Container(
                          height: 50,
                          width: double.infinity,
                          color: Colors.grey,
                          child: CustomStyles.lightGreyBGSquareButtonStyle('확인',
                              () {
                            replaceView(context, Login());
                          }))
                    ])))));
  }
}
