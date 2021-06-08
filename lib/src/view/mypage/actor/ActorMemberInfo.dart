import 'package:casting_call/KCastingAppData.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:casting_call/src/view/mypage/actor/ActorMemberInfoModify.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ActorMemberInfo extends StatefulWidget {
  @override
  _ActorMemberInfo createState() => _ActorMemberInfo();
}

class _ActorMemberInfo extends State<ActorMemberInfo> {
  @override
  void initState() {
    super.initState();
  }

  //========================================================================================================================
  // 메인 위젯
  //========================================================================================================================
  @override
  Widget build(BuildContext context) {
    return Theme(
        data: CustomStyles.defaultTheme(),
        child: Scaffold(
            appBar: CustomStyles.defaultAppBar('개인정보 관리', () {
              Navigator.pop(context);
            }),
            body: Container(
                child: Column(children: [
              SingleChildScrollView(
                child: Container(
                  padding:
                      EdgeInsets.only(top: 30, bottom: 30, left: 18, right: 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          alignment: Alignment.centerLeft,
                          child: Text('개인정보 관리',
                              style: CustomStyles.normal24TextStyle())),
                      Container(
                          margin: EdgeInsets.only(top: 30.0),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 3,
                                  child: Container(
                                      child: Text('아이디',
                                          style: CustomStyles
                                              .normal14TextStyle()))),
                              Expanded(
                                  flex: 7,
                                  child: Container(
                                      child: Text(
                                          StringUtils.checkedString(
                                              KCastingAppData()
                                                  .myInfo[APIConstants.id]),
                                          style: CustomStyles
                                              .normal14TextStyle())))
                            ],
                          )),
                      Container(
                          margin: EdgeInsets.only(top: 10.0),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 3,
                                  child: Container(
                                      child: Text('이름',
                                          style: CustomStyles
                                              .normal14TextStyle()))),
                              Expanded(
                                  flex: 7,
                                  child: Container(
                                      child: Text(
                                          StringUtils.checkedString(
                                              KCastingAppData().myInfo[
                                                  APIConstants.actor_name]),
                                          style: CustomStyles
                                              .normal14TextStyle())))
                            ],
                          )),
                      Container(
                          margin: EdgeInsets.only(top: 10.0),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 3,
                                  child: Container(
                                      child: Text('생년월일',
                                          style: CustomStyles
                                              .normal14TextStyle()))),
                              Expanded(
                                  flex: 7,
                                  child: Container(
                                      child: Text(
                                          StringUtils.checkedString(
                                              KCastingAppData().myInfo[
                                                  APIConstants.actor_birth]),
                                          style: CustomStyles
                                              .normal14TextStyle())))
                            ],
                          )),
                      Container(
                          margin: EdgeInsets.only(top: 10.0),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 3,
                                  child: Container(
                                      child: Text('성별',
                                          style: CustomStyles
                                              .normal14TextStyle()))),
                              Expanded(
                                  flex: 7,
                                  child: Container(
                                      child: Text(
                                          KCastingAppData()
                                              .myInfo[APIConstants.sex_type],
                                          style: CustomStyles
                                              .normal14TextStyle())))
                            ],
                          )),
                      Container(
                          margin: EdgeInsets.only(top: 10.0),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 3,
                                  child: Container(
                                      child: Text('연락처',
                                          style: CustomStyles
                                              .normal14TextStyle()))),
                              Expanded(
                                  flex: 7,
                                  child: Container(
                                      child: Text(
                                          StringUtils.checkedString(
                                              KCastingAppData().myInfo[
                                                  APIConstants.actor_phone]),
                                          style: CustomStyles
                                              .normal14TextStyle())))
                            ],
                          )),
                      /*Container(
                          margin: EdgeInsets.only(top: 10.0),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 3,
                                  child: Container(
                                      child: Text('은행계좌',
                                          style: CustomStyles
                                              .normal14TextStyle()))),
                              Expanded(
                                  flex: 7,
                                  child: Container(
                                      child: Text('우리) 000-0000-0000',
                                          style: CustomStyles
                                              .normal14TextStyle())))
                            ],
                          )),*/
                      Container(
                          margin: EdgeInsets.only(top: 10.0),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 3,
                                  child: Container(
                                      child: Text('이메일',
                                          style: CustomStyles
                                              .normal14TextStyle()))),
                              Expanded(
                                  flex: 7,
                                  child: Container(
                                      child: Text(
                                          StringUtils.checkedString(
                                              KCastingAppData().myInfo[
                                                  APIConstants.actor_email]),
                                          style: CustomStyles
                                              .normal14TextStyle())))
                            ],
                          )),
                      Container(
                          height: 50,
                          margin: EdgeInsets.only(top: 30.0),
                          width: double.infinity,
                          child: CustomStyles.greyBorderRound7ButtonStyle('수정',
                              () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ActorMemberInfoModify()),
                            );
                          })),
                      /*Container(
                          height: 50,
                          margin: EdgeInsets.only(top: 10.0),
                          width: double.infinity,
                          child: CustomStyles.greyBorderRound7ButtonStyle(
                              '회원탈퇴', () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) => DialogLeave(
                                onClickedAgree: () {
                                  // 로그인 페이지 이동
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => UserLogin()),
                                  );
                                },
                              ),
                            );
                          })),*/
                    ],
                  ),
                ),
              ),
            ]))));
  }
}
