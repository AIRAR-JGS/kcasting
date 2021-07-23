import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/model/CastingItemModel.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../KCastingAppData.dart';

/*
* 오디션 제안하기
* */
class ProposeAudition extends StatefulWidget {
  final int actorSeq;
  final String actorName;
  final String actorImgUrl;

  const ProposeAudition(
      {Key key, this.actorSeq, this.actorName, this.actorImgUrl})
      : super(key: key);

  @override
  _ProposeAudition createState() => _ProposeAudition();
}

class _ProposeAudition extends State<ProposeAudition> with BaseUtilMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  int _actorSeq;
  String _actorName;
  String _actorImgUrl;

  final _txtFieldContent = TextEditingController();

// 지원현황 리스트 관련 변수
  List<dynamic> _auditionList = [];
  List<CastingItemModel> _selectableAuditionList = [];

  ScrollController _scrollController;

  int _total = 0;
  int _limit = 20;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _actorSeq = widget.actorSeq;
    _actorName = widget.actorName;
    _actorImgUrl = widget.actorImgUrl;

    requestMyApplyListApi(context);

    _scrollController = new ScrollController(initialScrollOffset: 5.0)
      ..addListener(_scrollListener);
  }

  _scrollListener() {
    if (_total == 0 || _auditionList.length >= _total) return;

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
  * 오디션 제안 가능 목록 조회
  * */
  void requestMyApplyListApi(BuildContext _context) {
    final dio = Dio();

    // 지원현황 조회 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetData = new Map();
    targetData[APIConstants.actor_seq] = _actorSeq;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.SEL_PCT_PAPOKLIST;
    params[APIConstants.target] = targetData;

    // 오디션 제안 가능 목록 조회 api 호출
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value != null) {
        if (value[APIConstants.resultVal]) {
          // 오디션 제안 가능 목록 조회 성공
          var _responseList = value[APIConstants.data];

          var _pagingData = _responseList[APIConstants.paging];
          setState(() {
            _total = _pagingData[APIConstants.total];

            _auditionList.addAll(_responseList[APIConstants.list]);

            for (int i = 0; i < _auditionList.length; i++) {
              _selectableAuditionList.add(new CastingItemModel(
                  false,
                  _auditionList[i][APIConstants.castring_seq],
                  _auditionList[i][APIConstants.project_name],
                  _auditionList[i][APIConstants.casting_name],
                  _auditionList[i][APIConstants.isAlreadyProposal]));
            }

            _isLoading = false;
          });
        } else {
          showSnackBar(context, value[APIConstants.resultMsg]);
        }
      } else {
        showSnackBar(context, '다시 시도해 주세요.');
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
            appBar: CustomStyles.defaultAppBar('오디션 제안', () {
              Navigator.pop(context);
            }),
            body: Builder(builder: (context) {
              return Container(
                  child: Column(children: [
                Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                        child: Container(
                            padding: EdgeInsets.only(top: 20, bottom: 30),
                            child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                        top: 10,
                                        bottom: 10,
                                        left: 15,
                                        right: 15),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          flex: 0,
                                          child: Container(
                                              margin: EdgeInsets.only(right: 5),
                                              alignment: Alignment.topCenter,
                                              child: _actorImgUrl != null
                                                  ? ClipOval(
                                                      child: Image.network(
                                                          _actorImgUrl,
                                                          fit: BoxFit.cover,
                                                          width: 64.0,
                                                          height: 64.0),
                                                    )
                                                  : Icon(
                                                      Icons.account_circle,
                                                      color: CustomColors
                                                          .colorFontLightGrey,
                                                      size: 64,
                                                    )),
                                        ),
                                        Expanded(
                                            flex: 1,
                                            child: Text(
                                              StringUtils.checkedString(
                                                  _actorName),
                                              style: CustomStyles
                                                  .normal16TextStyle(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ))
                                      ],
                                    ),
                                  ),
                                  Container(
                                      margin: EdgeInsets.only(
                                          top: 15, left: 15, right: 15),
                                      alignment: Alignment.centerLeft,
                                      child: Text('제안 내용',
                                          style: CustomStyles
                                              .normal14TextStyle())),
                                  Container(
                                      margin: EdgeInsets.only(
                                          top: 10, left: 15, right: 15),
                                      padding: EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                          borderRadius: CustomStyles
                                              .circle7BorderRadius(),
                                          border: Border.all(
                                              width: 1,
                                              color: CustomColors
                                                  .colorFontLightGrey)),
                                      child: TextField(
                                        maxLines: 10,
                                        controller: _txtFieldContent,
                                        decoration: InputDecoration(
                                            isDense: true,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 0, horizontal: 0),
                                            hintText: "오디션 제안을 해보세요.",
                                            hintStyle:
                                                CustomStyles.light14TextStyle(),
                                            border: InputBorder.none),
                                      )),
                                  Container(
                                      margin: EdgeInsets.only(
                                          top: 20,
                                          bottom: 10,
                                          left: 15,
                                          right: 15),
                                      alignment: Alignment.centerLeft,
                                      child: Text('제안할 캐스팅',
                                          style: CustomStyles
                                              .normal14TextStyle())),
                                  Container(
                                    margin: EdgeInsets.only(top: 10),
                                    child: Divider(
                                      height: 0.1,
                                      color: CustomColors.colorFontLightGrey,
                                    ),
                                  ),
                                  Expanded(
                                      flex: 0,
                                      child: Container(
                                          alignment: Alignment.center,
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Wrap(children: [
                                                  ListView.separated(
                                                      physics:
                                                          NeverScrollableScrollPhysics(),
                                                      shrinkWrap: true,
                                                      // Need to display a loading tile if more items are coming
                                                      controller:
                                                          _scrollController,
                                                      itemCount:
                                                          _selectableAuditionList
                                                              .length,
                                                      itemBuilder:
                                                          (BuildContext context,
                                                              int index) {
                                                        return Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    bottom: 10,
                                                                    left: 10,
                                                                    right: 10),
                                                            alignment: Alignment
                                                                .center,
                                                            child: GestureDetector(
                                                                onTap: () {
                                                                  /*Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) => MyApplyDetail()),
                                                  );*/
                                                                },
                                                                child: Container(
                                                                    alignment: Alignment.center,
                                                                    padding: EdgeInsets.only(left: 15, right: 15, top: 10),
                                                                    child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                                                                      Expanded(
                                                                          flex:
                                                                              5,
                                                                          child: Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Container(margin: EdgeInsets.only(bottom: 5), child: Text(StringUtils.checkedString(_selectableAuditionList[index].projectName), style: CustomStyles.dark10TextStyle())),
                                                                                Container(margin: EdgeInsets.only(bottom: 5), child: Text(StringUtils.checkedString(_selectableAuditionList[index].castingName), style: CustomStyles.dark20TextStyle()))
                                                                              ])),
                                                                      Expanded(
                                                                          flex:
                                                                              0,
                                                                          child:
                                                                              Visibility(
                                                                            child:
                                                                                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                                                              Container(
                                                                                child: Text(
                                                                                  '이미 제안했던\n공고입니다.',
                                                                                  style: CustomStyles.dark14TextStyle(),
                                                                                  textAlign: TextAlign.center,
                                                                                ),
                                                                              )
                                                                            ]),
                                                                            visible: _selectableAuditionList[index].isAlreadyProposal == 0
                                                                                ? false
                                                                                : true,
                                                                          )),
                                                                      Expanded(
                                                                          flex:
                                                                              0,
                                                                          child:
                                                                              Visibility(
                                                                            child: Container(
                                                                                margin: EdgeInsets.all(10),
                                                                                alignment: Alignment.topRight,
                                                                                child: InkWell(
                                                                                  onTap: () {
                                                                                    setState(() {
                                                                                      if (_selectableAuditionList[index].isSelected == false) {
                                                                                        for (int i = 0; i < _selectableAuditionList.length; i++) {
                                                                                          if (i != index) {
                                                                                            _selectableAuditionList[i].isSelected = false;
                                                                                          }
                                                                                        }
                                                                                      }

                                                                                      _selectableAuditionList[index].isSelected = !_selectableAuditionList[index].isSelected;
                                                                                    });
                                                                                  },
                                                                                  child: Container(
                                                                                    decoration: BoxDecoration(shape: BoxShape.circle, color: (_selectableAuditionList[index].isSelected ? CustomColors.colorAccent : CustomColors.colorFontLightGrey)),
                                                                                    child: Padding(
                                                                                      padding: const EdgeInsets.all(5.0),
                                                                                      child: _selectableAuditionList[index].isSelected
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
                                                                                )),
                                                                            visible: _selectableAuditionList[index].isAlreadyProposal == 1
                                                                                ? false
                                                                                : true,
                                                                          )),
                                                                    ]))));
                                                      },
                                                      separatorBuilder:
                                                          (context, index) {
                                                        return Divider(
                                                          height: 1,
                                                          color: CustomColors
                                                              .colorFontLightGrey,
                                                        );
                                                      })
                                                ])
                                              ])))
                                ])))),
                Container(
                    width: MediaQuery.of(context).size.width,
                    height: 55,
                    child: CustomStyles.blueBGSquareButtonStyle('제안 보내기', () {
                      if (checkValidate(context)) {
                        requestAddFilmographyApi(context);
                      }
                    }))
              ]));
            })));
  }

  /*
 * 입력 데이터 유효성 검사
 * */
  bool checkValidate(BuildContext context) {
    if (StringUtils.isEmpty(_txtFieldContent.text)) {
      showSnackBar(context, '제안 내용을 입력해 주세요.');
      return false;
    }

    int cnt = 0;
    for (int i = 0; i < _selectableAuditionList.length; i++) {
      if (_selectableAuditionList[i].isSelected) {
        cnt++;
      }
    }

    if (cnt < 1) {
      showSnackBar(context, '제안할 캐스팅을 선택해 주세요.');
      return false;
    }

    return true;
  }

  /*
  * 오디션 제안하기
  * */
  void requestAddFilmographyApi(BuildContext context) {
    final dio = Dio();

    int castingSeq;
    for (int i = 0; i < _selectableAuditionList.length; i++) {
      if (_selectableAuditionList[i].isSelected) {
        castingSeq = _selectableAuditionList[i].castingSeq;
      }
    }

    // 제작사 필모그래피 추가 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetDatas = new Map();
    targetDatas[APIConstants.actor_seq] = _actorSeq;
    targetDatas[APIConstants.casting_seq] = castingSeq;
    targetDatas[APIConstants.production_seq] =
        KCastingAppData().myInfo[APIConstants.seq];
    targetDatas[APIConstants.audition_prps_contents] = _txtFieldContent.text;
    targetDatas[APIConstants.state_type] = "대기";

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.INS_APP_INFO;
    params[APIConstants.target] = targetDatas;

    // 오디션 제안하기 api 호출
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value == null) {
        // 에러 - 데이터 널
        showSnackBar(context, APIConstants.error_msg_server_not_response);
      } else {
        if (value[APIConstants.resultVal]) {
          // 오디션 제안하기 성공
          showSnackBar(context, '오디션 제안 완료');
          Navigator.pop(context);
        } else {
          // 오디션 제안하기 실패
          showSnackBar(context, APIConstants.error_msg_try_again);
        }
      }
    });
  }
}
