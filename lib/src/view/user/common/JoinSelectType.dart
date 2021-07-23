import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/view/user/actor/JoinActorSelectType.dart';
import 'package:casting_call/src/view/user/common/Login.dart';
import 'package:casting_call/src/view/user/common/CompanyAuth.dart';
import 'package:flutter/material.dart';

/*
* 회원 유형 선택
* */
class JoinSelectType extends StatefulWidget {
  @override
  _JoinSelectType createState() => _JoinSelectType();
}

class _JoinSelectType extends State<JoinSelectType> with BaseUtilMixin {
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
          replaceView(context, Login());
          return Future.value(false);
        },
        child: Theme(
            data: CustomStyles.defaultTheme(),
            child: Scaffold(
                key: _scaffoldKey,
                appBar: CustomStyles.defaultAppBar('회원가입', () {
                  replaceView(context, Login());
                }),
                body: Container(
                    padding: EdgeInsets.only(left: 30, right: 30),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                              onTap: () {
                                replaceView(context, JoinActorSelectType());
                              },
                              child: Container(
                                  alignment: Alignment.center,
                                  width: double.infinity,
                                  height:
                                      MediaQuery.of(context).size.height * 0.2,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          width: 0.5,
                                          color: CustomColors.colorFontGrey)),
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Text('저는 배역을 찾고 있어요',
                                            style: CustomStyles
                                                .normal16TextStyle()),
                                        Container(
                                            margin: EdgeInsets.only(top: 10),
                                            child: Text('배우',
                                                style: CustomStyles
                                                    .normal32TextStyle()))
                                      ]))),
                          GestureDetector(
                              onTap: () {
                                replaceView(
                                    context,
                                    CompanyAuth(
                                        memberType:
                                            APIConstants.member_type_product));
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
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Text('저는 배우를 찾고 있어요',
                                            style: CustomStyles
                                                .normal16TextStyle()),
                                        Container(
                                            margin: EdgeInsets.only(top: 10),
                                            child: Text('제작사',
                                                style: CustomStyles
                                                    .normal32TextStyle()))
                                      ]))),
                          GestureDetector(
                              onTap: () {
                                replaceView(
                                    context,
                                    CompanyAuth(
                                        memberType: APIConstants
                                            .member_type_management));
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
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Text('우리 배우들을 캐스팅 해주세요',
                                            style: CustomStyles
                                                .normal16TextStyle()),
                                        Container(
                                            margin: EdgeInsets.only(top: 10),
                                            child: Text('매니지먼트',
                                                style: CustomStyles
                                                    .normal32TextStyle()))
                                      ])))
                        ])))));
  }
}
