import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/model/EducationListModel.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:casting_call/src/view/mypage/management/RegisterAgencyActorProfileSubInfo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../KCastingAppData.dart';
import 'AgencyActorList.dart';

/*
* 보유 배우 프로필 추가 - 1
* */
class RegisterAgencyActorProfileMainInfo extends StatefulWidget {
  final String name;
  final String gender;

  const RegisterAgencyActorProfileMainInfo({Key key, this.name, this.gender})
      : super(key: key);

  @override
  _RegisterAgencyActorProfileMainInfo createState() =>
      _RegisterAgencyActorProfileMainInfo();
}

class _RegisterAgencyActorProfileMainInfo
    extends State<RegisterAgencyActorProfileMainInfo> with BaseUtilMixin {
  String _name;
  String _gender;

  final _txtFieldName = TextEditingController();
  final _txtFieldIntroduce = TextEditingController();
  final _txtFieldDramaPay = TextEditingController();
  final _txtFieldMoviePay = TextEditingController();
  final _txtFieldTall = TextEditingController();
  final _txtFieldWeight = TextEditingController();

  List<Map<UniqueKey, EducationListModel>> _educationList = [];

  String _birthY = '2000';
  String _birthM = '01';
  String _birthD = '01';
  String _birthDate = '2000-01-01';

  int _major = 0;

  List<Widget> _educationWidgets = [];

  @override
  void initState() {
    super.initState();

    _name = widget.name;
    _gender = widget.gender;

    _txtFieldName.text = _name;
  }

  Widget educationHistory(var uniqueKey) {
    int idx;

    for (int i = 0; i < _educationList.length; i++) {
      Map<UniqueKey, EducationListModel> item = _educationList[i];

      if (item.containsKey(uniqueKey)) {
        idx = i;
      }
    }

    return Column(
      key: uniqueKey,
      children: [
        Container(
          margin: EdgeInsets.only(top: 20, bottom: 10),
          child: Divider(
            height: 0.1,
            color: CustomColors.colorFontLightGrey,
          ),
        ),
        Container(
            margin: EdgeInsets.only(top: 5),
            padding: EdgeInsets.only(left: 15, right: 15),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Expanded(
                  child:
                      Text('학력사항', style: CustomStyles.darkBold14TextStyle()),
                ),
                Expanded(
                    flex: 0,
                    child: GestureDetector(
                        onTap: () {
                          setState(() {
                            for (int i = 0; i < _educationWidgets.length; i++) {
                              if (_educationWidgets[i].key == uniqueKey) {
                                _educationWidgets.removeAt(i);
                              }
                            }

                            for (int i = 0; i < _educationList.length; i++) {
                              Map<UniqueKey, EducationListModel> item =
                                  _educationList[i];

                              if (item.containsKey(uniqueKey)) {
                                _educationList.removeAt(i);
                              }
                            }
                          });
                        },
                        child: Icon(Icons.close)))
              ],
            )),
        Container(
          margin: EdgeInsets.only(top: 20, bottom: 10),
          child: Divider(
            height: 0.1,
            color: CustomColors.colorFontLightGrey,
          ),
        ),
        Container(
            margin: EdgeInsets.only(top: 5),
            padding: EdgeInsets.only(left: 15, right: 15),
            alignment: Alignment.centerLeft,
            child: Row(children: [
              Expanded(
                  flex: 2,
                  child: Text('학교', style: CustomStyles.darkBold14TextStyle())),
              Expanded(
                  flex: 5,
                  child: Container(
                      margin: EdgeInsets.only(left: 10),
                      child: Text('학교명',
                          style: CustomStyles.darkBold14TextStyle())))
            ])),
        Container(
            padding: EdgeInsets.only(left: 15, right: 15),
            margin: EdgeInsets.only(top: 5),
            child: Row(children: [
              Expanded(
                  flex: 2,
                  child: DropdownButtonFormField(
                      value: (_educationList[idx])[uniqueKey].educationType,
                      onChanged: (String newValue) {
                        setState(() {
                          (_educationList[idx])[uniqueKey].educationType =
                              newValue;
                        });
                      },
                      items: <String>['대학교', '대학원', '전문대']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value,
                                style: CustomStyles.dark16TextStyle()));
                      }).toList(),
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: CustomColors.colorFontGrey,
                                  width: 1.0),
                              borderRadius: CustomStyles.circle7BorderRadius()),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10)))),
              Expanded(
                  flex: 5,
                  child: Container(
                      margin: EdgeInsets.only(left: 5),
                      child: CustomStyles.greyBorderRound7TextField(
                          (_educationList[idx])[uniqueKey].educationName,
                          '학교명')))
            ])),
        Container(
            margin: EdgeInsets.only(top: 15),
            padding: EdgeInsets.only(left: 15, right: 15),
            alignment: Alignment.centerLeft,
            child: Text('전공', style: CustomStyles.darkBold14TextStyle())),
        Container(
            padding: EdgeInsets.only(left: 15, right: 15),
            margin: EdgeInsets.only(top: 5),
            child: CustomStyles.greyBorderRound7TextField(
                (_educationList[idx])[uniqueKey].majorName, '전공명'))
      ],
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
        appBar: CustomStyles.defaultAppBar('프로필 편집', () {
          addView(context, AgencyActorList());
        }),
        body: Container(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                flex: 1,
                child: SingleChildScrollView(
                    child: Container(
                        child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                      Container(
                          margin: EdgeInsets.only(top: 20),
                          padding: EdgeInsets.only(left: 15, right: 15),
                          alignment: Alignment.centerLeft,
                          child: Text('활동명',
                              style: CustomStyles.bold14TextStyle())),
                      Container(
                          padding: EdgeInsets.only(left: 15, right: 15),
                          margin: EdgeInsets.only(top: 5),
                          child: CustomStyles.greyBorderRound7TextField(
                              _txtFieldName, '')),
                      Container(
                          margin: EdgeInsets.only(top: 15),
                          padding: EdgeInsets.only(left: 15, right: 15),
                          alignment: Alignment.centerLeft,
                          child: Text('자기소개',
                              style: CustomStyles.bold14TextStyle())),
                      Container(
                          padding: EdgeInsets.only(left: 15, right: 15),
                          margin: EdgeInsets.only(top: 5),
                          child: TextField(
                            maxLines: 3,
                            controller: _txtFieldIntroduce,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 15),
                              hintText: '작품에 대해 성실하게 몰입하고 참여합니다.',
                              hintStyle: TextStyle(
                                  fontSize: 16,
                                  color: CustomColors.colorFontLightGrey),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: CustomColors.colorFontGrey,
                                      width: 1.0),
                                  borderRadius:
                                      CustomStyles.circle7BorderRadius()),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: CustomColors.colorFontGrey,
                                      width: 1.0),
                                  borderRadius:
                                      CustomStyles.circle7BorderRadius()),
                            ),
                            style: CustomStyles.normal16TextStyle(),
                          )),
                      Container(
                          margin: EdgeInsets.only(top: 15),
                          padding: EdgeInsets.only(left: 15, right: 15),
                          alignment: Alignment.centerLeft,
                          child: Text('드라마 페이',
                              style: CustomStyles.bold14TextStyle())),
                      Container(
                          padding: EdgeInsets.only(left: 15, right: 15),
                          margin: EdgeInsets.only(top: 5),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: CustomStyles
                                      .greyBorderRound7TextFieldWithOption(
                                          _txtFieldDramaPay,
                                          TextInputType.number,
                                          '')),
                              Expanded(
                                flex: 0,
                                child: Container(
                                  margin: EdgeInsets.only(left: 5),
                                  child: Text('만원',
                                      style: CustomStyles.bold14TextStyle()),
                                ),
                              )
                            ],
                          )),
                      Container(
                          margin: EdgeInsets.only(top: 15),
                          padding: EdgeInsets.only(left: 15, right: 15),
                          alignment: Alignment.centerLeft,
                          child: Text('영화 페이',
                              style: CustomStyles.bold14TextStyle())),
                      Container(
                          padding: EdgeInsets.only(left: 15, right: 15),
                          margin: EdgeInsets.only(top: 5),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: CustomStyles
                                      .greyBorderRound7TextFieldWithOption(
                                          _txtFieldMoviePay,
                                          TextInputType.number,
                                          '')),
                              Expanded(
                                flex: 0,
                                child: Container(
                                  margin: EdgeInsets.only(left: 5),
                                  child: Text('만원',
                                      style: CustomStyles.bold14TextStyle()),
                                ),
                              )
                            ],
                          )),
                      Container(
                          margin: EdgeInsets.only(top: 15),
                          padding: EdgeInsets.only(left: 15, right: 15),
                          alignment: Alignment.centerLeft,
                          child: Text('생년월일',
                              style: CustomStyles.bold14TextStyle())),
                      Container(
                          padding: EdgeInsets.only(left: 15, right: 15),
                          margin: EdgeInsets.only(top: 5),
                          child: GestureDetector(
                            onTap: () {
                              showDatePickerForBirthDay(context, (date) {
                                setState(() {
                                  _birthY = date.year.toString();
                                  _birthM =
                                      date.month.toString().padLeft(2, '0');
                                  _birthD = date.day.toString().padLeft(2, '0');

                                  _birthDate = date.year.toString() +
                                      '-' +
                                      date.month.toString() +
                                      '-' +
                                      date.day.toString();
                                });
                              });
                            },
                            child: Row(
                              children: [
                                Expanded(
                                    child: Container(
                                        height: 48,
                                        margin: EdgeInsets.only(right: 5),
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            borderRadius: CustomStyles
                                                .circle7BorderRadius(),
                                            border: Border.all(
                                                width: 1,
                                                color: CustomColors
                                                    .colorFontGrey)),
                                        child: GestureDetector(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(_birthY,
                                                  style: CustomStyles
                                                      .bold14TextStyle()),
                                              Icon(Icons.arrow_drop_down),
                                            ],
                                          ),
                                        ))),
                                Expanded(
                                    child: Container(
                                        height: 48,
                                        margin: EdgeInsets.only(right: 5),
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            borderRadius: CustomStyles
                                                .circle7BorderRadius(),
                                            border: Border.all(
                                                width: 1,
                                                color: CustomColors
                                                    .colorFontGrey)),
                                        child: GestureDetector(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(_birthM,
                                                  style: CustomStyles
                                                      .bold14TextStyle()),
                                              Icon(Icons.arrow_drop_down),
                                            ],
                                          ),
                                        ))),
                                Expanded(
                                    child: Container(
                                        height: 48,
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            borderRadius: CustomStyles
                                                .circle7BorderRadius(),
                                            border: Border.all(
                                                width: 1,
                                                color: CustomColors
                                                    .colorFontGrey)),
                                        child: GestureDetector(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(_birthD,
                                                  style: CustomStyles
                                                      .bold14TextStyle()),
                                              Icon(Icons.arrow_drop_down),
                                            ],
                                          ),
                                        ))),
                              ],
                            ),
                          )),
                      Container(
                        margin: EdgeInsets.only(top: 20, bottom: 10),
                        child: Divider(
                          height: 0.1,
                          color: CustomColors.colorFontLightGrey,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 5),
                        padding: EdgeInsets.only(left: 15, right: 15),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Expanded(
                                child: Text('키',
                                    style: CustomStyles.bold14TextStyle())),
                            Expanded(
                                child: Container(
                                    margin: EdgeInsets.only(left: 10),
                                    child: Text('체중',
                                        style: CustomStyles.bold14TextStyle())))
                          ],
                        ),
                      ),
                      Container(
                          padding: EdgeInsets.only(left: 15, right: 15),
                          margin: EdgeInsets.only(top: 5),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: CustomStyles
                                      .greyBorderRound7TextFieldWithOption(
                                          _txtFieldTall,
                                          TextInputType.number,
                                          '')),
                              Expanded(
                                flex: 0,
                                child: Container(
                                  margin: EdgeInsets.only(left: 5, right: 5),
                                  child: Text('cm',
                                      style: CustomStyles.bold14TextStyle()),
                                ),
                              ),
                              Expanded(
                                  flex: 1,
                                  child: Container(
                                      margin: EdgeInsets.only(left: 5),
                                      child: CustomStyles
                                          .greyBorderRound7TextFieldWithOption(
                                              _txtFieldWeight,
                                              TextInputType.number,
                                              ''))),
                              Expanded(
                                flex: 0,
                                child: Container(
                                  margin: EdgeInsets.only(left: 5),
                                  child: Text('kg',
                                      style: CustomStyles.bold14TextStyle()),
                                ),
                              )
                            ],
                          )),
                      Container(
                        margin: EdgeInsets.only(top: 20, bottom: 10),
                        child: Divider(
                          height: 0.1,
                          color: CustomColors.colorFontLightGrey,
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.only(top: 5),
                          padding: EdgeInsets.only(left: 15, right: 15),
                          alignment: Alignment.centerLeft,
                          child: Text('전공여부',
                              style: CustomStyles.bold14TextStyle())),
                      Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(top: 5),
                          padding: EdgeInsets.only(left: 10, right: 15),
                          child: Row(
                            children: <Widget>[
                              Radio(
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                value: 1,
                                groupValue: _major,
                                onChanged: (_) {
                                  setState(() {
                                    _major = 1;
                                  });
                                },
                              ),
                              Container(
                                margin: EdgeInsets.only(right: 10),
                                child: Text('전공',
                                    style: CustomStyles.bold14TextStyle()),
                              ),
                              Radio(
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                value: 0,
                                groupValue: _major,
                                onChanged: (_) {
                                  setState(() {
                                    _major = 0;
                                  });
                                },
                              ),
                              Text('비전공', style: CustomStyles.bold14TextStyle())
                            ],
                          )),

                      /////
                      Column(children: _educationWidgets),

                      Container(
                        margin: EdgeInsets.only(top: 20, bottom: 10),
                        child: Divider(
                          height: 0.1,
                          color: CustomColors.colorFontLightGrey,
                        ),
                      ),
                      Container(
                          height: 50,
                          margin: EdgeInsets.only(
                              left: 15, right: 15, top: 15, bottom: 50),
                          width: double.infinity,
                          child: CustomStyles.greyBorderRound7ButtonStyle(
                              '학력사항 추가', () {
                            setState(() {
                              UniqueKey _uKey = UniqueKey();

                              Map<UniqueKey, EducationListModel> _eduItem =
                                  new Map();
                              _eduItem[_uKey] = new EducationListModel(
                                  "대학교",
                                  new TextEditingController(),
                                  new TextEditingController());

                              _educationList.add(_eduItem);

                              _educationWidgets.add(educationHistory(_uKey));
                            });
                          })),
                    ])))),
            Container(
                width: double.infinity,
                height: 50,
                color: Colors.grey,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                        child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 55,
                            child:
                                CustomStyles.greyBGSquareButtonStyle('취소', () {
                              Navigator.pop(context);
                            }))),
                    Expanded(
                        child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 55,
                            child:
                                CustomStyles.blueBGSquareButtonStyle('다음', () {
                              requestUpdateApi(context);
                            })))
                  ],
                ))
          ]),
        ),
      ),
    );
  }

  /*
  * 제작사 회원정보 수정
  * */
  void requestUpdateApi(BuildContext context) {
    // 회원가입 api 호출 시 보낼 파라미터
    Map<String, dynamic> actorProfile = new Map();

    Map<String, dynamic> infoTargetData = new Map();
    infoTargetData[APIConstants.actor_name] = StringUtils.trimmedString(_txtFieldName.text);
    infoTargetData[APIConstants.sex_type] = _gender;
    infoTargetData[APIConstants.actor_birth] = _birthDate;
    infoTargetData[APIConstants.management_seq] = KCastingAppData().myInfo[APIConstants.management_seq];

    actorProfile[APIConstants.info_target] = infoTargetData;

    Map<String, dynamic> profileTargetData = new Map();
    profileTargetData[APIConstants.actor_Introduce] = _txtFieldIntroduce.text;
    profileTargetData[APIConstants.actor_drama_pay] = _txtFieldDramaPay.text;
    profileTargetData[APIConstants.actor_movie_pay] = _txtFieldMoviePay.text;
    profileTargetData[APIConstants.actor_tall] = _txtFieldTall.text;
    profileTargetData[APIConstants.actor_weight] = _txtFieldWeight.text;
    profileTargetData[APIConstants.actor_major_isAuth] = _major;

    actorProfile[APIConstants.profile_target] = profileTargetData;

    List<Map<String, dynamic>> educationTarget = [];

    for (int i = 0; i < _educationList.length; i++) {
      Map<String, dynamic> targetData = new Map();
      targetData[APIConstants.education_type] =
          _educationList[i].values.elementAt(0).educationType;
      targetData[APIConstants.education_name] =
          _educationList[i].values.elementAt(0).educationName.text;
      targetData[APIConstants.major_name] =
          _educationList[i].values.elementAt(0).majorName.text;
      targetData[APIConstants.diploma_url] = null;

      educationTarget.add(targetData);
    }

    if (educationTarget.length > 0) {
      actorProfile[APIConstants.education_target] = educationTarget;
    }

    replaceView(
        context, RegisterAgencyActorProfileSubInfo(targetData: actorProfile));
  }
}
