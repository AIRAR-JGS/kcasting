import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/KCastingAppData.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/dialog/DialogMemberLogoutConfirm.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:casting_call/src/view/audition/actor/AgencyActorAuditionApplyList.dart';
import 'package:casting_call/src/view/audition/actor/AgencyActorOfferedAuditionList.dart';
import 'package:casting_call/src/view/audition/production/ProposedAuditionList.dart';
import 'package:casting_call/src/view/mypage/management/AgencyActorList.dart';
import 'package:casting_call/src/view/mypage/management/AgencyMemberInfo.dart';
import 'package:casting_call/src/view/mypage/management/AgencyProfile.dart';
import 'package:casting_call/src/view/mypage/management/BookmarkedAgencyAuditionList.dart';
import 'package:casting_call/src/view/user/common/Login.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*
* 매니지먼트 마이페이지
* */
class AgencyMemberPage extends StatefulWidget {
  @override
  _AgencyMemberPage createState() => _AgencyMemberPage();
}

class _AgencyMemberPage extends State<AgencyMemberPage> with BaseUtilMixin {
  Map<String, dynamic> _stateData = new Map();

  @override
  void initState() {
    super.initState();

    //requestGetManagementState(context);
  }

  /*
  * 매니지먼트 상태 조회
  * */
  void requestGetManagementState(BuildContext context) {
    final dio = Dio();

    // 매니지먼트 상태 조회 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetData = new Map();
    targetData[APIConstants.seq] = KCastingAppData().myInfo[APIConstants.seq];

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.SEL_ACT_STATE;
    params[APIConstants.target] = targetData;

    // 매니지먼트 상태 조회 api 호출
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value != null) {
        if (value[APIConstants.resultVal]) {
          try {
            // 매니지먼트 상태 조회 성공
            var _responseData = value[APIConstants.data];
            var _responseList = _responseData[APIConstants.list] as List;

            setState(() {
              if (_responseList != null && _responseList.length > 0) {
                _stateData = _responseList[0];
              }
            });
          } catch (e) {
            showSnackBar(context, APIConstants.error_msg_try_again);
          }
        } else {
          showSnackBar(context, APIConstants.error_msg_try_again);
        }
      } else {
        showSnackBar(context, APIConstants.error_msg_server_not_response);
      }
    });
  }

  Widget _headerView() {
    return Container(
      child: Column(
        children: [
          Container(
              margin: EdgeInsets.only(top: 30, bottom: 15),
              child: KCastingAppData().myInfo == null
                  ? Icon(
                      Icons.account_circle,
                      color: CustomColors.colorFontLightGrey,
                      size: 100,
                    )
                  : (KCastingAppData()
                              .myInfo[APIConstants.production_img_url] !=
                          null
                      ? ClipOval(
                          child: Image.network(
                              KCastingAppData()
                                  .myInfo[APIConstants.production_img_url],
                              fit: BoxFit.cover,
                              width: 100.0,
                              height: 100.0),
                        )
                      : Icon(
                          Icons.account_circle,
                          color: CustomColors.colorFontLightGrey,
                          size: 100,
                        ))),
          Container(
              margin: EdgeInsets.only(bottom: 15),
              child: Text(
                  StringUtils.checkedString(
                      KCastingAppData().myInfo[APIConstants.production_name]),
                  style: CustomStyles.normal32TextStyle())),
          Container(
            margin: EdgeInsets.only(bottom: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: Column(
                    children: [
                      Container(
                          child: Text('지원현황',
                              style: CustomStyles.dark16TextStyle())),
                      Container(
                          margin: EdgeInsets.only(top: 5),
                          child: Text(
                              StringUtils.checkedString(
                                  _stateData[APIConstants.applyIngCnt]),
                              style: CustomStyles.dark24TextStyle()))
                    ],
                  ),
                ),
                Container(
                  height: 45,
                  margin: EdgeInsets.only(bottom: 5, left: 5, right: 5),
                  child: VerticalDivider(
                    color: CustomColors.colorFontLightGrey,
                  ),
                ),
                Container(
                  child: Column(
                    children: [
                      Container(
                          child: Text('받은 제안',
                              style: CustomStyles.dark16TextStyle())),
                      Container(
                          margin: EdgeInsets.only(top: 5),
                          child: Text(
                              StringUtils.checkedString(
                                  _stateData[APIConstants.proposalCnt]),
                              style: CustomStyles.dark24TextStyle()))
                    ],
                  ),
                ),
                Container(
                  height: 45,
                  margin: EdgeInsets.only(bottom: 5, left: 5, right: 5),
                  child: VerticalDivider(
                    color: CustomColors.colorFontLightGrey,
                  ),
                ),
                Container(
                  child: Column(
                    children: [
                      Container(
                          child: Text('보유 배우',
                              style: CustomStyles.dark16TextStyle())),
                      Container(
                          margin: EdgeInsets.only(top: 5),
                          child: Text(
                              StringUtils.checkedString(
                                  _stateData[APIConstants.viewCnt]),
                              style: CustomStyles.dark24TextStyle()))
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _listItemView(int idx) {
    var _mypageMenu = [
      '헤더',
      '프로필 관리',
      '보유 배우',
      '지원 현황',
      '받은 제안',
      '마이 스크랩',
      '개인정보 관리',
      '로그아웃',
      ''
    ];

    return Container(
        padding: EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 10),
        child: Text(_mypageMenu[idx].toString(),
            style: CustomStyles.normal16TextStyle()));
  }

  /*
  * 메인 위젯
  * */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      alignment: Alignment.center,
      child: ListView.separated(
        scrollDirection: Axis.vertical,
        itemCount: 8,
        itemBuilder: (context, index) {
          return (index == 0)
              ? _headerView()
              : GestureDetector(
                  onTap: () {
                    print('메뉴 ' + index.toString());
                    switch (index) {
                      // 프로필 관리
                      case 1:
                        // 프로필 관리 페이지 이동
                        addView(context, AgencyProfile());
                        break;

                      // 보유 배우
                      case 2:
                        // 보유 배우 페이지 이동
                        addView(context, AgencyActorList());
                        break;

                      // 지원 현황
                      case 3:
                        // 지원 현황 페이지 이동
                        addView(context, AgencyActorAuditionApplyList());
                        break;

                      // 받은 제안
                      case 4:
                        // 받은 제안 페이지 이동
                        addView(context, AgencyActorOfferedAuditionList());
                        break;

                      // 마이스크랩
                      case 5:
                        // 마이스크랩 페이지 이동
                        addView(context, BookmarkedAgencyAuditionList());
                        break;

                      // 개인정보 관리
                      case 6:
                        // 개인정보 관리 페이지 이동
                        addView(context, AgencyMemberInfo());
                        break;

                      // 로그아웃
                      case 7:
                        showDialog(
                          context: context,
                          builder: (BuildContext context) =>
                              DialogMemberLogoutConfirm(
                            onClickedAgree: () async {
                              KCastingAppData().clearData();

                              final SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              prefs.remove(APIConstants.autoLogin);
                              prefs.remove(APIConstants.id);
                              prefs.remove(APIConstants.pwd);

                              // 로그인 페이지 이동
                              replaceView(context, Login());
                            },
                          ),
                        );

                        break;

                      default:
                        break;
                    }
                  },
                  child: _listItemView(index),
                );
        },
        separatorBuilder: (context, index) {
          return Divider();
        },
      ),
    ));
  }
}
