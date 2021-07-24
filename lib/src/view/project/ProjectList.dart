import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/KCastingAppData.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/view/audition/production/RegisteredAuditionList.dart';
import 'package:casting_call/src/view/project/ProjectAdd.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/*
* 오디션 관리 (프로젝트 목록)
* */
class ProjectList extends StatefulWidget {
  @override
  _ProjectList createState() => _ProjectList();
}

class _ProjectList extends State<ProjectList>
    with SingleTickerProviderStateMixin, BaseUtilMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  bool _isUpload = false;

  final _txtFieldSearch = TextEditingController();

  TabController _tabController;
  int _tabIndex = 0;

  String projectName;

  // 프로젝트 리스트 관련 변수
  ScrollController _scrollController;

  int _total = 0;
  int _limit = 20;

  List<dynamic> _projectDramaList = [];
  List<dynamic> _projectMovieList = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    requestProjectListApi(context);

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);

    _scrollController = new ScrollController(initialScrollOffset: 5.0)
      ..addListener(_scrollListener);
  }

  _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _tabIndex = _tabController.index;

        _total = 0;
        _projectDramaList.clear();
        _projectMovieList.clear();

        requestProjectListApi(context);
      });
    }
  }

  _scrollListener() {
    int cnt =
        (_tabIndex == 0) ? _projectMovieList.length : _projectDramaList.length;

    if (_total == 0 || cnt >= _total) return;

    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      setState(() {
        print("comes to bottom $_isLoading");
        _isLoading = true;

        if (_isLoading) {
          print("RUNNING LOAD MORE");

          requestProjectListApi(context);
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
  * 프로젝트목록조회
  * */
  void requestProjectListApi(BuildContext context) {
    setState(() {
      _isUpload = true;
    });

    // 프로젝트목록조회 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetDatas = new Map();
    targetDatas[APIConstants.production_seq] =
        KCastingAppData().myInfo[APIConstants.seq];
    targetDatas[APIConstants.project_type] = _tabIndex == 0
        ? APIConstants.project_type_movie
        : APIConstants.project_type_drama;
    if (projectName != null) {
      targetDatas[APIConstants.project_name] = projectName;
    }

    Map<String, dynamic> paging = new Map();
    paging[APIConstants.offset] =
        (_tabIndex == 0) ? _projectMovieList.length : _projectDramaList.length;
    paging[APIConstants.limit] = _limit;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.SEL_PPJ_LIST;
    params[APIConstants.target] = targetDatas;
    params[APIConstants.paging] = paging;

    // 프로젝트목록조회 api 호출
    RestClient(Dio()).postRequestMainControl(params).then((value) async {
      try {
        if (value == null) {
          // 에러 - 데이터 널
          showSnackBar(context, APIConstants.error_msg_server_not_response);
        } else {
          if (value[APIConstants.resultVal]) {
            // 프로젝트목록조회 성공
            var _responseList = value[APIConstants.data];

            var _pagingData = _responseList[APIConstants.paging];
            setState(() {
              _total = _pagingData[APIConstants.total];

              if (_tabIndex == 0) {
                _projectMovieList.addAll(_responseList[APIConstants.list]);
              } else {
                _projectDramaList.addAll(_responseList[APIConstants.list]);
              }

              _isLoading = false;
            });
          } else {
            // 프로젝트목록조회 실패
            showSnackBar(context, APIConstants.error_msg_try_again);
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

  Widget tabProjectList() {
    return Container(
        alignment: Alignment.center,
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Wrap(children: [
            ListView.separated(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                controller: _scrollController,
                itemCount: (_tabIndex == 0)
                    ? _projectMovieList.length
                    : _projectDramaList.length,
                itemBuilder: (BuildContext context, int index) {
                  Map<String, dynamic> _data = (_tabIndex == 0)
                      ? _projectMovieList[index]
                      : _projectDramaList[index];

                  return Container(
                      margin: EdgeInsets.only(bottom: 15),
                      alignment: Alignment.center,
                      child: GestureDetector(
                          onTap: () {
                            addView(
                                context,
                                RegisteredAuditionList(
                                  projectSeq: _data[
                                      APIConstants.production_project_seq],
                                  projectName: _data[APIConstants.project_name],
                                ));
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
                                            _data[APIConstants.project_name],
                                            style: CustomStyles
                                                .dark20TextStyle())),
                                    Container(
                                        child: Row(children: [
                                      Text(
                                          '오디션 ' +
                                              _data[APIConstants.casting_cnt]
                                                  .toString() +
                                              '개',
                                          style: CustomStyles.dark10TextStyle())
                                    ]))
                                  ]))));
                },
                separatorBuilder: (context, index) {
                  return Divider(
                    height: 0.1,
                    color: CustomColors.colorFontLightGrey,
                  );
                })
          ]),
          Visibility(
            child: Container(
              margin: EdgeInsets.only(top: 100),
              child: Text('등록된 프로젝트가 없습니다.'),
            ),
            visible: (_tabIndex == 0
                ? (_projectMovieList.length > 0 ? false : true)
                : (_projectDramaList.length > 0 ? false : true)),
          )
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
            appBar: CustomStyles.defaultAppBar('오디션 관리', () {
              Navigator.pop(context);
            }),
            body: Stack(
              children: [
                Container(
                    child: SingleChildScrollView(
                        child: Container(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                      Container(
                        margin: EdgeInsets.only(top: 30.0, bottom: 10),
                        padding: EdgeInsets.only(left: 16, right: 16),
                        child: Text('오디션 관리',
                            style: CustomStyles.normal24TextStyle()),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 15, left: 15, right: 15),
                        padding: EdgeInsets.only(left: 10, right: 10),
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: CustomStyles.circle7BorderRadius(),
                          border: Border.all(
                              width: 1, color: CustomColors.colorFontLightGrey),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: TextField(
                                controller: _txtFieldSearch,
                                decoration: InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 0),
                                  hintText: "오디션을 검색해보세요",
                                  hintStyle: CustomStyles.normal16TextStyle(),
                                ),
                                style: CustomStyles.dark16TextStyle(),
                              ),
                            ),
                            Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: GestureDetector(
                                  onTap: () {
                                    _projectDramaList.clear();
                                    _projectMovieList.clear();

                                    projectName = _txtFieldSearch.text;
                                    requestProjectListApi(context);
                                  },
                                  child: Image.asset(
                                    'assets/images/btn_search.png',
                                    width: 20,
                                    fit: BoxFit.contain,
                                  ),
                                ))
                          ],
                        ),
                      ),
                      Container(
                          padding: EdgeInsets.only(right: 15, top: 20),
                          width: MediaQuery.of(context).size.width,
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
                                    tabs: [Tab(text: '영화'), Tab(text: '드라마')],
                                  ),
                                  flex: 1),
                              Expanded(
                                  child: Container(
                                margin: EdgeInsets.only(left: 15, right: 15),
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () {
                                    replaceView(context, ProjectAdd());
                                  },
                                  child: Text('+ 프로젝트 추가',
                                      style: CustomStyles.blue16TextStyle()),
                                ),
                              ))
                            ],
                          )),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Divider(
                          height: 0.1,
                          color: CustomColors.colorFontLightGrey,
                        ),
                      ),
                      Expanded(
                        flex: 0,
                        child: [tabProjectList(), tabProjectList()][_tabIndex],
                      )
                    ])))),
                Visibility(
                  child: Container(
                      color: Colors.black38,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator()),
                  visible: _isUpload,
                )
              ],
            )));
  }
}
