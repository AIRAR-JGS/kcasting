import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/KCastingAppData.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/dialog/DialogMemberLeaveConfirm.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:casting_call/src/view/mypage/production/ProductionMemberInfoModify.dart';
import 'package:casting_call/src/view/user/common/Login.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductionMemberInfo extends StatefulWidget {
  @override
  _ProductionMemberInfo createState() => _ProductionMemberInfo();
}

class _ProductionMemberInfo extends State<ProductionMemberInfo>
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
                                          APIConstants.production_name]),
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
                                         APIConstants.production_CEO_name]),
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
                                                          .production_homepage])
                                              ? '-'
                                              : KCastingAppData().myInfo[
                                                  APIConstants
                                                      .production_homepage],
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
                                                          .production_email])
                                              ? '-'
                                              : KCastingAppData().myInfo[
                                                  APIConstants
                                                      .production_email],
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
                            replaceView(context, ProductionMemberInfoModify());
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
                                  requestProductDeleteInfoApi(context);
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

  /*
  *제작사 회원 탈퇴
  * */
  void requestProductDeleteInfoApi(BuildContext context) {
    final dio = Dio();

    // 제작사 회원 탈퇴 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetDatas = new Map();
    targetDatas[APIConstants.production_seq] =
    KCastingAppData().myInfo[APIConstants.seq];

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.DEL_PRD_INFO;
    params[APIConstants.target] = targetDatas;

    // 제작사 회원 탈퇴 api 호출
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value != null) {
        if (value[APIConstants.resultVal]) {
          try {
            KCastingAppData().clearData();

            final SharedPreferences prefs =
            await SharedPreferences.getInstance();
            prefs.remove(APIConstants.autoLogin);
            prefs.remove(APIConstants.id);
            prefs.remove(APIConstants.pwd);

            // 로그인 페이지 이동
            replaceView(context, Login());

          } catch (e) {
            showSnackBar(context, APIConstants.error_msg_try_again);
          }
        } else {
          showSnackBar(context, value[APIConstants.resultMsg]);
        }
      } else {
        // 에러 - 데이터 널 - 서버가 응답하지 않습니다. 다시 시도해 주세요
        showSnackBar(context, APIConstants.error_msg_server_not_response);
      }
    });
  }
}
