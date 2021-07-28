import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../KCastingAppData.dart';

class PushNotification extends StatefulWidget {
  @override
  _PushNotification createState() => _PushNotification();
}

class _PushNotification extends State<PushNotification> with BaseUtilMixin {
  // 알림 리스트 관련 변수
  bool _isUpload = false;
  ScrollController _scrollController;

  int _total = 0;
  int _limit = 20;

  List<dynamic> _noticeList = [];
  bool _isLoading = true;

  @override
  void initState() {
    _scrollController = ScrollController(initialScrollOffset: 50.0);
    _scrollController.addListener(_scrollListener);

    super.initState();

    // 알림 목록 api 조회
    requestNoticeListApi(context);
  }

  // 리스트뷰 스크롤 컨트롤러 이벤트 리스너
  _scrollListener() {
    print(_scrollController.position.extentAfter);
    print(_scrollController.offset);

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
              var _responseList = value[APIConstants.data];
              var _pagingData = _responseList[APIConstants.paging];

              _total = _pagingData[APIConstants.total];
              KCastingAppData().myInfo[APIConstants.newAlertCnt] = _total;

              if (_responseList != null && _responseList.length > 0) {
                _noticeList.addAll(_responseList[APIConstants.list]);
              }

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
              SingleChildScrollView(
                  controller: _scrollController,
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(children: [
                    Container(
                        child: ListView.separated(
                            primary: false,
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: _noticeList.length,
                            itemBuilder: (BuildContext context, int index) {
                              Map<String, dynamic> _data = _noticeList[index];

                              return Container(
                                  alignment: Alignment.centerLeft,
                                  child: GestureDetector(
                                      onTap: () {
                                        requestCheckNoticeApi(
                                            context, _data[APIConstants.seq]);
                                      },
                                      child: Container(
                                          alignment: Alignment.centerLeft,
                                          padding: EdgeInsets.only(
                                              left: 15,
                                              right: 15,
                                              top: 20,
                                              bottom: 20),
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                    margin: EdgeInsets.only(
                                                        bottom: 5),
                                                    child: Text(
                                                        _data[APIConstants
                                                            .alert_contents],
                                                        style: CustomStyles
                                                            .normal16TextStyle())),
                                                Container(
                                                    child: Text(
                                                        _data[APIConstants
                                                            .addDate],
                                                        style: CustomStyles
                                                            .normal14TextStyle()))
                                              ]))));
                            },
                            separatorBuilder: (context, index) {
                              return Divider(
                                height: 0.1,
                                color: CustomColors.colorFontLightGrey,
                              );
                            })),
                    Visibility(
                        child: Divider(),
                        visible: _noticeList.length > 0 ? true : false),
                  ])),
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
