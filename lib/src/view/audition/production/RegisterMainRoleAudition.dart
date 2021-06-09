import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/model/CheckboxITemModel.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/ui/CircleThumbShape.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../KCastingAppData.dart';

/*
* 오디션 배역 추가 - 특정 배역
* */
class RegisterMainRoleAudition extends StatefulWidget {
  final int projectSeq;

  const RegisterMainRoleAudition({Key key, this.projectSeq}) : super(key: key);

  @override
  _RegisterMainRoleAudition createState() => _RegisterMainRoleAudition();
}

class _RegisterMainRoleAudition extends State<RegisterMainRoleAudition>
    with SingleTickerProviderStateMixin, BaseUtilMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  int _projectSeq;

  TabController _tabController;
  int _tabIndex = 0;

  int _userGender = 0;
  int _major = 0;

  String _startDate;
  String _endDate;
  String _castingType = APIConstants.casting_type_1;

  final _txtFieldCastingName = TextEditingController();
  final _txtFieldCastingCnt = TextEditingController();
  final _txtFieldCastingIntroduce = TextEditingController();
  final _txtFieldCastingUniqueness = TextEditingController();
  final _txtFieldCastingPay = TextEditingController();

  RangeValues _ageRangeValues = const RangeValues(0, 100);
  RangeValues _heightRangeValues = const RangeValues(0, 200);
  RangeValues _weightRangeValues = const RangeValues(0, 200);

  List<CheckboxItemModel> _languages = [];
  List<CheckboxItemModel> _dialect = [];
  List<CheckboxItemModel> _secialityMusic = [];
  List<CheckboxItemModel> _secialityDance = [];
  List<CheckboxItemModel> _secialitySports = [];
  List<CheckboxItemModel> _secialityEtc = [];

  int _isAgeLimit = 0;
  int _isHeightLimit = 0;
  int _isWeightLimit = 0;
  int _isPayLimit = 0;

  @override
  void initState() {
    super.initState();

    _projectSeq = widget.projectSeq;

    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection);

    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');

    _startDate = formatter.format(now);
    _endDate = formatter.format(DateTime(now.year + 1, now.month, now.day));

    _languages.add(new CheckboxItemModel('영어', false));
    _languages.add(new CheckboxItemModel('중국어', false));
    _languages.add(new CheckboxItemModel('일본어', false));
    _languages.add(new CheckboxItemModel('아랍어', false));
    _languages.add(new CheckboxItemModel('불어', false));
    _languages.add(new CheckboxItemModel('스페인어', false));

    _dialect.add(new CheckboxItemModel('경상도', false));
    _dialect.add(new CheckboxItemModel('전라도', false));
    _dialect.add(new CheckboxItemModel('충청도', false));
    _dialect.add(new CheckboxItemModel('강원도', false));
    _dialect.add(new CheckboxItemModel('제주도', false));
    _dialect.add(new CheckboxItemModel('연변', false));
    _dialect.add(new CheckboxItemModel('북한', false));

    _secialityMusic.add(new CheckboxItemModel('성악', false));
    _secialityMusic.add(new CheckboxItemModel('알앤비', false));
    _secialityMusic.add(new CheckboxItemModel('락', false));
    _secialityMusic.add(new CheckboxItemModel('랩', false));
    _secialityMusic.add(new CheckboxItemModel('뮤지컬', false));
    _secialityMusic.add(new CheckboxItemModel('피아노', false));
    _secialityMusic.add(new CheckboxItemModel('바이올린', false));
    _secialityMusic.add(new CheckboxItemModel('플루트', false));
    _secialityMusic.add(new CheckboxItemModel('첼로', false));
    _secialityMusic.add(new CheckboxItemModel('우쿨렐레', false));
    _secialityMusic.add(new CheckboxItemModel('일렉기타', false));
    _secialityMusic.add(new CheckboxItemModel('베이스', false));
    _secialityMusic.add(new CheckboxItemModel('통기타', false));
    _secialityMusic.add(new CheckboxItemModel('트럼펫', false));
    _secialityMusic.add(new CheckboxItemModel('트럼본', false));

    _secialityDance.add(new CheckboxItemModel('한국무용', false));
    _secialityDance.add(new CheckboxItemModel('발레', false));
    _secialityDance.add(new CheckboxItemModel('재즈댄스', false));
    _secialityDance.add(new CheckboxItemModel('뮤지컬댄스', false));
    _secialityDance.add(new CheckboxItemModel('스포츠댄스', false));
    _secialityDance.add(new CheckboxItemModel('브레이크', false));
    _secialityDance.add(new CheckboxItemModel('스트릿댄스', false));
    _secialityDance.add(new CheckboxItemModel('팝핀', false));
    _secialityDance.add(new CheckboxItemModel('힙합', false));
    _secialityDance.add(new CheckboxItemModel('하우스', false));
    _secialityDance.add(new CheckboxItemModel('방송댄스', false));
    _secialityDance.add(new CheckboxItemModel('라틴', false));
    _secialityDance.add(new CheckboxItemModel('밸리댄스', false));
    _secialityDance.add(new CheckboxItemModel('탭댄스', false));

    _secialitySports.add(new CheckboxItemModel('요가', false));
    _secialitySports.add(new CheckboxItemModel('골프', false));
    _secialitySports.add(new CheckboxItemModel('축구', false));
    _secialitySports.add(new CheckboxItemModel('야구', false));
    _secialitySports.add(new CheckboxItemModel('농구', false));
    _secialitySports.add(new CheckboxItemModel('수영', false));
    _secialitySports.add(new CheckboxItemModel('헬스', false));
    _secialitySports.add(new CheckboxItemModel('탁구', false));
    _secialitySports.add(new CheckboxItemModel('복싱', false));
    _secialitySports.add(new CheckboxItemModel('스쿼시', false));
    _secialitySports.add(new CheckboxItemModel('조깅', false));
    _secialitySports.add(new CheckboxItemModel('인라인', false));
    _secialitySports.add(new CheckboxItemModel('보드', false));

    _secialityEtc.add(new CheckboxItemModel('자전거', false));
    _secialityEtc.add(new CheckboxItemModel('등산', false));
    _secialityEtc.add(new CheckboxItemModel('레프팅', false));
    _secialityEtc.add(new CheckboxItemModel('수상스키', false));
    _secialityEtc.add(new CheckboxItemModel('암벽등반', false));
    _secialityEtc.add(new CheckboxItemModel('번지점프', false));
    _secialityEtc.add(new CheckboxItemModel('낚시', false));
    _secialityEtc.add(new CheckboxItemModel('작곡', false));
    _secialityEtc.add(new CheckboxItemModel('작사', false));
  }

  _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _tabIndex = _tabController.index;
      });
    }
  }

  Widget tabSpecialityMusic() {
    return Container(
      margin: EdgeInsets.only(left: 15, right: 15, top: 10),
      child: Wrap(
        children: [
          GridView.count(
            childAspectRatio: 3,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 4,
            children: List.generate(_secialityMusic.length, (index) {
              return Container(
                  child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: _secialityMusic[index].isSelected,
                      onChanged: (value) {
                        setState(() {
                          _secialityMusic[index].isSelected = value;
                        });
                      },
                    ),
                  ),
                  Text(_secialityMusic[index].itemName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CustomStyles.normal14TextStyle())
                ],
              ));
            }),
          ),
        ],
      ),
    );
  }

  Widget tabSpecialityDance() {
    return Container(
      margin: EdgeInsets.only(left: 15, right: 15, top: 10),
      child: Wrap(
        children: [
          GridView.count(
            childAspectRatio: 3,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 4,
            children: List.generate(_secialityDance.length, (index) {
              return Container(
                  child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: _secialityDance[index].isSelected,
                      onChanged: (value) {
                        setState(() {
                          _secialityDance[index].isSelected = value;
                        });
                      },
                    ),
                  ),
                  Text(_secialityDance[index].itemName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CustomStyles.normal14TextStyle())
                ],
              ));
            }),
          ),
        ],
      ),
    );
  }

  Widget tabSpecialitySports() {
    return Container(
      margin: EdgeInsets.only(left: 15, right: 15, top: 10),
      child: Wrap(
        children: [
          GridView.count(
            childAspectRatio: 3,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 4,
            children: List.generate(_secialitySports.length, (index) {
              return Container(
                  child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: _secialitySports[index].isSelected,
                      onChanged: (value) {
                        setState(() {
                          _secialitySports[index].isSelected = value;
                        });
                      },
                    ),
                  ),
                  Text(_secialitySports[index].itemName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CustomStyles.normal14TextStyle())
                ],
              ));
            }),
          ),
        ],
      ),
    );
  }

  Widget tabSpecialityEtc() {
    return Container(
      margin: EdgeInsets.only(left: 15, right: 15, top: 10),
      child: Wrap(
        children: [
          GridView.count(
            childAspectRatio: 3,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 4,
            children: List.generate(_secialityEtc.length, (index) {
              return Container(
                  child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: _secialityEtc[index].isSelected,
                      onChanged: (value) {
                        setState(() {
                          _secialityEtc[index].isSelected = value;
                        });
                      },
                    ),
                  ),
                  Text(_secialityEtc[index].itemName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CustomStyles.normal14TextStyle())
                ],
              ));
            }),
          ),
        ],
      ),
    );
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
          appBar: CustomStyles.defaultAppBar('배역 추가', () {
            Navigator.pop(context);
          }),
          body: Builder(
            builder: (context) {
              return Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        flex: 1,
                        child: SingleChildScrollView(
                            child: Container(
                                padding: EdgeInsets.only(top: 30, bottom: 30),
                                child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                          padding: EdgeInsets.only(
                                              left: 15, right: 15),
                                          margin: EdgeInsets.only(top: 15),
                                          alignment: Alignment.centerLeft,
                                          child: Text('오디션 기간',
                                              style: CustomStyles
                                                  .bold14TextStyle())),
                                      Container(
                                        padding: EdgeInsets.only(
                                            left: 15, right: 15),
                                        margin: EdgeInsets.only(top: 5),
                                        child: Row(
                                          children: [
                                            Expanded(
                                                child: GestureDetector(
                                              onTap: () {
                                                showDatePickerForDday(context,
                                                    (date) {
                                                  setState(() {
                                                    var _birthY =
                                                        date.year.toString();
                                                    var _birthM = date.month
                                                        .toString()
                                                        .padLeft(2, '0');
                                                    var _birthD = date.day
                                                        .toString()
                                                        .padLeft(2, '0');

                                                    _startDate = _birthY +
                                                        '-' +
                                                        _birthM +
                                                        '-' +
                                                        _birthD;
                                                  });
                                                });
                                              },
                                              child: Container(
                                                  height: 48,
                                                  margin:
                                                      EdgeInsets.only(right: 5),
                                                  padding: EdgeInsets.all(5),
                                                  decoration: BoxDecoration(
                                                      borderRadius: CustomStyles
                                                          .circle7BorderRadius(),
                                                      border: Border.all(
                                                          width: 1,
                                                          color: CustomColors
                                                              .colorFontGrey)),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                        margin: EdgeInsets.only(
                                                            right: 10),
                                                        child: Icon(
                                                            Icons.date_range,
                                                            color: CustomColors
                                                                .colorFontTitle),
                                                      ),
                                                      Text(_startDate,
                                                          style: CustomStyles
                                                              .bold14TextStyle()),
                                                    ],
                                                  )),
                                            )),
                                            Container(
                                              margin: EdgeInsets.only(
                                                  left: 10, right: 10),
                                              child: Text('-',
                                                  style: CustomStyles
                                                      .normal16TextStyle()),
                                            ),
                                            Expanded(
                                                child: GestureDetector(
                                              onTap: () {
                                                showDatePickerForDday(context,
                                                    (date) {
                                                  setState(() {
                                                    var _birthY =
                                                        date.year.toString();
                                                    var _birthM = date.month
                                                        .toString()
                                                        .padLeft(2, '0');
                                                    var _birthD = date.day
                                                        .toString()
                                                        .padLeft(2, '0');

                                                    _endDate = _birthY +
                                                        '-' +
                                                        _birthM +
                                                        '-' +
                                                        _birthD;
                                                  });
                                                });
                                              },
                                              child: Container(
                                                  height: 48,
                                                  margin:
                                                      EdgeInsets.only(right: 5),
                                                  padding: EdgeInsets.all(5),
                                                  decoration: BoxDecoration(
                                                      borderRadius: CustomStyles
                                                          .circle7BorderRadius(),
                                                      border: Border.all(
                                                          width: 1,
                                                          color: CustomColors
                                                              .colorFontGrey)),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                        margin: EdgeInsets.only(
                                                            right: 10),
                                                        child: Icon(
                                                            Icons.date_range,
                                                            color: CustomColors
                                                                .colorFontTitle),
                                                      ),
                                                      Text(_endDate,
                                                          style: CustomStyles
                                                              .bold14TextStyle()),
                                                    ],
                                                  )),
                                            )),
                                          ],
                                        ),
                                      ),
                                      /*Container(
                                    margin: EdgeInsets.only(top: 0),
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Radio<int>(
                                            value: _agreeTerms,
                                            visualDensity:
                                                VisualDensity.compact,
                                            groupValue: 1,
                                            toggleable: true,
                                            onChanged: (_) {
                                              setState(() {
                                                if (_agreeTerms == 0) {
                                                  _agreeTerms = 1;
                                                } else {
                                                  _agreeTerms = 0;
                                                }
                                              });
                                            },
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                          ),
                                          Text('캐스팅 시 마감',
                                              style: CustomStyles
                                                  .normal14TextStyle())
                                        ])),*/
                                      Container(
                                          padding: EdgeInsets.only(
                                              left: 15, right: 15),
                                          margin: EdgeInsets.only(top: 15),
                                          alignment: Alignment.centerLeft,
                                          child: Text('배역 이름',
                                              style: CustomStyles
                                                  .bold14TextStyle())),
                                      Container(
                                          padding: EdgeInsets.only(
                                              left: 15, right: 15),
                                          margin: EdgeInsets.only(top: 5),
                                          child: CustomStyles
                                              .greyBorderRound7TextField(
                                                  _txtFieldCastingName, '')),
                                      Container(
                                          margin: EdgeInsets.only(top: 15),
                                          padding: EdgeInsets.only(
                                              left: 15, right: 15),
                                          alignment: Alignment.centerLeft,
                                          child: Text('배역',
                                              style: CustomStyles
                                                  .bold14TextStyle())),
                                      Container(
                                          margin: EdgeInsets.only(top: 5),
                                          padding: EdgeInsets.only(
                                              left: 15, right: 15),
                                          width: double.infinity,
                                          child: DropdownButtonFormField(
                                            value: _castingType,
                                            onChanged: (String newValue) {
                                              setState(() {
                                                _castingType = newValue;
                                              });
                                            },
                                            items: <String>[
                                              APIConstants.casting_type_1,
                                              APIConstants.casting_type_2,
                                              APIConstants.casting_type_3,
                                              APIConstants.casting_type_4
                                            ].map<DropdownMenuItem<String>>(
                                                (String value) {
                                              return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value,
                                                      style: CustomStyles
                                                          .normal14TextStyle()));
                                            }).toList(),
                                            decoration: InputDecoration(
                                              contentPadding: EdgeInsets.only(
                                                  left: 15,
                                                  right: 15,
                                                  top: 0,
                                                  bottom: 0),
                                              border: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: CustomColors
                                                          .colorFontGrey,
                                                      width: 1.0),
                                                  borderRadius: CustomStyles
                                                      .circle7BorderRadius()),
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: CustomColors
                                                          .colorFontGrey,
                                                      width: 1.0),
                                                  borderRadius: CustomStyles
                                                      .circle7BorderRadius()),
                                            ),
                                          )),
                                      Container(
                                          padding: EdgeInsets.only(
                                              left: 15, right: 15),
                                          margin: EdgeInsets.only(top: 15),
                                          alignment: Alignment.centerLeft,
                                          child: Text('배역수',
                                              style: CustomStyles
                                                  .bold14TextStyle())),
                                      Container(
                                          padding: EdgeInsets.only(
                                              left: 15, right: 15),
                                          margin: EdgeInsets.only(top: 5),
                                          child: CustomStyles
                                              .greyBorderRound7TextFieldWithOption(
                                                  _txtFieldCastingCnt,
                                                  TextInputType.number,
                                                  '')),
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: 25, bottom: 25),
                                        child: Divider(
                                          height: 0.1,
                                          color:
                                              CustomColors.colorFontLightGrey,
                                        ),
                                      ),
                                      Container(
                                          padding: EdgeInsets.only(
                                              left: 15, right: 15),
                                          alignment: Alignment.centerLeft,
                                          child: Text('성별',
                                              style: CustomStyles
                                                  .bold14TextStyle())),
                                      Container(
                                          width: double.infinity,
                                          margin: EdgeInsets.only(top: 5),
                                          padding: EdgeInsets.only(
                                              left: 15, right: 15),
                                          child: Row(
                                            children: <Widget>[
                                              Radio(
                                                visualDensity:
                                                    VisualDensity.compact,
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                value: 0,
                                                groupValue: _userGender,
                                                onChanged: (_) {
                                                  setState(() {
                                                    _userGender = 0;
                                                  });
                                                },
                                              ),
                                              Container(
                                                  margin: EdgeInsets.only(
                                                      right: 10),
                                                  child: Text('남자',
                                                      style: CustomStyles
                                                          .normal14TextStyle())),
                                              Radio(
                                                visualDensity:
                                                    VisualDensity.compact,
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                value: 1,
                                                groupValue: _userGender,
                                                onChanged: (_) {
                                                  setState(() {
                                                    _userGender = 1;
                                                  });
                                                },
                                              ),
                                              Container(
                                                  margin: EdgeInsets.only(
                                                      right: 10),
                                                  child: Text('여자',
                                                      style: CustomStyles
                                                          .normal14TextStyle())),
                                              Radio(
                                                visualDensity:
                                                    VisualDensity.compact,
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                value: 2,
                                                groupValue: _userGender,
                                                onChanged: (_) {
                                                  setState(() {
                                                    _userGender = 2;
                                                  });
                                                },
                                              ),
                                              Text('무관',
                                                  style: CustomStyles
                                                      .normal14TextStyle())
                                            ],
                                          )),
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: 25, bottom: 25),
                                        child: Divider(
                                          height: 0.1,
                                          color:
                                              CustomColors.colorFontLightGrey,
                                        ),
                                      ),
                                      Container(
                                          padding: EdgeInsets.only(
                                              left: 15, right: 15),
                                          alignment: Alignment.centerLeft,
                                          child: Text('나이',
                                              style: CustomStyles
                                                  .bold14TextStyle())),
                                      Container(
                                          margin: EdgeInsets.only(
                                              bottom: 10, top: 10),
                                          padding: EdgeInsets.only(
                                              left: 20, right: 20),
                                          child: Column(
                                            children: [
                                              Container(
                                                margin:
                                                    EdgeInsets.only(bottom: 5),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Container(
                                                        child: Text(
                                                            _ageRangeValues
                                                                    .start
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
                                                  ],
                                                ),
                                              ),
                                              SliderTheme(
                                                data: SliderTheme.of(context)
                                                    .copyWith(
                                                        trackHeight: 1,
                                                        thumbColor: CustomColors
                                                            .colorAccent,
                                                        rangeThumbShape:
                                                            CircleThumbShape(),
                                                        overlayShape:
                                                            RoundSliderOverlayShape(
                                                                overlayRadius:
                                                                    6.0)),
                                                child: RangeSlider(
                                                  inactiveColor:
                                                      CustomColors.colorBgGrey,
                                                  activeColor:
                                                      CustomColors.colorPrimary,
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
                                                        .toString(),
                                                  ),
                                                  onChanged:
                                                      (RangeValues values) {
                                                    setState(() {
                                                      _ageRangeValues = values;
                                                    });
                                                  },
                                                ),
                                              ),
                                              Container(
                                                margin:
                                                    EdgeInsets.only(top: 15),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      width: 24,
                                                      height: 24,
                                                      child: Radio<int>(
                                                        value: _isAgeLimit,
                                                        groupValue: 1,
                                                        toggleable: true,
                                                        onChanged: (_) {
                                                          setState(() {
                                                            if (_isAgeLimit ==
                                                                0) {
                                                              _isAgeLimit = 1;
                                                            } else {
                                                              _isAgeLimit = 0;
                                                            }
                                                          });
                                                        },
                                                        materialTapTargetSize:
                                                            MaterialTapTargetSize
                                                                .shrinkWrap,
                                                      ),
                                                    ),
                                                    Text('나이 무관',
                                                        style: CustomStyles
                                                            .dark16TextStyle())
                                                  ],
                                                ),
                                              )
                                            ],
                                          )),
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: 25, bottom: 25),
                                        child: Divider(
                                          height: 0.1,
                                          color:
                                              CustomColors.colorFontLightGrey,
                                        ),
                                      ),
                                      Container(
                                          padding: EdgeInsets.only(
                                              left: 15, right: 15),
                                          alignment: Alignment.centerLeft,
                                          child: Text('키',
                                              style: CustomStyles
                                                  .bold14TextStyle())),
                                      Container(
                                          margin: EdgeInsets.only(
                                              bottom: 10, top: 10),
                                          padding: EdgeInsets.only(
                                              left: 20, right: 20),
                                          child: Column(
                                            children: [
                                              Container(
                                                margin:
                                                    EdgeInsets.only(bottom: 5),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Container(
                                                        child: Text(
                                                            _heightRangeValues
                                                                    .start
                                                                    .round()
                                                                    .toString() +
                                                                'cm',
                                                            style: CustomStyles
                                                                .dark16TextStyle())),
                                                    Container(
                                                        child: Text(
                                                            _heightRangeValues
                                                                    .end
                                                                    .round()
                                                                    .toString() +
                                                                'cm',
                                                            style: CustomStyles
                                                                .dark16TextStyle())),
                                                  ],
                                                ),
                                              ),
                                              SliderTheme(
                                                data: SliderTheme.of(context)
                                                    .copyWith(
                                                        trackHeight: 1,
                                                        thumbColor: CustomColors
                                                            .colorAccent,
                                                        rangeThumbShape:
                                                            CircleThumbShape(),
                                                        overlayShape:
                                                            RoundSliderOverlayShape(
                                                                overlayRadius:
                                                                    6.0)),
                                                child: RangeSlider(
                                                  inactiveColor:
                                                      CustomColors.colorBgGrey,
                                                  activeColor:
                                                      CustomColors.colorPrimary,
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
                                                  onChanged:
                                                      (RangeValues values) {
                                                    setState(() {
                                                      _heightRangeValues =
                                                          values;
                                                    });
                                                  },
                                                ),
                                              ),
                                              Container(
                                                margin:
                                                    EdgeInsets.only(top: 15),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                        width: 24,
                                                        height: 24,
                                                        child: Radio<int>(
                                                          value: _isHeightLimit,
                                                          groupValue: 1,
                                                          toggleable: true,
                                                          onChanged: (_) {
                                                            setState(() {
                                                              if (_isHeightLimit ==
                                                                  0) {
                                                                _isHeightLimit =
                                                                    1;
                                                              } else {
                                                                _isHeightLimit =
                                                                    0;
                                                              }
                                                            });
                                                          },
                                                          materialTapTargetSize:
                                                              MaterialTapTargetSize
                                                                  .shrinkWrap,
                                                        )),
                                                    Text('키 무관',
                                                        style: CustomStyles
                                                            .dark16TextStyle())
                                                  ],
                                                ),
                                              )
                                            ],
                                          )),
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: 25, bottom: 25),
                                        child: Divider(
                                          height: 0.1,
                                          color:
                                              CustomColors.colorFontLightGrey,
                                        ),
                                      ),
                                      Container(
                                          padding: EdgeInsets.only(
                                              left: 15, right: 15),
                                          alignment: Alignment.centerLeft,
                                          child: Text('체중',
                                              style: CustomStyles
                                                  .bold14TextStyle())),
                                      Container(
                                          margin: EdgeInsets.only(
                                              bottom: 10, top: 10),
                                          padding: EdgeInsets.only(
                                              left: 20, right: 20),
                                          child: Column(
                                            children: [
                                              Container(
                                                margin:
                                                    EdgeInsets.only(bottom: 5),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Container(
                                                        child: Text(
                                                            _weightRangeValues
                                                                    .start
                                                                    .round()
                                                                    .toString() +
                                                                'kg',
                                                            style: CustomStyles
                                                                .dark16TextStyle())),
                                                    Container(
                                                        child: Text(
                                                            _weightRangeValues
                                                                    .end
                                                                    .round()
                                                                    .toString() +
                                                                'kg',
                                                            style: CustomStyles
                                                                .dark16TextStyle())),
                                                  ],
                                                ),
                                              ),
                                              SliderTheme(
                                                data: SliderTheme.of(context)
                                                    .copyWith(
                                                        trackHeight: 1,
                                                        thumbColor: CustomColors
                                                            .colorAccent,
                                                        rangeThumbShape:
                                                            CircleThumbShape(),
                                                        overlayShape:
                                                            RoundSliderOverlayShape(
                                                                overlayRadius:
                                                                    6.0)),
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
                                                        .toString(),
                                                  ),
                                                  onChanged:
                                                      (RangeValues values) {
                                                    setState(() {
                                                      _weightRangeValues =
                                                          values;
                                                    });
                                                  },
                                                ),
                                              ),
                                              Container(
                                                margin:
                                                    EdgeInsets.only(top: 15),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                        width: 24,
                                                        height: 24,
                                                        child: Radio<int>(
                                                          value: _isWeightLimit,
                                                          groupValue: 1,
                                                          toggleable: true,
                                                          onChanged: (_) {
                                                            setState(() {
                                                              if (_isWeightLimit ==
                                                                  0) {
                                                                _isWeightLimit =
                                                                    1;
                                                              } else {
                                                                _isWeightLimit =
                                                                    0;
                                                              }
                                                            });
                                                          },
                                                          materialTapTargetSize:
                                                              MaterialTapTargetSize
                                                                  .shrinkWrap,
                                                        )),
                                                    Text('체중 무관',
                                                        style: CustomStyles
                                                            .dark16TextStyle())
                                                  ],
                                                ),
                                              )
                                            ],
                                          )),
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: 25, bottom: 25),
                                        child: Divider(
                                          height: 0.1,
                                          color:
                                              CustomColors.colorFontLightGrey,
                                        ),
                                      ),
                                      Container(
                                          padding: EdgeInsets.only(
                                              left: 15, right: 15),
                                          alignment: Alignment.centerLeft,
                                          child: Text('연기전공',
                                              style: CustomStyles
                                                  .bold14TextStyle())),
                                      Container(
                                          width: double.infinity,
                                          margin: EdgeInsets.only(top: 5),
                                          padding: EdgeInsets.only(
                                              left: 15, right: 15),
                                          child: Row(
                                            children: <Widget>[
                                              Radio(
                                                visualDensity:
                                                    VisualDensity.compact,
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                value: 0,
                                                groupValue: _major,
                                                onChanged: (_) {
                                                  setState(() {
                                                    _major = 0;
                                                  });
                                                },
                                              ),
                                              Container(
                                                margin:
                                                    EdgeInsets.only(right: 10),
                                                child: Text('전공',
                                                    style: CustomStyles
                                                        .bold14TextStyle()),
                                              ),
                                              Radio(
                                                visualDensity:
                                                    VisualDensity.compact,
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                value: 1,
                                                groupValue: _major,
                                                onChanged: (_) {
                                                  setState(() {
                                                    _major = 1;
                                                  });
                                                },
                                              ),
                                              Container(
                                                margin:
                                                    EdgeInsets.only(right: 10),
                                                child: Text('비전공',
                                                    style: CustomStyles
                                                        .bold14TextStyle()),
                                              ),
                                              Radio(
                                                visualDensity:
                                                    VisualDensity.compact,
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                value: 2,
                                                groupValue: _major,
                                                onChanged: (_) {
                                                  setState(() {
                                                    _major = 2;
                                                  });
                                                },
                                              ),
                                              Text('전공무관',
                                                  style: CustomStyles
                                                      .bold14TextStyle())
                                            ],
                                          )),
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: 25, bottom: 25),
                                        child: Divider(
                                          height: 0.1,
                                          color:
                                              CustomColors.colorFontLightGrey,
                                        ),
                                      ),
                                      Container(
                                          padding: EdgeInsets.only(
                                              left: 15, right: 15),
                                          alignment: Alignment.centerLeft,
                                          child: Text('언어',
                                              style: CustomStyles
                                                  .bold14TextStyle())),
                                      Wrap(
                                        children: [
                                          GridView.count(
                                            childAspectRatio: 3,
                                            padding: EdgeInsets.only(
                                                left: 15, right: 10),
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            crossAxisCount: 4,
                                            children: List.generate(
                                                _languages.length, (index) {
                                              return Container(
                                                  child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SizedBox(
                                                    width: 24,
                                                    height: 24,
                                                    child: Checkbox(
                                                      materialTapTargetSize:
                                                          MaterialTapTargetSize
                                                              .shrinkWrap,
                                                      value: _languages[index]
                                                          .isSelected,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          _languages[index]
                                                                  .isSelected =
                                                              value;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                  Text(
                                                      _languages[index]
                                                          .itemName,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: CustomStyles
                                                          .normal14TextStyle())
                                                ],
                                              ));
                                            }),
                                          ),
                                        ],
                                      ),
                                      Container(
                                          padding: EdgeInsets.only(
                                              left: 15, right: 15),
                                          margin: EdgeInsets.only(top: 15),
                                          alignment: Alignment.centerLeft,
                                          child: Text('사투리',
                                              style: CustomStyles
                                                  .bold14TextStyle())),
                                      Wrap(
                                        children: [
                                          GridView.count(
                                            childAspectRatio: 3,
                                            padding: EdgeInsets.only(
                                                left: 15, right: 10),
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            crossAxisCount: 4,
                                            children: List.generate(
                                                _dialect.length, (index) {
                                              return Container(
                                                  child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SizedBox(
                                                    width: 24,
                                                    height: 24,
                                                    child: Checkbox(
                                                      materialTapTargetSize:
                                                          MaterialTapTargetSize
                                                              .shrinkWrap,
                                                      value: _dialect[index]
                                                          .isSelected,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          _dialect[index]
                                                                  .isSelected =
                                                              value;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                  Text(_dialect[index].itemName,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: CustomStyles
                                                          .normal14TextStyle())
                                                ],
                                              ));
                                            }),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: 25, bottom: 25),
                                        child: Divider(
                                          height: 0.1,
                                          color:
                                              CustomColors.colorFontLightGrey,
                                        ),
                                      ),
                                      Container(
                                          padding: EdgeInsets.only(
                                              left: 15, right: 15),
                                          alignment: Alignment.centerLeft,
                                          child: Text('특기',
                                              style: CustomStyles
                                                  .bold14TextStyle())),
                                      Container(
                                          margin: EdgeInsets.only(top: 5),
                                          width:
                                              MediaQuery.of(context).size.width,
                                          color: CustomColors.colorWhite,
                                          child: TabBar(
                                              controller: _tabController,
                                              indicatorSize:
                                                  TabBarIndicatorSize.label,
                                              indicatorPadding: EdgeInsets.zero,
                                              labelStyle: CustomStyles
                                                  .bold14TextStyle(),
                                              unselectedLabelStyle: CustomStyles
                                                  .normal14TextStyle(),
                                              tabs: [
                                                Tab(text: '음악'),
                                                Tab(text: '춤'),
                                                Tab(text: '스포츠'),
                                                Tab(text: '기타')
                                              ])),
                                      Expanded(
                                        flex: 0,
                                        child: [
                                          tabSpecialityMusic(),
                                          tabSpecialityDance(),
                                          tabSpecialitySports(),
                                          tabSpecialityEtc()
                                        ][_tabIndex],
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: 25, bottom: 25),
                                        child: Divider(
                                          height: 0.1,
                                          color:
                                              CustomColors.colorFontLightGrey,
                                        ),
                                      ),
                                      Container(
                                          padding: EdgeInsets.only(
                                              left: 15, right: 15),
                                          alignment: Alignment.centerLeft,
                                          child: Text('캐릭터 소개',
                                              style: CustomStyles
                                                  .bold14TextStyle())),
                                      Container(
                                        margin: EdgeInsets.only(top: 5),
                                        padding: EdgeInsets.only(
                                            left: 15, right: 15),
                                        child: TextField(
                                          maxLines: 8,
                                          controller: _txtFieldCastingIntroduce,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 10,
                                                    horizontal: 10),
                                            hintText: "",
                                            hintStyle:
                                                CustomStyles.light14TextStyle(),
                                            border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: CustomColors
                                                        .colorFontLightGrey,
                                                    width: 1.0),
                                                borderRadius: CustomStyles
                                                    .circle7BorderRadius()),
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: CustomColors
                                                        .colorFontLightGrey,
                                                    width: 1.0),
                                                borderRadius: CustomStyles
                                                    .circle7BorderRadius()),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: 25, bottom: 25),
                                        child: Divider(
                                          height: 0.1,
                                          color:
                                              CustomColors.colorFontLightGrey,
                                        ),
                                      ),
                                      Container(
                                          padding: EdgeInsets.only(
                                              left: 15, right: 15),
                                          alignment: Alignment.centerLeft,
                                          child: Text('특이사항',
                                              style: CustomStyles
                                                  .bold14TextStyle())),
                                      Container(
                                        margin: EdgeInsets.only(top: 5),
                                        padding: EdgeInsets.only(
                                            left: 15, right: 15),
                                        child: TextField(
                                          maxLines: 8,
                                          controller:
                                              _txtFieldCastingUniqueness,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 10,
                                                    horizontal: 10),
                                            hintText: "",
                                            hintStyle:
                                                CustomStyles.light14TextStyle(),
                                            border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: CustomColors
                                                        .colorFontLightGrey,
                                                    width: 1.0),
                                                borderRadius: CustomStyles
                                                    .circle7BorderRadius()),
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: CustomColors
                                                        .colorFontLightGrey,
                                                    width: 1.0),
                                                borderRadius: CustomStyles
                                                    .circle7BorderRadius()),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: 25, bottom: 25),
                                        child: Divider(
                                          height: 0.1,
                                          color:
                                              CustomColors.colorFontLightGrey,
                                        ),
                                      ),
                                      Container(
                                          padding: EdgeInsets.only(
                                              left: 15, right: 15),
                                          alignment: Alignment.centerLeft,
                                          child: Text('페이',
                                              style: CustomStyles
                                                  .bold14TextStyle())),
                                      Container(
                                          padding: EdgeInsets.only(
                                              left: 15, right: 15),
                                          margin: EdgeInsets.only(top: 5),
                                          child: CustomStyles
                                              .greyBorderRound7TextFieldWithOption(
                                                  _txtFieldCastingPay,
                                                  TextInputType.number,
                                                  '만원 단위로 입력해 주세요.')),
                                      Container(
                                        padding: EdgeInsets.only(
                                            left: 15, right: 15),
                                        margin: EdgeInsets.only(top: 5),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: Radio<int>(
                                                value: _isPayLimit,
                                                groupValue: 1,
                                                toggleable: true,
                                                onChanged: (_) {
                                                  setState(() {
                                                    if (_isPayLimit == 0) {
                                                      _isPayLimit = 1;
                                                    } else {
                                                      _isPayLimit = 0;
                                                    }
                                                  });
                                                },
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                              ),
                                            ),
                                            Text('협의 후 결정',
                                                style: CustomStyles
                                                    .dark16TextStyle())
                                          ],
                                        ),
                                      )
                                    ])))),
                    Container(
                        width: double.infinity,
                        height: 55,
                        color: Colors.grey,
                        child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 55,
                            child: CustomStyles.blueBGSquareButtonStyle('배역 추가',
                                () {
                              if (checkValidate(context)) {
                                requestAddFilmographyApi(context);
                              }
                            })))
                  ],
                ),
              );
            },
          )),
    );
  }

  /*
  * 입력 데이터 유효성 검사
  * */
  bool checkValidate(BuildContext context) {
    if (StringUtils.isEmpty(_txtFieldCastingName.text)) {
      showSnackBar(context, '이용약관에 동의해 주세요.');
      return false;
    }

    if (StringUtils.isEmpty(_txtFieldCastingCnt.text)) {
      showSnackBar(context, '배역 수를 입력해 주세요.');
      return false;
    }

    if (StringUtils.isEmpty(_txtFieldCastingIntroduce.text)) {
      showSnackBar(context, '캐릭터 소개글을 입력해 주세요.');
      return false;
    }

    if (StringUtils.isEmpty(_txtFieldCastingUniqueness.text)) {
      showSnackBar(context, '특이사항을 입력해 주세요.');
      return false;
    }

    if (_isPayLimit == 0) {
      if (StringUtils.isEmpty(_txtFieldCastingPay.text)) {
        showSnackBar(context, '페이를 입력해 주세요.');
        return false;
      }
    }

    return true;
  }

  /*
  * 캐스팅 추가
  * */
  void requestAddFilmographyApi(BuildContext context) {
    final dio = Dio();

    // 캐스팅 추가 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetData = new Map();

    /*
    * casting_target
    * */
    Map<String, dynamic> castingTargetDatas = new Map();
    castingTargetDatas[APIConstants.production_seq] =
        KCastingAppData().myInfo[APIConstants.seq];
    castingTargetDatas[APIConstants.project_seq] = _projectSeq;
    castingTargetDatas[APIConstants.isMainRole] = 1;
    castingTargetDatas[APIConstants.casting_name] = _txtFieldCastingName.text;
    castingTargetDatas[APIConstants.casting_type] = _castingType;
    castingTargetDatas[APIConstants.casting_count] = _txtFieldCastingCnt.text;
    castingTargetDatas[APIConstants.sex_type] =
        (_userGender == 0) ? "남자" : ((_userGender == 1) ? "여자" : "무관");
    if (_isAgeLimit != 1) {
      castingTargetDatas[APIConstants.casting_min_age] =
          _ageRangeValues.start.toInt();
      castingTargetDatas[APIConstants.casting_max_age] =
          _ageRangeValues.end.toInt();
    }
    if (_isHeightLimit != 1) {
      castingTargetDatas[APIConstants.casting_min_tall] =
          _heightRangeValues.start.toInt();
      castingTargetDatas[APIConstants.casting_max_tall] =
          _heightRangeValues.end.toInt();
    }
    if (_isWeightLimit != 1) {
      castingTargetDatas[APIConstants.casting_min_weight] =
          _weightRangeValues.start.toInt();
      castingTargetDatas[APIConstants.casting_max_weight] =
          _weightRangeValues.end.toInt();
    }
    castingTargetDatas[APIConstants.major_type] =
        (_major == 0) ? "전공" : ((_major == 0) ? "비전공" : "무관");
    castingTargetDatas[APIConstants.casting_Introduce] =
        _txtFieldCastingIntroduce.text;
    castingTargetDatas[APIConstants.casting_uniqueness] =
        _txtFieldCastingUniqueness.text;
    if (_isPayLimit != 1) {
      castingTargetDatas[APIConstants.casting_pay] = _txtFieldCastingPay.text;
    }

    targetData[APIConstants.casting_target] = castingTargetDatas;

    /*
    * languge_target
    * */
    List<Map<String, dynamic>> languageTargetDatas = [];

    for (int i = 0; i < _languages.length; i++) {
      if (_languages[i].isSelected) {
        Map<String, dynamic> actorLanguage = new Map();
        actorLanguage[APIConstants.language_type] = _languages[i].itemName;

        languageTargetDatas.add(actorLanguage);
      }
    }

    if (languageTargetDatas.length > 0)
      targetData[APIConstants.languge_target] = languageTargetDatas;

    /*
    * dialect_target
    * */
    List<Map<String, dynamic>> dialectTargetDatas = [];

    for (int i = 0; i < _dialect.length; i++) {
      if (_dialect[i].isSelected) {
        Map<String, dynamic> actorDialect = new Map();
        actorDialect[APIConstants.dialect_type] = _dialect[i].itemName;

        dialectTargetDatas.add(actorDialect);
      }
    }

    if (dialectTargetDatas.length > 0)
      targetData[APIConstants.dialect_target] = dialectTargetDatas;

    /*
    * ability_target
    * */
    List<Map<String, dynamic>> abilityTargetDatas = [];

    for (int i = 0; i < _secialityMusic.length; i++) {
      if (_secialityMusic[i].isSelected) {
        Map<String, dynamic> data = new Map();
        data[APIConstants.parentType] = "음악";
        data[APIConstants.child_type] = _secialityMusic[i].itemName;

        abilityTargetDatas.add(data);
      }
    }

    for (int i = 0; i < _secialityDance.length; i++) {
      if (_secialityDance[i].isSelected) {
        Map<String, dynamic> data = new Map();
        data[APIConstants.parentType] = "춤";
        data[APIConstants.child_type] = _secialityDance[i].itemName;

        abilityTargetDatas.add(data);
      }
    }

    for (int i = 0; i < _secialitySports.length; i++) {
      if (_secialitySports[i].isSelected) {
        Map<String, dynamic> data = new Map();
        data[APIConstants.parentType] = "스포츠";
        data[APIConstants.child_type] = _secialitySports[i].itemName;

        abilityTargetDatas.add(data);
      }
    }

    for (int i = 0; i < _secialityEtc.length; i++) {
      if (_secialityEtc[i].isSelected) {
        Map<String, dynamic> data = new Map();
        data[APIConstants.parentType] = "기타";
        data[APIConstants.child_type] = _secialityEtc[i].itemName;

        abilityTargetDatas.add(data);
      }
    }

    if (abilityTargetDatas.length > 0)
      targetData[APIConstants.ability_target] = abilityTargetDatas;

    /*
    * firstAudition_target
    * */
    Map<String, dynamic> targetFirstAuditionData = new Map();
    targetFirstAuditionData[APIConstants.firstautidion_startdate] = _startDate;
    targetFirstAuditionData[APIConstants.firstautidion_enddate] = _endDate;
    targetFirstAuditionData[APIConstants.state_type] = "진행중";

    List<Map<String, dynamic>> targetFirstAuditionDatas = [];
    targetFirstAuditionDatas.add(targetFirstAuditionData);

    targetData[APIConstants.firstAudition_target] = targetFirstAuditionDatas;

    Map<String, dynamic> _params = new Map();
    _params[APIConstants.key] = APIConstants.IPC_PCT_INFO;
    _params[APIConstants.target] = targetData;

    // 캐스팅 추가 api 호출
    RestClient(dio).postRequestMainControl(_params).then((value) async {
      if (value == null) {
        // 에러 - 데이터 널
        showSnackBar(context, APIConstants.error_msg_server_not_response);
      } else {
        if (value[APIConstants.resultVal]) {
          try {
            // 캐스팅 추가 성공
            //var _responseList = value[APIConstants.data];
            showSnackBar(context, "배역이 추가되었습니다.");
            Navigator.pop(context);
          } catch (e) {
            showSnackBar(context, APIConstants.error_msg_try_again);
          }
        } else {
          // 캐스팅 추가 실패
          showSnackBar(context, APIConstants.error_msg_try_again);
        }
      }
    });
  }
}
