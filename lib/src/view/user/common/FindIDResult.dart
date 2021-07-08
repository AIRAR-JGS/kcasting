import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/view/user/common/FindID.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'FindPW.dart';
import 'Login.dart';

/*
* 아이디 찾기 결과
* */
class FindIDResult extends StatefulWidget {
  final String id;

  const FindIDResult({Key key, this.id}) : super(key: key);

  @override
  _FindIDResult createState() => _FindIDResult();
}

class _FindIDResult extends State<FindIDResult> with BaseUtilMixin {
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
          replaceView(context, FindID());
          return Future.value(false);
        },
        child: Theme(
            data: CustomStyles.defaultTheme(),
            child: Scaffold(
                key: _scaffoldKey,
                appBar: CustomStyles.defaultAppBar('아이디 찾기', () {
                  replaceView(context, FindID());
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
                              child: Text('아이디 찾기',
                                  textAlign: TextAlign.center,
                                  style: CustomStyles.normal24TextStyle())),
                          Container(
                              margin: EdgeInsets.only(top: 30),
                              width: double.infinity,
                              child: Text('고객님의 정보와 일치하는 아이디 목록입니다.',
                                  textAlign: TextAlign.center,
                                  style: CustomStyles.normal14TextStyle())),
                          Container(
                              margin: EdgeInsets.only(top: 30),
                              alignment: Alignment.center,
                              width: double.infinity,
                              child: Text(_id,
                                  textAlign: TextAlign.center,
                                  style: CustomStyles.normal16TextStyle())),
                          Container(
                              margin: EdgeInsets.only(top: 30),
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
                                            }))),
                                    Expanded(
                                        flex: 1,
                                        child: Container(
                                            height: 50,
                                            child: CustomStyles
                                                .greyBorderRound7ButtonStyle(
                                                    '비밀번호 찾기', () {
                                              replaceView(context, FindPW());
                                            })))
                                  ]))
                        ])))));
  }
}
