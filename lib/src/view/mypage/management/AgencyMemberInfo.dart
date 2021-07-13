import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/KCastingAppData.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/dialog/DialogMemberLeaveConfirm.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:casting_call/src/view/mypage/management/AgencyMemberInfoModify.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AgencyMemberInfo extends StatefulWidget {
  @override
  _AgencyMemberInfo createState() => _AgencyMemberInfo();
}

class _AgencyMemberInfo extends State<AgencyMemberInfo>
    with BaseUtilMixin {
  @override
  void initState() {
    super.initState();
  }

  /*
  * 메인 위젯
  * */
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
                                          StringUtils.checkedString(KCastingAppData()
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
                                      child: Text('기업명',
                                          style: CustomStyles
                                              .normal14TextStyle()))),
                              Expanded(
                                  flex: 7,
                                  child: Container(
                                      child: Text(
                                          StringUtils.checkedString(KCastingAppData().myInfo[
                                          APIConstants.management_name]),
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
                                      child: Text('사업자번호',
                                          style: CustomStyles
                                              .normal14TextStyle()))),
                              Expanded(
                                  flex: 7,
                                  child: Container(
                                      child: Text(
                                          StringUtils.checkedString(
                                              KCastingAppData().myInfo[APIConstants
                                                  .businessRegistration_number]),
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
                                      child: Text('대표자',
                                          style: CustomStyles
                                              .normal14TextStyle()))),
                              Expanded(
                                  flex: 7,
                                  child: Container(
                                      child: Text(
                                         StringUtils.checkedString( KCastingAppData().myInfo[
                                         APIConstants.management_CEO_name]),
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
                                      child: Text('홈페이지',
                                          style: CustomStyles
                                              .normal14TextStyle()))),
                              Expanded(
                                  flex: 7,
                                  child: Container(
                                      child: Text(
                                          StringUtils.isEmpty(
                                                  KCastingAppData().myInfo[
                                                      APIConstants
                                                          .management_homepage])
                                              ? '-'
                                              : KCastingAppData().myInfo[
                                                  APIConstants
                                                      .management_homepage],
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
                                      child: Text('이메일',
                                          style: CustomStyles
                                              .normal14TextStyle()))),
                              Expanded(
                                  flex: 7,
                                  child: Container(
                                      child: Text(
                                          StringUtils.isEmpty(
                                                  KCastingAppData().myInfo[
                                                      APIConstants
                                                          .management_email])
                                              ? '-'
                                              : KCastingAppData().myInfo[
                                                  APIConstants
                                                      .management_email],
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
                            replaceView(context, AgencyMemberInfoModify());
                          })),
                      Container(
                          height: 50,
                          margin: EdgeInsets.only(top: 10.0),
                          width: double.infinity,
                          child: CustomStyles.greyBorderRound7ButtonStyle(
                              '회원탈퇴', () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) =>
                                  DialogMemberLeaveConfirm(
                                onClickedAgree: () {
                                  //requestProductDeleteInfoApi(context);
                                },
                              ),
                            );
                          })),
                    ],
                  ),
                ),
              ),
            ]))));
  }
}
