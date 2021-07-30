import 'package:cached_network_image/cached_network_image.dart';
import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/util/DateTileUtils.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:casting_call/src/view/audition/actor/AgencyActorAuditionApply.dart';
import 'package:casting_call/src/view/audition/actor/AuditionApplyUploadImage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../KCastingAppData.dart';

/*
* 캐스팅보드 상세
* */
class AuditionDetail extends StatefulWidget {
  final int castingSeq;

  const AuditionDetail({Key key, this.castingSeq}) : super(key: key);

  @override
  _AuditionDetail createState() => _AuditionDetail();
}

class _AuditionDetail extends State<AuditionDetail> with BaseUtilMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  int _castingSeq;

  Map<String, dynamic> _castingBoardData = new Map();
  String _ageStr = "";
  String _heightStr = "";
  String _weightStr = "";
  String _payStr = "";
  String _shootingDateStr = "";
  List<dynamic> _castingLanguage;
  List<dynamic> _castingAbility;
  String _castingLanguageStr = "";
  String _castingAbilityStr = "";
  String _castingStateStr = "";

  String _isBookmarkedKey;

  @override
  void initState() {
    super.initState();

    _castingSeq = widget.castingSeq;

    if (KCastingAppData().myInfo[APIConstants.member_type] ==
        APIConstants.member_type_actor) {
      _isBookmarkedKey = APIConstants.isActorCastringScrap;
    }

    if (KCastingAppData().myInfo[APIConstants.member_type] ==
        APIConstants.member_type_management) {
      _isBookmarkedKey = APIConstants.isManagementCastringScrap;
    }

    requestCastingDetailApi(context);
  }

  /*
  * 캐스팅보드 상세 조회
  * */
  void requestCastingDetailApi(BuildContext context) {
    final dio = Dio();

    // 캐스팅보드 상세 조회 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetData = new Map();
    targetData[APIConstants.casting_seq] = _castingSeq;
    if (KCastingAppData().myInfo[APIConstants.member_type] ==
        APIConstants.member_type_actor) {
      targetData[APIConstants.actor_seq] =
          KCastingAppData().myInfo[APIConstants.seq];
    }

    if (KCastingAppData().myInfo[APIConstants.member_type] ==
        APIConstants.member_type_management) {
      targetData[APIConstants.management_seq] =
          KCastingAppData().myInfo[APIConstants.seq];
    }

    // params data1
    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.SAR_PCT_INFO;
    params[APIConstants.target] = targetData;

    // 캐스팅보드 상세 조회 api 호출
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value == null) {
        // 에러 - 데이터 널
        showSnackBar(context, APIConstants.error_msg_server_not_response);
      } else {
        if (value[APIConstants.resultVal]) {
          try {
            // 캐스팅보드 상세 조회 성공
            var _responseList = value[APIConstants.data] as List;

            setState(() {
              for (int i = 0; i < _responseList.length; i++) {
                var _data = _responseList[i];

                switch (_data[APIConstants.table]) {
                  // 캐스팅보드 상세
                  case APIConstants.table_production_casting:
                    {
                      var _listData = _data[APIConstants.data];
                      if (_listData != null) {
                        List<dynamic> _actorProfileList =
                            _listData[APIConstants.list] as List;
                        if (_actorProfileList != null) {
                          _castingBoardData = _actorProfileList.length > 0
                              ? _actorProfileList[0]
                              : null;

                          if (_castingBoardData[APIConstants.casting_min_age] ==
                                  null &&
                              _castingBoardData[APIConstants.casting_max_age] ==
                                  null) {
                            _ageStr = "무관";
                          } else {
                            _ageStr +=
                                _castingBoardData[APIConstants.casting_min_age]
                                    .toString();
                            _ageStr += "~";
                            _ageStr +=
                                _castingBoardData[APIConstants.casting_max_age]
                                    .toString();
                          }

                          if (_castingBoardData[
                                      APIConstants.casting_min_tall] ==
                                  null &&
                              _castingBoardData[
                                      APIConstants.casting_max_tall] ==
                                  null) {
                            _heightStr = "무관";
                          } else {
                            _heightStr +=
                                _castingBoardData[APIConstants.casting_min_tall]
                                    .toString();
                            _heightStr += "~";
                            _heightStr +=
                                _castingBoardData[APIConstants.casting_max_tall]
                                    .toString();
                          }

                          if (_castingBoardData[
                                      APIConstants.casting_min_weight] ==
                                  null &&
                              _castingBoardData[
                                      APIConstants.casting_max_weight] ==
                                  null) {
                            _weightStr = "무관";
                          } else {
                            _weightStr += _castingBoardData[
                                    APIConstants.casting_min_weight]
                                .toString();
                            _weightStr += "~";
                            _weightStr += _castingBoardData[
                                    APIConstants.casting_max_weight]
                                .toString();
                          }

                          if (_castingBoardData[APIConstants.casting_pay] !=
                              null) {
                            _payStr +=
                                _castingBoardData[APIConstants.casting_pay]
                                    .toString();
                            _payStr += "만원";
                          } else {
                            _payStr = "무관";
                          }

                          if (_castingBoardData[
                                      APIConstants.shooting_startDate] !=
                                  null &&
                              _castingBoardData[
                                      APIConstants.shooting_endDate] !=
                                  null) {
                            DateTime startDay = DateTileUtils.stringToDateTime(
                                _castingBoardData[
                                    APIConstants.shooting_startDate]);
                            String startDayStr =
                                DateTileUtils.dateTimeToFormattedString(
                                    startDay);

                            DateTime endDay = DateTileUtils.stringToDateTime(
                                _castingBoardData[
                                    APIConstants.shooting_endDate]);
                            String endDayStr =
                                DateTileUtils.dateTimeToFormattedString(endDay);

                            _shootingDateStr += startDayStr;
                            _shootingDateStr += "~";
                            _shootingDateStr += endDayStr;
                          }

                          // 배우 회원인 경우
                          if (KCastingAppData()
                                  .myInfo[APIConstants.member_type] ==
                              APIConstants.member_type_actor) {
                            if (_castingBoardData[
                                    APIConstants.firstAudition_state_type] ==
                                "마감") {
                              _castingStateStr = "마감된 공고입니다.";
                            } else {
                              if (_castingBoardData[APIConstants.isApply] ==
                                  0) {
                                _castingStateStr = "";
                              } else {
                                _castingStateStr = "이미 지원한 공고입니다.";
                              }
                            }
                          } else if(KCastingAppData()
                              .myInfo[APIConstants.member_type] ==
                              APIConstants.member_type_management) {
                            if (_castingBoardData[
                            APIConstants.firstAudition_state_type] ==
                                "마감") {
                              _castingStateStr = "마감된 공고입니다.";
                            }
                          }
                        }
                      }
                      break;
                    }

                  // 캐스팅보드 언어
                  case APIConstants.table_casting_language:
                    {
                      var _listData = _data[APIConstants.data];
                      if (_listData != null) {
                        _castingLanguage = _listData[APIConstants.list] as List;
                      } else {
                        _castingLanguage = [];
                      }

                      for (int i = 0; i < _castingLanguage.length; i++) {
                        var _lanData = _castingLanguage[i];
                        _castingLanguageStr +=
                            _lanData[APIConstants.language_type];

                        if (i != _castingLanguage.length - 1)
                          _castingLanguageStr += "\t";
                      }

                      if (_castingLanguage == null ||
                          _castingLanguage.length == 0) {
                        _castingLanguageStr += "-";
                      }

                      break;
                    }

                  // 캐스팅보드 특기
                  case APIConstants.table_casting_ability:
                    {
                      var _listData = _data[APIConstants.data];
                      if (_listData != null) {
                        _castingAbility = _listData[APIConstants.list] as List;
                      } else {
                        _castingAbility = [];
                      }

                      for (int i = 0; i < _castingAbility.length; i++) {
                        var _abilityData = _castingAbility[i];
                        _castingAbilityStr +=
                            _abilityData[APIConstants.child_type];

                        if (i != _castingAbility.length - 1)
                          _castingAbilityStr += ",\t";
                      }

                      if (_castingAbility.length == 0) {
                        _castingAbilityStr += "-";
                      }
                      break;
                    }
                }
              }
            });
          } catch (e) {
            showSnackBar(context, APIConstants.error_msg_try_again);
          }
        } else {
          // 캐스팅보드 상세 조회 실패
          showSnackBar(context, APIConstants.error_msg_try_again);
        }
      }
    });
  }

  /*
  * 배우 북마크 목록
  * */
  void requestActorBookmarkEditApi(BuildContext context) {
    final dio = Dio();

    // 배우 북마크 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetDate = new Map();
    targetDate[APIConstants.actor_seq] =
        KCastingAppData().myInfo[APIConstants.seq];
    targetDate[APIConstants.casting_seq] = _castingSeq;

    Map<String, dynamic> params = new Map();
    if (_castingBoardData[_isBookmarkedKey] == 1) {
      params[APIConstants.key] = APIConstants.DEA_ACS_INFO;
    } else {
      params[APIConstants.key] = APIConstants.INS_ACS_INFO;
    }

    params[APIConstants.target] = targetDate;

    // 배우 북마크 api 호출
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value != null) {
        if (value[APIConstants.resultVal]) {
          try {
            // 배우 북마크 성공
            setState(() {
              //var _responseData = value[APIConstants.data];
              //var _responseList = _responseData[APIConstants.list] as List;

              setState(() {
                if (_castingBoardData[_isBookmarkedKey] == 1) {
                  _castingBoardData[_isBookmarkedKey] = 0;
                } else {
                  _castingBoardData[_isBookmarkedKey] = 1;
                }
              });

              // KCastingAppData().myBookmark.addAll(_responseList);
            });
          } catch (e) {}
        }
      }
    });
  }

  /*
  * 매니지먼트 북마크 목록
  * */
  void requestManagementBookmarkEditApi(BuildContext context) {
    final dio = Dio();

    // 매니지먼트 북마크 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetDate = new Map();
    targetDate[APIConstants.management_seq] =
        KCastingAppData().myInfo[APIConstants.seq];
    targetDate[APIConstants.casting_seq] = _castingSeq;

    Map<String, dynamic> params = new Map();
    if (_castingBoardData[_isBookmarkedKey] == 1) {
      params[APIConstants.key] = APIConstants.DEA_MCS_INFO;
    } else {
      params[APIConstants.key] = APIConstants.INS_MCS_INFO;
    }

    params[APIConstants.target] = targetDate;

    // 매니지먼트 북마크 api 호출
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value != null) {
        if (value[APIConstants.resultVal]) {
          try {
            // 매니지먼트 북마크 성공
            setState(() {
              //var _responseData = value[APIConstants.data];
              //var _responseList = _responseData[APIConstants.list] as List;

              setState(() {
                if (_castingBoardData[_isBookmarkedKey] == 1) {
                  _castingBoardData[_isBookmarkedKey] = 0;
                } else {
                  _castingBoardData[_isBookmarkedKey] = 1;
                }
              });

              // KCastingAppData().myBookmark.addAll(_responseList);
            });
          } catch (e) {}
        }
      }
    });
  }

  /*
  * 메인 위젯
  * */
  @override
  Widget build(BuildContext context) {
    return Theme(
        data: CustomStyles.defaultTheme(),
        child: Scaffold(
            key: _scaffoldKey,
            appBar: CustomStyles.defaultAppBar('캐스팅보드', () {
              Navigator.pop(context);
            }),
            body: Container(
                child: Column(children: [
              Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                      child: Container(
                          padding: EdgeInsets.only(top: 20, bottom: 50),
                          child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    child: Text(
                                        StringUtils.checkedString(
                                            _castingBoardData[
                                                APIConstants.project_name]),
                                        style: CustomStyles
                                            .darkBold12TextStyle())),
                                Container(
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    margin: EdgeInsets.only(top: 5.0),
                                    child: Text(
                                        StringUtils.checkedString(
                                            _castingBoardData[
                                                APIConstants.casting_name]),
                                        style: CustomStyles.dark24TextStyle())),
                                Container(
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    margin: EdgeInsets.only(top: 20.0),
                                    child: Row(children: [
                                      Expanded(
                                          flex: 3,
                                          child: Container(
                                              child: Text('제작사',
                                                  style: CustomStyles
                                                      .darkBold16TextStyle()))),
                                      Expanded(
                                          flex: 7,
                                          child: Container(
                                              child: Text(
                                                  StringUtils.checkedString(
                                                      _castingBoardData[
                                                          APIConstants
                                                              .production_name]),
                                                  style: TextStyle(
                                                      decoration: TextDecoration
                                                          .underline,
                                                      color: CustomColors
                                                          .colorFontDarkGrey,
                                                      fontSize: 16.0,
                                                      fontWeight:
                                                          FontWeight.normal))))
                                    ])),
                                Container(
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    margin: EdgeInsets.only(top: 10.0),
                                    child: Row(children: [
                                      Expanded(
                                          flex: 3,
                                          child: Container(
                                              child: Text('마감일',
                                                  style: CustomStyles
                                                      .darkBold16TextStyle()))),
                                      Expanded(
                                          flex: 7,
                                          child: Container(
                                              child: Text('0000.00.00',
                                                  style: CustomStyles
                                                      .dark16TextStyle())))
                                    ])),
                                Container(
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    margin: EdgeInsets.only(top: 10.0),
                                    child: Row(children: [
                                      Expanded(
                                          flex: 3,
                                          child: Container(
                                              child: Text('지원자',
                                                  style: CustomStyles
                                                      .darkBold16TextStyle()))),
                                      Expanded(
                                          flex: 7,
                                          child: Container(
                                              child: Text(
                                                  StringUtils.checkedString(
                                                          _castingBoardData[
                                                              APIConstants
                                                                  .apply_cnt]) +
                                                      "명",
                                                  style: CustomStyles
                                                      .dark16TextStyle())))
                                    ])),
                                Visibility(
                                    child: Container(
                                        padding: EdgeInsets.only(
                                            left: 15, right: 15),
                                        margin: EdgeInsets.only(top: 10.0),
                                        child: Text('첨부파일 또는 이미지',
                                            style: CustomStyles
                                                .darkBold16TextStyle())),
                                    visible: _castingBoardData[APIConstants
                                                .project_file_url] ==
                                            null
                                        ? false
                                        : true),
                                Visibility(
                                    child: Container(
                                        margin: EdgeInsets.only(
                                            top: 15.0, left: 15, right: 15),
                                        padding: EdgeInsets.only(
                                            left: 15,
                                            right: 15,
                                            top: 12,
                                            bottom: 12),
                                        decoration: BoxDecoration(
                                          color: CustomColors.colorBgGrey,
                                        ),
                                        child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                  flex: 1,
                                                  child: Text('첨부파일',
                                                      style: CustomStyles
                                                          .dark14TextStyle(),
                                                      overflow:
                                                          TextOverflow.clip)),
                                              Expanded(
                                                  flex: 0,
                                                  child: CustomStyles
                                                      .darkBold14TextButtonStyle(
                                                          '다운로드', () async {
                                                    String _url =
                                                        _castingBoardData[
                                                            APIConstants
                                                                .project_file_url];
                                                    await canLaunch(_url)
                                                        ? await launch(_url)
                                                        : throw '$_url을 열 수 없습니다.';
                                                  }))
                                            ])),
                                    visible:
                                        _castingBoardData[APIConstants.isImg] ==
                                                null
                                            ? false
                                            : (_castingBoardData[
                                                        APIConstants.isImg] ==
                                                    0
                                                ? true
                                                : false)),
                                Visibility(
                                    child: Container(
                                      margin: EdgeInsets.only(top: 15),
                                      alignment: Alignment.center,
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            stops: [
                                              0.1,
                                              1
                                            ],
                                            colors: [
                                              CustomColors.colorAccent,
                                              CustomColors.colorPrimary
                                            ]),
                                      ),
                                      child: _castingBoardData[APIConstants
                                                  .project_file_url] !=
                                              null
                                          ? CachedNetworkImage(
                                          placeholder: (context, url) => Container(
                                              alignment: Alignment.center,
                                              child: CircularProgressIndicator()),
                                              imageUrl: _castingBoardData[
                                                  APIConstants
                                                      .project_file_url],
                                              fit: BoxFit.fitWidth,
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Container())
                                          : null,
                                    ),
                                    visible:
                                        _castingBoardData[APIConstants.isImg] ==
                                                null
                                            ? false
                                            : (_castingBoardData[
                                                        APIConstants.isImg] ==
                                                    1
                                                ? true
                                                : false)),
                                Container(
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    margin: EdgeInsets.only(top: 30.0),
                                    child: Text('배역소개',
                                        style: CustomStyles.dark20TextStyle())),
                                Container(
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    margin: EdgeInsets.only(top: 20.0),
                                    child: Row(children: [
                                      Expanded(
                                          flex: 3,
                                          child: Container(
                                              child: Text('배역',
                                                  style: CustomStyles
                                                      .darkBold16TextStyle()))),
                                      Expanded(
                                          flex: 7,
                                          child: Container(
                                              child: Text(
                                                  StringUtils.checkedString(
                                                      _castingBoardData[
                                                          APIConstants
                                                              .casting_type]),
                                                  style: CustomStyles
                                                      .dark16TextStyle())))
                                    ])),
                                Container(
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    margin: EdgeInsets.only(top: 10.0),
                                    child: Row(children: [
                                      Expanded(
                                          flex: 3,
                                          child: Container(
                                              child: Text('배역 수',
                                                  style: CustomStyles
                                                      .darkBold16TextStyle()))),
                                      Expanded(
                                          flex: 7,
                                          child: Container(
                                              child: Text(
                                                  StringUtils.checkedString(
                                                          _castingBoardData[
                                                              APIConstants
                                                                  .casting_count]) +
                                                      "명",
                                                  style: CustomStyles
                                                      .dark16TextStyle())))
                                    ])),
                                Container(
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    margin: EdgeInsets.only(top: 10.0),
                                    child: Row(children: [
                                      Expanded(
                                          flex: 3,
                                          child: Container(
                                              child: Text('성별',
                                                  style: CustomStyles
                                                      .darkBold16TextStyle()))),
                                      Expanded(
                                          flex: 7,
                                          child: Container(
                                              child: Text(
                                                  StringUtils.checkedString(
                                                      _castingBoardData[
                                                          APIConstants
                                                              .sex_type]),
                                                  style: CustomStyles
                                                      .dark16TextStyle())))
                                    ])),
                                Container(
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    margin: EdgeInsets.only(top: 10.0),
                                    child: Row(children: [
                                      Expanded(
                                          flex: 3,
                                          child: Container(
                                              child: Text('나이',
                                                  style: CustomStyles
                                                      .darkBold16TextStyle()))),
                                      Expanded(
                                          flex: 7,
                                          child: Container(
                                              child: Text(_ageStr,
                                                  style: CustomStyles
                                                      .dark16TextStyle())))
                                    ])),
                                Container(
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    margin: EdgeInsets.only(top: 10.0),
                                    child: Row(children: [
                                      Expanded(
                                          flex: 3,
                                          child: Container(
                                              child: Text('키',
                                                  style: CustomStyles
                                                      .darkBold16TextStyle()))),
                                      Expanded(
                                          flex: 7,
                                          child: Container(
                                              child: Text(_heightStr,
                                                  style: CustomStyles
                                                      .dark16TextStyle())))
                                    ])),
                                Container(
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    margin: EdgeInsets.only(top: 10.0),
                                    child: Row(children: [
                                      Expanded(
                                          flex: 3,
                                          child: Container(
                                              child: Text('체중',
                                                  style: CustomStyles
                                                      .darkBold16TextStyle()))),
                                      Expanded(
                                          flex: 7,
                                          child: Container(
                                              child: Text(_weightStr,
                                                  style: CustomStyles
                                                      .dark16TextStyle())))
                                    ])),
                                Container(
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    margin: EdgeInsets.only(top: 10.0),
                                    child: Row(children: [
                                      Expanded(
                                          flex: 3,
                                          child: Container(
                                              child: Text('연기전공',
                                                  style: CustomStyles
                                                      .darkBold16TextStyle()))),
                                      Expanded(
                                          flex: 7,
                                          child: Container(
                                              child: Text(
                                                  StringUtils.checkedString(
                                                      _castingBoardData[
                                                          APIConstants
                                                              .major_type]),
                                                  style: CustomStyles
                                                      .dark16TextStyle())))
                                    ])),
                                Container(
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    margin: EdgeInsets.only(top: 10.0),
                                    child: Row(children: [
                                      Expanded(
                                          flex: 3,
                                          child: Container(
                                              child: Text('언어',
                                                  style: CustomStyles
                                                      .darkBold16TextStyle()))),
                                      Expanded(
                                          flex: 7,
                                          child: Container(
                                              child: Text(_castingLanguageStr,
                                                  style: CustomStyles
                                                      .dark16TextStyle())))
                                    ])),
                                Container(
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    margin: EdgeInsets.only(top: 10.0),
                                    child: Row(children: [
                                      Expanded(
                                          flex: 3,
                                          child: Container(
                                              child: Text('특기',
                                                  style: CustomStyles
                                                      .darkBold16TextStyle()))),
                                      Expanded(
                                          flex: 7,
                                          child: Container(
                                              child: Text(_castingAbilityStr,
                                                  style: CustomStyles
                                                      .dark16TextStyle())))
                                    ])),
                                Container(
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    margin: EdgeInsets.only(top: 10.0),
                                    child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                              flex: 3,
                                              child: Container(
                                                  child: Text('캐릭터 소개',
                                                      style: CustomStyles
                                                          .darkBold16TextStyle()))),
                                          Expanded(
                                              flex: 7,
                                              child: Container(
                                                  child: Text(
                                                      StringUtils.checkedString(
                                                          _castingBoardData[
                                                              APIConstants
                                                                  .casting_Introduce]),
                                                      style: CustomStyles
                                                          .dark16TextStyle())))
                                        ])),
                                Container(
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    margin: EdgeInsets.only(top: 10.0),
                                    child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                              flex: 3,
                                              child: Container(
                                                  child: Text('특이사항',
                                                      style: CustomStyles
                                                          .darkBold16TextStyle()))),
                                          Expanded(
                                              flex: 7,
                                              child: Container(
                                                  child: Text(
                                                      StringUtils.checkedString(
                                                          _castingBoardData[
                                                              APIConstants
                                                                  .casting_uniqueness]),
                                                      style: CustomStyles
                                                          .dark16TextStyle())))
                                        ])),
                                Container(
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    margin: EdgeInsets.only(top: 10.0),
                                    child: Row(children: [
                                      Expanded(
                                          flex: 3,
                                          child: Container(
                                              child: Text('페이',
                                                  style: CustomStyles
                                                      .darkBold16TextStyle()))),
                                      Expanded(
                                          flex: 7,
                                          child: Container(
                                              child: Text(_payStr,
                                                  style: CustomStyles
                                                      .dark16TextStyle())))
                                    ])),
                                Container(
                                    margin:
                                        EdgeInsets.only(top: 30, bottom: 30),
                                    child: Divider(
                                        height: 0.1,
                                        color:
                                            CustomColors.colorFontLightGrey)),
                                Container(
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    child: Text('작품소개',
                                        style: CustomStyles.dark20TextStyle())),
                                Container(
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    margin: EdgeInsets.only(top: 20.0),
                                    child: Row(children: [
                                      Expanded(
                                          flex: 3,
                                          child: Container(
                                              child: Text('장르',
                                                  style: CustomStyles
                                                      .darkBold16TextStyle()))),
                                      Expanded(
                                          flex: 7,
                                          child: Container(
                                              child: Text(
                                                  StringUtils.checkedString(
                                                      _castingBoardData[
                                                          APIConstants
                                                              .genre_type]),
                                                  style: CustomStyles
                                                      .dark16TextStyle())))
                                    ])),
                                Container(
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    margin: EdgeInsets.only(top: 10.0),
                                    child: Row(children: [
                                      Expanded(
                                          flex: 3,
                                          child: Container(
                                              child: Text('제작유형',
                                                  style: CustomStyles
                                                      .darkBold16TextStyle()))),
                                      Expanded(
                                          flex: 7,
                                          child: Container(
                                              child: Text(
                                                  StringUtils.checkedString(
                                                      _castingBoardData[
                                                          APIConstants
                                                              .project_type]),
                                                  style: CustomStyles
                                                      .dark16TextStyle())))
                                    ])),
                                Container(
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    margin: EdgeInsets.only(top: 10.0),
                                    child: Row(children: [
                                      Expanded(
                                          flex: 3,
                                          child: Container(
                                              child: Text('제작사',
                                                  style: CustomStyles
                                                      .darkBold16TextStyle()))),
                                      Expanded(
                                          flex: 7,
                                          child: Container(
                                              child: Text(
                                                  StringUtils.checkedString(
                                                      _castingBoardData[
                                                          APIConstants
                                                              .production_name]),
                                                  style: CustomStyles
                                                      .dark16TextStyle())))
                                    ])),
                                Container(
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    margin: EdgeInsets.only(top: 10.0),
                                    child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                              flex: 3,
                                              child: Container(
                                                  child: Text('작품소개',
                                                      style: CustomStyles
                                                          .darkBold16TextStyle()))),
                                          Expanded(
                                              flex: 7,
                                              child: Container(
                                                  child: Text(
                                                      StringUtils.checkedString(
                                                          _castingBoardData[
                                                              APIConstants
                                                                  .project_Introduce]),
                                                      style: CustomStyles
                                                          .dark16TextStyle())))
                                        ])),
                                Container(
                                    margin:
                                        EdgeInsets.only(top: 30, bottom: 30),
                                    child: Divider(
                                        height: 0.1,
                                        color:
                                            CustomColors.colorFontLightGrey)),
                                Container(
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    child: Text('일정안내',
                                        style: CustomStyles.dark20TextStyle())),
                                Container(
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    margin: EdgeInsets.only(top: 20.0),
                                    child: Row(children: [
                                      Expanded(
                                          flex: 3,
                                          child: Container(
                                              child: Text('촬영기간',
                                                  style: CustomStyles
                                                      .darkBold16TextStyle()))),
                                      Expanded(
                                          flex: 7,
                                          child: Container(
                                              child: Text(_shootingDateStr,
                                                  style: CustomStyles
                                                      .dark16TextStyle())))
                                    ])),
                                Container(
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    margin: EdgeInsets.only(top: 10.0),
                                    child: Row(children: [
                                      Expanded(
                                          flex: 3,
                                          child: Container(
                                              child: Text('촬영지역',
                                                  style: CustomStyles
                                                      .darkBold16TextStyle()))),
                                      Expanded(
                                          flex: 7,
                                          child: Container(
                                              child: Text(
                                                  StringUtils.checkedString(
                                                      _castingBoardData[
                                                          APIConstants
                                                              .shooting_place]),
                                                  style: CustomStyles
                                                      .dark16TextStyle())))
                                    ]))
                              ])))),
              Visibility(
                  child: Container(
                      height: 55,
                      color: CustomColors.colorBgGrey,
                      child: Row(children: [
                        Expanded(
                            flex: 1,
                            child: Container(
                                height: 55,
                                child: CustomStyles.blueBGSquareButtonStyle(
                                    '지원하기 D-56', () {
                                  if (KCastingAppData()
                                          .myInfo[APIConstants.member_type] ==
                                      APIConstants.member_type_actor) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                AuditionApplyUploadImage(
                                                  castingSeq: _castingSeq,
                                                  projectName:
                                                      _castingBoardData[
                                                          APIConstants
                                                              .project_name],
                                                  castingName:
                                                      _castingBoardData[
                                                          APIConstants
                                                              .casting_name],
                                                )));
                                  }
                                  //else if(KCastingAppData().myInfo[APIConstants.member_type] == APIConstants.member_type_management) {
                                  else {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                AgencyActorAuditionApply(
                                                  castingSeq: _castingSeq,
                                                  projectName:
                                                      _castingBoardData[
                                                          APIConstants
                                                              .project_name],
                                                  castingName:
                                                      _castingBoardData[
                                                          APIConstants
                                                              .casting_name],
                                                )));
                                  }
                                }))),
                        GestureDetector(
                            onTap: () {
                              if (KCastingAppData()
                                      .myInfo[APIConstants.member_type] ==
                                  APIConstants.member_type_actor) {
                                requestActorBookmarkEditApi(context);
                              } else {
                                requestManagementBookmarkEditApi(context);
                              }
                            },
                            child: Visibility(
                                child: Container(
                                    height: 55,
                                    width: 55,
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    alignment: Alignment.center,
                                    child: ((_castingBoardData[
                                                _isBookmarkedKey] ==
                                            1)
                                        ? Image.asset(
                                            'assets/images/toggle_like_on.png',
                                            width: 20,
                                            color: CustomColors.colorAccent)
                                        : Image.asset(
                                            'assets/images/toggle_like_off.png',
                                            width: 20))),
                                visible: (KCastingAppData().myInfo[
                                            APIConstants.member_type]) ==
                                        APIConstants.member_type_product
                                    ? false
                                    : true))
                      ])),
                  visible: KCastingAppData().myInfo[APIConstants.member_type] ==
                          APIConstants.member_type_product
                      ? false
                      : _castingStateStr == ""
                          ? true
                          : false),
              Visibility(
                child: Container(
                    height: 55,
                    color: CustomColors.colorBgGrey,
                    child: Row(children: [
                      Expanded(
                          flex: 1,
                          child: Container(
                              height: 55,
                              child: CustomStyles.greyBGSquareButtonStyle(
                                  _castingStateStr, () {})))
                    ])),
                visible: _castingStateStr == "" ? false : true,
              )
            ]))));
  }
}
