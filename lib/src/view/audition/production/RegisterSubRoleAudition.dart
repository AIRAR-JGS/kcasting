import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';

import '../../../../KCastingAppData.dart';

class RegisterSubRoleAudition extends StatefulWidget {
  final int projectSeq;

  const RegisterSubRoleAudition({Key key, this.projectSeq}) : super(key: key);

  @override
  _RegisterSubRoleAudition createState() => _RegisterSubRoleAudition();
}

class _RegisterSubRoleAudition extends State<RegisterSubRoleAudition>
    with SingleTickerProviderStateMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  int _projectSeq;

  int _isPayLimit = 0;

  String _startDate = '2021.03.29';
  String _endDate = '2021.08.29';

  final _txtFieldCastingName = TextEditingController();
  final _txtFieldCastingIntroduce = TextEditingController();
  final _txtFieldCastingCnt = TextEditingController();
  final _txtFieldCastingPay = TextEditingController();

  @override
  void initState() {
    super.initState();

    _projectSeq = widget.projectSeq;

    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);

    _startDate = formattedDate;
    _endDate = formattedDate;
  }

  // DatePicker(회원가입 시 생년월일 선택하는 컴포넌트)
  void _showDatePicker(int type) {
    DatePicker.showDatePicker(context,
        showTitleActions: true,
        minTime: DateTime.now(),
        maxTime: DateTime(2031, 1, 1),
        theme: DatePickerTheme(
            headerColor: CustomColors.colorWhite,
            backgroundColor: CustomColors.colorWhite,
            itemStyle: TextStyle(
                color: CustomColors.colorFontGrey,
                fontWeight: FontWeight.bold,
                fontSize: 15),
            doneStyle:
                TextStyle(color: CustomColors.colorFontGrey, fontSize: 13),
            cancelStyle:
                TextStyle(color: CustomColors.colorFontGrey, fontSize: 13)),
        onChanged: (date) {}, onConfirm: (date) {
      setState(() {
        var _yy = date.year.toString();
        var _mm = date.month.toString().padLeft(2, '0');
        var _dd = date.day.toString().padLeft(2, '0');

        var _selectDate = _yy + '-' + _mm + '-' + _dd;

        if (type == 0) {
          _startDate = _selectDate;
        } else {
          _endDate = _selectDate;
        }
      });
    }, currentTime: DateTime.now(), locale: LocaleType.ko);
  }

  void showSnackBar(context, String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  //========================================================================================================================
  // 메인 위젯
  //========================================================================================================================
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
                                                _showDatePicker(0);
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
                                                _showDatePicker(1);
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
                                          padding: EdgeInsets.only(
                                              left: 15, right: 15),
                                          alignment: Alignment.centerLeft,
                                          margin: EdgeInsets.only(top: 15),
                                          child: Text('배역설명',
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
                                            hintText:
                                                "단역과 엑스트라로 들어갈 배우들 모집합니다.",
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
                                          padding: EdgeInsets.only(
                                              left: 15, right: 15),
                                          alignment: Alignment.centerLeft,
                                          margin: EdgeInsets.only(top: 15),
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

  //========================================================================================================================
  // 입력 데이터 유효성 검사
  //========================================================================================================================
  bool checkValidate(BuildContext context) {
    if (StringUtils.isEmpty(_txtFieldCastingName.text)) {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('배역 이름을 입력해 주세요.')));
      return false;
    }

    if (StringUtils.isEmpty(_txtFieldCastingCnt.text)) {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('배역 수를 입력해 주세요.')));
      return false;
    }

    if (StringUtils.isEmpty(_txtFieldCastingIntroduce.text)) {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('캐릭터 소개글을 입력해 주세요.')));
      return false;
    }

    if (_isPayLimit == 0) {
      if (StringUtils.isEmpty(_txtFieldCastingPay.text)) {
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text('페이를 입력해 주세요.')));
        return false;
      }
    }
    //

    return true;
  }

  //========================================================================================================================
  // 캐스팅 추가
  //========================================================================================================================
  void requestAddFilmographyApi(BuildContext context) {
    final dio = Dio();

    // 캐스팅 추가 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetData = new Map();

    Map<String, dynamic> castingTargetDatas = new Map();
    castingTargetDatas[APIConstants.production_seq] =
        KCastingAppData().myInfo[APIConstants.seq];
    castingTargetDatas[APIConstants.project_seq] = _projectSeq;
    castingTargetDatas[APIConstants.isMainRole] = 0;
    castingTargetDatas[APIConstants.casting_name] = _txtFieldCastingName.text;
    castingTargetDatas[APIConstants.casting_type] = APIConstants.casting_type_4;
    castingTargetDatas[APIConstants.casting_count] = _txtFieldCastingCnt.text;
    castingTargetDatas[APIConstants.sex_type] = "무관";
    castingTargetDatas[APIConstants.casting_min_age] = null;
    castingTargetDatas[APIConstants.casting_max_age] = null;
    castingTargetDatas[APIConstants.casting_min_tall] = null;
    castingTargetDatas[APIConstants.casting_max_tall] = null;
    castingTargetDatas[APIConstants.casting_min_weight] = null;
    castingTargetDatas[APIConstants.casting_max_weight] = null;
    castingTargetDatas[APIConstants.major_type] = "무관";
    castingTargetDatas[APIConstants.casting_Introduce] =
        _txtFieldCastingIntroduce.text;
    castingTargetDatas[APIConstants.casting_uniqueness] = null;
    if (_isPayLimit == 1) {
      castingTargetDatas[APIConstants.casting_pay] = null;
    } else {
      castingTargetDatas[APIConstants.casting_pay] = _txtFieldCastingPay.text;
    }

    targetData[APIConstants.casting_target] = castingTargetDatas;

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
