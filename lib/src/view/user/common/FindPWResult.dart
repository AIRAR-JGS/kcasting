import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/view/user/common/FindPW.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Login.dart';

/*
* 비밀번호 찾기 결과
* */
class FindPWResult extends StatefulWidget {
  final String id;

  const FindPWResult({Key key, this.id}) : super(key: key);

  @override
  _FindPWResult createState() => _FindPWResult();
}

class _FindPWResult extends State<FindPWResult> with BaseUtilMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  String _id = "";

  @override
  void initState() {
    super.initState();

    _id = widget.id;
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
                    padding: EdgeInsets.only(left: 30, right: 30),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                              margin: EdgeInsets.only(top: 30),
                              alignment: Alignment.center,
                              width: double.infinity,
                              child: Text('비밀번호 찾기',
                                  textAlign: TextAlign.center,
                                  style: CustomStyles.normal24TextStyle())),
                          Container(
                              margin: EdgeInsets.only(top: 30),
                              width: double.infinity,
                              child: Text(
                                  '아래의 이메일 주소로 임시 비밀번호를 발송하였습니다.\n임시 비밀번호로 로그인 하신 뒤 보안을 위해 비밀번호 변경을 해주세요.',
                                  textAlign: TextAlign.start,
                                  style: CustomStyles.normal14TextStyle())),
                          Container(
                              margin: EdgeInsets.only(top: 20),
                              alignment: Alignment.center,
                              width: double.infinity,
                              child: Text(_id,
                                  textAlign: TextAlign.center,
                                  style: CustomStyles.normal16TextStyle())),
                          Container(
                              margin: EdgeInsets.only(top: 40),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                        flex: 1,
                                        child: Container(
                                            margin: EdgeInsets.only(right: 10),
                                            height: 50,
                                            child: CustomStyles
                                                .greyBorderRound7ButtonStyle(
                                                    '로그인', () {
                                              replaceView(context, Login());
                                            })))
                                  ]))
                        ])))));
  }
}
