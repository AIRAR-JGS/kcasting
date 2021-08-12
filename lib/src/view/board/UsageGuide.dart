import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/ui/DecoratedTabBar.dart';
import 'package:casting_call/src/view/board/UsageGuideDetail.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/*
* 이용안내 목록
* */
class UsageGuide extends StatefulWidget {
  @override
  _UsageGuide createState() => _UsageGuide();
}

class _UsageGuide extends State<UsageGuide>
    with BaseUtilMixin, SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _isUpload = false;

  TabController _tabController;
  int _tabIndex = 0;

  // 이용안내 리스트 관련 변수
  List<dynamic> _infoList = [];
  ScrollController _scrollController;

  int _total = 0;
  int _limit = 20;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _scrollController = new ScrollController(initialScrollOffset: 5.0)
      ..addListener(_scrollListener);

    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);

    requestInfoListApi(context);
  }

  _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _tabIndex = _tabController.index;

        _total = 0;
        _infoList = [];
        requestInfoListApi(context);
      });
    }
  }

  _scrollListener() {
    if (_total == 0 || _infoList.length >= _total) return;

    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      setState(() {
        _isLoading = true;

        if (_isLoading) {
          requestInfoListApi(context);
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
  * 이용안내 조회
  * */
  void requestInfoListApi(BuildContext _context) {
    setState(() {
      _isUpload = true;
    });

    // 이용안내 조회 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetData = new Map();
    switch (_tabIndex) {
      case 0:
        targetData[APIConstants.infomation_type] =
            APIConstants.member_type_actor;
        break;
      case 1:
        targetData[APIConstants.infomation_type] =
            APIConstants.member_type_product;
        break;
      case 2:
        targetData[APIConstants.infomation_type] =
            APIConstants.member_type_management;
        break;
    }

    Map<String, dynamic> paging = new Map();
    paging[APIConstants.offset] = _infoList.length;
    paging[APIConstants.limit] = _limit;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.SEL_TOT_USELIST;
    params[APIConstants.target] = targetData;
    params[APIConstants.paging] = paging;

    // 이용안내 조회 api 호출
    RestClient(Dio()).postRequestMainControl(params).then((value) async {
      try {
        if (value != null) {
          if (value[APIConstants.resultVal]) {
            // 이용안내 조회 성공
            var _responseList = value[APIConstants.data];

            var _pagingData = _responseList[APIConstants.paging];
            setState(() {
              _total = _pagingData[APIConstants.total];

              _infoList.addAll(_responseList[APIConstants.list]);

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

  Widget tabInfo() {
    return Column(children: [
      Container(
          padding: EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 70),
          child: (_infoList.length > 0
              ? ListView.builder(
                  primary: false,
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _infoList.length,
                  itemBuilder: (BuildContext context, int index) {
                    Map<String, dynamic> _data = _infoList[index];
                    return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UsageGuideDetail(
                                    seq: _infoList[index]
                                        [APIConstants.useInfo_seq])),
                          ).then((value) => {
                                _total = 0,
                                _infoList = [],
                                requestInfoListApi(context)
                              });
                        },
                        child: Container(
                            margin: EdgeInsets.only(bottom: 15),
                            decoration: BoxDecoration(
                                color: CustomColors.colorWhite,
                                borderRadius: CustomStyles.circle7BorderRadius(),
                                boxShadow: [
                                  BoxShadow(
                                    color: CustomColors.colorFontLightGrey
                                        .withAlpha(100),
                                    blurRadius: 2.0,
                                    spreadRadius: 2.0,
                                    offset: Offset(2, 1),
                                  )
                                ]),
                            alignment: Alignment.centerLeft,
                            child: Container(
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.only(
                                    left: 15, right: 15, top: 15, bottom: 15),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                          margin: EdgeInsets.only(bottom: 5),
                                          child: Text(
                                              _data[APIConstants
                                                  .use_infomation_name],
                                              style: CustomStyles
                                                  .normal20TextStyle())),
                                      Container(
                                          /*alignment: Alignment.centerRight,*/
                                          margin: EdgeInsets.only(top: 15),
                                          child: Text(
                                              '등록일: ' +
                                                  _data[APIConstants.addDate],
                                              style: CustomStyles
                                                  .light12TextStyle()))
                                    ]))));
                  })
              : Container(
                  alignment: Alignment.center,
                  child: Text('알림이 없습니다.',
                      style: CustomStyles.normal16TextStyle()))))
    ]);
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
            body: Builder(builder: (BuildContext context) {
              return Stack(children: [
                Container(
                    child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Container(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Container(
                                margin: EdgeInsets.only(top: 30.0, bottom: 10),
                                padding: EdgeInsets.only(left: 16, right: 16),
                                child: Text('이용안내',
                                    style: CustomStyles.normal24TextStyle()),
                              ),
                              Container(
                                  width: MediaQuery.of(context).size.width,
                                  color: CustomColors.colorWhite,
                                  child: DecoratedTabBar(
                                      decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                  color:
                                                      CustomColors.colorBgGrey,
                                                  width: 1.0))),
                                      tabBar: TabBar(
                                          controller: _tabController,
                                          indicatorPadding: EdgeInsets.zero,
                                          indicatorColor:
                                          CustomColors.colorAccent.withAlpha(200),
                                          labelStyle:
                                          CustomStyles.bold14TextStyle(),
                                          indicatorWeight: 3,
                                          unselectedLabelStyle:
                                          CustomStyles.normal14TextStyle(),
                                          tabs: [
                                            Tab(text: '배우회원'),
                                            Tab(text: '제작사회원'),
                                            Tab(text: '매니지먼트회원')
                                          ]))),
                              Expanded(
                                  flex: 0,
                                  child: [
                                    tabInfo(),
                                    tabInfo(),
                                    tabInfo()
                                  ][_tabIndex]),
                              Visibility(
                                  child: Container(
                                      alignment: Alignment.center,
                                      margin: EdgeInsets.only(top: 50),
                                      child: Text('이용안내가 없습니다.',
                                          style:
                                              CustomStyles.normal16TextStyle(),
                                          textAlign: TextAlign.center)),
                                  visible: _infoList.length > 0 ? false : true)
                            ])))),
                Visibility(
                  child: Container(
                      color: Colors.black38,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator()),
                  visible: _isUpload,
                )
              ]);
            })));
  }
}
