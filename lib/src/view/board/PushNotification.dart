import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/view/audition/actor/AuditionApplyDetail.dart';
import 'package:casting_call/src/view/audition/actor/OfferedAuditionDetail.dart';
import 'package:casting_call/src/view/audition/production/RegisteredAuditionDetail.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../KCastingAppData.dart';

class PushNotification extends StatefulWidget {
  final VoidCallback onClickedHome;

  const PushNotification({Key key, this.onClickedHome}) : super(key: key);

  @override
  _PushNotification createState() => _PushNotification();
}

class _PushNotification extends State<PushNotification> with BaseUtilMixin {
  VoidCallback _onClickedHome;

  // 알림 리스트 관련 변수
  bool _isUpload = false;
  ScrollController _scrollController;

  int _total = 0;
  int _limit = 20;

  List<dynamic> _noticeList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _onClickedHome = widget.onClickedHome;

    _scrollController = ScrollController(initialScrollOffset: 50.0);
    _scrollController.addListener(_scrollListener);

    // 알림 목록 api 조회
    requestNoticeListApi(context);
  }

  // 리스트뷰 스크롤 컨트롤러 이벤트 리스너
  _scrollListener() {
    if (_total == 0 || _noticeList.length >= _total) return;

    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      setState(() {
        _isLoading = true;

        if (_isLoading) {
          requestNoticeListApi(context);
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /*
  * 알림목록조회 api 호출
  * */
  void requestNoticeListApi(BuildContext context) {
    setState(() {
      _isUpload = true;
    });

    // 알림목록조회 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetData = new Map();
    targetData[APIConstants.member_type] =
        KCastingAppData().myInfo[APIConstants.member_type];

    switch (KCastingAppData().myInfo[APIConstants.member_type]) {
      case APIConstants.member_type_actor:
        targetData[APIConstants.actor_seq] =
            KCastingAppData().myInfo[APIConstants.seq];
        break;
      case APIConstants.member_type_product:
        targetData[APIConstants.production_seq] =
            KCastingAppData().myInfo[APIConstants.seq];
        break;
      case APIConstants.member_type_management:
        targetData[APIConstants.management_seq] =
            KCastingAppData().myInfo[APIConstants.seq];
        break;
    }

    Map<String, dynamic> paging = new Map();
    paging[APIConstants.offset] = _noticeList.length;
    paging[APIConstants.limit] = _limit;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.SEL_TOT_ALERTLIST;
    params[APIConstants.target] = targetData;
    params[APIConstants.paging] = paging;

    // 알림목록조회 api 호출
    RestClient(Dio()).postRequestMainControl(params).then((value) async {
      try {
        if (value != null) {
          if (value[APIConstants.resultVal]) {
            // 알림목록조회 성공
            setState(() {
              var _responseData = value[APIConstants.data];
              var _pagingData = _responseData[APIConstants.paging];

              _total = _pagingData[APIConstants.total];
              KCastingAppData().myInfo[APIConstants.newAlertCnt] = _total;

              var _responseList = _responseData[APIConstants.list];
              if (_responseList != null && _responseList.length > 0) {
                _noticeList.addAll(_responseList);
              }

              _onClickedHome();

              _isLoading = false;
            });
          }
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

  /*
  * 알림읽음처리 api 호출
  * */
  void requestCheckNoticeApi(BuildContext context, int seq) {
    setState(() {
      _isUpload = true;
    });

    // 알림읽음처리 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetData = new Map();
    targetData[APIConstants.seq] = seq;
    targetData[APIConstants.member_type] =
        KCastingAppData().myInfo[APIConstants.member_type];

    switch (KCastingAppData().myInfo[APIConstants.member_type]) {
      case APIConstants.member_type_actor:
        targetData[APIConstants.actor_seq] =
            KCastingAppData().myInfo[APIConstants.seq];
        break;
      case APIConstants.member_type_product:
        targetData[APIConstants.production_seq] =
            KCastingAppData().myInfo[APIConstants.seq];
        break;
      case APIConstants.member_type_management:
        targetData[APIConstants.management_seq] =
            KCastingAppData().myInfo[APIConstants.seq];
        break;
    }

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.CHK_TOT_ALERT;
    params[APIConstants.target] = targetData;

    // 알림읽음처리 api 호출
    RestClient(Dio()).postRequestMainControl(params).then((value) async {
      try {
        if (value != null) {
          if (value[APIConstants.resultVal]) {
            // 알림읽음처리 성공
            setState(() {
              _total = 0;
              _noticeList = [];
              requestNoticeListApi(context);
            });
          }
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

  Future<void> _refreshPage() async {
    setState(() {
      _total = 0;

      _noticeList = [];
      requestNoticeListApi(context);
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
            appBar: CustomStyles.defaultAppBar('', () {
              Navigator.pop(context);
            }),
            body: Stack(children: [
              RefreshIndicator(
                  child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Column(children: [
                        Container(
                            padding: EdgeInsets.only(
                                left: 15, right: 15, top: 20, bottom: 70),
                            child: ListView.builder(
                                primary: false,
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: _noticeList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  Map<String, dynamic> _data =
                                      _noticeList[index];

                                  return Container(
                                      alignment: Alignment.centerLeft,
                                      child: GestureDetector(
                                          onTap: () {
                                            if (_data[APIConstants
                                                        .alert_type] !=
                                                    null &&
                                                _data[APIConstants.type_seq] !=
                                                    null) {
                                              switch (_data[
                                                  APIConstants.alert_type]) {
                                                case APIConstants.ADD_ACT_PRP:
                                                  // 배우 회원 오디션 제안 받음
                                                  addView(
                                                      context,
                                                      OfferedAuditionDetail(
                                                          seq: _data[
                                                              APIConstants
                                                                  .type_seq]));

                                                  break;

                                                case APIConstants.ADD_MNG_PRP:
                                                  // 매니지먼트 회원 오디션 제안 받음
                                                  addView(
                                                      context,
                                                      OfferedAuditionDetail(
                                                          seq: _data[
                                                              APIConstants
                                                                  .type_seq]));

                                                  break;

                                                case APIConstants.UPD_ACT_AAS:
                                                  // 배우 회원이 지원한 오디션 상태값 변경됨
                                                  addView(
                                                      context,
                                                      AuditionApplyDetail(
                                                          applySeq: _data[
                                                              APIConstants
                                                                  .type_seq]));

                                                  break;

                                                case APIConstants.UPD_MNG_AAS:
                                                  // 매니지먼트 소속 배우 회원이 지원한 오디션 상태값 변경됨
                                                  addView(
                                                      context,
                                                      AuditionApplyDetail(
                                                          applySeq: _data[
                                                              APIConstants
                                                                  .type_seq]));

                                                  break;

                                                case APIConstants.ADD_PRD_AAA:
                                                  // 제작사가 등록한 오디션에 누가 지원함
                                                  addView(
                                                      context,
                                                      RegisteredAuditionDetail(
                                                          castingSeq: _data[
                                                              APIConstants
                                                                  .type_seq]));

                                                  break;

                                                case APIConstants.UPD_PRD_PPS:
                                                  // 제작사가 제안한 오디션에 배우가 수락 또는 거절함
                                                  addView(
                                                      context,
                                                      OfferedAuditionDetail(
                                                          seq: _data[
                                                              APIConstants
                                                                  .type_seq]));

                                                  break;
                                              }
                                            }

                                            requestCheckNoticeApi(context,
                                                _data[APIConstants.seq]);
                                          },
                                          child: Container(
                                              margin:
                                                  EdgeInsets.only(bottom: 10),
                                              decoration: BoxDecoration(
                                                  borderRadius: CustomStyles
                                                      .circle7BorderRadius(),
                                                  border: Border.all(
                                                      width: 0.5,
                                                      color: CustomColors
                                                          .colorBgGrey)),
                                              alignment: Alignment.centerLeft,
                                              padding: EdgeInsets.only(
                                                  left: 15,
                                                  right: 15,
                                                  top: 20,
                                                  bottom: 15),
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                        margin: EdgeInsets.only(
                                                            bottom: 10),
                                                        child: Text(
                                                            _data[APIConstants
                                                                .alert_contents],
                                                            style: CustomStyles
                                                                .normal16TextStyle())),
                                                    Container(
                                                        alignment: Alignment
                                                            .centerRight,
                                                        child: Text(
                                                            _data[APIConstants
                                                                .addDate],
                                                            style: CustomStyles
                                                                .normal14TextStyle()))
                                                  ]))));
                                }))
                      ])),
                  onRefresh: _refreshPage),
              Visibility(
                  child: Container(
                      alignment: Alignment.center,
                      child: Text('알림이 없습니다.',
                          style: CustomStyles.normal16TextStyle())),
                  visible: _noticeList.length > 0 ? false : true),
              Visibility(
                child: Container(
                    color: Colors.black38,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator()),
                visible: _isUpload,
              )
            ])));
  }
}
