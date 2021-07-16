import 'package:cached_network_image/cached_network_image.dart';
import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/KCastingAppData.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/dialog/DialogAddActor.dart';
import 'package:casting_call/src/dialog/DialogDeleteActorConfirm.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:casting_call/src/view/mypage/management/AgencyActorProfile.dart';
import 'package:casting_call/src/view/mypage/management/RegisterAgencyActorProfileMainInfo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/*
* 보유 배우 목록
* */
class AgencyActorList extends StatefulWidget {
  final String genderType;

  const AgencyActorList({Key key, this.genderType}) : super(key: key);

  @override
  _AgencyActorList createState() => _AgencyActorList();
}

class _AgencyActorList extends State<AgencyActorList>
    with SingleTickerProviderStateMixin, BaseUtilMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  TabController _tabController;
  int _tabIndex = 0;

  // 배우 리스트 관련 변수
  ScrollController _scrollController;

  int _total = 0;
  int _limit = 20;

  bool _isLoading = true;
  bool _isEditMode = false;

  List<dynamic> _actorList = [];
  List<dynamic> _originalActorList = [];
  List<int> _deletedActorList = [];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);

    // 배우 목록 api 조회
    requestActorListApi(context);

    // 리스트뷰 스크롤 컨트롤러
    _scrollController = new ScrollController(initialScrollOffset: 5.0)
      ..addListener(_scrollListener);
  }

  _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _tabIndex = _tabController.index;

        _total = 0;
        _actorList = [];
        _originalActorList = [];

        requestActorListApi(context);
      });
    }
  }

  // 리스트뷰 스크롤 컨트롤러 이벤트 리스너
  _scrollListener() {
    if (_total == 0 || _actorList.length >= _total) return;

    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      setState(() {
        _isLoading = true;

        if (_isLoading) {
          requestActorListApi(context);
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
  * 배우목록조회 api 호출
  * */
  void requestActorListApi(BuildContext context) {
    final dio = Dio();

    // 배우목록조회 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetData = new Map();
    if (_tabIndex == 1) {
      targetData[APIConstants.sex_type] = APIConstants.actor_sex_female;
    } else if (_tabIndex == 2) {
      targetData[APIConstants.sex_type] = APIConstants.actor_sex_male;
    }
    targetData[APIConstants.management_seq] =
        KCastingAppData().myInfo[APIConstants.management_seq];

    Map<String, dynamic> paging = new Map();
    paging[APIConstants.offset] = _actorList.length;
    paging[APIConstants.limit] = _limit;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.SEL_MGM_ACTORLIST;
    params[APIConstants.target] = targetData;
    params[APIConstants.paging] = paging;

    // 배우목록조회 api 호출
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value != null) {
        if (value[APIConstants.resultVal]) {
          try {
            // 배우목록조회 성공
            setState(() {
              var _responseList = value[APIConstants.data];
              var _pagingData = _responseList[APIConstants.paging];

              _total = _pagingData[APIConstants.total];

              if (_responseList != null && _responseList.length > 0) {
                List<dynamic> tempList = _responseList[APIConstants.list];
                for (int i = 0; i < tempList.length; i++) {
                  Map<String, dynamic> _data = tempList[i];
                  _data["isSelected"] = false;

                  _actorList.add(_data);
                }

                _originalActorList.addAll(_actorList);
              }

              _isLoading = false;
            });
          } catch (e) {}
        }
      }
    });
  }

  /*
  *배우 삭제
  * */
  void requestActorDeleteApi(BuildContext context) {
    final dio = Dio();

    // 배우 삭제 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetDatas = new Map();
    targetDatas[APIConstants.actor_seq] = _deletedActorList;
    targetDatas[APIConstants.management_seq] =
        KCastingAppData().myInfo[APIConstants.management_seq];

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.DEL_MGM_ACTORLIST;
    params[APIConstants.target] = targetDatas;

    // 배우 삭제 api 호출
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value != null) {
        if (value[APIConstants.resultVal]) {
          try {
            // 배우 삭제 성공
            var _responseData = value[APIConstants.data];
            var _responseList = _responseData[APIConstants.list] as List;

            setState(() {
              if (_responseList != null && _responseList.length > 0) {
                _actorList = _responseList;
                _originalActorList = _responseList;
              }
            });
          } catch (e) {
            showSnackBar(context, APIConstants.error_msg_try_again);
          }
        } else {
          showSnackBar(context, APIConstants.error_msg_try_again);
        }
      } else {
        // 에러 - 데이터 널 - 서버가 응답하지 않습니다. 다시 시도해 주세요
        showSnackBar(context, APIConstants.error_msg_server_not_response);
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
            appBar: CustomStyles.defaultAppBar('보유 배우', () {
              Navigator.pop(context);
            }),
            body: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: SingleChildScrollView(
                    key: ObjectKey(_actorList.length > 0 ? _actorList[0] : ""),
                    controller: _scrollController,
                    child: Column(children: [
                      Expanded(
                          flex: 0,
                          child: Container(
                              child: Column(children: [
                            Container(
                                padding: EdgeInsets.only(left: 10, right: 10),
                                margin: EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                    border: Border(
                                  bottom: BorderSide(
                                      color: CustomColors.colorBgGrey),
                                )),
                                width: MediaQuery.of(context).size.width,
                                child: TabBar(
                                    indicatorPadding: EdgeInsets.zero,
                                    isScrollable: true,
                                    automaticIndicatorColorAdjustment: true,
                                    controller: _tabController,
                                    labelStyle: CustomStyles.bold16TextStyle(),
                                    unselectedLabelStyle:
                                        CustomStyles.normal16TextStyle(),
                                    tabs: [
                                      Tab(text: '전체'),
                                      Tab(text: '여배우'),
                                      Tab(text: '남배우')
                                    ])),
                            Visibility(
                              child: Container(
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.only(left: 20, right: 15),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text((_actorList.length > 0
                                                ? _actorList.length.toString()
                                                : "0") +
                                            "명"),
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              TextButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      _isEditMode = true;
                                                    });
                                                  },
                                                  child: Text("편집",
                                                      style: CustomStyles
                                                          .normal14TextStyle()),
                                                  style: TextButton.styleFrom(
                                                      padding: EdgeInsets.zero,
                                                      minimumSize: Size(10, 10),
                                                      alignment:
                                                          Alignment.center)),
                                              Container(
                                                  height: 15,
                                                  child: VerticalDivider(
                                                    width: 0.1,
                                                    color: CustomColors
                                                        .colorFontGrey,
                                                  )),
                                              TextButton(
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                              context) =>
                                                          DialogAddActor(
                                                              onClickedAgree:
                                                                  (name,
                                                                      gender) {
                                                        addView(
                                                            context,
                                                            RegisterAgencyActorProfileMainInfo(
                                                                name: name,
                                                                gender:
                                                                    gender == 0
                                                                        ? "남자"
                                                                        : "여자"));
                                                      }),
                                                    );
                                                  },
                                                  child: Text("배우추가",
                                                      style: CustomStyles
                                                          .normal14TextStyle()),
                                                  style: TextButton.styleFrom(
                                                      padding: EdgeInsets.zero,
                                                      minimumSize: Size(70, 10),
                                                      alignment:
                                                          Alignment.center))
                                            ])
                                      ])),
                              visible: !_isEditMode,
                            ),
                            Visibility(
                              child: Container(
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.only(left: 20, right: 15),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text((_actorList.length > 0
                                                ? _actorList.length.toString()
                                                : "0") +
                                            "명"),
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              TextButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      _actorList.clear();
                                                      _actorList.addAll(
                                                          _originalActorList);
                                                      _deletedActorList = [];

                                                      _isEditMode = false;
                                                    });
                                                  },
                                                  child: Text("취소",
                                                      style: CustomStyles
                                                          .normal14TextStyle()),
                                                  style: TextButton.styleFrom(
                                                      padding: EdgeInsets.zero,
                                                      minimumSize: Size(10, 10),
                                                      alignment:
                                                          Alignment.center)),
                                              Container(
                                                  height: 15,
                                                  child: VerticalDivider(
                                                    width: 0.1,
                                                    color: CustomColors
                                                        .colorFontGrey,
                                                  )),
                                              TextButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      for (int i = 0;
                                                          i < _actorList.length;
                                                          i++) {
                                                        if (_actorList[i]
                                                            ["isSelected"]) {
                                                          _deletedActorList.add(
                                                              _actorList[i][
                                                                  APIConstants
                                                                      .actor_seq]);
                                                        }
                                                      }

                                                      if (_deletedActorList
                                                              .length >
                                                          0) {
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                                  context) =>
                                                              DialogDeleteActorConfirm(
                                                            deleteCnt:
                                                                _deletedActorList
                                                                    .length,
                                                            onClickedAgree: () {
                                                              requestActorDeleteApi(
                                                                  context);
                                                            },
                                                          ),
                                                        );
                                                      }

                                                      _isEditMode = false;
                                                    });
                                                  },
                                                  child: Text("삭제",
                                                      style: CustomStyles
                                                          .normal14TextStyle()),
                                                  style: TextButton.styleFrom(
                                                      padding: EdgeInsets.zero,
                                                      minimumSize: Size(10, 10),
                                                      alignment:
                                                          Alignment.center))
                                            ])
                                      ])),
                              visible: _isEditMode,
                            )
                          ]))),
                      _actorList.length > 0
                          ? Wrap(children: [
                              GridView.count(
                                  padding: EdgeInsets.only(
                                      left: 16, right: 16, bottom: 50),
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 5,
                                  childAspectRatio: (0.76),
                                  children:
                                      List.generate(_actorList.length, (index) {
                                    Map<String, dynamic> _data =
                                        _actorList[index];
                                    return _isEditMode
                                        ? Center(
                                            child: Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        _data["isSelected"] =
                                                            !_data[
                                                                "isSelected"];
                                                      });
                                                    },
                                                    child: Column(
                                                        children: <Widget>[
                                                          Stack(children: [
                                                            Container(
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        CustomStyles
                                                                            .circle7BorderRadius(),
                                                                    color: CustomColors
                                                                        .colorBgGrey,
                                                                    border: Border.all(
                                                                        width:
                                                                            3,
                                                                        color: (_data["isSelected"]
                                                                            ? CustomColors
                                                                                .colorPrimary
                                                                            : CustomColors
                                                                                .colorFontLightGrey))),
                                                                width: (MediaQuery.of(context)
                                                                        .size
                                                                        .width /
                                                                    2),
                                                                height: (MediaQuery.of(context)
                                                                        .size
                                                                        .width /
                                                                    2),
                                                                child: _data[APIConstants.main_img_url] != null
                                                                    ? ClipRRect(
                                                                        borderRadius:
                                                                            CustomStyles.circle4BorderRadius(),
                                                                        child: CachedNetworkImage(imageUrl: _data[APIConstants.main_img_url], fit: BoxFit.cover))
                                                                    : null),
                                                            Container(
                                                                margin:
                                                                    EdgeInsets
                                                                        .all(
                                                                            10),
                                                                alignment:
                                                                    Alignment
                                                                        .topRight,
                                                                child: InkWell(
                                                                    onTap: () {
                                                                      setState(
                                                                          () {
                                                                        _data["isSelected"] =
                                                                            !_data["isSelected"];
                                                                      });
                                                                    },
                                                                    child: Container(
                                                                        decoration: BoxDecoration(shape: BoxShape.circle, color: (_data["isSelected"] ? CustomColors.colorPrimary : CustomColors.colorFontLightGrey)),
                                                                        child: Padding(
                                                                            padding: const EdgeInsets.all(5.0),
                                                                            child: _data["isSelected"]
                                                                                ? Icon(
                                                                                    Icons.check,
                                                                                    size: 15.0,
                                                                                    color: CustomColors.colorWhite,
                                                                                  )
                                                                                : Icon(
                                                                                    Icons.check_box_outline_blank,
                                                                                    size: 15.0,
                                                                                    color: CustomColors.colorFontLightGrey,
                                                                                  )))))
                                                          ]),
                                                          Container(
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              margin: EdgeInsets
                                                                  .only(top: 5),
                                                              child: Text(
                                                                  StringUtils.checkedString(_data[
                                                                      APIConstants
                                                                          .actor_name]),
                                                                  style: CustomStyles
                                                                      .dark20TextStyle()))
                                                        ]))))
                                        : Center(
                                            child: Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            settings: RouteSettings(
                                                                name:
                                                                    'AgencyActorProfile'),
                                                            builder: (context) => AgencyActorProfile(
                                                                seq: _data[
                                                                    APIConstants
                                                                        .seq],
                                                                actorProfileSeq:
                                                                    _data[APIConstants
                                                                        .actorProfile_seq])),
                                                      );
                                                    },
                                                    child: Column(
                                                        children: <Widget>[
                                                          Container(
                                                              decoration: BoxDecoration(
                                                                  color: CustomColors
                                                                      .colorBgGrey,
                                                                  borderRadius:
                                                                      CustomStyles
                                                                          .circle7BorderRadius()),
                                                              width: (MediaQuery.of(context)
                                                                      .size
                                                                      .width /
                                                                  2),
                                                              height: (MediaQuery.of(context)
                                                                      .size
                                                                      .width /
                                                                  2),
                                                              child: _data[APIConstants.main_img_url] !=
                                                                      null
                                                                  ? ClipRRect(
                                                                      borderRadius:
                                                                          CustomStyles
                                                                              .circle7BorderRadius(),
                                                                      child: CachedNetworkImage(
                                                                          imageUrl:
                                                                              _data[APIConstants.main_img_url],
                                                                          fit: BoxFit.cover))
                                                                  : null),
                                                          Container(
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              margin: EdgeInsets
                                                                  .only(top: 5),
                                                              child: Text(
                                                                  StringUtils.checkedString(_data[
                                                                      APIConstants
                                                                          .actor_name]),
                                                                  style: CustomStyles
                                                                      .dark20TextStyle()))
                                                        ]))));
                                  }))
                            ])
                          : Container(
                              margin: EdgeInsets.only(top: 30),
                              child: Text('배우가 없습니다.',
                                  style: CustomStyles.normal16TextStyle()))
                    ])))));
  }
}
