import 'dart:io';

import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/dialog/DialogAuditionApplyConfirm.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:casting_call/src/view/actor/ActorProfileWidget.dart';
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
  final List<Map<String, dynamic>> dbImgages;
  final List<File> newImgages;
  final List<Map<String, dynamic>> dbVideos;
  final List<File> newVideos;
  final List<File> newVideoThumbs;
  final int actorSeq;

  const AuditionApplyUploadProfile(
      {Key key,
      this.castingSeq,
      this.projectName,
      this.castingName,
      this.dbImgages,
      this.newImgages,
      this.dbVideos,
      this.newVideos,
      this.newVideoThumbs,
      this.actorSeq})
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
  List<Map<String, dynamic>> _dbImgages;
  List<File> _newImgages;
  List<Map<String, dynamic>> _dbVideos;
  List<File> _newVideos;
  List<File> _newVideoThumbs;
  int _actorSeq;

  final GlobalKey<TagsState> _myKeywordTagStateKey = GlobalKey<TagsState>();

  String _actorAgeStr = "";
  String _actorEducationStr = "";
  String _actorLanguageStr = "";
  String _actordialectStr = "";
  String _actorAbilityStr = "";
  List<String> _actorKwdList = [];

  List<dynamic> _filmorgraphyList = [];

  bool _isUpload = false;

  @override
  void initState() {
    super.initState();

    _castingSeq = widget.castingSeq;
    _projectName = widget.projectName;
    _castingName = widget.castingName;
    _dbImgages = widget.dbImgages;
    _newImgages = widget.newImgages;
    _dbVideos = widget.dbVideos;
    _newVideos = widget.newVideos;
    _newVideoThumbs = widget.newVideoThumbs;
    _actorSeq = widget.actorSeq;

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

    // 배우 사투리
    if (KCastingAppData().myDialect != null) {
      for (int i = 0; i < KCastingAppData().myDialect.length; i++) {
        var _dialectData = KCastingAppData().myDialect[i];
        _actordialectStr += _dialectData[APIConstants.dialect_type];

        if (i != KCastingAppData().myDialect.length - 1)
          _actordialectStr += ",\t";
      }
    }

    // 배우 특기
    for (int i = 0; i < KCastingAppData().myAbility.length; i++) {
      var _abilityData = KCastingAppData().myAbility[i];
      _actorAbilityStr += _abilityData[APIConstants.child_type];

      if (i != KCastingAppData().myAbility.length - 1)
        _actorAbilityStr += ",\t";
    }

    // 배우 캐스팅 키워드
    if (KCastingAppData().myCastingKwd != null) {
      for (int i = 0; i < KCastingAppData().myCastingKwd.length; i++) {
        var _castingKwdData = KCastingAppData().myCastingKwd[i];

        for (int j = 0; j < KCastingAppData().commonCodeK01.length; j++) {
          var _castingKwdCode = KCastingAppData().commonCodeK01[j];

          if (_castingKwdData[APIConstants.code_seq] ==
              _castingKwdCode[APIConstants.seq]) {
            _actorKwdList.add(_castingKwdCode[APIConstants.child_name]);
          }
        }
      }
    }

    // 배우 외모 키워드
    for (int i = 0; i < KCastingAppData().myLookKwd.length; i++) {
      var _lookKwdData = KCastingAppData().myLookKwd[i];

      for (int j = 0; j < KCastingAppData().commonCodeK02.length; j++) {
        var _lookKwdCode = KCastingAppData().commonCodeK02[j];

        if (_lookKwdData[APIConstants.code_seq] ==
            _lookKwdCode[APIConstants.seq]) {
          _actorKwdList.add(_lookKwdCode[APIConstants.child_name]);
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                          padding: EdgeInsets.only(
                                              left: 15, right: 15),
                                          child: Text(
                                              StringUtils.checkedString(
                                                  _projectName),
                                              style: CustomStyles
                                                  .darkBold12TextStyle())),
                                      Container(
                                          padding: EdgeInsets.only(
                                              left: 15, right: 15),
                                          margin: EdgeInsets.only(top: 5.0),
                                          child: Text(
                                              StringUtils.checkedString(
                                                      _castingName) +
                                                  "역",
                                              style: CustomStyles
                                                  .dark24TextStyle())),
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: 20, bottom: 10),
                                        child: Divider(
                                          height: 0.1,
                                          color:
                                              CustomColors.colorFontLightGrey,
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(
                                            left: 15, right: 15),
                                        child: Container(
                                          padding: const EdgeInsets.all(10.0),
                                          decoration: new BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: CustomColors.colorFontTitle,
                                          ),
                                          child: new Text('3',
                                              style: new TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20.0)),
                                        ),
                                      ),
                                      Container(
                                          margin: EdgeInsets.only(top: 5.0),
                                          padding: EdgeInsets.only(
                                              left: 15, right: 15),
                                          child: Text('내 프로필',
                                              style: CustomStyles
                                                  .bold14TextStyle())),
                                      Container(
                                          margin: EdgeInsets.only(top: 5),
                                          padding: EdgeInsets.only(
                                              left: 15, right: 15),
                                          child: Text(
                                              '제출되는 내 프로필을 확인 후 지원하기를 눌러주세요.\n프로필수정은 내 프로필에서 할 수 있습니다.',
                                              style: CustomStyles
                                                  .normal14TextStyle())),
                                      ActorProfileWidget.profileWidget(
                                          context,
                                          _myKeywordTagStateKey,
                                          KCastingAppData().myProfile,
                                          _actorAgeStr,
                                          _actorEducationStr,
                                          _actorLanguageStr,
                                          _actordialectStr,
                                          _actorAbilityStr,
                                          _actorKwdList),
                                      Container(
                                          margin: EdgeInsets.only(
                                              top: 30.0, bottom: 5),
                                          padding: EdgeInsets.only(
                                              left: 15, right: 15),
                                          child: Text('경력사항',
                                              style: CustomStyles
                                                  .bold16TextStyle())),
                                      Wrap(children: [
                                        ListView.builder(
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            padding: EdgeInsets.only(
                                                left: 10, right: 10),
                                            itemCount: _filmorgraphyList.length,
                                            itemBuilder: (context, index) {
                                              return Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          bottom: 10),
                                                      child: Divider(
                                                        height: 0.1,
                                                        color: CustomColors
                                                            .colorFontLightGrey,
                                                      ),
                                                    ),
                                                    ActorFilmoListItem(
                                                        idx: index,
                                                        data: _filmorgraphyList[
                                                            index],
                                                        isEditMode: false,
                                                        onClickEvent: () {
                                                          setState(() {
                                                            _filmorgraphyList
                                                                .removeAt(
                                                                    index);
                                                          });
                                                        })
                                                  ]);
                                            })
                                      ])
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
                                    child: CustomStyles.greyBGSquareButtonStyle(
                                        '이전단계', () {
                                      replaceView(
                                          context,
                                          AuditionApplyUploadVideo(
                                              castingSeq: _castingSeq,
                                              projectName: _projectName,
                                              castingName: _castingName,
                                              dbImgages: _dbImgages,
                                              newImgages: _newImgages,
                                              actorSeq: _actorSeq));
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
  Future<void> requestAddApply(BuildContext context) async {
    try {
      final dio = Dio();

      Map<String, dynamic> targetData = new Map();

      if (KCastingAppData().myInfo[APIConstants.member_type] ==
          APIConstants.member_type_actor) {
        targetData[APIConstants.actor_seq] =
            KCastingAppData().myInfo[APIConstants.seq];
      } else if (KCastingAppData().myInfo[APIConstants.member_type] ==
          APIConstants.member_type_management) {
        targetData[APIConstants.actor_seq] = _actorSeq;
      }

      targetData[APIConstants.casting_seq] = _castingSeq;

      if (_dbImgages.length > 0) {
        targetData[APIConstants.db_imgages] = _dbImgages;
      }

      if (_dbVideos.length > 0) {
        targetData[APIConstants.db_videos] = _dbVideos;
      }

      Map<String, dynamic> params = new Map();
      params[APIConstants.key] = APIConstants.INS_AAA_INFO_FORMDATA;
      params[APIConstants.target] = targetData;

      // 새로 등록한 이미지 추가
      var newImageFiles = [];
      for (int i = 0; i < _newImgages.length; i++) {
        var temp = _newImgages[i].path.split('/');
        String fileName = temp[temp.length - 1];
        newImageFiles.add(await MultipartFile.fromFile(_newImgages[i].path,
            filename: fileName));
      }

      if (newImageFiles.length > 0) {
        params[APIConstants.new_images] = newImageFiles;
      }

      // 새로 등록한 비디오 및 썸네일 추가
      var newVideoFiles = [];
      var newVideoThumbFiles = [];
      for (int i = 0; i < _newVideos.length; i++) {
        var temp = _newVideos[i].path.split('/');
        String fileName = temp[temp.length - 1];
        newVideoFiles.add(await MultipartFile.fromFile(_newVideos[i].path,
            filename: fileName));

        var tempImg = _newVideoThumbs[i].path.split('/');
        String thumbFileName = tempImg[tempImg.length - 1];
        newVideoThumbFiles.add(await MultipartFile.fromFile(
            _newVideoThumbs[i].path,
            filename: thumbFileName));
      }

      if (newVideoFiles.length > 0) {
        params[APIConstants.new_videos] = newVideoFiles;
        params[APIConstants.new_videos_thumb] = newVideoThumbFiles;
      }

      // 지원하기 api 호출
      RestClient(dio)
          .postRequestMainControlFormData(params)
          .then((value) async {
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

              if (KCastingAppData().myInfo[APIConstants.member_type] ==
                  APIConstants.member_type_actor) {
                replaceView(context, AuditionApplyComplete());
              } else if (KCastingAppData().myInfo[APIConstants.member_type] ==
                  APIConstants.member_type_management) {
                replaceView(
                    context, AuditionApplyComplete(actorSeq: _actorSeq));
              }
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
