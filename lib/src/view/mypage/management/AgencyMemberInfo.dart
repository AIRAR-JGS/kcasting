import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/KCastingAppData.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/dialog/DialogMemberLeaveConfirm.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:casting_call/src/view/mypage/management/AgencyMemberInfoModify.dart';
import 'package:casting_call/src/view/user/common/Login.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AgencyMemberInfo extends StatefulWidget {
  @override
  _AgencyMemberInfo createState() => _AgencyMemberInfo();
}

class _AgencyMemberInfo extends State<AgencyMemberInfo> with BaseUtilMixin {
  bool _isUpload = false;

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
        child: Align(
            alignment: Alignment.topCenter,
            child: Container(
                width: KCastingAppData().isWeb
                    ? CustomStyles.appWidth
                    : double.infinity,
                child: Scaffold(
                    appBar: CustomStyles.defaultAppBar('개인정보 관리', () {
                      Navigator.pop(context);
                    }),
                    body: Stack(
                      children: [
                        Container(
                            child: Column(children: [
                          SingleChildScrollView(
                              child: Container(
                                  padding: EdgeInsets.only(
                                      top: 30, bottom: 30, left: 18, right: 18),
                                  child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                            alignment: Alignment.centerLeft,
                                            child: Text('개인정보 관리',
                                                style: CustomStyles
                                                    .normal24TextStyle())),
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
                                                                        .myInfo[
                                                                    APIConstants
                                                                        .id]),
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
                                                            StringUtils.checkedString(
                                                                KCastingAppData()
                                                                        .myInfo[
                                                                    APIConstants
                                                                        .management_name]),
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
                                                                KCastingAppData()
                                                                        .myInfo[
                                                                    APIConstants
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
                                                            StringUtils.checkedString(
                                                                KCastingAppData()
                                                                        .myInfo[
                                                                    APIConstants
                                                                        .management_CEO_name]),
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
                                                            StringUtils.isEmpty(KCastingAppData()
                                                                        .myInfo[
                                                                    APIConstants
                                                                        .management_homepage])
                                                                ? '-'
                                                                : KCastingAppData()
                                                                        .myInfo[
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
                                                            StringUtils.isEmpty(KCastingAppData()
                                                                        .myInfo[
                                                                    APIConstants
                                                                        .management_email])
                                                                ? '-'
                                                                : KCastingAppData()
                                                                        .myInfo[
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
                                            child: CustomStyles
                                                .greyBorderRound7ButtonStyle(
                                                    '수정', () {
                                              replaceView(context,
                                                  AgencyMemberInfoModify());
                                            })),
                                        Container(
                                            height: 50,
                                            margin: EdgeInsets.only(top: 10.0),
                                            width: double.infinity,
                                            child: CustomStyles
                                                .greyBorderRound7ButtonStyle(
                                                    '회원탈퇴', () {
                                              showDialog(
                                                  context: context,
                                                  builder: (BuildContext
                                                          context) =>
                                                      DialogMemberLeaveConfirm(
                                                          onClickedAgree: () {
                                                        requestManagementDeleteInfoApi(
                                                            context);
                                                      }));
                                            }))
                                      ])))
                        ])),
                        Visibility(
                          child: Container(
                              color: Colors.black38,
                              alignment: Alignment.center,
                              child: CircularProgressIndicator()),
                          visible: _isUpload,
                        )
                      ],
                    )))));
  }

  /*
  *매니지먼트 회원 탈퇴
  * */
  void requestManagementDeleteInfoApi(BuildContext context) {
    setState(() {
      _isUpload = true;
    });

    // 매니지먼트 회원 탈퇴 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetDatas = new Map();
    targetDatas[APIConstants.management_seq] =
        KCastingAppData().myInfo[APIConstants.seq];

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.DEL_MGM_INFO;
    params[APIConstants.target] = targetDatas;

    // 매니지먼트 회원 탈퇴 api 호출
    RestClient(Dio()).postRequestMainControl(params).then((value) async {
      try {
        if (value != null) {
          if (value[APIConstants.resultVal]) {
            KCastingAppData().clearData();

            final SharedPreferences prefs =
                await SharedPreferences.getInstance();
            prefs.remove(APIConstants.autoLogin);
            prefs.remove(APIConstants.id);
            prefs.remove(APIConstants.pwd);

            // 로그인 페이지 이동
            replaceView(context, Login());
          } else {
            showSnackBar(context, value[APIConstants.resultMsg]);
          }
        } else {
          // 에러 - 데이터 널 - 서버가 응답하지 않습니다. 다시 시도해 주세요
          showSnackBar(context, APIConstants.error_msg_server_not_response);
        }
      } catch (e) {
        showSnackBar(context, APIConstants.error_msg_try_again);
      } finally {
        setState(() {
          _isUpload = false;
        });
      }
    });
  }
}
