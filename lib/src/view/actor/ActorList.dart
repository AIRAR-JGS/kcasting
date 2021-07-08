import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/model/CastingTypeModel.dart';
import 'package:casting_call/src/model/CheckboxITemModel.dart';
import 'package:casting_call/src/model/CommonCodeModel.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/ui/CircleThumbShape.dart';
import 'package:casting_call/src/view/actor/ActorListItem.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';

import '../../../KCastingAppData.dart';

/*
* 배우 목록
* */
class ActorList extends StatefulWidget {
  final String genderType;

  const ActorList({Key key, this.genderType}) : super(key: key);

  @override
  _ActorList createState() => _ActorList();
}

class _ActorList extends State<ActorList> with BaseUtilMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  // 필터 관련 변수
  final GlobalKey<TagsState> _filterStateKey = GlobalKey<TagsState>();
  List<CastingTypeModel> _filterItemList = [];
  var _filterList = ['키워드', '성별', '나이', '키', '체중'];

  // 키워드 관련 변수
  List<CommonCodeModel> _keywordList = [];

  //  성별 관련 변수 - 남성, 여성
  List<CheckboxItemModel> _sexTypeList = [];
  var _genderType = [
    APIConstants.actor_sex_male,
    APIConstants.actor_sex_female
  ];

  // 나이 관련 변수
  int _isAgeLimit = 0;
  RangeValues _ageRangeValues = const RangeValues(0, 100);

  // 키 관련 변수
  int _isHeightLimit = 0;
  RangeValues _heightRangeValues = const RangeValues(0, 200);

  // 체중 관련 변수
  int _isWeightLimit = 0;
  RangeValues _weightRangeValues = const RangeValues(0, 200);

  // 배우 리스트 관련 변수
  ScrollController _scrollController;

  int _total = 0;
  int _limit = 20;

  List<dynamic> _actorList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // 필터
    for (int i = 0; i < _filterList.length; i++) {
      _filterItemList
          .add(new CastingTypeModel(_filterList[i].toString(), false, 0));
    }

    // 키워드
    for (int i = 0; i < KCastingAppData().commonCodeK02.length; i++) {
      var commonCode = KCastingAppData().commonCodeK02[i];

      _keywordList.add(new CommonCodeModel(commonCode[APIConstants.seq],
          commonCode[APIConstants.child_name], false));
    }

    // 성별
    for (int i = 0; i < _genderType.length; i++) {
      _sexTypeList.add(new CheckboxItemModel(_genderType[i], false));
    }

    if (widget.genderType != null) {
      for (int i = 0; i < _genderType.length; i++) {
        if (_sexTypeList[i].itemName == widget.genderType) {
          _sexTypeList[i].isSelected = true;

          _filterItemList[1].isActive = true;
        }
      }
    }

    // 배우 목록 api 조회
    requestActorListApi(context);

    // 리스트뷰 스크롤 컨트롤러
    _scrollController = new ScrollController(initialScrollOffset: 5.0)
      ..addListener(_scrollListener);
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

    // 외모 키워드
    int lookKeywordStr;
    for (int i = 0; i < _keywordList.length; i++) {
      if (_keywordList[i].isSelected) {
        lookKeywordStr = _keywordList[i].seq;
        targetData[APIConstants.look_kwd_seq] = lookKeywordStr;
      }
    }

    // 성별
    String sexTypeStr;
    for (int i = 0; i < _sexTypeList.length; i++) {
      if (_sexTypeList[i].isSelected) {
        sexTypeStr = _sexTypeList[i].itemName;
      }
    }

    if (sexTypeStr != null) {
      targetData[APIConstants.sex_type] = sexTypeStr;
    }

    // 나이
    if (_isAgeLimit == 1) {
      Map<String, dynamic> age = new Map();
      age[APIConstants.min] = _ageRangeValues.start.toInt();
      age[APIConstants.max] = _ageRangeValues.end.toInt();

      targetData[APIConstants.actor_age] = age;
    }

    // 키
    if (_isHeightLimit == 1) {
      Map<String, dynamic> height = new Map();
      height[APIConstants.min] = _heightRangeValues.start.toInt();
      height[APIConstants.max] = _heightRangeValues.end.toInt();

      targetData[APIConstants.actor_tall] = height;
    }

    // 체중
    if (_isWeightLimit == 1) {
      Map<String, dynamic> weight = new Map();
      weight[APIConstants.min] = _weightRangeValues.start.toInt();
      weight[APIConstants.max] = _weightRangeValues.end.toInt();

      targetData[APIConstants.actor_weight] = weight;
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
    return Scaffold(
        key: _scaffoldKey,
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
                            margin: EdgeInsets.only(
                                top: 15, left: 16, right: 11, bottom: 5),
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 1,
                                    child: Tags(
                                        columns: 1,
                                        symmetry: false,
                                        horizontalScroll: true,
                                        spacing: 1,
                                        heightHorizontalScroll: 30,
                                        key: _filterStateKey,
                                        itemCount: _filterItemList.length,
                                        itemBuilder: (int index) {
                                          CastingTypeModel category =
                                              _filterItemList[index];

                                          return ItemTags(
                                              textStyle: CustomStyles
                                                  .dark16TextStyle(),
                                              textColor:
                                                  CustomColors.colorFontTitle,
                                              activeColor:
                                                  CustomColors.colorPrimary,
                                              textActiveColor:
                                                  CustomColors.colorWhite,
                                              key: Key(index.toString()),
                                              index: index,
                                              title: category.name,
                                              active: category.isActive,
                                              combine: ItemTagsCombine
                                                  .withTextBefore,
                                              image: ItemTagsImage(
                                                  child: Visibility(
                                                child: Image.asset(
                                                    'assets/images/btn_close.png',
                                                    width: 10),
                                                visible: category.isActive,
                                              )),
                                              elevation: 0.0,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              onPressed: (item) {
                                                print(item);

                                                setState(() {
                                                  category.isActive =
                                                      !category.isActive;

                                                  if (index == 0) {
                                                    for (int i = 0;
                                                        i < _keywordList.length;
                                                        i++) {
                                                      _keywordList[i]
                                                          .isSelected = false;
                                                    }
                                                  }

                                                  if (index == 1) {
                                                    for (int i = 0;
                                                        i < _sexTypeList.length;
                                                        i++) {
                                                      _sexTypeList[i]
                                                          .isSelected = false;
                                                    }
                                                  }

                                                  if (index == 2) {
                                                    if (category.isActive) {
                                                      _isAgeLimit = 1;
                                                    } else {
                                                      _isAgeLimit = 0;
                                                    }
                                                  }

                                                  if (index == 3) {
                                                    if (category.isActive) {
                                                      _isHeightLimit = 1;
                                                    } else {
                                                      _isHeightLimit = 0;
                                                    }
                                                  }

                                                  if (index == 4) {
                                                    if (category.isActive) {
                                                      _isWeightLimit = 1;
                                                    } else {
                                                      _isWeightLimit = 0;
                                                    }
                                                  }
                                                });
                                              });
                                        })),
                                GestureDetector(
                                  onTap: () {
                                    _actorList = [];
                                    _total = 0;
                                    requestActorListApi(context);
                                  },
                                  child: Container(
                                      width: 30,
                                      padding: EdgeInsets.all(5),
                                      margin: EdgeInsets.only(left: 8),
                                      child: Image.asset(
                                          'assets/images/btn_search.png',
                                          width: 18)),
                                )
                              ],
                            )),

                        // 키워드
                        Visibility(
                            child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: 20,
                                margin: EdgeInsets.only(
                                    left: 20, right: 20, top: 10),
                                child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _keywordList.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                          child: InkWell(
                                              child: Text(
                                                  _keywordList[index].childName,
                                                  style: _keywordList[index]
                                                          .isSelected
                                                      ? CustomStyles
                                                          .blue16TextStyle()
                                                      : CustomStyles
                                                          .normal16TextStyle()),
                                              onTap: () {
                                                setState(() {
                                                  _keywordList[index]
                                                          .isSelected =
                                                      !_keywordList[index]
                                                          .isSelected;

                                                  for (int i = 0;
                                                      i < _keywordList.length;
                                                      i++) {
                                                    if (i != index) {
                                                      _keywordList[i]
                                                          .isSelected = false;
                                                    }
                                                  }
                                                });
                                              }));
                                    },
                                    separatorBuilder: (context, index) {
                                      return VerticalDivider();
                                    })),
                            visible: _filterItemList[0].isActive),

                        // 성별
                        // 성별 무관, 남성, 여성
                        Visibility(
                          child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 20,
                              margin:
                                  EdgeInsets.only(left: 20, right: 20, top: 10),
                              child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _sexTypeList.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                        child: InkWell(
                                            child: Text(
                                                _sexTypeList[index].itemName,
                                                style: _sexTypeList[index]
                                                        .isSelected
                                                    ? CustomStyles
                                                        .blue16TextStyle()
                                                    : CustomStyles
                                                        .normal16TextStyle()),
                                            onTap: () {
                                              setState(() {
                                                _sexTypeList[index].isSelected =
                                                    !_sexTypeList[index]
                                                        .isSelected;

                                                for (int i = 0;
                                                    i < _sexTypeList.length;
                                                    i++) {
                                                  if (i != index) {
                                                    _sexTypeList[i].isSelected =
                                                        false;
                                                  }
                                                }
                                              });
                                            }));
                                  },
                                  separatorBuilder: (context, index) {
                                    return VerticalDivider();
                                  })),
                          visible: _filterItemList[1].isActive,
                        ),

                        // 나이
                        // 나이 무관, 0~100세
                        Visibility(
                          child: Container(
                              margin: EdgeInsets.only(bottom: 10, top: 10),
                              padding: EdgeInsets.only(left: 20, right: 20),
                              child: Column(children: [
                                Container(
                                    margin: EdgeInsets.only(bottom: 5),
                                    child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                              child: Text(
                                                  _ageRangeValues.start
                                                          .round()
                                                          .toString() +
                                                      '세',
                                                  style: CustomStyles
                                                      .dark16TextStyle())),
                                          Container(
                                              child: Text(
                                                  _ageRangeValues.end
                                                          .round()
                                                          .toString() +
                                                      '세',
                                                  style: CustomStyles
                                                      .dark16TextStyle()))
                                        ])),
                                SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                        trackHeight: 1,
                                        thumbColor: CustomColors.colorAccent,
                                        rangeThumbShape: CircleThumbShape(),
                                        overlayShape: RoundSliderOverlayShape(
                                            overlayRadius: 6.0)),
                                    child: RangeSlider(
                                        inactiveColor: CustomColors.colorBgGrey,
                                        activeColor: CustomColors.colorPrimary,
                                        values: _ageRangeValues,
                                        min: 0,
                                        max: 100,
                                        divisions: 10,
                                        labels: RangeLabels(
                                            _ageRangeValues.start
                                                .round()
                                                .toString(),
                                            _ageRangeValues.end
                                                .round()
                                                .toString()),
                                        onChanged: (RangeValues values) {
                                          setState(() {
                                            _ageRangeValues = values;
                                          });
                                        }))
                              ])),
                          visible: _filterItemList[2].isActive,
                        ),

                        // 키
                        // 키 무관, 0~200
                        Visibility(
                          child: Container(
                              margin: EdgeInsets.only(bottom: 10, top: 10),
                              padding: EdgeInsets.only(left: 20, right: 20),
                              child: Column(children: [
                                Container(
                                    margin: EdgeInsets.only(bottom: 5),
                                    child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                              child: Text(
                                                  _heightRangeValues.start
                                                          .round()
                                                          .toString() +
                                                      'cm',
                                                  style: CustomStyles
                                                      .dark16TextStyle())),
                                          Container(
                                              child: Text(
                                                  _heightRangeValues.end
                                                          .round()
                                                          .toString() +
                                                      'cm',
                                                  style: CustomStyles
                                                      .dark16TextStyle()))
                                        ])),
                                SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                        trackHeight: 1,
                                        thumbColor: CustomColors.colorAccent,
                                        rangeThumbShape: CircleThumbShape(),
                                        overlayShape: RoundSliderOverlayShape(
                                            overlayRadius: 6.0)),
                                    child: RangeSlider(
                                        inactiveColor: CustomColors.colorBgGrey,
                                        activeColor: CustomColors.colorPrimary,
                                        values: _heightRangeValues,
                                        min: 0,
                                        max: 200,
                                        divisions: 20,
                                        labels: RangeLabels(
                                          _heightRangeValues.start
                                              .round()
                                              .toString(),
                                          _heightRangeValues.end
                                              .round()
                                              .toString(),
                                        ),
                                        onChanged: (RangeValues values) {
                                          setState(() {
                                            _heightRangeValues = values;
                                          });
                                        }))
                              ])),
                          visible: _filterItemList[3].isActive,
                        ),

                        // 체중
                        // 체중 무관, 0~150
                        Visibility(
                            child: Container(
                                margin: EdgeInsets.only(bottom: 10, top: 10),
                                padding: EdgeInsets.only(left: 20, right: 20),
                                child: Column(children: [
                                  Container(
                                      margin: EdgeInsets.only(bottom: 5),
                                      child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                                child: Text(
                                                    _weightRangeValues.start
                                                            .round()
                                                            .toString() +
                                                        'kg',
                                                    style: CustomStyles
                                                        .dark16TextStyle())),
                                            Container(
                                                child: Text(
                                                    _weightRangeValues.end
                                                            .round()
                                                            .toString() +
                                                        'kg',
                                                    style: CustomStyles
                                                        .dark16TextStyle()))
                                          ])),
                                  SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                          trackHeight: 1,
                                          thumbColor: CustomColors.colorAccent,
                                          rangeThumbShape: CircleThumbShape(),
                                          overlayShape: RoundSliderOverlayShape(
                                              overlayRadius: 6.0)),
                                      child: RangeSlider(
                                          inactiveColor:
                                              CustomColors.colorBgGrey,
                                          activeColor:
                                              CustomColors.colorPrimary,
                                          values: _weightRangeValues,
                                          min: 0,
                                          max: 200,
                                          divisions: 20,
                                          labels: RangeLabels(
                                              _weightRangeValues.start
                                                  .round()
                                                  .toString(),
                                              _weightRangeValues.end
                                                  .round()
                                                  .toString()),
                                          onChanged: (RangeValues values) {
                                            setState(() {
                                              _weightRangeValues = values;
                                            });
                                          }))
                                ])),
                            visible: _filterItemList[4].isActive),

                        Container(
                            margin: EdgeInsets.only(bottom: 10),
                            child: Divider(
                                color: CustomColors.colorFontLightGrey)),

                        Container(
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.only(
                                left: 15, right: 15, bottom: 15),
                            child: RichText(
                                text: new TextSpan(
                                    style: CustomStyles.normal14TextStyle(),
                                    children: <TextSpan>[
                                  new TextSpan(
                                      text: _total.toString(),
                                      style: CustomStyles.red14TextStyle()),
                                  new TextSpan(text: '명의 배우')
                                ])))
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
                                return ActorListItem(data: _actorList[index]);
                              }))
                        ])
                      : Container(
                          margin: EdgeInsets.only(top: 30),
                          child: Text('배우가 없습니다.',
                              style: CustomStyles.normal16TextStyle()))
                ]))));
  }
}
