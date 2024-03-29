import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/dialog/DialogAuditionApplyCancel.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/ui/DecoratedTabBar.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../../KCastingAppData.dart';
import 'AuditionApplyDetail.dart';

/*
* 지원 현황 목록
* */
class AuditionApplyList extends StatefulWidget {
  final int actorSeq;

  const AuditionApplyList({Key key, this.actorSeq}) : super(key: key);

  @override
  _AuditionApplyList createState() => _AuditionApplyList();
}

class _AuditionApplyList extends State<AuditionApplyList>
    with SingleTickerProviderStateMixin, BaseUtilMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool _isUpload = false;
  int _actorSeq;

  TabController _tabController;
  int _tabIndex = 0;

  // 지원현황 리스트 관련 변수
  List<dynamic> _auditionList = [];

  // 지원 현황 상세 조회 윗부분
  String actorName = '';
  int applyIngCnt = 0;
  int applyCompleteCnt = 0;
  int applyFailCnt = 0;

  ScrollController _scrollController;

  int _total = 0;
  int _limit = 20;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _actorSeq = widget.actorSeq;
    if (KCastingAppData().myInfo[APIConstants.member_type] ==
        APIConstants.member_type_actor) {
      _actorSeq = KCastingAppData().myInfo[APIConstants.seq];
    }

    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);

    _scrollController = new ScrollController(initialScrollOffset: 5.0)
      ..addListener(_scrollListener);

    requestMyApplyListHeadApi(context);
    requestMyApplyListApi(context, "진행중");
  }

  _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _tabIndex = _tabController.index;

        String stateType =
            _tabIndex == 0 ? "진행중" : (_tabIndex == 1 ? "계약완료" : "불합격");
        _auditionList = [];
        requestMyApplyListApi(context, stateType);
      });
    }
  }

  _scrollListener() {
    if (_total == 0 || _auditionList.length >= _total) return;

    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      setState(() {
        _isLoading = true;

        if (_isLoading) {
          String stateType =
              _tabIndex == 0 ? "진행중" : (_tabIndex == 1 ? "계약완료" : "불합격");
          requestMyApplyListApi(context, stateType);
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
  * 지원현황 윗부분 조회
  * */
  void requestMyApplyListHeadApi(BuildContext _context) {
    setState(() {
      _isUpload = true;
    });

    // 지원현황 윗부분 조회 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetData = new Map();
    targetData[APIConstants.actor_seq] = _actorSeq;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.SEL_MGM_ACTORAUDITION_HEAD;
    params[APIConstants.target] = targetData;

    // 지원현황 윗부분 조회 api 호출
    RestClient(Dio()).postRequestMainControl(params).then((value) async {
      try {
        if (value != null) {
          if (value[APIConstants.resultVal]) {
            // 지원현황 윗부분 조회 성공
            var _responseData = value[APIConstants.data];

            if (_responseData == null) {
              return;
            }

            setState(() {
              List<dynamic> _responseList = _responseData[APIConstants.list];

              if (_responseList != null && _responseList.length > 0) {
                Map<String, dynamic> headerData = _responseList[0];

                if (headerData != null) {
                  actorName = headerData[APIConstants.actor_name];
                  applyIngCnt = headerData[APIConstants.applyIngCnt];
                  applyCompleteCnt = headerData[APIConstants.applyCompleteCnt];
                  applyFailCnt = headerData[APIConstants.applyFailCnt];
                }
              }
            });
          } else {
            showSnackBar(context, value[APIConstants.resultMsg]);
          }
        } else {
          showSnackBar(context, '다시 시도해 주세요.');
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
  * 지원현황 조회
  * */
  void requestMyApplyListApi(BuildContext _context, String stateType) {
    setState(() {
      _isUpload = true;
    });

    // 지원현황 조회 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetData = new Map();
    targetData[APIConstants.actor_seq] = _actorSeq;
    targetData[APIConstants.state_type] = stateType;

    Map<String, dynamic> paging = new Map();
    paging[APIConstants.offset] = _auditionList.length;
    paging[APIConstants.limit] = _limit;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.SEL_MGM_ACTORAUDITION_BODY;
    params[APIConstants.target] = targetData;
    params[APIConstants.paging] = paging;

    // 지원현황 조회 api 호출
    RestClient(Dio()).postRequestMainControl(params).then((value) async {
      try {
        if (value != null) {
          if (value[APIConstants.resultVal]) {
            // 지원현황 조회 성공
            var _responseList = value[APIConstants.data];

            var _pagingData = _responseList[APIConstants.paging];
            setState(() {
              _total = _pagingData[APIConstants.total];

              _auditionList.addAll(_responseList[APIConstants.list]);

              _isLoading = false;
            });
          } else {
            showSnackBar(context, value[APIConstants.resultMsg]);
          }
        } else {
          showSnackBar(context, '다시 시도해 주세요.');
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
  * 지원 취소
  * */
  void requestCancelApplyAuditionApi(
      BuildContext _context, int _auditionApplySeq) {
    setState(() {
      _isUpload = true;
    });

    // 지원현황 조회 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetData = new Map();
    targetData[APIConstants.auditionApply_seq] = _auditionApplySeq;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.DEL_AAA_INFO;
    params[APIConstants.target] = targetData;

    // 지원현황 조회 api 호출
    RestClient(Dio()).postRequestMainControl(params).then((value) async {
      try {
        if (value != null) {
          if (value[APIConstants.resultVal]) {
            // 지원현황 조회 성공
            showSnackBar(context, "지원을 취소했습니다.");

            _tabIndex = 0;

            _total = 0;
            _auditionList = [];

            requestMyApplyListApi(context, "진행중");
          } else {
            showSnackBar(context, value[APIConstants.resultMsg]);
          }
        } else {
          showSnackBar(context, '다시 시도해 주세요.');
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

  Widget tabMyApplyStatus() {
    return Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(bottom: 70, top: 30),
        padding: EdgeInsets.only(left: 15, right: 15),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Wrap(children: [
            ListView.builder(
                primary: false,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _auditionList.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                      onTap: () {
                        addView(
                            context,
                            AuditionApplyDetail(
                                applySeq: _auditionList[index]
                                    [APIConstants.auditionApply_seq]));
                      },
                      child: Container(
                          padding: EdgeInsets.only(left: 15, right: 15),
                          margin: EdgeInsets.only(bottom: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: CustomColors.colorWhite,
                              border: Border(
                                  left: BorderSide(
                                      color: _auditionList[index]
                                                  [APIConstants.state]
                                              .toString()
                                              .contains(' 합격')
                                          ? CustomColors.colorBlue
                                              .withAlpha(200)
                                          : _auditionList[index]
                                                      [APIConstants.state]
                                                  .toString()
                                                  .contains(' 불합격')
                                              ? CustomColors.colorPurple
                                                  .withAlpha(200)
                                              : CustomColors.colorBgGrey,
                                      width: 5)),
                              boxShadow: [
                                BoxShadow(
                                  color: CustomColors.colorFontLightGrey
                                      .withAlpha(100),
                                  blurRadius: 2.0,
                                  spreadRadius: 2.0,
                                  offset: Offset(2, 1),
                                )
                              ]),
                          child: Container(
                              decoration: BoxDecoration(
                                  color: CustomColors.colorWhite,
                                  borderRadius:
                                      CustomStyles.circle6BorderRadius()),
                              alignment: Alignment.center,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                        margin: EdgeInsets.only(top: 15),
                                        child: Text(
                                            _auditionList[index]
                                                [APIConstants.project_name],
                                            style: CustomStyles
                                                .dark12TextStyle())),
                                    Container(
                                        margin: EdgeInsets.only(bottom: 15),
                                        child: Text(
                                            _auditionList[index]
                                                [APIConstants.casting_name],
                                            style: CustomStyles
                                                .dark20TextStyle())),
                                    Visibility(
                                        child: Container(
                                            child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                              Expanded(
                                                  flex: 0,
                                                  child: Row(children: [
                                                    Text(
                                                        '지원일: ' +
                                                            _auditionList[index]
                                                                [APIConstants
                                                                    .addDate],
                                                        style: CustomStyles
                                                            .dark10TextStyle()),
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                right: 5)),
                                                    CustomStyles
                                                        .underline10TextButtonStyle(
                                                            '지원취소', () {
                                                      // 지원취소 버튼 클릭
                                                      showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                                  _context) =>
                                                              DialogAuditionApplyCancel(
                                                                  onClickedAgree:
                                                                      () {
                                                                requestCancelApplyAuditionApi(
                                                                    context,
                                                                    _auditionList[
                                                                            index]
                                                                        [
                                                                        APIConstants
                                                                            .auditionApply_seq]);
                                                              }));
                                                    })
                                                  ])),
                                              Expanded(
                                                  flex: 1,
                                                  child: Container(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      margin: EdgeInsets.only(
                                                          bottom: 15),
                                                      width:
                                                      (KCastingAppData().isWeb)
                                                          ? CustomStyles.appWidth
                                                          : MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      child: Text(
                                                          StringUtils.checkedString(
                                                              _auditionList[
                                                                      index][
                                                                  APIConstants
                                                                      .state]),
                                                          style: CustomStyles
                                                              .dark12TextStyle())))
                                            ])),
                                        visible: _tabIndex == 0 ? true : false),
                                    Visibility(
                                        child: Container(
                                            child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                              Expanded(
                                                  flex: 0,
                                                  child: Text(
                                                      '지원일: ' +
                                                          _auditionList[index][
                                                              APIConstants
                                                                  .addDate],
                                                      style: CustomStyles
                                                          .dark10TextStyle())),
                                              Expanded(
                                                  flex: 1,
                                                  child: Container(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      margin: EdgeInsets.only(
                                                          bottom: 15),
                                                      width:
                                                      (KCastingAppData().isWeb)
                                                          ? CustomStyles.appWidth
                                                          : MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      child: Text(
                                                        StringUtils
                                                            .checkedString(
                                                                _auditionList[
                                                                        index][
                                                                    APIConstants
                                                                        .state]),
                                                        style: CustomStyles
                                                            .dark12TextStyle(),
                                                      )))
                                            ])),
                                        visible: _tabIndex != 0 ? true : false)
                                  ]))));
                })
          ])
        ]));
  }

  Future<void> _refreshPage() async {
    setState(() {
      _total = 0;

      String stateType =
          _tabIndex == 0 ? "진행중" : (_tabIndex == 1 ? "계약완료" : "불합격");
      _auditionList = [];
      requestMyApplyListApi(context, stateType);
    });
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
                    key: _scaffoldKey,
                    appBar: CustomStyles.defaultAppBar('지원현황', () {
                      Navigator.pop(context);
                    }),
                    body: Builder(builder: (BuildContext context) {
                      return Stack(children: [
                        Container(
                            child: RefreshIndicator(
                                onRefresh: _refreshPage,
                                child: SingleChildScrollView(
                                    controller: _scrollController,
                                    physics: AlwaysScrollableScrollPhysics(),
                                    key: ObjectKey(_auditionList.length > 0
                                        ? _auditionList[0]
                                        : ""),
                                    child: Container(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                          Container(
                                              margin: EdgeInsets.only(
                                                  top: 30.0, bottom: 20),
                                              padding: EdgeInsets.only(
                                                  left: 15, right: 15),
                                              child: Text('지원 현황',
                                                  style: CustomStyles
                                                      .normal24TextStyle())),
                                          Container(
                                              width: (KCastingAppData().isWeb)
                                                  ? CustomStyles.appWidth
                                                  : MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: DecoratedTabBar(
                                                  decoration: BoxDecoration(
                                                      border: Border(
                                                          bottom: BorderSide(
                                                              color: CustomColors
                                                                  .colorBgGrey,
                                                              width: 1.0))),
                                                  tabBar: TabBar(
                                                      controller:
                                                          _tabController,
                                                      indicatorPadding:
                                                          EdgeInsets.zero,
                                                      indicatorColor:
                                                          CustomColors
                                                              .colorAccent
                                                              .withAlpha(200),
                                                      labelStyle: CustomStyles
                                                          .bold16TextStyle(),
                                                      indicatorWeight: 3,
                                                      labelColor: CustomColors
                                                          .colorFontTitle,
                                                      unselectedLabelStyle:
                                                          CustomStyles
                                                              .normal16TextStyle(),
                                                      tabs: [
                                                        Tab(
                                                            text:
                                                                '진행중($applyIngCnt)'),
                                                        Tab(
                                                            text:
                                                                '계약완료($applyCompleteCnt)'),
                                                        Tab(
                                                            text:
                                                                '불합격($applyFailCnt)')
                                                      ]))),
                                          Expanded(
                                            flex: 0,
                                            child: [
                                              tabMyApplyStatus(),
                                              tabMyApplyStatus(),
                                              tabMyApplyStatus()
                                            ][_tabIndex],
                                          ),
                                          Visibility(
                                              child: Container(
                                                  alignment: Alignment.center,
                                                  margin:
                                                      EdgeInsets.only(top: 50),
                                                  child: Text('지원현황이 없습니다.',
                                                      style: CustomStyles
                                                          .normal16TextStyle(),
                                                      textAlign:
                                                          TextAlign.center)),
                                              visible: _auditionList.length > 0
                                                  ? false
                                                  : true)
                                        ]))))),
                        Visibility(
                            child: Container(
                                color: Colors.black38,
                                alignment: Alignment.center,
                                child: CircularProgressIndicator()),
                            visible: _isUpload)
                      ]);
                    })))));
  }
}
