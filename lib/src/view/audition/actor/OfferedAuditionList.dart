import 'package:cached_network_image/cached_network_image.dart';
import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
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
        print("comes to bottom $_isLoading");
        _isLoading = true;

        if (_isLoading) {
          print("RUNNING LOAD MORE");

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
    final dio = Dio();

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
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value != null) {
        if (value[APIConstants.resultVal]) {
          try {
            // 배우 제안 받은 목록 조회 성공
            var _responseList = value[APIConstants.data];

            var _pagingData = _responseList[APIConstants.paging];
            setState(() {
              _total = _pagingData[APIConstants.total];

              _scoutList.addAll(_responseList[APIConstants.list]);

              _isLoading = false;
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

  Widget tabItem() {
    return Container(
        child: Column(
      children: [
        Wrap(
          children: [
            ListView.separated(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              // Need to display a loading tile if more items are coming
              controller: _scrollController,
              itemCount: _scoutList.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () {
                        addView(
                            context,
                            OfferedAuditionDetail(
                                seq: _scoutList[index]
                                    [APIConstants.auditionProposal_seq]));
                      },
                      child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(
                              left: 16, right: 16, top: 10, bottom: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(top: 10, bottom: 15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 0,
                                      child: Container(
                                          margin: EdgeInsets.only(right: 5),
                                          alignment: Alignment.topCenter,
                                          child: ClipOval(
                                            child: CachedNetworkImage(
                                              imageUrl: _scoutList[index][
                                                  APIConstants
                                                      .production_img_url],
                                              errorWidget: (context, url,
                                                      error) =>
                                                  Image.asset(
                                                      'assets/images/btn_mypage.png',
                                                      fit: BoxFit.contain,
                                                      width: 30,
                                                      color: CustomColors
                                                          .colorBgGrey),
                                              height: 30,
                                            ),
                                          )),
                                    ),
                                    Expanded(
                                        flex: 1,
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    StringUtils.checkedString(
                                                        _scoutList[index][
                                                            APIConstants
                                                                .production_name]),
                                                    style: CustomStyles
                                                        .normal16TextStyle(),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 0,
                                                  child: Text(
                                                    StringUtils.checkedString(
                                                        _scoutList[index][
                                                            APIConstants
                                                                .state_type]),
                                                    style: CustomStyles
                                                        .normal16TextStyle(),
                                                  ),
                                                )
                                              ],
                                            ),
                                            Container(
                                              alignment: Alignment.centerLeft,
                                              margin: EdgeInsets.only(top: 10),
                                              child: Text(
                                                StringUtils.checkedString(
                                                    _scoutList[index][APIConstants
                                                        .audition_prps_contents]),
                                                style: CustomStyles
                                                    .normal14TextStyle(),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            )
                                          ],
                                        ))
                                  ],
                                ),
                              ),
                              Container(
                                  padding: EdgeInsets.only(left: 10, right: 10),
                                  margin: EdgeInsets.only(bottom: 10),
                                  alignment: Alignment.centerLeft,
                                  width: MediaQuery.of(context).size.width,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          CustomStyles.circle7BorderRadius(),
                                      border: Border.all(
                                          width: 0.5,
                                          color: CustomColors.colorBgGrey)),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                            StringUtils.checkedString(
                                                _scoutList[index][
                                                    APIConstants.project_name]),
                                            style:
                                                CustomStyles.dark12TextStyle()),
                                      ),
                                      Expanded(
                                        flex: 0,
                                        child: Text(
                                            StringUtils.checkedString(
                                                _scoutList[index][
                                                    APIConstants.casting_name]),
                                            style: CustomStyles
                                                .normal14TextStyle()),
                                      ),
                                    ],
                                  ))
                            ],
                          )),
                    ));
              },
              separatorBuilder: (context, index) {
                return Divider(
                  height: 0.1,
                  color: CustomColors.colorFontLightGrey,
                );
              },
            )
          ],
        ),
      ],
    ));
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
            appBar: CustomStyles.defaultAppBar('받은 제안', () {
              Navigator.pop(context);
            }),
            body: Container(
              child: SingleChildScrollView(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 30.0, bottom: 10),
                        padding: EdgeInsets.only(left: 16, right: 16),
                        child: Text('받은 제안',
                            style: CustomStyles.normal24TextStyle()),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        color: CustomColors.colorWhite,
                        child: TabBar(
                          indicatorSize: TabBarIndicatorSize.label,
                          controller: _tabController,
                          indicatorPadding: EdgeInsets.zero,
                          labelStyle: CustomStyles.bold14TextStyle(),
                          unselectedLabelStyle:
                              CustomStyles.normal14TextStyle(),
                          tabs: [
                            Tab(text: '전체'),
                            Tab(text: '수락'),
                            Tab(text: '거절'),
                            Tab(text: '대기')
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Divider(
                          height: 0.1,
                          color: CustomColors.colorFontLightGrey,
                        ),
                      ),
                      Expanded(
                        flex: 0,
                        child: [
                          tabItem(),
                          tabItem(),
                          tabItem(),
                          tabItem()
                        ][_tabIndex],
                      ),
                      Visibility(
                          child: Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.only(top: 50),
                            child: Text(
                              '목록이 없습니다.',
                              style: CustomStyles.normal16TextStyle(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          visible: _scoutList.length > 0 ? false : true),
                    ],
                  ),
                ),
              ),
            )));
  }
}
