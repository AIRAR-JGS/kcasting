import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/dialog/DialogAuditionApplyConfirm.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:casting_call/src/view/mypage/actor/ActorFilmoListItem.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';

import '../../../../KCastingAppData.dart';
import 'AuditionApplyComplete.dart';
import 'AuditionApplyUploadVideo.dart';

/*
* 오디션 지원하기 - 프로필 업로드
* */
class AuditionApplyUploadProfile extends StatefulWidget {
  final int castingSeq;
  final String projectName;
  final String castingName;
  final List<dynamic> applyImageData;
  final List<dynamic> applyVideoData;

  const AuditionApplyUploadProfile(
      {Key key,
      this.castingSeq,
      this.projectName,
      this.castingName,
      this.applyImageData,
      this.applyVideoData})
      : super(key: key);

  @override
  _AuditionApplyUploadProfile createState() => _AuditionApplyUploadProfile();
}

class _AuditionApplyUploadProfile extends State<AuditionApplyUploadProfile>
    with BaseUtilMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  int _castingSeq;
  String _projectName;
  String _castingName;
  List<dynamic> _applyImageData;
  List<dynamic> _applyVideoData;

  final GlobalKey<TagsState> _myKeywordTagStateKey = GlobalKey<TagsState>();

  //String _actorAgeStr = "";
  String _actorEducationStr = "";
  String _actorLanguageStr = "";
  String _actorAbilityStr = "";
  List<String> _actorLookKwdList = [];

  List<dynamic> _filmorgraphyList = [];

  bool _isUpload = false;

  @override
  void initState() {
    super.initState();

    _castingSeq = widget.castingSeq;
    _projectName = widget.projectName;
    _castingName = widget.castingName;
    _applyVideoData = widget.applyVideoData;
    _applyImageData = widget.applyImageData;

    // 배우 학력사항
    for (int i = 0; i < KCastingAppData().myEducation.length; i++) {
      var _eduData = KCastingAppData().myEducation[i];
      _actorEducationStr += _eduData[APIConstants.education_name];
      _actorEducationStr += "\t";
      _actorEducationStr += _eduData[APIConstants.major_name];

      if (i != KCastingAppData().myEducation.length - 1)
        _actorEducationStr += "\n";
    }

    // 배우 언어
    for (int i = 0; i < KCastingAppData().myLanguage.length; i++) {
      var _lanData = KCastingAppData().myLanguage[i];
      _actorLanguageStr += _lanData[APIConstants.language_type];

      if (i != KCastingAppData().myLanguage.length - 1)
        _actorLanguageStr += "\t";
    }

    // 배우 특기
    for (int i = 0; i < KCastingAppData().myAbility.length; i++) {
      var _abilityData = KCastingAppData().myAbility[i];
      _actorAbilityStr += _abilityData[APIConstants.child_type];

      if (i != KCastingAppData().myAbility.length - 1)
        _actorAbilityStr += ",\t";
    }

    // 배우 외모 키워드
    for (int i = 0; i < KCastingAppData().myLookKwd.length; i++) {
      var _lookKwdData = KCastingAppData().myLookKwd[i];

      for (int j = 0; j < KCastingAppData().commonCodeK02.length; j++) {
        var _lookKwdCode = KCastingAppData().commonCodeK02[j];

        if (_lookKwdData[APIConstants.code_seq] ==
            _lookKwdCode[APIConstants.seq]) {
          _actorLookKwdList.add(_lookKwdCode[APIConstants.child_name]);
        }
      }
    }

    // 배우 필모그래피
    _filmorgraphyList.addAll(KCastingAppData().myFilmorgraphy);
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
            appBar: CustomStyles.defaultAppBar('프로필 업로드', () {
              Navigator.pop(context);
            }),
            body: Builder(builder: (BuildContext context) {
              return Stack(
                children: [
                  Container(
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
                                  padding: EdgeInsets.only(left: 15, right: 15),
                                  child: Text(
                                      StringUtils.checkedString(_projectName),
                                      style:
                                          CustomStyles.darkBold12TextStyle())),
                              Container(
                                  padding: EdgeInsets.only(left: 15, right: 15),
                                  margin: EdgeInsets.only(top: 5.0),
                                  child: Text(
                                      StringUtils.checkedString(_castingName) +
                                          "역",
                                      style: CustomStyles.dark24TextStyle())),
                              Container(
                                margin: EdgeInsets.only(top: 20, bottom: 10),
                                child: Divider(
                                  height: 0.1,
                                  color: CustomColors.colorFontLightGrey,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(left: 15, right: 15),
                                child: Container(
                                  padding: const EdgeInsets.all(10.0),
                                  decoration: new BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: CustomColors.colorFontTitle,
                                  ),
                                  child: new Text('3',
                                      style: new TextStyle(
                                          color: Colors.white, fontSize: 20.0)),
                                ),
                              ),
                              Container(
                                  margin: EdgeInsets.only(top: 5.0),
                                  padding: EdgeInsets.only(left: 15, right: 15),
                                  child: Text('내 프로필',
                                      style: CustomStyles.bold14TextStyle())),
                              Container(
                                  margin: EdgeInsets.only(top: 5),
                                  padding: EdgeInsets.only(left: 15, right: 15),
                                  child: Text(
                                      '제출되는 내 프로필을 확인 후 지원하기를 눌러주세요.\n프로필수정은 내 프로필에서 할 수 있습니다.',
                                      style: CustomStyles.normal14TextStyle())),
                              Container(
                                  margin: EdgeInsets.only(top: 30.0),
                                  padding: EdgeInsets.only(left: 15, right: 15),
                                  child: Text(
                                      StringUtils.checkedString(
                                          KCastingAppData().myProfile[
                                              APIConstants.actor_name]),
                                      style: CustomStyles.normal32TextStyle())),
                              Container(
                                  margin: EdgeInsets.only(top: 15),
                                  padding: EdgeInsets.only(left: 15, right: 15),
                                  child: Text(
                                      StringUtils.checkedString(
                                          KCastingAppData().myProfile[
                                              APIConstants.actor_Introduce]),
                                      style: CustomStyles.normal16TextStyle())),
                              Container(
                                  padding: EdgeInsets.only(left: 15, right: 15),
                                  margin: EdgeInsets.only(top: 20.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          flex: 3,
                                          child: Container(
                                              child: Text('드라마페이',
                                                  style: CustomStyles
                                                      .normal14TextStyle()))),
                                      Expanded(
                                          flex: 7,
                                          child: Container(
                                              child: Text(
                                                  StringUtils.checkedString(
                                                          KCastingAppData()
                                                                  .myProfile[
                                                              APIConstants
                                                                  .actor_drama_pay]) +
                                                      "만원",
                                                  style: CustomStyles
                                                      .normal14TextStyle())))
                                    ],
                                  )),
                              Container(
                                  padding: EdgeInsets.only(left: 15, right: 15),
                                  margin: EdgeInsets.only(top: 10.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          flex: 3,
                                          child: Container(
                                              child: Text('영화페이',
                                                  style: CustomStyles
                                                      .normal14TextStyle()))),
                                      Expanded(
                                          flex: 7,
                                          child: Container(
                                              child: Text(
                                                  StringUtils.checkedString(
                                                          KCastingAppData()
                                                                  .myProfile[
                                                              APIConstants
                                                                  .actor_movie_pay]) +
                                                      "만원",
                                                  style: CustomStyles
                                                      .normal14TextStyle())))
                                    ],
                                  )),
                              Container(
                                  padding: EdgeInsets.only(left: 15, right: 15),
                                  margin: EdgeInsets.only(top: 10.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          flex: 3,
                                          child: Container(
                                              child: Text('나이',
                                                  style: CustomStyles
                                                      .normal14TextStyle()))),
                                      Expanded(
                                          flex: 7,
                                          child: Container(
                                              child: Text(
                                                  StringUtils.checkedString(
                                                      KCastingAppData()
                                                              .myProfile[
                                                          APIConstants
                                                              .actor_birth]),
                                                  style: CustomStyles
                                                      .normal14TextStyle())))
                                    ],
                                  )),
                              Container(
                                  padding: EdgeInsets.only(left: 15, right: 15),
                                  margin: EdgeInsets.only(top: 10.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          flex: 3,
                                          child: Container(
                                              child: Text('키',
                                                  style: CustomStyles
                                                      .normal14TextStyle()))),
                                      Expanded(
                                          flex: 7,
                                          child: Container(
                                              child: Text(
                                                  StringUtils.checkedString(
                                                          KCastingAppData()
                                                                  .myProfile[
                                                              APIConstants
                                                                  .actor_tall]) +
                                                      "cm",
                                                  style: CustomStyles
                                                      .normal14TextStyle())))
                                    ],
                                  )),
                              Container(
                                  padding: EdgeInsets.only(left: 15, right: 15),
                                  margin: EdgeInsets.only(top: 10.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          flex: 3,
                                          child: Container(
                                              child: Text('체중',
                                                  style: CustomStyles
                                                      .normal14TextStyle()))),
                                      Expanded(
                                          flex: 7,
                                          child: Container(
                                              child: Text(
                                                  StringUtils.checkedString(
                                                          KCastingAppData()
                                                                  .myProfile[
                                                              APIConstants
                                                                  .actor_weight]) +
                                                      "kg",
                                                  style: CustomStyles
                                                      .normal14TextStyle())))
                                    ],
                                  )),
                              Container(
                                  padding: EdgeInsets.only(left: 15, right: 15),
                                  margin: EdgeInsets.only(top: 10.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          flex: 3,
                                          child: Container(
                                              child: Text('전공여부',
                                                  style: CustomStyles
                                                      .normal14TextStyle()))),
                                      Expanded(
                                          flex: 7,
                                          child: Container(
                                              child: Text(
                                                  KCastingAppData().myProfile[
                                                              APIConstants
                                                                  .actor_major_isAuth] ==
                                                          0
                                                      ? "비전공"
                                                      : "전공",
                                                  style: CustomStyles
                                                      .normal14TextStyle())))
                                    ],
                                  )),
                              Container(
                                  padding: EdgeInsets.only(left: 15, right: 15),
                                  margin: EdgeInsets.only(top: 10.0),
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                            flex: 3,
                                            child: Container(
                                                child: Text('학력사항',
                                                    style: CustomStyles
                                                        .normal14TextStyle()))),
                                        Expanded(
                                            flex: 7,
                                            child: Container(
                                                child: Text(_actorEducationStr,
                                                    style: CustomStyles
                                                        .normal14TextStyle())))
                                      ])),
                              Container(
                                  padding: EdgeInsets.only(left: 15, right: 15),
                                  margin: EdgeInsets.only(top: 10.0),
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                            flex: 3,
                                            child: Container(
                                                child: Text('언어',
                                                    style: CustomStyles
                                                        .normal14TextStyle()))),
                                        Expanded(
                                            flex: 7,
                                            child: Container(
                                                child: Text(_actorLanguageStr,
                                                    style: CustomStyles
                                                        .normal14TextStyle())))
                                      ])),
                              Container(
                                  padding: EdgeInsets.only(left: 15, right: 15),
                                  margin: EdgeInsets.only(top: 10.0),
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                            flex: 3,
                                            child: Container(
                                                child: Text('특기',
                                                    style: CustomStyles
                                                        .normal14TextStyle()))),
                                        Expanded(
                                            flex: 7,
                                            child: Container(
                                                child: Text(_actorAbilityStr,
                                                    style: CustomStyles
                                                        .normal14TextStyle())))
                                      ])),
                              Container(
                                  padding: EdgeInsets.only(left: 15, right: 15),
                                  margin: EdgeInsets.only(top: 10.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                          flex: 3,
                                          child: Container(
                                              child: Text('키워드',
                                                  style: CustomStyles
                                                      .normal14TextStyle()))),
                                      Expanded(
                                        flex: 7,
                                        child: Container(
                                          alignment: Alignment.topLeft,
                                          margin: EdgeInsets.only(bottom: 10),
                                          padding: EdgeInsets.only(
                                            right: 15,
                                          ),
                                          child: Tags(
                                            runSpacing: 5,
                                            spacing: 5,
                                            alignment: WrapAlignment.start,
                                            runAlignment: WrapAlignment.start,
                                            key: _myKeywordTagStateKey,
                                            itemCount: _actorLookKwdList.length,
                                            // required
                                            itemBuilder: (int index) {
                                              final item =
                                                  _actorLookKwdList[index];
                                              return ItemTags(
                                                textStyle: CustomStyles
                                                    .dark14TextStyle(),
                                                textColor:
                                                    CustomColors.colorFontGrey,
                                                activeColor:
                                                    CustomColors.colorFontGrey,
                                                textActiveColor:
                                                    CustomColors.colorWhite,
                                                key: Key(index.toString()),
                                                index: index,
                                                title: item,
                                                active: false,
                                                pressEnabled: false,
                                                combine: ItemTagsCombine
                                                    .withTextBefore,
                                                elevation: 0.0,
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                onPressed: (item) =>
                                                    print(item),
                                                onLongPressed: (item) =>
                                                    print(item),
                                              );
                                            },
                                          ),
                                        ),
                                      )
                                    ],
                                  )),
                              Container(
                                  margin: EdgeInsets.only(top: 30.0, bottom: 5),
                                  padding: EdgeInsets.only(left: 15, right: 15),
                                  child: Text('경력사항',
                                      style: CustomStyles.bold16TextStyle())),
                              Wrap(
                                children: [
                                  ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    padding:
                                        EdgeInsets.only(left: 10, right: 10),
                                    itemCount: _filmorgraphyList.length,
                                    itemBuilder: (context, index) {
                                      return Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(bottom: 10),
                                            child: Divider(
                                              height: 0.1,
                                              color: CustomColors
                                                  .colorFontLightGrey,
                                            ),
                                          ),
                                          ActorFilmoListItem(
                                              idx: index,
                                              data: _filmorgraphyList[index],
                                              isEditMode: false,
                                              onClickEvent: () {
                                                setState(() {
                                                  _filmorgraphyList
                                                      .removeAt(index);
                                                });
                                              })
                                        ],
                                      );
                                    },
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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
                                    child: CustomStyles.greyBGSquareButtonStyle(
                                        '이전단계', () {
                                      replaceView(
                                          context,
                                          AuditionApplyUploadVideo(
                                              castingSeq: _castingSeq,
                                              projectName: _projectName,
                                              castingName: _castingName,
                                              applyImageData: _applyImageData));
                                    }))),
                            Expanded(
                                child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 55,
                                    child: CustomStyles.blueBGSquareButtonStyle(
                                        '지원하기', () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext _context) =>
                                            DialogAuditionApplyConfirm(
                                          onClickedAgree: () {
                                            setState(() {
                                              _isUpload = true;
                                            });
                                            requestAddApply(context);
                                          },
                                        ),
                                      );
                                    })))
                          ],
                        ))
                  ])),
                  Visibility(
                    child: Container(
                      color: Colors.black38,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(),
                    ),
                    visible: _isUpload,
                  )
                ],
              );
            })));
  }

  /*
  * 지원하기
  * */
  void requestAddApply(BuildContext context) {
    try {
      final dio = Dio();

      Map<String, dynamic> targetData = new Map();
      targetData[APIConstants.actor_seq] =
          KCastingAppData().myInfo[APIConstants.seq];
      targetData[APIConstants.casting_seq] = _castingSeq;
      targetData[APIConstants.file_image] = _applyImageData;
      targetData[APIConstants.file_video] = _applyVideoData;

      Map<String, dynamic> params = new Map();
      params[APIConstants.key] = APIConstants.INS_AAA_INFO;
      params[APIConstants.target] = targetData;

      // 지원하기 api 호출
      RestClient(dio).postRequestMainControl(params).then((value) async {
        if (value == null) {
          // 에러 - 데이터 널
          showSnackBar(context, APIConstants.error_msg_server_not_response);
        } else {
          if (value[APIConstants.resultVal]) {
            try {
              // 지원하기 성공
              setState(() {
                _isUpload = false;
              });

              replaceView(context, AuditionApplyComplete());
            } catch (e) {
              showSnackBar(context, APIConstants.error_msg_try_again);
            }
          } else {
            // 지원하기 실패
            showSnackBar(context, APIConstants.error_msg_try_again);
          }
        }
      });
    } catch (e) {
      showSnackBar(context, APIConstants.error_msg_try_again);
    } finally {}
  }
}
