import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/view/audition/actor/AuditionApplyUploadImage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/*
* 매니지먼트 보유배우 오디션 지원하기
* */
class AgencyActorAuditionApply extends StatefulWidget {
  final int castingSeq;
  final String projectName;
  final String castingName;

  const AgencyActorAuditionApply(
      {Key key, this.castingSeq, this.projectName, this.castingName})
      : super(key: key);

  @override
  _AgencyActorAuditionApply createState() => _AgencyActorAuditionApply();
}

class _AgencyActorAuditionApply extends State<AgencyActorAuditionApply>
    with BaseUtilMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  int _castingSeq;
  String _projectName;
  String _castingName;

  // 배우 리스트 관련 변수
  ScrollController _scrollController;

  int _total = 0;
  int _limit = 20;

  List<dynamic> _actorList = [];
  bool _isLoading = true;

  int _selectActorIdx = -1;

  @override
  void initState() {
    _scrollController = ScrollController(initialScrollOffset: 0.5);
    _scrollController.addListener(_scrollListener);

    super.initState();

    _castingSeq = widget.castingSeq;
    _projectName = widget.projectName;
    _castingName = widget.castingName;

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
    final dio = Dio();

    // 배우목록조회 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetData = new Map();

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

  Widget listItem(Map<String, dynamic> _data, int idx) {
    return Container(
        child: Visibility(
            child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectActorIdx = idx;
                  });
                },
                child: Container(
                    padding: EdgeInsets.only(
                        top: 10, bottom: 10, left: 5, right: 15),
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
                                          child: Image.network(
                                              _data[APIConstants.main_img_url],
                                              fit: BoxFit.cover,
                                              width: 50.0,
                                              height: 50.0),
                                        )
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
                            flex: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: (idx == _selectActorIdx
                                      ? CustomColors.colorAccent
                                      : CustomColors.colorFontLightGrey)),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: idx == _selectActorIdx
                                    ? Icon(
                                        Icons.check,
                                        size: 15.0,
                                        color: CustomColors.colorWhite,
                                      )
                                    : Icon(
                                        Icons.check_box_outline_blank,
                                        size: 15.0,
                                        color: CustomColors.colorFontLightGrey,
                                      ),
                              ),
                            ),
                          )
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
          body: Column(
            children: [
              Expanded(
                  child: NotificationListener<ScrollNotification>(
                child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: AlwaysScrollableScrollPhysics(),
                    key: ObjectKey(_actorList.length > 0 ? _actorList[0] : ""),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 30.0, bottom: 10),
                          padding: EdgeInsets.only(left: 16, right: 16),
                          child: Text('지원할 배우',
                              style: CustomStyles.normal24TextStyle()),
                        ),
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
                                      decoration: InputDecoration(
                                          isDense: true,
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 0, horizontal: 0),
                                          hintText: "배역을 검색해보세요",
                                          hintStyle:
                                              CustomStyles.normal16TextStyle()),
                                      style: CustomStyles.dark16TextStyle())),
                              Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: GestureDetector(
                                      onTap: () {},
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
                                      return listItem(_data, index);
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
              Container(
                  height: 55,
                  color: CustomColors.colorBgGrey,
                  child: Row(children: [
                    Expanded(
                        flex: 1,
                        child: Container(
                            height: 55,
                            child:
                                CustomStyles.greyBGSquareButtonStyle('취소', () {
                              Navigator.pop(context);
                            }))),
                    Expanded(
                        flex: 1,
                        child: Container(
                            height: 55,
                            child: CustomStyles.blueBGSquareButtonStyle('지원하기',
                                () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          AuditionApplyUploadImage(
                                              castingSeq: _castingSeq,
                                              projectName: _projectName,
                                              castingName: _castingName)));
                            }))),
                  ]))
            ],
          )),
    );
  }
}
