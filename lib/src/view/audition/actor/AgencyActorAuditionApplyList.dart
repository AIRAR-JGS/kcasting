import 'package:cached_network_image/cached_network_image.dart';
import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/KCastingAppData.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:casting_call/src/view/audition/actor/AuditionApplyList.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/*
* 매니지먼트 보유배우 지원 현황
* */
class AgencyActorAuditionApplyList extends StatefulWidget {
  final String genderType;

  const AgencyActorAuditionApplyList({Key key, this.genderType})
      : super(key: key);

  @override
  _AgencyActorAuditionApplyList createState() =>
      _AgencyActorAuditionApplyList();
}

class _AgencyActorAuditionApplyList extends State<AgencyActorAuditionApplyList>
    with BaseUtilMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool _isUpload = false;
  String actorName;
  final _txtFieldSearch = TextEditingController();

  // 배우 리스트 관련 변수
  ScrollController _scrollController;

  int _total = 0;
  int _limit = 20;

  List<dynamic> _actorList = [];
  bool _isLoading = true;

  @override
  void initState() {
    _scrollController = ScrollController(initialScrollOffset: 50.0);
    _scrollController.addListener(_scrollListener);

    super.initState();

    // 배우 목록 api 조회
    requestActorListApi(context);
  }

  // 리스트뷰 스크롤 컨트롤러 이벤트 리스너
  _scrollListener() {
    print(_scrollController.position.extentAfter);
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
    _scrollController.dispose();
    super.dispose();
  }

  /*
  * 배우목록조회 api 호출
  * */
  void requestActorListApi(BuildContext context) {
    setState(() {
      _isUpload = true;
    });

    // 배우목록조회 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetData = new Map();
    targetData[APIConstants.management_seq] = KCastingAppData().myInfo[APIConstants.management_seq];
    if(actorName != null) {
      targetData[APIConstants.actor_name] = actorName;
    }

    Map<String, dynamic> paging = new Map();
    paging[APIConstants.offset] = _actorList.length;
    paging[APIConstants.limit] = _limit;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.SEL_MGM_AUDITIONSTATELIST;
    params[APIConstants.target] = targetData;
    params[APIConstants.paging] = paging;

    // 배우목록조회 api 호출
    RestClient(Dio()).postRequestMainControl(params).then((value) async {
      try {
        if (value != null) {
          if (value[APIConstants.resultVal]) {
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

  Widget listItem(Map<String, dynamic> _data) {
    return Container(
        child: Visibility(
            child: GestureDetector(
                onTap: () {
                  addView(
                      context,
                      AuditionApplyList(
                        actorSeq: _data[APIConstants.actor_seq],
                      ));
                },
                child: Container(
                    padding: EdgeInsets.only(
                        top: 10, bottom: 10, left: 5, right: 10),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              flex: 1,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  _data[APIConstants.main_img_url] != null
                                      ? ClipOval(
                                          child: CachedNetworkImage(
                                              placeholder: (context, url) => Container(
                                                  alignment: Alignment.center,
                                                  child: CircularProgressIndicator()),
                                              imageUrl: _data[
                                                  APIConstants.main_img_url],
                                              fit: BoxFit.cover,
                                              width: 50.0,
                                              height: 50.0,
                                              errorWidget:
                                                  (context, url, error) => Icon(
                                                        Icons.account_circle,
                                                        color: CustomColors
                                                            .colorFontLightGrey,
                                                        size: 50,
                                                      )))
                                      : ClipOval(
                                          child: Icon(
                                          Icons.account_circle,
                                          color:
                                              CustomColors.colorFontLightGrey,
                                          size: 50,
                                        )),
                                  Container(
                                    margin: EdgeInsets.only(left: 10),
                                    child: Text(_data[APIConstants.actor_name],
                                        style: CustomStyles.dark16TextStyle()),
                                  )
                                ],
                              )),
                          Expanded(
                              flex: 1,
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                        child: Column(
                                      children: [
                                        Text('진행중',
                                            style: CustomStyles
                                                .normal14TextStyle()),
                                        Container(
                                          margin: EdgeInsets.only(top: 5),
                                          child: Text(
                                              StringUtils.checkedString(_data[
                                                      APIConstants.applyIngCnt]
                                                  .toString()),
                                              style: CustomStyles
                                                  .dark16TextStyle()),
                                        )
                                      ],
                                    )),
                                    Container(
                                        child: Column(
                                      children: [
                                        Text('계약완료',
                                            style: CustomStyles
                                                .normal14TextStyle()),
                                        Container(
                                          margin: EdgeInsets.only(top: 5),
                                          child: Text(
                                              StringUtils.checkedString(_data[
                                                      APIConstants
                                                          .applyCompleteCnt]
                                                  .toString()),
                                              style: CustomStyles
                                                  .dark16TextStyle()),
                                        )
                                      ],
                                    )),
                                    Container(
                                        child: Column(
                                      children: [
                                        Text('불합격',
                                            style: CustomStyles
                                                .normal14TextStyle()),
                                        Container(
                                          margin: EdgeInsets.only(top: 5),
                                          child: Text(
                                              StringUtils.checkedString(_data[
                                                      APIConstants.applyFailCnt]
                                                  .toString()),
                                              style: CustomStyles
                                                  .dark16TextStyle()),
                                        )
                                      ],
                                    ))
                                  ]))
                        ])))));
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
          appBar: CustomStyles.defaultAppBar('보유 배우 지원 현황', () {
            Navigator.pop(context);
          }),
          body: NotificationListener<ScrollNotification>(
            child: Stack(
              children: [
                SingleChildScrollView(
                    controller: _scrollController,
                    physics: AlwaysScrollableScrollPhysics(),
                    key: ObjectKey(_actorList.length > 0 ? _actorList[0] : ""),
                    child: Column(
                      children: [
                        Container(
                            margin: EdgeInsets.only(
                                top: 30, left: 15, right: 15, bottom: 20),
                            padding: EdgeInsets.only(left: 10, right: 10),
                            height: 50,
                            decoration: BoxDecoration(
                                borderRadius:
                                    CustomStyles.circle7BorderRadius(),
                                border: Border.all(
                                    width: 1,
                                    color: CustomColors.colorFontLightGrey)),
                            child: Row(children: [
                              Flexible(
                                  child: TextField(
                                    controller: _txtFieldSearch,
                                      decoration: InputDecoration(
                                          isDense: true,
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 0, horizontal: 0),
                                          hintText: "배우를 검색해보세요",
                                          hintStyle:
                                              CustomStyles.normal16TextStyle()),
                                      style: CustomStyles.dark16TextStyle())),
                              Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: GestureDetector(
                                      onTap: () {
                                        _actorList.clear();

                                        actorName = _txtFieldSearch.text;
                                        requestActorListApi(context);
                                      },
                                      child: Image.asset(
                                          'assets/images/btn_search.png',
                                          width: 20,
                                          fit: BoxFit.contain)))
                            ])),
                        Divider(),
                        _actorList.length > 0
                            ? Container(
                                child: ListView.separated(
                                    primary: false,
                                    physics: NeverScrollableScrollPhysics(),
                                    padding: EdgeInsets.only(
                                        left: 15, right: 15, bottom: 30),
                                    shrinkWrap: true,
                                    itemCount: _actorList.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      Map<String, dynamic> _data =
                                          _actorList[index];
                                      return listItem(_data);
                                    },
                                    separatorBuilder: (context, index) {
                                      return Divider();
                                    }))
                            : Container(
                                margin: EdgeInsets.only(top: 30),
                                child: Text('보유배우의 지원현황이 없습니다.',
                                    style: CustomStyles.normal16TextStyle()))
                      ],
                    )),
                Visibility(
                  child: Container(
                      color: Colors.black38,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator()),
                  visible: _isUpload,
                )
              ],
            ),
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo is ScrollStartNotification) {
                if (scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent) {
                  if (_total != 0 || _actorList.length < _total) {
                    setState(() {
                      _isLoading = true;

                      if (_isLoading) {
                        requestActorListApi(context);
                      }
                    });
                  }
                }
              }
              return true;
            },
          )),
    );
  }
}
