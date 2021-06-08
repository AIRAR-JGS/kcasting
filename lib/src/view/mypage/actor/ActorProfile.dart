import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/KCastingAppData.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/view/actor/ActorProfileWidget.dart';
import 'package:casting_call/src/view/mypage/actor/ActorFilmoAdd.dart';
import 'package:casting_call/src/view/mypage/actor/ActorProfileModifyMainInfo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ActorProfile extends StatefulWidget {
  @override
  _ActorProfile createState() => _ActorProfile();
}

class _ActorProfile extends State<ActorProfile>
    with SingleTickerProviderStateMixin, BaseUtilMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  final GlobalKey<TagsState> _myKeywordTagStateKey = GlobalKey<TagsState>();

  File _profileImgFile;
  final picker = ImagePicker();

  TabController _tabController;
  int _tabIndex = 0;

  bool _isUpload = false;

  String _actorAgeStr = "";
  String _actorEducationStr = "";
  String _actorLanguageStr = "";
  String _actorAbilityStr = "";
  List<String> _actorLookKwdList = [];

  List<dynamic> _filmorgraphyList = [];
  List<dynamic> _originalFilmorgraphyList = [];
  List<int> _deletedFilmorgraphyList = [];
  bool _isFlimorgraphyListEditMode = false;

  List<dynamic> _myPhotos = [];
  List<dynamic> _originalMyPhotos = [];
  List<int> _deletedImageList = [];
  bool _isImageListEditMode = false;

  List<dynamic> _myVideos = [];
  List<dynamic> _originalMyVideos = [];
  List<int> _deletedVideoList = [];
  bool _isVideoListEditMode = false;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _tabIndex = _tabController.index;
        });
      }
    });

    setState(() {
      // 배우 이미지
      _myPhotos = KCastingAppData().myImage;
      _originalMyPhotos = KCastingAppData().myImage;

      _myVideos = KCastingAppData().myVideo;
      _originalMyVideos = KCastingAppData().myVideo;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    initData();
  }

  void initData() {
    setState(() {
      _actorAgeStr = "";
      _actorEducationStr = "";
      _actorLanguageStr = "";
      _actorAbilityStr = "";
      _actorLookKwdList = [];
      _filmorgraphyList = [];
      _originalFilmorgraphyList = [];
      _isFlimorgraphyListEditMode = false;

      _deletedFilmorgraphyList = [];
      _deletedImageList = [];
      _deletedVideoList = [];

      // 배우 학력사항
      if (KCastingAppData().myEducation != null) {
        for (int i = 0; i < KCastingAppData().myEducation.length; i++) {
          var _eduData = KCastingAppData().myEducation[i];
          _actorEducationStr += _eduData[APIConstants.education_name];
          _actorEducationStr += "\t";
          _actorEducationStr += _eduData[APIConstants.major_name];

          if (i != KCastingAppData().myEducation.length - 1)
            _actorEducationStr += "\n";
        }
      }

      // 배우 언어
      if (KCastingAppData().myLanguage != null) {
        for (int i = 0; i < KCastingAppData().myLanguage.length; i++) {
          var _lanData = KCastingAppData().myLanguage[i];
          _actorLanguageStr += _lanData[APIConstants.language_type];

          if (i != KCastingAppData().myLanguage.length - 1)
            _actorLanguageStr += "\t";
        }
      }

      // 배우 특기
      if (KCastingAppData().myAbility != null) {
        for (int i = 0; i < KCastingAppData().myAbility.length; i++) {
          var _abilityData = KCastingAppData().myAbility[i];
          _actorAbilityStr += _abilityData[APIConstants.child_type];

          if (i != KCastingAppData().myAbility.length - 1)
            _actorAbilityStr += ",\t";
        }
      }

      // 배우 외모 키워드
      if (KCastingAppData().myLookKwd != null) {
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
      }

      // 배우 필모그래피
      if (KCastingAppData().myFilmorgraphy != null) {
        _filmorgraphyList.addAll(KCastingAppData().myFilmorgraphy);
        _originalFilmorgraphyList.addAll(KCastingAppData().myFilmorgraphy);
      }
    });
  }

  /*
  * 배우프로필 이미지 수정
  * */
  void requestUpdateActorProfile(BuildContext context, File profileFile) {
    final dio = Dio();

    final bytes = File(profileFile.path).readAsBytesSync();
    String img64 = base64Encode(bytes);

    // 배우프로필 이미지 수정 api 호출 시 보낼 파라미터
    Map<String, dynamic> fileData = new Map();
    fileData[APIConstants.base64string] = APIConstants.data_image + img64;

    Map<String, dynamic> targetData = new Map();
    targetData[APIConstants.seq] =
        KCastingAppData().myInfo[APIConstants.actorProfile_seq];
    targetData[APIConstants.file] = fileData;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.UPD_APR_MAINIMG;
    params[APIConstants.target] = targetData;

    // 배우프로필 이미지 수정 api 호출
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value == null) {
        // 에러 - 데이터 널
        showSnackBar(context, APIConstants.error_msg_server_not_response);
      } else {
        if (value[APIConstants.resultVal]) {
          // 배우프로필 이미지 수정 성공
          var _responseData = value[APIConstants.data];
          var _responseList = _responseData[APIConstants.list];

          setState(() {
            // 수정된 회원정보 전역변수에 저장
            if (_responseList.length > 0) {
              var newProfileData = _responseList[0];

              if (newProfileData[APIConstants.main_img_url] != null) {
                KCastingAppData().myProfile[APIConstants.main_img_url] =
                    newProfileData[APIConstants.main_img_url];
              }
            }
          });
        } else {
          // 배우프로필 이미지  수정 실패
          showSnackBar(context, APIConstants.error_msg_try_again);
        }
      }
    });
  }

  /*
  *배우 필모그래피 삭제
  * */
  void requestActorFilmorgraphyDeleteApi(BuildContext context) {
    final dio = Dio();

    // 배우 필모그래피 삭제 api 호출 시 보낼 파라미터
    Map<String, dynamic> callbackDatas = new Map();
    callbackDatas[APIConstants.actor_seq] =
        KCastingAppData().myInfo[APIConstants.seq];

    Map<String, dynamic> targetDatas = new Map();
    targetDatas[APIConstants.seq] = _deletedFilmorgraphyList;
    targetDatas[APIConstants.callback] = callbackDatas;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.DEA_AFM_LIST;
    params[APIConstants.target] = targetDatas;

    // 배우 필모그래피 삭제 api 호출
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value != null) {
        if (value[APIConstants.resultVal]) {
          try {
            // 배우 필모그래피 삭제 성공
            var _responseData = value[APIConstants.data];
            var _responseList = _responseData[APIConstants.list] as List;

            setState(() {
              if (_responseList != null && _responseList.length > 0) {
                _filmorgraphyList = _responseList;
                _originalFilmorgraphyList = _responseList;
              }
            });
          } catch (e) {
            showSnackBar(context, APIConstants.error_msg_try_again);
          }
        } else {
          showSnackBar(context, APIConstants.error_msg_try_again);
        }
      } else {
        // 에러 - 데이터 널 - 서버가 응답하지 않습니다. 다시 시도해 주세요
        showSnackBar(context, APIConstants.error_msg_server_not_response);
      }
    });
  }

  /*
  * 배우 이미지 추가
  * */
  void requestAddActorImage(BuildContext context, File profileFile) {
    final dio = Dio();

    final bytes = File(profileFile.path).readAsBytesSync();
    String img64 = base64Encode(bytes);

    // 배우 이미지 추가 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetData = new Map();
    targetData[APIConstants.actor_seq] =
        KCastingAppData().myInfo[APIConstants.seq];

    Map<String, dynamic> fileData = new Map();
    fileData[APIConstants.base64string] = APIConstants.data_image + img64;
    List<Map<String, dynamic>> fileDatas = [];
    fileDatas.add(fileData);

    targetData[APIConstants.file] = fileDatas;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.INS_AIM_LIST;
    params[APIConstants.target] = targetData;

    // 배우 이미지 추가 api 호출
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value == null) {
        // 에러 - 데이터 널
        showSnackBar(context, APIConstants.error_msg_server_not_response);
      } else {
        if (value[APIConstants.resultVal]) {
          // 배우 이미지 추가 성공
          var _responseData = value[APIConstants.data];
          var _responseList = _responseData[APIConstants.list];

          setState(() {
            // 수정된 회원정보 전역변수에 저장
            if (_responseList.length > 0) {
              KCastingAppData().myImage = _responseList;

              _myPhotos = _responseList;
              _originalMyPhotos = _responseList;
            }
          });
        } else {
          // 배우 이미지 추가 실패
          showSnackBar(context, APIConstants.error_msg_try_again);
        }
      }
    });
  }

  /*
  *배우 이미지 삭제
  * */
  void requestActorImageDeleteApi(BuildContext context) {
    final dio = Dio();

    // 배우 이미지 삭제 api 호출 시 보낼 파라미터
    Map<String, dynamic> callbackDatas = new Map();
    callbackDatas[APIConstants.actor_seq] =
        KCastingAppData().myInfo[APIConstants.seq];

    Map<String, dynamic> targetDatas = new Map();
    targetDatas[APIConstants.seq] = _deletedImageList;
    targetDatas[APIConstants.callback] = callbackDatas;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.DEA_AIM_LIST;
    params[APIConstants.target] = targetDatas;

    // 배우 이미지 삭제 api 호출
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value != null) {
        if (value[APIConstants.resultVal]) {
          try {
            var _responseData = value[APIConstants.data];
            var _responseList = _responseData[APIConstants.list];

            setState(() {
              // 수정된 회원정보 전역변수에 저장
              if (_responseList.length > 0) {
                KCastingAppData().myImage = _responseList;

                _myPhotos = _responseList;
                _originalMyPhotos = _responseList;
              }
            });
          } catch (e) {
            showSnackBar(context, APIConstants.error_msg_try_again);
          }
        } else {
          showSnackBar(context, APIConstants.error_msg_try_again);
        }
      } else {
        // 에러 - 데이터 널 - 서버가 응답하지 않습니다. 다시 시도해 주세요
        showSnackBar(context, APIConstants.error_msg_server_not_response);
      }
    });
  }

  /*
  * 배우 비디오 추가
  * */
  void requestAddActorVideo(
      BuildContext context, File videoFile, Uint8List bytes) {
    setState(() {
      _isUpload = true;
    });

    try {
      final dio = Dio();

      final videoFileBytes = File(videoFile.path).readAsBytesSync();
      String videoFile64 = base64Encode(videoFileBytes);

      //final bytes = File(thumbnailFile.path).readAsBytesSync();
      String thumbnailFile62 = base64Encode(bytes);

      // 배우 비디오 추가 api 호출 시 보낼 파라미터
      Map<String, dynamic> targetData = new Map();
      targetData[APIConstants.actor_seq] =
          KCastingAppData().myInfo[APIConstants.seq];

      Map<String, dynamic> fileData = new Map();
      fileData[APIConstants.base64string] =
          APIConstants.data_file + videoFile64;
      fileData[APIConstants.base64string_thumb] =
          APIConstants.data_image + thumbnailFile62;

      List<Map<String, dynamic>> fileDatas = [];
      fileDatas.add(fileData);

      targetData[APIConstants.file] = fileDatas;

      Map<String, dynamic> params = new Map();
      params[APIConstants.key] = APIConstants.INS_AVD_LIST;
      params[APIConstants.target] = targetData;

      // 배우 비디오 추가 api 호출
      RestClient(dio).postRequestMainControl(params).then((value) async {
        if (value == null) {
          // 에러 - 데이터 널
          showSnackBar(context, APIConstants.error_msg_server_not_response);
        } else {
          if (value[APIConstants.resultVal]) {
            // 배우 비디오 추가 성공
            var _responseData = value[APIConstants.data];
            var _responseList = _responseData[APIConstants.list];

            setState(() {
              _isUpload = false;

              // 수정된 회원정보 전역변수에 저장
              if (_responseList.length > 0) {
                KCastingAppData().myVideo = _responseList;

                _myVideos = _responseList;
                _originalMyVideos = _responseList;
              }
            });
          } else {
            // 배우 비디오 추가 실패
            showSnackBar(context, APIConstants.error_msg_try_again);
          }
        }
      });
    } catch (e) {
      showSnackBar(context, APIConstants.error_msg_try_again);
      setState(() {
        _isUpload = false;
      });
    }
  }

  /*
  *배우 비디오 삭제
  * */
  void requestActorVideoDeleteApi(BuildContext context) {
    final dio = Dio();

    // 배우 필모그래피 삭제 api 호출 시 보낼 파라미터
    Map<String, dynamic> callbackDatas = new Map();
    callbackDatas[APIConstants.actor_seq] =
        KCastingAppData().myInfo[APIConstants.seq];

    Map<String, dynamic> targetDatas = new Map();
    targetDatas[APIConstants.seq] = _deletedVideoList;
    targetDatas[APIConstants.callback] = callbackDatas;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.DEA_AVD_LIST;
    params[APIConstants.target] = targetDatas;

    // 배우 필모그래피 삭제 api 호출
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value != null) {
        if (value[APIConstants.resultVal]) {
          try {
            var _responseData = value[APIConstants.data];
            var _responseList = _responseData[APIConstants.list];

            setState(() {
              // 수정된 회원정보 전역변수에 저장
              KCastingAppData().myVideo = _responseList;

              _myVideos = _responseList;
              _originalMyVideos = _responseList;
            });
          } catch (e) {
            showSnackBar(context, APIConstants.error_msg_try_again);
          }
        } else {
          showSnackBar(context, APIConstants.error_msg_try_again);
        }
      } else {
        // 에러 - 데이터 널 - 서버가 응답하지 않습니다. 다시 시도해 주세요
        showSnackBar(context, APIConstants.error_msg_server_not_response);
      }
    });
  }

  // 갤러리에서 이미지 가져오기
  Future getImageFromGallery(int type) async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      print(pickedFile.path);
      if (type == 0) {
        _profileImgFile = File(pickedFile.path);
        requestUpdateActorProfile(context, _profileImgFile);
      } else {
        File _image = File(pickedFile.path);

        final size = _image.readAsBytesSync().lengthInBytes;
        final kb = size / 1024;
        final mb = kb / 1024;

        if (mb > 25) {
          showSnackBar(context, "25MB 미만의 파일만 업로드 가능합니다.");
        } else {
          requestAddActorImage(context, _image);
        }
      }
    } else {
      showSnackBar(context, "선택된 이미지가 없습니다.");
    }
  }

  Future getVideoFromGallery() async {
    final pickedFile = await picker.getVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      print(pickedFile.path);

      getVideoThumbnail(pickedFile.path);
    } else {
      showSnackBar(context, "선택된 이미지가 없습니다.");
    }
  }

  getVideoThumbnail(String filePath) async {
    Uint8List bytes = await VideoThumbnail.thumbnailData(
        video: filePath, imageFormat: ImageFormat.JPEG);

    var _videoFile = File(filePath);
    final size = _videoFile.readAsBytesSync().lengthInBytes;
    final kb = size / 1024;
    final mb = kb / 1024;

    if (mb > 25) {
      showSnackBar(context, "25MB 미만의 파일만 업로드 가능합니다.");
    } else {
      requestAddActorVideo(context, _videoFile, bytes);
    }
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
            appBar: CustomStyles.defaultAppBar('프로필 관리', () {
              Navigator.pop(context);
            }),
            body: Builder(builder: (BuildContext context) {
              return Stack(children: [
                Container(
                    child: SingleChildScrollView(
                        child: Container(
                            padding: EdgeInsets.only(bottom: 200),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ActorProfileWidget.mainImageWidget(context,
                                      true, KCastingAppData().myProfile, () {
                                    getImageFromGallery(0);
                                  }),
                                  ActorProfileWidget.profileWidget(
                                      context,
                                      _myKeywordTagStateKey,
                                      KCastingAppData().myProfile,
                                      _actorAgeStr,
                                      _actorEducationStr,
                                      _actorLanguageStr,
                                      _actorAbilityStr,
                                      _actorLookKwdList),
                                  Container(
                                      height: 50,
                                      margin: EdgeInsets.only(
                                          left: 15, right: 15, top: 15),
                                      width: double.infinity,
                                      child: CustomStyles
                                          .greyBorderRound7ButtonStyle('프로필 편집',
                                              () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ActorProfileModifyMainInfo()),
                                        );
                                      })),
                                  Container(
                                    margin: EdgeInsets.only(top: 30),
                                    child: Divider(
                                      height: 1,
                                      color: CustomColors.colorFontLightGrey,
                                    ),
                                  ),
                                  ActorProfileWidget.profileTabBarWidget(
                                      _tabController),
                                  Expanded(
                                    flex: 0,
                                    child: [
                                      Container(
                                          margin: EdgeInsets.only(bottom: 30),
                                          child: Column(children: [
                                            Visibility(
                                              child: Container(
                                                  padding: EdgeInsets.only(
                                                      top: 20,
                                                      left: 20,
                                                      right: 20,
                                                      bottom: 15),
                                                  child: Row(children: [
                                                    Expanded(
                                                        flex: 1,
                                                        child: Text(
                                                            '출연 작품: ' +
                                                                _filmorgraphyList
                                                                    .length
                                                                    .toString(),
                                                            style: CustomStyles
                                                                .normal14TextStyle())),
                                                    Expanded(
                                                        flex: 0,
                                                        child: CustomStyles
                                                            .darkBold14TextButtonStyle(
                                                                '추가', () {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          ActorFilmoAdd()));
                                                        })),
                                                    Container(width: 20),
                                                    Expanded(
                                                        flex: 0,
                                                        child: CustomStyles
                                                            .darkBold14TextButtonStyle(
                                                                '편집', () {
                                                          setState(() {
                                                            _isFlimorgraphyListEditMode =
                                                                true;
                                                          });
                                                        }))
                                                  ])),
                                              visible:
                                                  !_isFlimorgraphyListEditMode,
                                            ),
                                            Visibility(
                                              child: Container(
                                                  padding: EdgeInsets.only(
                                                      top: 20,
                                                      left: 20,
                                                      right: 20,
                                                      bottom: 15),
                                                  child: Row(children: [
                                                    Expanded(
                                                        flex: 1,
                                                        child: Text(
                                                            '출연 작품: ' +
                                                                _filmorgraphyList
                                                                    .length
                                                                    .toString(),
                                                            style: CustomStyles
                                                                .normal14TextStyle())),
                                                    Expanded(
                                                        flex: 0,
                                                        child: CustomStyles
                                                            .darkBold14TextButtonStyle(
                                                                '취소', () {
                                                          setState(() {
                                                            _filmorgraphyList
                                                                .clear();
                                                            _filmorgraphyList
                                                                .addAll(
                                                                    _originalFilmorgraphyList);

                                                            _deletedFilmorgraphyList =
                                                                [];

                                                            _isFlimorgraphyListEditMode =
                                                                false;
                                                          });
                                                        })),
                                                    Container(width: 20),
                                                    Expanded(
                                                        flex: 0,
                                                        child: CustomStyles
                                                            .darkBold14TextButtonStyle(
                                                                '저장', () {
                                                          setState(() {
                                                            _originalFilmorgraphyList
                                                                .clear();
                                                            _originalFilmorgraphyList
                                                                .addAll(
                                                                    _filmorgraphyList);

                                                            _isFlimorgraphyListEditMode =
                                                                false;

                                                            if (_deletedFilmorgraphyList
                                                                    .length >
                                                                0)
                                                              requestActorFilmorgraphyDeleteApi(
                                                                  context);
                                                          });
                                                        }))
                                                  ])),
                                              visible:
                                                  _isFlimorgraphyListEditMode,
                                            ),
                                            ActorProfileWidget
                                                .filmorgraphyListWidget(
                                                    _isFlimorgraphyListEditMode,
                                                    _filmorgraphyList, (index) {
                                              setState(() {
                                                _deletedFilmorgraphyList.add(
                                                    _filmorgraphyList[index]
                                                        [APIConstants.seq]);
                                                _filmorgraphyList
                                                    .removeAt(index);
                                              });
                                            })
                                          ])),
                                      Container(
                                          child: Column(children: [
                                        Visibility(
                                          child: Container(
                                              padding: EdgeInsets.only(
                                                  top: 20,
                                                  left: 20,
                                                  right: 20,
                                                  bottom: 15),
                                              child: Row(children: [
                                                Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                        '최대 8장(각 25MB 미만)')),
                                                Expanded(
                                                    flex: 0,
                                                    child: CustomStyles
                                                        .darkBold14TextButtonStyle(
                                                            '추가', () async {
                                                      //
                                                      var status = Platform
                                                              .isAndroid
                                                          ? await Permission
                                                              .storage
                                                              .request()
                                                          : await Permission
                                                              .photos
                                                              .request();
                                                      if (status.isGranted) {
                                                        if (_myPhotos.length ==
                                                            8) {
                                                          showSnackBar(context,
                                                              '이미지는 최대 8장까지 등록하실 수 있습니다.');
                                                        } else {
                                                          getImageFromGallery(
                                                              1);
                                                        }
                                                      } else {
                                                        showDialog(
                                                            context: context,
                                                            builder: (BuildContext
                                                                    context) =>
                                                                CupertinoAlertDialog(
                                                                    title: Text(
                                                                        '저장공간 접근권한'),
                                                                    content: Text(
                                                                        '사진 또는 비디오를 업로드하려면, 기기 사진, 미디어, 파일 접근 권한이 필요합니다.'),
                                                                    actions: <
                                                                        Widget>[
                                                                      CupertinoDialogAction(
                                                                        child: Text(
                                                                            '거부'),
                                                                        onPressed:
                                                                            () =>
                                                                                Navigator.of(context).pop(),
                                                                      ),
                                                                      CupertinoDialogAction(
                                                                          child: Text(
                                                                              '허용'),
                                                                          onPressed: () =>
                                                                              openAppSettings())
                                                                    ]));
                                                      }
                                                      //
                                                    })),
                                                Container(width: 20),
                                                Expanded(
                                                    flex: 0,
                                                    child: CustomStyles
                                                        .darkBold14TextButtonStyle(
                                                            '편집', () {
                                                      setState(() {
                                                        _originalMyPhotos =
                                                            _myPhotos;

                                                        _isImageListEditMode =
                                                            true;
                                                      });
                                                    }))
                                              ])),
                                          visible: !_isImageListEditMode,
                                        ),
                                        Visibility(
                                          child: Container(
                                              padding: EdgeInsets.only(
                                                  top: 20,
                                                  left: 20,
                                                  right: 20,
                                                  bottom: 15),
                                              child: Row(children: [
                                                Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                        '최대 8장(각 25MB 미만)')),
                                                Expanded(
                                                    flex: 0,
                                                    child: CustomStyles
                                                        .darkBold14TextButtonStyle(
                                                            '취소', () {
                                                      setState(() {
                                                        _myPhotos =
                                                            _originalMyPhotos;
                                                        _deletedImageList = [];

                                                        _isImageListEditMode =
                                                            false;
                                                      });
                                                    })),
                                                Container(width: 20),
                                                Expanded(
                                                    flex: 0,
                                                    child: CustomStyles
                                                        .darkBold14TextButtonStyle(
                                                            '저장', () {
                                                      setState(() {
                                                        _originalMyPhotos =
                                                            _myPhotos;

                                                        _isImageListEditMode =
                                                            false;

                                                        if (_deletedImageList
                                                                .length >
                                                            0)
                                                          requestActorImageDeleteApi(
                                                              context);
                                                      });
                                                    }))
                                              ])),
                                          visible: _isImageListEditMode,
                                        ),
                                        ActorProfileWidget.imageTabItemWidget(
                                            _isImageListEditMode, _myPhotos,
                                            (index) {
                                          setState(() {
                                            _deletedImageList.add(
                                                _myPhotos[index]
                                                    [APIConstants.seq]);

                                            _myPhotos.removeAt(index);
                                          });
                                        })
                                      ])),
                                      Container(
                                          margin: EdgeInsets.only(bottom: 30),
                                          child: Column(children: [
                                            Visibility(
                                              child: Container(
                                                padding: EdgeInsets.only(
                                                    top: 20,
                                                    left: 20,
                                                    right: 20,
                                                    bottom: 15),
                                                child: Row(children: [
                                                  Expanded(
                                                      flex: 1,
                                                      child: Text(
                                                          '최대 2개(각 25MB 미만)',
                                                          style: CustomStyles
                                                              .normal14TextStyle())),
                                                  Expanded(
                                                      flex: 0,
                                                      child: CustomStyles
                                                          .darkBold14TextButtonStyle(
                                                              '추가', () async {
                                                        //
                                                        var status = Platform
                                                                .isAndroid
                                                            ? await Permission
                                                                .storage
                                                                .request()
                                                            : await Permission
                                                                .photos
                                                                .request();
                                                        if (status.isGranted) {
                                                          if (_myVideos
                                                                  .length ==
                                                              2) {
                                                            showSnackBar(
                                                                context,
                                                                "비디오는 최대 2개까지 등록하실 수 있습니다.");
                                                          } else {
                                                            getVideoFromGallery();
                                                          }
                                                        } else {
                                                          showDialog(
                                                              context: context,
                                                              builder: (BuildContext
                                                                      context) =>
                                                                  CupertinoAlertDialog(
                                                                    title: Text(
                                                                        '저장공간 접근권한'),
                                                                    content: Text(
                                                                        '사진 또는 비디오를 업로드하려면, 기기 사진, 미디어, 파일 접근 권한이 필요합니다.'),
                                                                    actions: <
                                                                        Widget>[
                                                                      CupertinoDialogAction(
                                                                        child: Text(
                                                                            '거부'),
                                                                        onPressed:
                                                                            () =>
                                                                                Navigator.of(context).pop(),
                                                                      ),
                                                                      CupertinoDialogAction(
                                                                        child: Text(
                                                                            '허용'),
                                                                        onPressed:
                                                                            () =>
                                                                                openAppSettings(),
                                                                      ),
                                                                    ],
                                                                  ));
                                                        }
                                                        //
                                                      })),
                                                  Container(width: 20),
                                                  Expanded(
                                                      flex: 0,
                                                      child: CustomStyles
                                                          .darkBold14TextButtonStyle(
                                                              '편집', () {
                                                        setState(() {
                                                          _originalMyVideos =
                                                              _myVideos;

                                                          _isVideoListEditMode =
                                                              true;
                                                        });
                                                      }))
                                                ]),
                                              ),
                                              visible: !_isVideoListEditMode,
                                            ),
                                            Visibility(
                                              child: Container(
                                                padding: EdgeInsets.only(
                                                    top: 20,
                                                    left: 20,
                                                    right: 20,
                                                    bottom: 15),
                                                child: Row(children: [
                                                  Expanded(
                                                      flex: 1,
                                                      child: Text(
                                                          '최대 2개(각 25MB 미만)',
                                                          style: CustomStyles
                                                              .normal14TextStyle())),
                                                  Expanded(
                                                      flex: 0,
                                                      child: CustomStyles
                                                          .darkBold14TextButtonStyle(
                                                              '취소', () {
                                                        setState(() {
                                                          _myVideos =
                                                              _originalMyVideos;

                                                          _deletedVideoList =
                                                              [];

                                                          _isVideoListEditMode =
                                                              false;
                                                        });
                                                      })),
                                                  Container(width: 20),
                                                  Expanded(
                                                      flex: 0,
                                                      child: CustomStyles
                                                          .darkBold14TextButtonStyle(
                                                              '저장', () {
                                                        setState(() {
                                                          _originalMyVideos =
                                                              _myVideos;

                                                          _isVideoListEditMode =
                                                              false;

                                                          if (_deletedVideoList
                                                                  .length >
                                                              0)
                                                            requestActorVideoDeleteApi(
                                                                context);
                                                        });
                                                      }))
                                                ]),
                                              ),
                                              visible: _isVideoListEditMode,
                                            ),
                                            ActorProfileWidget
                                                .videoTabItemWidget(
                                                    _isVideoListEditMode,
                                                    _myVideos, (index) {
                                              setState(() {
                                                _deletedVideoList.add(
                                                    _myVideos[index]
                                                        [APIConstants.seq]);
                                                _myVideos.removeAt(index);
                                              });
                                            })
                                          ]))
                                    ][_tabIndex],
                                  )
                                ])))),
                Visibility(
                  child: Container(
                      color: Colors.black38,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator()),
                  visible: _isUpload,
                )
              ]);
            })));
  }
}
