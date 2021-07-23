import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../KCastingAppData.dart';

/*
* 배우 필모그래피 추가
* */
class ActorFilmoAdd extends StatefulWidget {
  final int actorSeq;

  const ActorFilmoAdd({Key key, this.actorSeq}) : super(key: key);

  @override
  _ActorFilmoAdd createState() => _ActorFilmoAdd();
}

class _ActorFilmoAdd extends State<ActorFilmoAdd> with BaseUtilMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  int _actorSeq;

  final _txtFieldProjectName = TextEditingController();
  final _txtFieldProjectReleaseYear = TextEditingController();
  final _txtFieldCastingName = TextEditingController();

  String _projectType = APIConstants.project_type_drama;
  String _castingType = APIConstants.casting_type_1;

  @override
  void initState() {
    super.initState();

    _actorSeq = widget.actorSeq;
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
        appBar: CustomStyles.defaultAppBar('필모그래피 추가', () {
          Navigator.pop(context);
        }),
        body: Container(
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    alignment: Alignment.centerLeft,
                                    child: Text('작품명',
                                        style: CustomStyles.bold14TextStyle())),
                                Container(
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    margin: EdgeInsets.only(top: 5),
                                    child:
                                        CustomStyles.greyBorderRound7TextField(
                                            _txtFieldProjectName, '작품명 입력')),
                                Container(
                                    margin: EdgeInsets.only(top: 15),
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    alignment: Alignment.centerLeft,
                                    child: Text('개봉연도',
                                        style: CustomStyles.bold14TextStyle())),
                                Container(
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    margin: EdgeInsets.only(top: 5),
                                    child: CustomStyles
                                        .greyBorderRound7TextFieldWithOption(
                                            _txtFieldProjectReleaseYear,
                                            TextInputType.number,
                                            '개봉연도 입력')),
                                Container(
                                    margin: EdgeInsets.only(top: 15),
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    alignment: Alignment.centerLeft,
                                    child: Text('제작유형',
                                        style: CustomStyles.bold14TextStyle())),
                                Container(
                                    margin: EdgeInsets.only(top: 5),
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    width: double.infinity,
                                    child: DropdownButtonFormField(
                                      value: _projectType,
                                      onChanged: (String newValue) {
                                        setState(() {
                                          _projectType = newValue;
                                        });
                                      },
                                      items: <String>[
                                        APIConstants.project_type_drama,
                                        APIConstants.project_type_movie
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
                                                color:
                                                    CustomColors.colorFontGrey,
                                                width: 1.0),
                                            borderRadius: CustomStyles
                                                .circle7BorderRadius()),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color:
                                                    CustomColors.colorFontGrey,
                                                width: 1.0),
                                            borderRadius: CustomStyles
                                                .circle7BorderRadius()),
                                      ),
                                    )),
                                Container(
                                  margin: EdgeInsets.only(top: 20),
                                  child: Divider(
                                    height: 0.1,
                                    color: CustomColors.colorFontLightGrey,
                                  ),
                                ),
                                Container(
                                    margin: EdgeInsets.only(top: 15),
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    alignment: Alignment.centerLeft,
                                    child: Text('배역',
                                        style: CustomStyles.bold14TextStyle())),
                                Container(
                                    margin: EdgeInsets.only(top: 5),
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
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
                                        APIConstants.casting_type_4,
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
                                                color:
                                                    CustomColors.colorFontGrey,
                                                width: 1.0),
                                            borderRadius: CustomStyles
                                                .circle7BorderRadius()),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color:
                                                    CustomColors.colorFontGrey,
                                                width: 1.0),
                                            borderRadius: CustomStyles
                                                .circle7BorderRadius()),
                                      ),
                                    )),
                                Container(
                                    margin: EdgeInsets.only(top: 15),
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    alignment: Alignment.centerLeft,
                                    child: Text('배역 이름',
                                        style: CustomStyles.bold14TextStyle())),
                                Container(
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    margin: EdgeInsets.only(top: 5),
                                    child:
                                        CustomStyles.greyBorderRound7TextField(
                                            _txtFieldCastingName, '배역 이름 입력'))
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
                              child: CustomStyles.greyBGSquareButtonStyle('취소',
                                  () {
                                Navigator.pop(context);
                              }))),
                      Expanded(
                          child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 55,
                              child: CustomStyles.blueBGSquareButtonStyle('추가',
                                  () {
                                if (checkValidate(context)) {
                                  requestAddFilmographyApi(context);
                                }
                              })))
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }

  /*
  * 입력 데이터 유효성 검사
  * */
  bool checkValidate(BuildContext context) {
    if (StringUtils.isEmpty(_txtFieldProjectName.text)) {
      showSnackBar(context, '작품명을 입력해 주세요.');
      return false;
    }

    if (StringUtils.isEmpty(_txtFieldProjectReleaseYear.text)) {
      showSnackBar(context, '개봉연도를 입력해 주세요.');
      return false;
    }

    if (StringUtils.isEmpty(_txtFieldCastingName.text)) {
      showSnackBar(context, '배역 이름을 입력해 주세요.');
      return false;
    }

    return true;
  }

  /*
  * 제작사 필모그래피 추가
  * */
  void requestAddFilmographyApi(BuildContext context) {
    final dio = Dio();

    // 제작사 필모그래피 추가 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetDatas = new Map();
    targetDatas[APIConstants.actor_seq] = _actorSeq;
    targetDatas[APIConstants.project_name] = _txtFieldProjectName.text;
    targetDatas[APIConstants.project_releaseYear] =
        StringUtils.trimmedString(_txtFieldProjectReleaseYear.text);
    targetDatas[APIConstants.project_type] = _projectType;
    targetDatas[APIConstants.casting_name] = _castingType;
    targetDatas[APIConstants.casting_character_name] =
        _txtFieldCastingName.text;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.INS_AFM_INFO;
    params[APIConstants.target] = targetDatas;

    // 제작사 필모그래피 추가 api 호출
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value == null) {
        // 에러 - 데이터 널
        showSnackBar(context, APIConstants.error_msg_server_not_response);
      } else {
        if (value[APIConstants.resultVal]) {
          // 제작사 필모그래피 추가 성공
          try {
            var _responseData = value[APIConstants.data];
            var _responseList = _responseData[APIConstants.list] as List;

            if (_responseList != null && _responseList.length > 0) {
              KCastingAppData().myFilmorgraphy = _responseList;
            }

            // 스낵바
            Navigator.pop(context);
          } catch (e) {
            showSnackBar(context, APIConstants.error_msg_try_again);
          }
        } else {
          // 회원가입 실패
          showSnackBar(context, APIConstants.error_msg_try_again);
        }
      }
    });
  }
}
