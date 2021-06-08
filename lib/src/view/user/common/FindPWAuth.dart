import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/view/user/common/FindPW.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'FindPWResult.dart';

/*
* 비밀번호 찾기 휴대폰 인증
* */
class FindPWAuth extends StatefulWidget {
  @override
  _FindPWAuth createState() => _FindPWAuth();
}

class _FindPWAuth extends State<FindPWAuth> with BaseUtilMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  final _txtFieldName = TextEditingController();
  final _txtFieldPhone = TextEditingController();
  final _txtFieldCode = TextEditingController();

  bool _isAuthError = false;

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
          replaceView(context, FindPW());
          return Future.value(false);
        },
        child: Theme(
            data: CustomStyles.defaultTheme(),
            child: Scaffold(
                key: _scaffoldKey,
                appBar: CustomStyles.defaultAppBar('비밀번호 찾기', () {
                  replaceView(context, FindPW());
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
                                    child: Text(
                                        '회원정보에 등록한 휴대전화 번호와 입력한 휴대전화 번호가 같아야, 인증번호를 받을 수 있습니다.',
                                        textAlign: TextAlign.center,
                                        style:
                                            CustomStyles.normal14TextStyle())),
                                Container(
                                    margin: EdgeInsets.only(top: 30),
                                    child:
                                        CustomStyles.greyBorderRound7TextField(
                                            _txtFieldName, '이름')),
                                Container(
                                    margin: EdgeInsets.only(top: 5),
                                    width: double.infinity,
                                    child: Row(children: [
                                      Expanded(
                                          flex: 1,
                                          child: Container(
                                              child: CustomStyles
                                                  .greyBorderRound7TextFieldWithOption(
                                                      _txtFieldPhone,
                                                      TextInputType.number,
                                                      '휴대폰 번호'))),
                                      Expanded(
                                          flex: 0,
                                          child: Container(
                                              height: 48,
                                              margin: EdgeInsets.only(left: 5),
                                              child: CustomStyles
                                                  .greyBGRound7ButtonStyle(
                                                      '인증번호 받기', () {
                                                // 인증번호 받기 버튼 클릭
                                              })))
                                    ])),
                                Container(
                                    margin: EdgeInsets.only(top: 5),
                                    child: CustomStyles
                                        .greyBorderRound7TextFieldWithOption(
                                            _txtFieldCode,
                                            TextInputType.number,
                                            '인증번호')),
                                Visibility(
                                    child: Container(
                                        margin: EdgeInsets.only(top: 30),
                                        width: double.infinity,
                                        child: Text('인증번호가 틀립니다. 다시 입력해 주세요.',
                                            textAlign: TextAlign.center,
                                            style:
                                                CustomStyles.red14TextStyle())),
                                    visible: _isAuthError)
                              ]))),
                      Container(
                          height: 50,
                          width: double.infinity,
                          child: CustomStyles.lightGreyBGSquareButtonStyle('다음',
                              () {
                            replaceView(context, FindPWResult());
                          }))
                    ])))));
  }
}
