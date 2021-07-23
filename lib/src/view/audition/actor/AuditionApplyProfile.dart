import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:casting_call/src/view/actor/ActorProfileWidget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';

/*
* 오디션 지원 시 제출한 프로필
* */
class AuditionApplyProfile extends StatefulWidget {
  final int applySeq;
  final bool isProduction;

  const AuditionApplyProfile({Key key, this.applySeq, this.isProduction})
      : super(key: key);

  @override
  _AuditionApplyProfile createState() => _AuditionApplyProfile();
}

class _AuditionApplyProfile extends State<AuditionApplyProfile>
    with SingleTickerProviderStateMixin, BaseUtilMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  int _applySeq;

  bool _isProduction = false;

  Map<String, dynamic> _actorProfile = new Map();
  List<dynamic> _actorFilmorgraphy = [];
  List<dynamic> _actorImage = [];
  List<dynamic> _actorVideo = [];
  List<String> _actorCastingKwdList = [];
  List<String> _actorLookKwdList = [];

  final GlobalKey<TagsState> _myKeywordTagStateKey = GlobalKey<TagsState>();
  final GlobalKey<TagsState> _myCastingKeywordTagStateKey = GlobalKey<TagsState>();

  // 탭바 뷰 관련 변수(필모그래피, 이미지, 비디오)
  TabController _tabController;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();

    _applySeq = widget.applySeq;
    _isProduction = widget.isProduction;

    // 배우 프로필 조회 api 호출
    requestActorProfileApi(context);

    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _tabIndex = _tabController.index;
      });
    }
  }

  /*
  * 배우 오디션 제출 프로필 조회
  * */
  void requestActorProfileApi(BuildContext context) {
    final dio = Dio();

    // 배우 오디션 제출 프로필 조회 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetData = new Map();
    targetData[APIConstants.audition_apply_seq] = _applySeq;
    if (_isProduction) {
      targetData[APIConstants.changeIsView] = _applySeq;
    }

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.SAR_AAP_INFO;
    params[APIConstants.target] = targetData;

    // 배우 오디션 제출 프로필 조회 api 호출
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value == null) {
        // 에러 - 데이터 널
        showSnackBar(context, APIConstants.error_msg_server_not_response);
      } else {
        if (value[APIConstants.resultVal]) {
          // 배우 오디션 제출 프로필 조회 성공
          var _responseList = value[APIConstants.data] as List;

          setState(() {
            for (int i = 0; i < _responseList.length; i++) {
              var _data = _responseList[i];

              switch (_data[APIConstants.table]) {
                // 배우 프로필
                case APIConstants.table_audition_apply_profile:
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

                    // 키워드
                    if (_actorProfile[APIConstants.actor_kwd] != null) {
                      String actorKwd = _actorProfile[APIConstants.actor_kwd];
                      List<String> actorKwdArr = actorKwd.split(',');
                      for (int i = 0; i < actorKwdArr.length; i++) {
                        _actorLookKwdList.add(actorKwdArr[i]);
                      }
                    }
                    break;
                  }

                // 배우 필모그래피
                case APIConstants.table_audition_apply_filmography:
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
                case APIConstants.table_audition_apply_image:
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
                case APIConstants.table_audition_apply_video:
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
          // 배우 오디션 제출 프로필 조회 실패
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
            key: _scaffoldKey,
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
                            _myCastingKeywordTagStateKey,
                            _actorProfile,
                            "",
                            StringUtils.checkedString(
                                _actorProfile[APIConstants.actor_education]),
                            StringUtils.checkedString(
                                _actorProfile[APIConstants.actor_languge]),
                            StringUtils.checkedString(
                                _actorProfile[APIConstants.table_actor_dialect]),
                            StringUtils.checkedString(
                                _actorProfile[APIConstants.actor_ability]),
                            _actorCastingKwdList,
                            _actorLookKwdList),
                        Container(
                          margin: EdgeInsets.only(top: 20),
                          child: Divider(
                            height: 1,
                            color: CustomColors.colorFontLightGrey,
                          ),
                        ),
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
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ]))));
  }
}
