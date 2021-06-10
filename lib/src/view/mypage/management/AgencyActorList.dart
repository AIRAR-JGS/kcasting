import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/view/actor/ActorListItem.dart';
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

  List<dynamic> _actorList = [];
  bool _isLoading = true;

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

        requestActorListApi(context);
      });
    }
  }

  // 리스트뷰 스크롤 컨트롤러 이벤트 리스너
  _scrollListener() {
    print("dd");
    print(_scrollController.offset);
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
    print("ee");
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

    Map<String, dynamic> paging = new Map();
    paging[APIConstants.offset] = _actorList.length;
    paging[APIConstants.limit] = _limit;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.SEL_ACT_LIST;
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
                _actorList.addAll(_responseList[APIConstants.list]);
              }

              _isLoading = false;
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
                              decoration: BoxDecoration(
                                  border: Border(
                                bottom:
                                    BorderSide(color: CustomColors.colorBgGrey),
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
                                ],
                              ),
                            ),
                            Container(
                                alignment: Alignment.centerLeft,
                                margin: EdgeInsets.only(left: 15, right: 15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                        onPressed: () {},
                                        child: Text("편집",
                                            style: CustomStyles
                                                .normal14TextStyle()),
                                        style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            minimumSize: Size(10, 10),
                                            alignment: Alignment.center)),
                                    Container(
                                        height: 15,
                                        child: VerticalDivider(
                                          width: 0.1,
                                          color: CustomColors.colorFontGrey,
                                        )),
                                    TextButton(
                                        onPressed: () {},
                                        child: Text("배우추가",
                                            style: CustomStyles
                                                .normal14TextStyle()),
                                        style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            minimumSize: Size(70, 10),
                                            alignment: Alignment.center)),
                                  ],
                                ))
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
                                    return ActorListItem(
                                        isMan: false, data: _actorList[index]);
                                  }))
                            ])
                          : Container(
                              margin: EdgeInsets.only(top: 30),
                              child: Text('배우가 없습니다.',
                                  style: CustomStyles.normal16TextStyle()))
                    ])))));
  }
}
