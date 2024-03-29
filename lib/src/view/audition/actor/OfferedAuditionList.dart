import 'package:cached_network_image/cached_network_image.dart';
import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/ui/DecoratedTabBar.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../../../KCastingAppData.dart';
import 'OfferedAuditionDetail.dart';

/*
* 받은 제안 목록
* */
class OfferedAuditionList extends StatefulWidget {
  final int actorSeq;

  const OfferedAuditionList({Key key, this.actorSeq}) : super(key: key);

  @override
  _OfferedAuditionList createState() => _OfferedAuditionList();
}

class _OfferedAuditionList extends State<OfferedAuditionList>
    with SingleTickerProviderStateMixin, BaseUtilMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  int _actorSeq;
  bool _isUpload = false;

  TabController _tabController;
  int _tabIndex = 0;

  List<dynamic> _scoutList = [];

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

    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection);

    requestMyApplyListApi(context);

    _scrollController = new ScrollController(initialScrollOffset: 5.0)
      ..addListener(_scrollListener);
  }

  _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _tabIndex = _tabController.index;

        _total = 0;
        _scoutList = [];

        requestMyApplyListApi(context);
      });
    }
  }

  _scrollListener() {
    if (_total == 0 || _scoutList.length >= _total) return;

    if (_scrollController.offset >=
        _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      setState(() {
        _isLoading = true;

        if (_isLoading) {
          requestMyApplyListApi(context);
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
  * 배우 제안 받은 목록 조회
  * */
  void requestMyApplyListApi(BuildContext context) {
    setState(() {
      _isUpload = true;
    });

    // 배우 제안 받은 목록 조회 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetData = new Map();
    targetData[APIConstants.actor_seq] = _actorSeq;
    if (_tabIndex == 1) {
      targetData[APIConstants.state_type] = "수락";
    } else if (_tabIndex == 2) {
      targetData[APIConstants.state_type] = "거절";
    } else if (_tabIndex == 3) {
      targetData[APIConstants.state_type] = "대기";
    }

    Map<String, dynamic> paging = new Map();
    paging[APIConstants.offset] = _scoutList.length;
    paging[APIConstants.limit] = _limit;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.SEL_APP_ACTORSLIST;
    params[APIConstants.target] = targetData;
    params[APIConstants.paging] = paging;

    // 배우 제안 받은 목록 조회 api 호출
    RestClient(Dio()).postRequestMainControl(params).then((value) async {
      try {
        if (value != null) {
          if (value[APIConstants.resultVal]) {
            // 배우 제안 받은 목록 조회 성공
            var _responseList = value[APIConstants.data];

            var _pagingData = _responseList[APIConstants.paging];
            setState(() {
              _total = _pagingData[APIConstants.total];

              _scoutList.addAll(_responseList[APIConstants.list]);

              _isLoading = false;
            });
          } else {
            showSnackBar(context, APIConstants.error_msg_try_again);
          }
        } else {
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

  Widget tabItem() {
    return Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(bottom: 70, top: 30),
        padding: EdgeInsets.only(left: 15, right: 15),
        child: Column(children: [
          Wrap(children: [
            ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                primary: false,
                itemCount: _scoutList.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  OfferedAuditionDetail(
                                      seq: _scoutList[index]
                                      [APIConstants.auditionProposal_seq])),
                        ).then((value) =>
                        {
                          _total = 0,
                          _scoutList = [],
                          requestMyApplyListApi(context)
                        });
                      },
                      child: Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(bottom: 15),
                          decoration: BoxDecoration(
                              color: CustomColors.colorWhite,
                              border: Border(
                                  left: BorderSide(
                                      color: StringUtils.checkedString(
                                          _scoutList[index]
                                          [APIConstants.state_type])
                                          .contains('수락')
                                          ? CustomColors.colorBlue
                                          .withAlpha(200)
                                          : StringUtils.checkedString(
                                          _scoutList[
                                          index]
                                          [APIConstants.state_type])
                                          .contains('거절')
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
                              alignment: Alignment.center,
                              padding: EdgeInsets.only(
                                  left: 15, right: 15, top: 10, bottom: 10),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                        margin:
                                        EdgeInsets.only(top: 10, bottom: 15),
                                        child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.start,
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 0,
                                                child: Container(
                                                    decoration: new BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        gradient:
                                                        LinearGradient(colors: [
                                                          CustomColors
                                                              .colorPrimary,
                                                          CustomColors
                                                              .colorAccent
                                                        ])),
                                                    padding: EdgeInsets.all(2),
                                                    margin: EdgeInsets.only(
                                                        right: 15),
                                                    alignment: Alignment
                                                        .topCenter,
                                                    child: Container(
                                                      alignment: Alignment
                                                          .center,
                                                      width: 30,
                                                      height: 30,
                                                      decoration: new BoxDecoration(
                                                          shape: BoxShape
                                                              .circle,
                                                          color: CustomColors
                                                              .colorWhite),
                                                      padding: EdgeInsets.all(
                                                          1.0),
                                                      child: ClipOval(
                                                          child: CachedNetworkImage(
                                                              width: 30,
                                                              height: 30,
                                                              fit: BoxFit.cover,
                                                              placeholder: (
                                                                  context,
                                                                  url) =>
                                                                  Container(
                                                                      alignment:
                                                                      Alignment
                                                                          .center,
                                                                      child:
                                                                      CircularProgressIndicator()),
                                                              imageUrl: _scoutList[index]
                                                              [APIConstants
                                                                  .production_img_url],
                                                              errorWidget: (
                                                                  context,
                                                                  url, error) =>
                                                                  Image.asset(
                                                                      'assets/images/btn_mypage.png',
                                                                      color: CustomColors
                                                                          .colorBgGrey,
                                                                      width: 30,
                                                                      fit: BoxFit
                                                                          .contain))),
                                                    )),
                                              ),
                                              Expanded(
                                                  flex: 1,
                                                  child: Column(children: [
                                                    Row(children: [
                                                      Expanded(
                                                        flex: 1,
                                                        child: Text(
                                                          StringUtils
                                                              .checkedString(
                                                              _scoutList[index][
                                                              APIConstants
                                                                  .production_name]),
                                                          style: CustomStyles
                                                              .bold16TextStyle(),
                                                          maxLines: 1,
                                                          overflow:
                                                          TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                      Expanded(
                                                          flex: 0,
                                                          child: Text(
                                                              StringUtils
                                                                  .checkedString(
                                                                  _scoutList[index][
                                                                  APIConstants
                                                                      .state_type]),
                                                              style: CustomStyles
                                                                  .bold17TextStyle()))
                                                    ]),
                                                    Container(
                                                        alignment:
                                                        Alignment.centerLeft,
                                                        margin: EdgeInsets.only(
                                                            top: 5, left: 3),
                                                        child: Text(
                                                            StringUtils
                                                                .checkedString(
                                                                _scoutList[index][
                                                                APIConstants
                                                                    .audition_prps_contents]),
                                                            style: CustomStyles
                                                                .grey14TextStyle(),
                                                            maxLines: 2,
                                                            overflow: TextOverflow
                                                                .ellipsis))
                                                  ]))
                                            ])),
                                    Divider(),
                                    Container(
                                        padding:
                                        EdgeInsets.only(left: 10, right: 10),
                                        alignment: Alignment.centerLeft,
                                        width: MediaQuery
                                            .of(context)
                                            .size
                                            .width,
                                        height: 40,
                                        child: Row(children: [
                                          Expanded(
                                              child: Text(
                                                  StringUtils.checkedString(
                                                      _scoutList[index][APIConstants
                                                          .project_name]),
                                                  style: CustomStyles
                                                      .bold14TextStyle())),
                                          Expanded(
                                              flex: 0,
                                              child: Text(
                                                  StringUtils.checkedString(
                                                      _scoutList[index][APIConstants
                                                          .casting_name]),
                                                  style: CustomStyles
                                                      .bold16TextStyle()))
                                        ]))
                                  ]))));
                })
          ])
        ]));
  }

  Future<void> _refreshPage() async {
    setState(() {
      _total = 0;
      _scoutList = [];

      requestMyApplyListApi(context);
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
                    appBar: CustomStyles.defaultAppBar('받은 제안', () {
                      Navigator.pop(context);
                    }),
                    body: Stack(
                        children: [
                          Container(
                              child: RefreshIndicator(
                                  onRefresh: _refreshPage,
                                  child: SingleChildScrollView(
                                      controller: _scrollController,
                                      physics: AlwaysScrollableScrollPhysics(),
                                      key: ObjectKey(
                                          _scoutList.length > 0
                                              ? _scoutList[0]
                                              : ""),
                                      child: Container(
                                          child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  margin:
                                                  EdgeInsets.only(
                                                      top: 30.0, bottom: 10),
                                                  padding:
                                                  EdgeInsets.only(
                                                      left: 16, right: 16),
                                                  child: Text('받은 제안',
                                                      style:
                                                      CustomStyles
                                                          .normal24TextStyle()),
                                                ),
                                                Container(
                                                    width: MediaQuery
                                                        .of(context)
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
                                                            controller: _tabController,
                                                            indicatorPadding: EdgeInsets
                                                                .zero,
                                                            indicatorColor: CustomColors
                                                                .colorAccent
                                                                .withAlpha(200),
                                                            labelStyle: CustomStyles
                                                                .bold16TextStyle(),
                                                            indicatorWeight: 3,
                                                            labelColor: CustomColors
                                                                .colorFontTitle,
                                                            unselectedLabelStyle: CustomStyles
                                                                .normal16TextStyle(),
                                                            tabs: [
                                                              Tab(text: '전체'),
                                                              Tab(text: '수락'),
                                                              Tab(text: '거절'),
                                                              Tab(text: '대기')
                                                            ]))),
                                                Expanded(
                                                    flex: 0,
                                                    child: [
                                                      tabItem(),
                                                      tabItem(),
                                                      tabItem(),
                                                      tabItem()
                                                    ][_tabIndex]),
                                                Visibility(
                                                    child: Container(
                                                      alignment: Alignment
                                                          .center,
                                                      margin: EdgeInsets.only(
                                                          top: 50),
                                                      child: Text(
                                                        '받은 제안이 없습니다.',
                                                        style:
                                                        CustomStyles
                                                            .normal16TextStyle(),
                                                        textAlign: TextAlign
                                                            .center,
                                                      ),
                                                    ),
                                                    visible:
                                                    _scoutList.length > 0
                                                        ? false
                                                        : true)
                                              ]))))),
                          Visibility(
                            child: Container(
                                color: Colors.black38,
                                alignment: Alignment.center,
                                child: CircularProgressIndicator()),
                            visible: _isUpload,
                          )
                        ]
                    )))));
  }
}
