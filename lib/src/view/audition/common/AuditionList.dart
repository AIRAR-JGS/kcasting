import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/model/CastingTypeModel.dart';
import 'package:casting_call/src/model/CheckboxITemModel.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/ui/CircleThumbShape.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';

import '../../../../KCastingAppData.dart';
import 'AuditionListItem.dart';

/*
* 캐스팅보드 목록
* */
class AuditionList extends StatefulWidget {
  @override
  _AuditionList createState() => _AuditionList();
}

class _AuditionList extends State<AuditionList> with BaseUtilMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String _castingListOrderType = APIConstants.order_type_new;

  // 필터 관련 변수
  final GlobalKey<TagsState> _filterStateKey = GlobalKey<TagsState>();
  var _filterList = ['배역', '제작유형', '성별', '나이', '키', '체중'];
  List<CastingTypeModel> _filterItemList = [];

  // 배역 타입 관련 변수 - 주연, 조연, 조단역, 보조출연
  List<CheckboxItemModel> _castingTypeList = [];
  var _castingType = [
    APIConstants.casting_type_1,
    APIConstants.casting_type_2,
    APIConstants.casting_type_3,
    APIConstants.casting_type_4
  ];

  //  제작유형 관련 변수 - 영화, 드라마
  List<CheckboxItemModel> _projectTypeList = [];
  var _projectType = [
    APIConstants.project_type_movie,
    APIConstants.project_type_drama
  ];

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

  // 캐스팅보드 리스트 관련 변수
  ScrollController _scrollController;

  int _total = 0;
  int _limit = 20;

  List<dynamic> _castingBoardList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < _filterList.length; i++) {
      _filterItemList
          .add(new CastingTypeModel(_filterList[i].toString(), false, 0));
    }

    for (int i = 0; i < _castingType.length; i++) {
      _castingTypeList.add(new CheckboxItemModel(_castingType[i], false));
    }

    for (int i = 0; i < _projectType.length; i++) {
      _projectTypeList.add(new CheckboxItemModel(_projectType[i], false));
    }

    for (int i = 0; i < _genderType.length; i++) {
      _sexTypeList.add(new CheckboxItemModel(_genderType[i], false));
    }

    requestCastingListApi(context);

    _scrollController = new ScrollController(initialScrollOffset: 5.0)
      ..addListener(_scrollListener);
  }

  _scrollListener() {
    if (_total == 0 || _castingBoardList.length >= _total) return;

    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      setState(() {
        _isLoading = true;

        if (_isLoading) {
          requestCastingListApi(context);
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
  * 캐스팅 목록
  * */
  void requestCastingListApi(BuildContext context) {
    final dio = Dio();

    // 캐스팅 목록 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetDate = new Map();
    targetDate[APIConstants.order_type] = _castingListOrderType;
    if (KCastingAppData().myInfo[APIConstants.member_type] ==
        APIConstants.member_type_actor) {
      targetDate[APIConstants.actor_seq] =
          KCastingAppData().myInfo[APIConstants.seq];
    }

    if (KCastingAppData().myInfo[APIConstants.member_type] ==
        APIConstants.member_type_management) {
      targetDate[APIConstants.management_seq] =
          KCastingAppData().myInfo[APIConstants.seq];
    }

    // 배역
    String castingTypeStr;
    for (int i = 0; i < _castingTypeList.length; i++) {
      if (_castingTypeList[i].isSelected) {
        castingTypeStr = _castingTypeList[i].itemName;
      }
    }

    if (castingTypeStr != null) {
      targetDate[APIConstants.casting_type] = castingTypeStr;
    }

    // 제작유형
    String projectTypeStr;
    for (int i = 0; i < _projectTypeList.length; i++) {
      if (_projectTypeList[i].isSelected) {
        projectTypeStr = _projectTypeList[i].itemName;
      }
    }

    if (projectTypeStr != null) {
      targetDate[APIConstants.project_type] = projectTypeStr;
    }

    // 성별
    String sexTypeStr;
    for (int i = 0; i < _sexTypeList.length; i++) {
      if (_sexTypeList[i].isSelected) {
        sexTypeStr = _sexTypeList[i].itemName;
      }
    }

    if (sexTypeStr != null) {
      targetDate[APIConstants.sex_type] = sexTypeStr;
    }

    // 나이
    if (_isAgeLimit == 1) {
      Map<String, dynamic> age = new Map();
      age[APIConstants.min] = _ageRangeValues.start.toInt();
      age[APIConstants.max] = _ageRangeValues.end.toInt();

      targetDate[APIConstants.casting_age] = age;
    }

    // 키
    if (_isHeightLimit == 1) {
      Map<String, dynamic> height = new Map();
      height[APIConstants.min] = _heightRangeValues.start.toInt();
      height[APIConstants.max] = _heightRangeValues.end.toInt();

      targetDate[APIConstants.casting_tall] = height;
    }

    // 체중
    if (_isWeightLimit == 1) {
      Map<String, dynamic> weight = new Map();
      weight[APIConstants.min] = _weightRangeValues.start.toInt();
      weight[APIConstants.max] = _weightRangeValues.end.toInt();

      targetDate[APIConstants.casting_weight] = weight;
    }

    Map<String, dynamic> paging = new Map();
    paging[APIConstants.offset] = _castingBoardList.length;
    paging[APIConstants.limit] = _limit;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.SEL_PCT_LIST;
    params[APIConstants.target] = targetDate;
    params[APIConstants.paging] = paging;

    // 캐스팅 목록 api 호출
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value != null) {
        if (value[APIConstants.resultVal]) {
          try {
            // 캐스팅 목록 성공
            setState(() {
              var _responseData = value[APIConstants.data];
              var _responseList = _responseData[APIConstants.list] as List;
              var _pagingData = _responseData[APIConstants.paging];

              _total = _pagingData[APIConstants.total];

              if (_responseList != null && _responseList.length > 0) {
                _castingBoardList.addAll(_responseList);
              }

              _isLoading = false;
            });
          } catch (e) {}
        }
      }
    });
  }

  Future<void> _refreshPage() async {

    setState(() {
      _total = 0;

      _castingBoardList = [];
      requestCastingListApi(context);
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
            child: RefreshIndicator(
              onRefresh: _refreshPage,
              child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: AlwaysScrollableScrollPhysics(),
                  key: ObjectKey(_castingBoardList.length > 0 ? _castingBoardList[0] : ""),
                  child: Column(children: [
                    Expanded(
                        flex: 0,
                        child: Column(children: [
                          Container(
                              margin: EdgeInsets.only(
                                  top: 15, left: 16, right: 11, bottom: 5),
                              child: Row(children: [
                                Expanded(
                                    flex: 1,
                                    child: Tags(
                                        columns: 1,
                                        symmetry: false,
                                        horizontalScroll: true,
                                        spacing: 2,
                                        heightHorizontalScroll: 30,
                                        key: _filterStateKey,
                                        itemCount: _filterItemList.length,
                                        itemBuilder: (int index) {
                                          CastingTypeModel category =
                                          _filterItemList[index];

                                          return ItemTags(
                                              textStyle:
                                              CustomStyles.dark16TextStyle(),
                                              textColor: CustomColors.colorFontTitle,
                                              activeColor: CustomColors.colorPrimary,
                                              textActiveColor:
                                              CustomColors.colorWhite,
                                              key: Key(index.toString()),
                                              index: index,
                                              title: category.name,
                                              active: category.isActive,
                                              combine: ItemTagsCombine.withTextBefore,
                                              image: ItemTagsImage(
                                                  child: Visibility(
                                                    child: Image.asset(
                                                        'assets/images/btn_close.png',
                                                        width: 10),
                                                    visible: category.isActive,
                                                  )),
                                              elevation: 0.0,
                                              padding: EdgeInsets.only(left: 7, right: 4, top: 5, bottom: 4),
                                              borderRadius: BorderRadius.circular(5),
                                              onPressed: (item) {
                                                setState(() {
                                                  category.isActive =
                                                  !category.isActive;

                                                  if (index == 0) {
                                                    for (int i = 0;
                                                    i < _castingTypeList.length;
                                                    i++) {
                                                      _castingTypeList[i].isSelected =
                                                      false;
                                                    }
                                                  }

                                                  if (index == 1) {
                                                    for (int i = 0;
                                                    i < _projectTypeList.length;
                                                    i++) {
                                                      _projectTypeList[i].isSelected =
                                                      false;
                                                    }
                                                  }

                                                  if (index == 2) {
                                                    for (int i = 0;
                                                    i < _sexTypeList.length;
                                                    i++) {
                                                      _sexTypeList[i].isSelected =
                                                      false;
                                                    }
                                                  }

                                                  if (index == 3) {
                                                    if (category.isActive) {
                                                      _isAgeLimit = 1;
                                                    } else {
                                                      _isAgeLimit = 0;
                                                    }
                                                  }

                                                  if (index == 4) {
                                                    if (category.isActive) {
                                                      _isHeightLimit = 1;
                                                    } else {
                                                      _isHeightLimit = 0;
                                                    }
                                                  }

                                                  if (index == 5) {
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
                                    _castingBoardList = [];
                                    _total = 0;
                                    requestCastingListApi(context);
                                  },
                                  child: Container(
                                      width: 30,
                                      padding: EdgeInsets.all(5),
                                      margin: EdgeInsets.only(left: 8),
                                      child: Image.asset(
                                          'assets/images/btn_search.png',
                                          width: 18)),
                                )
                              ])),

                          // 배역
                          // 전체, 조연, 조단역, 단역, 이미지단역, 보조출연
                          Visibility(
                            child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: 20,
                                margin: EdgeInsets.only(left: 20, right: 20, top: 10),
                                child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _castingTypeList.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                          child: InkWell(
                                              child: Text(
                                                  _castingTypeList[index].itemName,
                                                  style: _castingTypeList[index]
                                                      .isSelected
                                                      ? CustomStyles.blue16TextStyle()
                                                      : CustomStyles
                                                      .normal16TextStyle()),
                                              onTap: () {
                                                setState(() {
                                                  _castingTypeList[index].isSelected =
                                                  !_castingTypeList[index]
                                                      .isSelected;

                                                  for (int i = 0;
                                                  i < _castingTypeList.length;
                                                  i++) {
                                                    if (i != index) {
                                                      _castingTypeList[i].isSelected =
                                                      false;
                                                    }
                                                  }
                                                });
                                              }));
                                    },
                                    separatorBuilder: (context, index) {
                                      return VerticalDivider();
                                    })),
                            visible: _filterItemList[0].isActive,
                          ),

                          // 제작유형
                          // 전체, 영화, 드라마
                          Visibility(
                            child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: 20,
                                margin: EdgeInsets.only(left: 20, right: 20, top: 10),
                                child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _projectTypeList.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                          child: InkWell(
                                              child: Text(
                                                  _projectTypeList[index].itemName,
                                                  style: _projectTypeList[index]
                                                      .isSelected
                                                      ? CustomStyles.blue16TextStyle()
                                                      : CustomStyles
                                                      .normal16TextStyle()),
                                              onTap: () {
                                                setState(() {
                                                  _projectTypeList[index].isSelected =
                                                  !_projectTypeList[index]
                                                      .isSelected;

                                                  for (int i = 0;
                                                  i < _projectTypeList.length;
                                                  i++) {
                                                    if (i != index) {
                                                      _projectTypeList[i].isSelected =
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

                          // 성별
                          // 성별 무관, 남성, 여성
                          Visibility(
                            child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: 20,
                                margin: EdgeInsets.only(left: 20, right: 20, top: 10),
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
                                                      ? CustomStyles.blue16TextStyle()
                                                      : CustomStyles
                                                      .normal16TextStyle()),
                                              onTap: () {
                                                setState(() {
                                                  _sexTypeList[index].isSelected =
                                                  !_sexTypeList[index].isSelected;

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
                            visible: _filterItemList[2].isActive,
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
                                            _ageRangeValues.start.round().toString(),
                                            _ageRangeValues.end.round().toString(),
                                          ),
                                          onChanged: (RangeValues values) {
                                            setState(() {
                                              _ageRangeValues = values;
                                            });
                                          }))
                                ])),
                            visible: _filterItemList[3].isActive,
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
                                                style:
                                                CustomStyles.dark16TextStyle())),
                                        Container(
                                            child: Text(
                                                _heightRangeValues.end
                                                    .round()
                                                    .toString() +
                                                    'cm',
                                                style:
                                                CustomStyles.dark16TextStyle())),
                                      ],
                                    ),
                                  ),
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
                                            _heightRangeValues.end.round().toString(),
                                          ),
                                          onChanged: (RangeValues values) {
                                            setState(() {
                                              _heightRangeValues = values;
                                            });
                                          }))
                                ])),
                            visible: _filterItemList[4].isActive,
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
                                                style:
                                                CustomStyles.dark16TextStyle())),
                                        Container(
                                            child: Text(
                                                _weightRangeValues.end
                                                    .round()
                                                    .toString() +
                                                    'kg',
                                                style:
                                                CustomStyles.dark16TextStyle())),
                                      ],
                                    ),
                                  ),
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
                                          values: _weightRangeValues,
                                          min: 0,
                                          max: 200,
                                          divisions: 20,
                                          labels: RangeLabels(
                                            _weightRangeValues.start
                                                .round()
                                                .toString(),
                                            _weightRangeValues.end.round().toString(),
                                          ),
                                          onChanged: (RangeValues values) {
                                            setState(() {
                                              _weightRangeValues = values;
                                            });
                                          }))
                                ])),
                            visible: _filterItemList[5].isActive,
                          ),

                          Container(
                            margin: EdgeInsets.only(bottom: 10),
                            child: Divider(
                              color: CustomColors.colorFontLightGrey,
                            ),
                          ),

                          Container(
                              margin:
                              EdgeInsets.only(left: 15, right: 15, bottom: 15),
                              child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      child: RichText(
                                          text: new TextSpan(
                                            style: CustomStyles.normal14TextStyle(),
                                            children: <TextSpan>[
                                              new TextSpan(
                                                  text:
                                                  _total.toString(),
                                                  style: CustomStyles.red14TextStyle()),
                                              new TextSpan(text: '개의 배역'),
                                            ],
                                          )),
                                    ),
                                    Row(children: [
                                      Container(
                                          child: (_castingListOrderType ==
                                              APIConstants.order_type_fin)
                                              ? CustomStyles.blue16TextButtonStyle(
                                              '마감임박', () {
                                            _castingListOrderType =
                                                APIConstants.order_type_fin;
                                            _castingBoardList = [];
                                            _total = 0;
                                            requestCastingListApi(context);
                                          })
                                              : CustomStyles.normal16TextButtonStyle(
                                              '마감임박', () {
                                            _castingListOrderType =
                                                APIConstants.order_type_fin;
                                            _castingBoardList = [];
                                            _total = 0;
                                            requestCastingListApi(context);
                                          })),
                                      Container(
                                        child: Text(' | '),
                                      ),
                                      Container(
                                          child: (_castingListOrderType ==
                                              APIConstants.order_type_new)
                                              ? CustomStyles.blue16TextButtonStyle(
                                              '최신등록', () {
                                            _castingListOrderType =
                                                APIConstants.order_type_new;
                                            _castingBoardList = [];
                                            _total = 0;
                                            requestCastingListApi(context);
                                          })
                                              : CustomStyles.normal16TextButtonStyle(
                                              '최신등록', () {
                                            _castingListOrderType =
                                                APIConstants.order_type_new;
                                            _castingBoardList = [];
                                            _total = 0;
                                            requestCastingListApi(context);
                                          }))
                                    ])
                                  ]))
                        ])),
                    _castingBoardList.length > 0
                        ? (Wrap(children: [
                      ListView.builder(
                          padding: EdgeInsets.only(bottom: 70),
                          primary: false,
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _castingBoardList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                                margin: EdgeInsets.only(bottom: 10),
                                alignment: Alignment.center,
                                child: AuditionListItem(
                                  castingItem: _castingBoardList[index],
                                  isMyScrapList: false,
                                  onClickedBookmark: () {
                                    if (KCastingAppData()
                                        .myInfo[APIConstants.member_type] ==
                                        APIConstants.member_type_actor) {
                                      requestActorBookmarkEditApi(
                                          context, index);
                                    } else if (KCastingAppData()
                                        .myInfo[APIConstants.member_type] ==
                                        APIConstants.member_type_management) {
                                      requestManagementBookmarkEditApi(
                                          context, index);
                                    }
                                  },
                                ));
                          })
                    ]))
                        : Container(
                        margin: EdgeInsets.only(top: 30),
                        child: Text('캐스팅이 없습니다.',
                            style: CustomStyles.normal16TextStyle()))
                  ])),
            )));
  }

  /*
  * 배우 북마크 목록
  * */
  void requestActorBookmarkEditApi(BuildContext context, int idx) {
    final dio = Dio();

    // 배우 북마크 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetDate = new Map();
    targetDate[APIConstants.actor_seq] =
        KCastingAppData().myInfo[APIConstants.seq];
    targetDate[APIConstants.casting_seq] =
        _castingBoardList[idx][APIConstants.casting_seq];

    Map<String, dynamic> params = new Map();
    if (_castingBoardList[idx][APIConstants.isActorCastringScrap] == 1) {
      params[APIConstants.key] = APIConstants.DEA_ACS_INFO;
    } else {
      params[APIConstants.key] = APIConstants.INS_ACS_INFO;
    }

    params[APIConstants.target] = targetDate;

    // 배우 북마크 api 호출
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value != null) {
        if (value[APIConstants.resultVal]) {
          _total = 0;
          _castingBoardList = [];

          requestCastingListApi(context);
        }
      }
    });
  }

  /*
  * 매니지먼트 북마크 목록
  * */
  void requestManagementBookmarkEditApi(BuildContext context, int idx) {
    final dio = Dio();

    // 매니지먼트 북마크 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetDate = new Map();
    targetDate[APIConstants.management_seq] =
        KCastingAppData().myInfo[APIConstants.seq];
    targetDate[APIConstants.casting_seq] =
        _castingBoardList[idx][APIConstants.casting_seq];

    Map<String, dynamic> params = new Map();
    if (_castingBoardList[idx][APIConstants.isActorCastringScrap] == 1) {
      params[APIConstants.key] = APIConstants.DEA_MCS_INFO;
    } else {
      params[APIConstants.key] = APIConstants.INS_MCS_INFO;
    }

    params[APIConstants.target] = targetDate;

    // 매니지먼트 북마크 api 호출
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value != null) {
        if (value[APIConstants.resultVal]) {
          _total = 0;
          _castingBoardList = [];

          requestCastingListApi(context);
        }
      }
    });
  }
}
