import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/dialog/DialogRegisterAuditionRole.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/util/DateTileUtils.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'RegisterMainRoleAudition.dart';
import 'RegisterSubRoleAudition.dart';
import 'RegisteredAuditionDetail.dart';

/*
* 제작사 오디션 목록
* */
class RegisteredAuditionList extends StatefulWidget {
  final int projectSeq;
  final String projectName;

  const RegisteredAuditionList({Key key, this.projectSeq, this.projectName})
      : super(key: key);

  @override
  _RegisteredAuditionList createState() => _RegisteredAuditionList();
}

class _RegisteredAuditionList extends State<RegisteredAuditionList>
    with SingleTickerProviderStateMixin, BaseUtilMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  int _projectSeq;
  String _projectName;

  String _apiKey = APIConstants.SEL_PCT_INGLIST;

  TabController _tabController;
  int _tabIndex = 0;

  ScrollController _scrollController;

  int _total = 0;
  int _limit = 20;

  List<dynamic> _castingStateList = [];

  bool _isLoading = true;
  int _isNotPayment = 0;

  @override
  void initState() {
    super.initState();

    _projectSeq = widget.projectSeq;
    _projectName = widget.projectName;

    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);

    //requestCastingStateList(context);

    _scrollController = new ScrollController(initialScrollOffset: 5.0)
      ..addListener(_scrollListener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _total = 0;
    _castingStateList = [];

    requestCastingStateList(context);
  }

  _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _tabIndex = _tabController.index;

        _total = 0;
        _castingStateList = [];

        switch (_tabIndex) {
          case 0:
            _apiKey = APIConstants.SEL_PCT_INGLIST;
            break;
          case 1:
            _apiKey = APIConstants.SEL_PCT_CMPLIST;
            break;
          case 2:
            _apiKey = APIConstants.SEL_PCT_FINLIST;
            break;
        }

        requestCastingStateList(context);
      });
    }
  }

  _scrollListener() {
    if (_total == 0 || _castingStateList.length >= _total) return;

    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      setState(() {
        print("comes to bottom $_isLoading");
        _isLoading = true;

        if (_isLoading) {
          print("RUNNING LOAD MORE");

          requestCastingStateList(context);
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
  캐스팅 진행 현황 조회
  * */
  void requestCastingStateList(BuildContext context) {
    final dio = Dio();

    // 캐스팅 진행 현황 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetData = new Map();
    targetData[APIConstants.project_seq] = _projectSeq;
    if (_apiKey == APIConstants.SEL_PCT_CMPLIST) {
      targetData[APIConstants.isNotPayment] = _isNotPayment;
    }

    Map<String, dynamic> paging = new Map();
    paging[APIConstants.offset] = _castingStateList.length;
    paging[APIConstants.limit] = _limit;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = _apiKey;
    params[APIConstants.target] = targetData;
    params[APIConstants.paging] = paging;

    // 캐스팅 진행 현황 조회 api 호출
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value == null) {
        // 에러 - 데이터 널
        showSnackBar(context, '다시 시도해 주세요.');
      } else {
        if (value[APIConstants.resultVal]) {
          // 캐스팅 진행 현황 조회 성공
          var _responseList = value[APIConstants.data];

          var _pagingData = _responseList[APIConstants.paging];
          setState(() {
            _total = _pagingData[APIConstants.total];

            _castingStateList.addAll(_responseList[APIConstants.list]);

            _isLoading = false;
          });
        } else {
          // 캐스팅 진행 현황 조회 실패
          showSnackBar(context, value[APIConstants.resultMsg]);
        }
      }
    });
  }

  Widget tabCastingList() {
    return Container(
        alignment: Alignment.center,
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Wrap(children: [
            ListView.separated(
                physics: NeverScrollableScrollPhysics(),
                controller: _scrollController,
                shrinkWrap: true,
                itemCount: _castingStateList.length,
                itemBuilder: (BuildContext context, int index) {
                  Map<String, dynamic> _data = _castingStateList[index];

                  return Container(
                      margin: EdgeInsets.only(bottom: 15),
                      alignment: Alignment.center,
                      child: GestureDetector(
                          onTap: () {
                            addView(
                                context,
                                RegisteredAuditionDetail(
                                    castingSeq:
                                        _data[APIConstants.casting_seq]));
                          },
                          child: Container(
                              alignment: Alignment.center,
                              padding:
                                  EdgeInsets.only(left: 15, right: 15, top: 15),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                        margin: EdgeInsets.only(bottom: 5),
                                        child: Text(
                                            StringUtils.checkedString(_data[
                                                APIConstants.casting_name]),
                                            style: CustomStyles
                                                .dark20TextStyle())),
                                    Container(
                                        child: Row(children: [
                                      Text(
                                          '작성일 : ' +
                                              StringUtils.checkedString(_data[
                                                  APIConstants
                                                      .productionCasting_addDate]),
                                          style: CustomStyles.dark10TextStyle())
                                    ])),
                                    Visibility(
                                        child: GestureDetector(
                                      onTap: () {
                                        addView(
                                            context,
                                            RegisteredAuditionDetail(
                                                castingSeq: _data[
                                                    APIConstants.casting_seq]));
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(top: 10),
                                        padding: EdgeInsets.only(
                                            top: 10,
                                            bottom: 10,
                                            left: 10,
                                            right: 10),
                                        decoration: BoxDecoration(
                                          borderRadius: CustomStyles
                                              .circle7BorderRadius(),
                                          border: Border.all(
                                              width: 1,
                                              color: CustomColors
                                                  .colorFontLightGrey),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                                child: Column(
                                              children: [
                                                Text('1차 오디션',
                                                    style: CustomStyles
                                                        .dark14TextStyle()),
                                                Container(
                                                  margin:
                                                      EdgeInsets.only(top: 5),
                                                  child: Text(
                                                      StringUtils.checkedString(
                                                                  _data[APIConstants
                                                                      .firstAudition_state_type]) ==
                                                              "진행중"
                                                          ? DateTileUtils
                                                              .getDDayFromString(
                                                                  _data[APIConstants
                                                                      .firstAudition_endDate])
                                                          : "마감",
                                                      style: CustomStyles
                                                          .dark14TextStyle()),
                                                )
                                              ],
                                            )),
                                            Container(
                                                child: Column(
                                              children: [
                                                Text('지원자',
                                                    style: CustomStyles
                                                        .dark14TextStyle()),
                                                Container(
                                                  margin:
                                                      EdgeInsets.only(top: 5),
                                                  child: Text(
                                                      StringUtils.checkedString(
                                                          _data[APIConstants
                                                                  .firstAuditionTarget_cnt]
                                                              .toString()),
                                                      style: CustomStyles
                                                          .dark14TextStyle()),
                                                )
                                              ],
                                            )),
                                            Container(
                                                child: Column(
                                              children: [
                                                Text('합격',
                                                    style: CustomStyles
                                                        .dark14TextStyle()),
                                                Container(
                                                  margin:
                                                      EdgeInsets.only(top: 5),
                                                  child: Text(
                                                      StringUtils.checkedString(
                                                          _data[APIConstants
                                                                  .firstAuditionTarget_pass_cnt]
                                                              .toString()),
                                                      style: CustomStyles
                                                          .dark14TextStyle()),
                                                )
                                              ],
                                            )),
                                            Container(
                                                child: Column(
                                              children: [
                                                Text('불합격',
                                                    style: CustomStyles
                                                        .dark14TextStyle()),
                                                Container(
                                                  margin:
                                                      EdgeInsets.only(top: 5),
                                                  child: Text(
                                                      StringUtils.checkedString(
                                                          _data[APIConstants
                                                                  .firstAuditionTarget_fail_cnt]
                                                              .toString()),
                                                      style: CustomStyles
                                                          .dark14TextStyle()),
                                                )
                                              ],
                                            ))
                                          ],
                                        ),
                                      ),
                                    )),
                                    Visibility(
                                        visible: _data[APIConstants
                                                    .secondAudition_state_type] ==
                                                null
                                            ? false
                                            : true,
                                        child: GestureDetector(
                                          onTap: () {
                                            addView(
                                                context,
                                                RegisteredAuditionDetail(
                                                    castingSeq: _data[
                                                        APIConstants
                                                            .casting_seq]));
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(top: 10),
                                            padding: EdgeInsets.only(
                                                top: 10,
                                                bottom: 10,
                                                left: 10,
                                                right: 10),
                                            decoration: BoxDecoration(
                                              borderRadius: CustomStyles
                                                  .circle7BorderRadius(),
                                              border: Border.all(
                                                  width: 1,
                                                  color: CustomColors
                                                      .colorFontLightGrey),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                    child: Column(
                                                  children: [
                                                    Text('2차 오디션',
                                                        style: CustomStyles
                                                            .dark14TextStyle()),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          top: 5),
                                                      child: Text(
                                                          StringUtils.checkedString(_data[
                                                                      APIConstants
                                                                          .secondAudition_state_type]) ==
                                                                  "진행중"
                                                              ? DateTileUtils
                                                                  .getDDayFromString(_data[
                                                                      APIConstants
                                                                          .secondAudition_endDate])
                                                              : "마감",
                                                          style: CustomStyles
                                                              .dark14TextStyle()),
                                                    )
                                                  ],
                                                )),
                                                Container(
                                                    child: Column(
                                                  children: [
                                                    Text('1차 합격자',
                                                        style: CustomStyles
                                                            .dark14TextStyle()),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          top: 5),
                                                      child: Text(
                                                          StringUtils.checkedString(
                                                              _data[APIConstants
                                                                      .secondAuditionTarget_cnt]
                                                                  .toString()),
                                                          style: CustomStyles
                                                              .dark14TextStyle()),
                                                    )
                                                  ],
                                                )),
                                                Container(
                                                    child: Column(
                                                  children: [
                                                    Text('제출',
                                                        style: CustomStyles
                                                            .dark14TextStyle()),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          top: 5),
                                                      child: Text(
                                                          StringUtils.checkedString(
                                                              _data[APIConstants
                                                                      .secondAuditionTarget_isSubmit]
                                                                  .toString()),
                                                          style: CustomStyles
                                                              .dark14TextStyle()),
                                                    )
                                                  ],
                                                )),
                                                Container(
                                                    child: Column(
                                                  children: [
                                                    Text('미제출',
                                                        style: CustomStyles
                                                            .dark14TextStyle()),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          top: 5),
                                                      child: Text(
                                                          StringUtils.checkedString(
                                                              _data[APIConstants
                                                                      .secondAuditionTarget_isNotSubmit]
                                                                  .toString()),
                                                          style: CustomStyles
                                                              .dark14TextStyle()),
                                                    )
                                                  ],
                                                )),
                                                Container(
                                                    child: Column(
                                                  children: [
                                                    Text('합격',
                                                        style: CustomStyles
                                                            .dark14TextStyle()),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          top: 5),
                                                      child: Text(
                                                          StringUtils.checkedString(
                                                              _data[APIConstants
                                                                      .secondAuditionTarget_pass_cnt]
                                                                  .toString()),
                                                          style: CustomStyles
                                                              .dark14TextStyle()),
                                                    )
                                                  ],
                                                ))
                                              ],
                                            ),
                                          ),
                                        )),
                                    Visibility(
                                        visible: _data[APIConstants
                                                    .thirdAudition_state_type] ==
                                                null
                                            ? false
                                            : true,
                                        child: GestureDetector(
                                          onTap: () {
                                            addView(
                                                context,
                                                RegisteredAuditionDetail(
                                                    castingSeq: _data[
                                                        APIConstants
                                                            .casting_seq]));
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(top: 10),
                                            padding: EdgeInsets.only(
                                                top: 10,
                                                bottom: 10,
                                                left: 10,
                                                right: 10),
                                            decoration: BoxDecoration(
                                              borderRadius: CustomStyles
                                                  .circle7BorderRadius(),
                                              border: Border.all(
                                                  width: 1,
                                                  color: CustomColors
                                                      .colorFontLightGrey),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                    child: Column(
                                                  children: [
                                                    Text('3차 오디션',
                                                        style: CustomStyles
                                                            .dark14TextStyle()),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          top: 5),
                                                      child: Text(
                                                          StringUtils.checkedString(
                                                              _data[APIConstants
                                                                  .thirdAudition_state_type]),
                                                          style: CustomStyles
                                                              .dark14TextStyle()),
                                                    )
                                                  ],
                                                )),
                                                Container(
                                                    child: Column(
                                                  children: [
                                                    Text('2차 합격자',
                                                        style: CustomStyles
                                                            .dark14TextStyle()),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          top: 5),
                                                      child: Text(
                                                          StringUtils.checkedString(
                                                              _data[APIConstants
                                                                      .thirdAuditionTarget_cnt]
                                                                  .toString()),
                                                          style: CustomStyles
                                                              .dark14TextStyle()),
                                                    )
                                                  ],
                                                )),
                                                Container(
                                                    child: Column(
                                                  children: [
                                                    Text('면접완료',
                                                        style: CustomStyles
                                                            .dark14TextStyle()),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          top: 5),
                                                      child: Text(
                                                          StringUtils.checkedString(
                                                              _data[APIConstants
                                                                      .thirdAuditionTarget_interviewFin]
                                                                  .toString()),
                                                          style: CustomStyles
                                                              .dark14TextStyle()),
                                                    )
                                                  ],
                                                )),
                                                Container(
                                                    child: Column(
                                                  children: [
                                                    Text('최종합격',
                                                        style: CustomStyles
                                                            .dark14TextStyle()),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          top: 5),
                                                      child: Text(
                                                          StringUtils.checkedString(
                                                              _data[APIConstants
                                                                      .thirdAuditionTarget_pass]
                                                                  .toString()),
                                                          style: CustomStyles
                                                              .dark14TextStyle()),
                                                    )
                                                  ],
                                                )),
                                                Container(
                                                    child: Column(
                                                  children: [
                                                    Text('불합격',
                                                        style: CustomStyles
                                                            .dark14TextStyle()),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          top: 5),
                                                      child: Text(
                                                          StringUtils.checkedString(
                                                              _data[APIConstants
                                                                      .thirdAuditionTarget_fail]
                                                                  .toString()),
                                                          style: CustomStyles
                                                              .dark14TextStyle()),
                                                    )
                                                  ],
                                                ))
                                              ],
                                            ),
                                          ),
                                        ))
                                  ]))));
                },
                separatorBuilder: (context, index) {
                  return Divider(
                    height: 0.1,
                    color: CustomColors.colorFontLightGrey,
                  );
                })
          ])
        ]));
  }

  Widget tabCastingContractedList() {
    return Container(
        alignment: Alignment.center,
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Wrap(children: [
            ListView.separated(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _castingStateList.length,
                controller: _scrollController,
                itemBuilder: (BuildContext context, int index) {
                  Map<String, dynamic> _data = _castingStateList[index];

                  return Container(
                      margin: EdgeInsets.only(bottom: 15),
                      alignment: Alignment.center,
                      child: GestureDetector(
                          onTap: () {
                            addView(
                                context,
                                RegisteredAuditionDetail(
                                    castingSeq:
                                        _data[APIConstants.casting_seq]));
                          },
                          child: Container(
                              alignment: Alignment.center,
                              padding:
                                  EdgeInsets.only(left: 15, right: 15, top: 15),
                              child: Column(children: [
                                Container(
                                    margin: EdgeInsets.only(bottom: 5),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                        StringUtils.checkedString(
                                            _data[APIConstants.casting_name]),
                                        style: CustomStyles.dark20TextStyle())),
                                Container(
                                    child: Row(children: [
                                  Text(
                                      '작성일 : ' +
                                          StringUtils.checkedString(_data[
                                              APIConstants
                                                  .productionCasting_addDate]),
                                      style: CustomStyles.dark10TextStyle())
                                ])),
                                GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    margin: EdgeInsets.only(top: 10),
                                    padding: EdgeInsets.only(
                                        top: 10,
                                        bottom: 10,
                                        left: 10,
                                        right: 10),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          CustomStyles.circle7BorderRadius(),
                                      border: Border.all(
                                          width: 1,
                                          color:
                                              CustomColors.colorFontLightGrey),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          child: Text('캐스팅',
                                              style: CustomStyles
                                                  .dark10TextStyle()),
                                        ),
                                        Container(
                                          child: Text(
                                              StringUtils.checkedString(_data[
                                                  APIConstants.casting_name]),
                                              style: CustomStyles
                                                  .dark20TextStyle()),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              ]))));
                },
                separatorBuilder: (context, index) {
                  return Divider(
                    height: 0.1,
                    color: CustomColors.colorFontLightGrey,
                  );
                })
          ])
        ]));
  }

  Widget tabCastingOffList() {
    return Container(
        alignment: Alignment.center,
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Wrap(children: [
            ListView.separated(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _castingStateList.length,
                controller: _scrollController,
                itemBuilder: (BuildContext context, int index) {
                  Map<String, dynamic> _data = _castingStateList[index];

                  return Container(
                      margin: EdgeInsets.only(bottom: 15),
                      alignment: Alignment.center,
                      child: GestureDetector(
                          onTap: () {
                            addView(
                                context,
                                RegisteredAuditionDetail(
                                    castingSeq:
                                        _data[APIConstants.casting_seq]));
                          },
                          child: Container(
                              alignment: Alignment.center,
                              padding:
                                  EdgeInsets.only(left: 15, right: 15, top: 15),
                              child: Column(children: [
                                Container(
                                    margin: EdgeInsets.only(bottom: 5),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                        StringUtils.checkedString(
                                            _data[APIConstants.casting_name]),
                                        style: CustomStyles.dark20TextStyle())),
                                Container(
                                    child: Row(children: [
                                  Text(
                                      '작성일 : ' +
                                          StringUtils.checkedString(_data[
                                              APIConstants
                                                  .productionCasting_addDate]),
                                      style: CustomStyles.dark10TextStyle())
                                ])),
                                /*GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ActorDetail()),
                                        );
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(top: 10),
                                        padding: EdgeInsets.only(
                                            top: 10,
                                            bottom: 10,
                                            left: 10,
                                            right: 10),
                                        decoration: BoxDecoration(
                                          borderRadius: CustomStyles
                                              .circle7BorderRadius(),
                                          border: Border.all(
                                              width: 1,
                                              color: CustomColors
                                                  .colorFontLightGrey),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              child: Text('캐스팅',
                                                  style: CustomStyles
                                                      .dark10TextStyle()),
                                            ),
                                            Container(
                                              child: Text(
                                                  StringUtils.checkedString(
                                                      _data[APIConstants
                                                          .casting_name]),
                                                  style: CustomStyles
                                                      .dark20TextStyle()),
                                            )
                                          ],
                                        ),
                                      ),
                                    )*/
                              ]))));
                },
                separatorBuilder: (context, index) {
                  return Divider(
                    height: 0.1,
                    color: CustomColors.colorFontLightGrey,
                  );
                })
          ])
        ]));
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
            appBar: CustomStyles.defaultAppBar('', () {
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
                        child: Text(_projectName,
                            style: CustomStyles.normal24TextStyle()),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10, left: 15, right: 15),
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) =>
                                  DialogRegisterAuditionRole(
                                      onClickedAddCertainRole: () {
                                replaceView(
                                    context,
                                    RegisterMainRoleAudition(
                                      projectSeq: _projectSeq,
                                    ));
                              }, onClickedAddLargeRole: () {
                                replaceView(
                                    context,
                                    RegisterSubRoleAudition(
                                      projectSeq: _projectSeq,
                                    ));
                              }),
                            );
                          },
                          child: Text('+ 배역 추가',
                              style: CustomStyles.blue16TextStyle()),
                        ),
                      ),
                      Container(
                          padding: EdgeInsets.only(right: 15),
                          width: MediaQuery.of(context).size.width * 0.8,
                          color: CustomColors.colorWhite,
                          child: Row(
                            children: [
                              Expanded(
                                  child: TabBar(
                                    controller: _tabController,
                                    indicatorSize: TabBarIndicatorSize.label,
                                    indicatorPadding: EdgeInsets.zero,
                                    labelStyle: CustomStyles.bold14TextStyle(),
                                    unselectedLabelStyle:
                                        CustomStyles.normal14TextStyle(),
                                    tabs: [
                                      Tab(text: '진행중'),
                                      Tab(text: '계약완료'),
                                      Tab(text: '마감')
                                    ],
                                  ),
                                  flex: 1)
                            ],
                          )),
                      Visibility(
                          child: Container(
                            margin:
                                EdgeInsets.only(left: 15, right: 15, top: 15),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Radio<int>(
                                      value: _isNotPayment,
                                      groupValue: 1,
                                      toggleable: true,
                                      onChanged: (value) {
                                        setState(() {
                                          if (_isNotPayment == 0) {
                                            _isNotPayment = 1;
                                          } else {
                                            _isNotPayment = 0;
                                          }

                                          _total = 0;
                                          _castingStateList = [];
                                          _apiKey =
                                              APIConstants.SEL_PCT_CMPLIST;

                                          requestCastingStateList(context);
                                        });
                                      },
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    )),
                                Text('미지급만 보기',
                                    style: CustomStyles.dark16TextStyle())
                              ],
                            ),
                          ),
                          visible: _tabIndex == 1 ? true : false),
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
                          tabCastingList(),
                          tabCastingContractedList(),
                          tabCastingOffList()
                        ][_tabIndex],
                      ),
                      Visibility(
                          child: Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.only(top: 50),
                            child: Text(
                              '등록된 오디션이 없습니다.',
                              style: CustomStyles.normal16TextStyle(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          visible: _castingStateList.length > 0 ? false : true),
                    ],
                  ),
                ),
              ),
            )));
  }
}
