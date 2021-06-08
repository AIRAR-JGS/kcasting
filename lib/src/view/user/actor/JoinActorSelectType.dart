import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/dialog/DialogParentAuth.dart';
import 'package:casting_call/src/view/user/common/JoinSelectType.dart';
import 'package:flutter/material.dart';

import 'JoinActorAdult.dart';
import 'JoinActorChildParentAgree.dart';

/*
* 배우 회원 유형 선택
* */
class JoinActorSelectType extends StatefulWidget {
  @override
  _JoinActorSelectType createState() => _JoinActorSelectType();
}

class _JoinActorSelectType extends State<JoinActorSelectType>
    with BaseUtilMixin {
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
          replaceView(context, JoinSelectType());
          return Future.value(false);
        },
        child: Theme(
            data: CustomStyles.defaultTheme(),
            child: Scaffold(
                key: _scaffoldKey,
                appBar: CustomStyles.defaultAppBar('회원가입', () {
                  replaceView(context, JoinSelectType());
                }),
                body: Container(
                    padding: EdgeInsets.only(left: 30, right: 30),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      DialogParentAuth(onClickedAgree: () {
                                        replaceView(context,
                                            JoinActorChildParentAgree());
                                      }));
                            },
                            child: Container(
                              alignment: Alignment.center,
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height * 0.2,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      width: 0.5,
                                      color: CustomColors.colorFontGrey)),
                              child: Container(
                                  child: Text('14세 미만 회원가입',
                                      style: CustomStyles.normal24TextStyle())),
                            ),
                          ),
                          GestureDetector(
                              onTap: () {
                                replaceView(context, JoinActorAdult());
                              },
                              child: Container(
                                  margin: EdgeInsets.only(top: 20),
                                  alignment: Alignment.center,
                                  width: double.infinity,
                                  height:
                                      MediaQuery.of(context).size.height * 0.2,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          width: 0.5,
                                          color: CustomColors.colorFontGrey)),
                                  child: Container(
                                      child: Text('14세 이상 회원가입',
                                          style: CustomStyles
                                              .normal24TextStyle()))))
                        ])))));
  }
}
