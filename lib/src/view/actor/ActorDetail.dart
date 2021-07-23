import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/KCastingAppData.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/view/actor/ActorProfileWidget.dart';
import 'package:casting_call/src/view/audition/production/ProposeAudition.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';

/*
* 배우 상세화면
* */
class ActorDetail extends StatefulWidget {
  final int seq;
  final int actorProfileSeq;

  const ActorDetail({Key key, this.seq, this.actorProfileSeq})
      : super(key: key);

  @override
  _ActorDetail createState() => _ActorDetail();
}

class _ActorDetail extends State<ActorDetail>
    with SingleTickerProviderStateMixin, BaseUtilMixin {
  int _seq;
  int _actorProfileSeq;

  Map<String, dynamic> _actorProfile = new Map();
  List<dynamic> _actorFilmorgraphy = [];
  List<dynamic> _actorImage = [];
  List<dynamic> _actorVideo = [];

  String _actorAgeStr = "";
  String _actorEducationStr = "";
  String _actorLanguageStr = "";
  String _actordialectStr = "";
  String _actorAbilityStr = "";
  List<String> _actorKwdList = [];

  final GlobalKey<TagsState> _myKeywordTagStateKey = GlobalKey<TagsState>();

  // 탭바 뷰 관련 변수(필모그래피, 이미지, 비디오)
  TabController _tabController;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();

    _seq = widget.seq;
    _actorProfileSeq = widget.actorProfileSeq;

    // 배우 프로필 조회 api 호출
    requestActorProfileApi(context);

    // 탭바 (필모그래피, 이미지, 비디오)
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _tabIndex = _tabController.index;
        });
      }
    });
  }

  /*
  * 배우프로필조회
  * */
  void requestActorProfileApi(BuildContext context) {
    final dio = Dio();

    // 배우프로필조회 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetData = new Map();
    targetData[APIConstants.actor_seq] = _seq;
    targetData[APIConstants.actor_profile_seq] = _actorProfileSeq;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.SAR_APR_INFO;
    params[APIConstants.target] = targetData;

    // 배우프로필조회 api 호출
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value == null) {
        // 에러 - 데이터 널
        showSnackBar(context, APIConstants.error_msg_server_not_response);
      } else {
        if (value[APIConstants.resultVal]) {
          // 배우프로필조회 성공
          var _responseList = value[APIConstants.data] as List;

          setState(() {
            for (int i = 0; i < _responseList.length; i++) {
              var _data = _responseList[i];

              switch (_data[APIConstants.table]) {
                // 배우 프로필
                case APIConstants.table_actor_profile:
                  {
                    var _listData = _data[APIConstants.data];
                    if (_listData != null) {
                      List<dynamic> _actorProfileList =
                          _listData[APIConstants.list] as List;
                      if (_actorProfileList != null) {
                        _actorProfile = _actorProfileList.length > 0
                            ? _actorProfileList[0]
                            : null;
                      }
                    }
                    break;
                  }

                // 배우 학력사항
                case APIConstants.table_actor_education:
                  {
                    var _listData = _data[APIConstants.data];
                    List<dynamic> _actorEducation;
                    if (_listData != null) {
                      _actorEducation = _listData[APIConstants.list] as List;
                    } else {
                      _actorEducation = [];
                    }

                    for (int i = 0; i < _actorEducation.length; i++) {
                      var _eduData = _actorEducation[i];
                      _actorEducationStr +=
                          _eduData[APIConstants.education_name];
                      _actorEducationStr += "\t";
                      _actorEducationStr += _eduData[APIConstants.major_name];

                      if (i != _actorEducation.length - 1)
                        _actorEducationStr += "\n";
                    }

                    break;
                  }

                // 배우 언어
                case APIConstants.table_actor_languge:
                  {
                    var _listData = _data[APIConstants.data];
                    List<dynamic> _actorLanguage;
                    if (_listData != null) {
                      _actorLanguage = _listData[APIConstants.list] as List;
                    } else {
                      _actorLanguage = [];
                    }

                    for (int i = 0; i < _actorLanguage.length; i++) {
                      var _lanData = _actorLanguage[i];
                      _actorLanguageStr += _lanData[APIConstants.language_type];

                      if (i != _actorLanguage.length - 1)
                        _actorLanguageStr += ",\t";
                    }

                    break;
                  }

                // 배우 사투리
                case APIConstants.table_actor_dialect:
                  {
                    var _listData = _data[APIConstants.data];
                    List<dynamic> _actorDialect;
                    if (_listData != null) {
                      _actorDialect = _listData[APIConstants.list] as List;
                    } else {
                      _actorDialect = [];
                    }

                    for (int i = 0; i < _actorDialect.length; i++) {
                      var _lanData = _actorDialect[i];
                      _actordialectStr += _lanData[APIConstants.language_type];

                      if (i != _actorDialect.length - 1)
                        _actordialectStr += ",\t";
                    }

                    break;
                  }

                // 배우 특기
                case APIConstants.table_actor_ability:
                  {
                    var _listData = _data[APIConstants.data];
                    List<dynamic> _actorAbility;
                    if (_listData != null) {
                      _actorAbility = _listData[APIConstants.list] as List;
                    } else {
                      _actorAbility = [];
                    }

                    for (int i = 0; i < _actorAbility.length; i++) {
                      var _abilityData = _actorAbility[i];
                      _actorAbilityStr += _abilityData[APIConstants.child_type];

                      if (i != _actorAbility.length - 1)
                        _actorAbilityStr += ",\t";
                    }
                    break;
                  }

                // 배우 캐스팅 키워드
                case APIConstants.table_actor_castingKwd:
                  {
                    var _listData = _data[APIConstants.data];
                    List<dynamic> _actorCastingKwd;
                    if (_listData != null) {
                      _actorCastingKwd = _listData[APIConstants.list] as List;
                    } else {
                      _actorCastingKwd = [];
                    }

                    for (int i = 0; i < _actorCastingKwd.length; i++) {
                      var _lookKwdData = _actorCastingKwd[i];

                      for (int j = 0;
                          j < KCastingAppData().commonCodeK01.length;
                          j++) {
                        var _castingKwdCode =
                            KCastingAppData().commonCodeK01[j];

                        if (_lookKwdData[APIConstants.code_seq] ==
                            _castingKwdCode[APIConstants.seq]) {
                          _actorKwdList
                              .add(_castingKwdCode[APIConstants.child_name]);
                        }
                      }
                    }

                    break;
                  }

                // 배우 외모 키워드
                case APIConstants.table_actor_lookkwd:
                  {
                    var _listData = _data[APIConstants.data];
                    List<dynamic> _actorLookKwd;
                    if (_listData != null) {
                      _actorLookKwd = _listData[APIConstants.list] as List;
                    } else {
                      _actorLookKwd = [];
                    }

                    for (int i = 0; i < _actorLookKwd.length; i++) {
                      var _lookKwdData = _actorLookKwd[i];

                      for (int j = 0;
                          j < KCastingAppData().commonCodeK02.length;
                          j++) {
                        var _lookKwdCode = KCastingAppData().commonCodeK02[j];

                        if (_lookKwdData[APIConstants.code_seq] ==
                            _lookKwdCode[APIConstants.seq]) {
                          _actorKwdList
                              .add(_lookKwdCode[APIConstants.child_name]);
                        }
                      }
                    }

                    break;
                  }

                // 배우 필모그래피
                case APIConstants.table_actor_filmography:
                  {
                    var _listData = _data[APIConstants.data];
                    if (_listData != null) {
                      _actorFilmorgraphy = _listData[APIConstants.list] as List;
                    } else {
                      _actorFilmorgraphy = [];
                    }
                    break;
                  }

                // 배우 이미지
                case APIConstants.table_actor_image:
                  {
                    var _listData = _data[APIConstants.data];
                    if (_listData != null) {
                      _actorImage = _listData[APIConstants.list] as List;
                    } else {
                      _actorImage = [];
                    }
                    break;
                  }

                // 배우 비디오
                case APIConstants.table_actor_video:
                  {
                    var _listData = _data[APIConstants.data];
                    if (_listData != null) {
                      _actorVideo = _listData[APIConstants.list] as List;
                    } else {
                      _actorVideo = [];
                    }

                    break;
                  }
              }
            }
          });
        } else {
          // 배우프로필조회 실패
          showSnackBar(context, APIConstants.error_msg_try_again);
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
            appBar: CustomStyles.defaultAppBar('프로필 관리', () {
              Navigator.pop(context);
            }),
            body: Container(
                child: Column(children: [
              Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                      child: Container(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                        ActorProfileWidget.mainImageWidget(
                            context, false, _actorProfile, null),
                        ActorProfileWidget.profileWidget(
                            context,
                            _myKeywordTagStateKey,
                            _actorProfile,
                            _actorAgeStr,
                            _actorEducationStr,
                            _actordialectStr,
                            _actorLanguageStr,
                            _actorAbilityStr,
                            _actorKwdList),
                        Container(
                            margin: EdgeInsets.only(top: 20),
                            child: Divider(
                              height: 1,
                              color: CustomColors.colorFontLightGrey,
                            )),
                        ActorProfileWidget.profileTabBarWidget(_tabController),
                        Expanded(
                          flex: 0,
                          child: [
                            Container(
                                margin: EdgeInsets.only(bottom: 30),
                                child: Column(children: [
                                  Container(
                                      padding: EdgeInsets.only(
                                          top: 20,
                                          left: 20,
                                          right: 20,
                                          bottom: 15),
                                      child: Row(children: [
                                        Expanded(
                                            flex: 1,
                                            child: Text(
                                                '출연 작품: ' +
                                                    _actorFilmorgraphy.length
                                                        .toString(),
                                                style: CustomStyles
                                                    .normal14TextStyle()))
                                      ])),
                                  ActorProfileWidget.filmorgraphyListWidget(
                                      false, _actorFilmorgraphy, (index) {})
                                ])),
                            ActorProfileWidget.imageTabItemWidget(
                                false, _actorImage, null),
                            ActorProfileWidget.videoTabItemWidget(
                                false, _actorVideo, null)
                          ][_tabIndex],
                        )
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
                                  '오디션 제안', () {
                                addView(
                                    context,
                                    ProposeAudition(
                                        actorSeq:
                                            _actorProfile[APIConstants.seq],
                                        actorName: _actorProfile[
                                            APIConstants.actor_name],
                                        actorImgUrl: _actorProfile[
                                            APIConstants.main_img_url]));
                              }))),
                      Container(
                          height: 55,
                          width: 55,
                          padding: EdgeInsets.only(left: 15, right: 15),
                          alignment: Alignment.center,
                          child: Image.asset(
                            'assets/images/toggle_like_off.png',
                            width: 20,
                          ))
                    ])),
                visible: KCastingAppData().myInfo[APIConstants.member_type] ==
                        APIConstants.member_type_product
                    ? true
                    : false,
              )
            ]))));
  }
}
