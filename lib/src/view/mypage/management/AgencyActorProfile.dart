import 'dart:async';
import 'dart:convert';

// import 'dart:html' as html;
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
import 'package:casting_call/src/view/mypage/management/AgencyActorProfileModifyMainInfo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

// import 'package:image_picker_web/image_picker_web.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

/*
*  보유 배우 프로필
* */
class AgencyActorProfile extends StatefulWidget {
  final int seq;
  final int actorProfileSeq;

  const AgencyActorProfile({Key key, this.seq, this.actorProfileSeq})
      : super(key: key);

  @override
  _AgencyActorProfile createState() => _AgencyActorProfile();
}

class _AgencyActorProfile extends State<AgencyActorProfile>
    with SingleTickerProviderStateMixin, BaseUtilMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  int _seq;
  int _actorProfileSeq;

  File _profileImgFile;
  Uint8List _profileImgFile2;
  final picker = ImagePicker();

  TabController _tabController;
  int _tabIndex = 0;

  bool _isUpload = false;

  Map<String, dynamic> _actorProfile = new Map();
  List<dynamic> _actorEducation = [];
  List<dynamic> _actorLanguage = [];
  List<dynamic> _actorDialect = [];
  List<dynamic> _actorAbility = [];
  List<dynamic> _actorCastingKwd = [];
  List<dynamic> _actorLookKwd = [];
  String _actorAgeStr = "";
  String _actorEducationStr = "";
  String _actorLanguageStr = "";
  String _actorDialectStr = "";
  String _actorAbilityStr = "";
  List<String> _actorKwdList = [];
  final GlobalKey<TagsState> _myKeywordTagStateKey = GlobalKey<TagsState>();

  List<dynamic> _actorFilmorgraphy = [];
  List<dynamic> _originalFilmorgraphyList = [];
  List<int> _deletedFilmorgraphyList = [];
  bool _isFlimorgraphyListEditMode = false;

  List<dynamic> _actorImage = [];
  List<dynamic> _originalMyPhotos = [];
  List<int> _deletedImageList = [];
  bool _isImageListEditMode = false;

  List<dynamic> _actorVideo = [];
  List<dynamic> _originalMyVideos = [];
  List<int> _deletedVideoList = [];
  bool _isVideoListEditMode = false;

  @override
  void initState() {
    super.initState();

    _seq = widget.seq;
    _actorProfileSeq = widget.actorProfileSeq;

    requestActorProfileApi(context);

    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _tabIndex = _tabController.index;
        });
      }
    });
  }

  /*
  * 배우프로필조회
  * */
  void requestActorProfileApi(BuildContext context) {
    final dio = Dio();

    // 배우프로필조회 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetData = new Map();
    targetData[APIConstants.actor_seq] = _seq;
    targetData[APIConstants.actor_profile_seq] = _actorProfileSeq;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.SAR_APR_INFO;
    params[APIConstants.target] = targetData;

    _actorKwdList.clear();

    // 배우프로필조회 api 호출
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value == null) {
        // 에러 - 데이터 널
        showSnackBar(context, APIConstants.error_msg_server_not_response);
      } else {
        if (value[APIConstants.resultVal]) {
          // 배우프로필조회 성공
          var _responseList = value[APIConstants.data] as List;

          setState(() {
            for (int i = 0; i < _responseList.length; i++) {
              var _data = _responseList[i];

              switch (_data[APIConstants.table]) {
                // 배우 프로필
                case APIConstants.table_actor_profile:
                  {
                    var _listData = _data[APIConstants.data];
                    if (_listData != null) {
                      List<dynamic> _actorProfileList =
                          _listData[APIConstants.list] as List;
                      if (_actorProfileList != null) {
                        _actorProfile = _actorProfileList.length > 0
                            ? _actorProfileList[0]
                            : null;
                      }
                    }
                    break;
                  }

                // 배우 학력사항
                case APIConstants.table_actor_education:
                  {
                    var _listData = _data[APIConstants.data];
                    if (_listData != null) {
                      _actorEducation.clear();
                      _actorEducation.addAll(_listData[APIConstants.list]);
                    } else {
                      _actorEducation = [];
                    }

                    _actorEducationStr = "";
                    for (int i = 0; i < _actorEducation.length; i++) {
                      var _eduData = _actorEducation[i];
                      _actorEducationStr +=
                          _eduData[APIConstants.education_name];
                      _actorEducationStr += "\t";
                      _actorEducationStr += _eduData[APIConstants.major_name];

                      if (i != _actorEducation.length - 1)
                        _actorEducationStr += "\n";
                    }

                    break;
                  }

                // 배우 언어
                case APIConstants.table_actor_languge:
                  {
                    var _listData = _data[APIConstants.data];

                    if (_listData != null) {
                      _actorLanguage.clear();
                      _actorLanguage.addAll(_listData[APIConstants.list]);
                    } else {
                      _actorLanguage = [];
                    }

                    _actorLanguageStr = "";
                    for (int i = 0; i < _actorLanguage.length; i++) {
                      var _lanData = _actorLanguage[i];
                      _actorLanguageStr += _lanData[APIConstants.language_type];

                      if (i != _actorLanguage.length - 1)
                        _actorLanguageStr += "\t";
                    }

                    break;
                  }

                // 배우 사투리
                case APIConstants.table_actor_dialect:
                  {
                    var _listData = _data[APIConstants.data];

                    if (_listData != null) {
                      _actorDialect.clear();
                      _actorDialect.addAll(_listData[APIConstants.list]);
                    } else {
                      _actorDialect = [];
                    }

                    _actorDialectStr = "";
                    for (int i = 0; i < _actorDialect.length; i++) {
                      var _lanData = _actorDialect[i];
                      _actorDialectStr += _lanData[APIConstants.dialect_type];

                      if (i != _actorDialect.length - 1)
                        _actorDialectStr += "\t";
                    }

                    break;
                  }

                // 배우 특기
                case APIConstants.table_actor_ability:
                  {
                    var _listData = _data[APIConstants.data];

                    if (_listData != null) {
                      _actorAbility.clear();
                      _actorAbility.addAll(_listData[APIConstants.list]);
                    } else {
                      _actorAbility = [];
                    }

                    _actorAbilityStr = "";
                    for (int i = 0; i < _actorAbility.length; i++) {
                      var _abilityData = _actorAbility[i];
                      _actorAbilityStr += _abilityData[APIConstants.child_type];

                      if (i != _actorAbility.length - 1)
                        _actorAbilityStr += ",\t";
                    }
                    break;
                  }

                // 배우 키워드
                case APIConstants.table_actor_castingKwd:
                  {
                    var _listData = _data[APIConstants.data];

                    if (_listData != null) {
                      _actorCastingKwd.clear();
                      _actorCastingKwd.addAll(_listData[APIConstants.list]);
                    } else {
                      _actorCastingKwd = [];
                    }

                    for (int i = 0; i < _actorCastingKwd.length; i++) {
                      var _lookKwdData = _actorCastingKwd[i];

                      for (int j = 0;
                      j < KCastingAppData().commonCodeK01.length;
                      j++) {
                        var _lookKwdCode = KCastingAppData().commonCodeK01[j];

                        if (_lookKwdData[APIConstants.code_seq] ==
                            _lookKwdCode[APIConstants.seq]) {
                          _actorKwdList.add(_lookKwdCode[APIConstants.child_name]);
                        }
                      }
                    }

                    break;
                  }

                // 배우 외모 키워드
                case APIConstants.table_actor_lookkwd:
                  {
                    var _listData = _data[APIConstants.data];

                    if (_listData != null) {
                      _actorLookKwd.clear();
                      _actorLookKwd.addAll(_listData[APIConstants.list]);
                    } else {
                      _actorLookKwd = [];
                    }

                    for (int i = 0; i < _actorLookKwd.length; i++) {
                      var _lookKwdData = _actorLookKwd[i];

                      for (int j = 0;
                          j < KCastingAppData().commonCodeK02.length;
                          j++) {
                        var _lookKwdCode = KCastingAppData().commonCodeK02[j];

                        if (_lookKwdData[APIConstants.code_seq] ==
                            _lookKwdCode[APIConstants.seq]) {
                          _actorKwdList.add(_lookKwdCode[APIConstants.child_name]);
                        }
                      }
                    }

                    break;
                  }

                // 배우 필모그래피
                case APIConstants.table_actor_filmography:
                  {
                    var _listData = _data[APIConstants.data];
                    if (_listData != null) {
                      _actorFilmorgraphy.clear();
                      _actorFilmorgraphy.addAll(_listData[APIConstants.list]);
                      _originalFilmorgraphyList.clear();
                      _originalFilmorgraphyList.addAll(_listData[APIConstants.list]);
                    } else {
                      _actorFilmorgraphy = [];
                      _originalFilmorgraphyList = [];
                    }
                    break;
                  }

                // 배우 이미지
                case APIConstants.table_actor_image:
                  {
                    var _listData = _data[APIConstants.data];
                    if (_listData != null) {
                      _actorImage.clear();
                      _actorImage.addAll(_listData[APIConstants.list]);
                      _originalMyPhotos.clear();
                      _originalMyPhotos.addAll(_listData[APIConstants.list]);
                    } else {
                      _actorImage = [];
                      _originalMyPhotos = [];
                    }
                    break;
                  }

                // 배우 비디오
                case APIConstants.table_actor_video:
                  {
                    var _listData = _data[APIConstants.data];
                    if (_listData != null) {
                      _actorVideo.clear();
                      _actorVideo.addAll(_listData[APIConstants.list]);
                      _originalMyVideos.clear();
                      _originalMyVideos.addAll(_listData[APIConstants.list]);
                    } else {
                      _actorVideo = [];
                      _originalMyVideos = [];
                    }

                    break;
                  }
              }
            }
          });
        } else {
          // 배우프로필조회 실패
          showSnackBar(context, APIConstants.error_msg_try_again);
        }
      }
    });
  }

  /*
  * 배우프로필 이미지 수정
  * */
  void requestUpdateActorProfile(BuildContext context, File profileFile) async {
    final dio = Dio();

    Map<String, dynamic> targetData = new Map();
    targetData[APIConstants.seq] = _actorProfileSeq;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.UPD_APR_MAINIMG_FORMDATA;
    params[APIConstants.target] = targetData;

    var temp = profileFile.path.split('/');
    String fileName = temp[temp.length - 1];
    params[APIConstants.target_files_array] =
        await MultipartFile.fromFile(profileFile.path, filename: fileName);

    // 배우프로필 이미지 수정 api 호출
    RestClient(dio).postRequestMainControlFormData(params).then((value) async {
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
                _actorProfile[APIConstants.main_img_url] =
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

  void requestUpdateActorProfileWeb(
      BuildContext context, Uint8List profileFile) async {
    var client = new http.Client();
    try {
      /*  List<html.File> fileArr = [];
      fileArr.add(profileFile);*/

      var uri = Uri.parse(APIConstants.getURL(APIConstants.URL_MAIN_CONTROL));

      Map<String, String> targetData = new Map();
      targetData[APIConstants.seq] = _actorProfileSeq.toString();
      Map<String, String> params = new Map();
      params[APIConstants.key] = 'UPD_APR_MAINIMG_FormData_one';
      //params[APIConstants.key] = APIConstants.UPD_APR_MAINIMG_FORMDATA;
      params[APIConstants.target] = json.encode(targetData);

      http.MultipartRequest request = new http.MultipartRequest('POST', uri)
        ..fields.addAll(params);

      /*http.MultipartRequest request = new http.MultipartRequest('POST', uri);
      request.fields.ad*/

      //요청에 이미지 파일 추가
      /*for (int i = 0; i < fileArr.length; i++) {
        request.files.add(
          http.MultipartFile(
            'target_files$i',
            http.ByteStream.fromBytes(await _getHtmlFileContent(fileArr[i])),
            fileArr[i].size
          ),
        );
      }*/

      request.files.add(
          http.MultipartFile.fromBytes(APIConstants.target_files, profileFile));


    } catch (e) {

    } finally {
      client.close();
    }
  }

  /*Future<Uint8List> _getHtmlFileContent(html.File blob) async {
    Uint8List file;
    final reader = html.FileReader();
    reader.readAsDataUrl(blob.slice(0, blob.size, blob.type));
    reader.onLoadEnd.listen((event) {
      Uint8List data =
          Base64Decoder().convert(reader.result.toString().split(",").last);
      file = data;
    }).onData((data) {
      file = Base64Decoder().convert(reader.result.toString().split(",").last);
      return file;
    });
    while (file == null) {
      await new Future.delayed(const Duration(milliseconds: 1));
      if (file != null) {
        break;
      }
    }
    return file;
  }*/

  /*
  *배우 필모그래피 삭제
  * */
  void requestActorFilmorgraphyDeleteApi(BuildContext context) {
    final dio = Dio();

    // 배우 필모그래피 삭제 api 호출 시 보낼 파라미터
    Map<String, dynamic> callbackDatas = new Map();
    callbackDatas[APIConstants.actor_seq] = _seq;

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
                _actorFilmorgraphy = _responseList;
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
  void requestAddActorImage(BuildContext context, File profileFile) async {
    // 배우 이미지 추가 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetData = new Map();
    targetData[APIConstants.actor_seq] = _seq;

    var files = [];
    var temp = profileFile.path.split('/');
    String fileName = temp[temp.length - 1];
    files.add(
        await MultipartFile.fromFile(profileFile.path, filename: fileName));

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.INS_AIM_LIST_FORMDATA;
    params[APIConstants.target] = targetData;
    params[APIConstants.target_files_array] = files;

    // 배우 이미지 추가 api 호출
    RestClient(Dio())
        .postRequestMainControlFormData(params)
        .then((value) async {
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
              _actorImage = _responseList;
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
    callbackDatas[APIConstants.actor_seq] = _seq;

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
                _actorImage = _responseList;
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
      BuildContext context, File videoFile, String thumbFilePath) async {
    setState(() {
      _isUpload = true;
    });

    try {
      final dio = Dio();

      // 배우 비디오 추가 api 호출 시 보낼 파라미터
      Map<String, dynamic> targetData = new Map();
      targetData[APIConstants.actor_seq] = _seq;

      var files = [];
      var temp = videoFile.path.split('/');
      String fileName = temp[temp.length - 1];
      files.add(
          await MultipartFile.fromFile(videoFile.path, filename: fileName));

      var thums = [];
      var tempImg = thumbFilePath.split('/');
      String thumbFileName = tempImg[tempImg.length - 1];
      thums.add(
          await MultipartFile.fromFile(thumbFilePath, filename: thumbFileName));

      Map<String, dynamic> params = new Map();
      params[APIConstants.key] = APIConstants.INS_AVD_LIST_FORMDATA;
      params[APIConstants.target] = targetData;
      params[APIConstants.target_files_array] = files;
      params[APIConstants.target_files_thumb_array] = thums;

      // 배우 비디오 추가 api 호출
      RestClient(dio)
          .postRequestMainControlFormData(params)
          .then((value) async {
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
                _actorVideo = _responseList;
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
    callbackDatas[APIConstants.actor_seq] = _seq;

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
              _actorVideo = _responseList;
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
    // 웹 테스트
    /*Uint8List bytesFromPicker = await ImagePickerWeb.getImage(outputType: ImageType.bytes);
    requestUpdateActorProfileWeb(context, bytesFromPicker);

    setState(() {
      _profileImgFile2 = bytesFromPicker;
    });*/

    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (type == 0) {
        _profileImgFile = File(pickedFile.path);

        requestUpdateActorProfile(context, _profileImgFile);
      } else {
        File _image = File(pickedFile.path);

        final size = _image.readAsBytesSync().lengthInBytes;
        final kb = size / 1024;
        final mb = kb / 1024;

        if (mb > 100) {
          showSnackBar(context, "100MB 미만의 파일만 업로드 가능합니다.");
        } else {
          requestAddActorImage(context, _image);
        }
      }
    } else {
      showSnackBar(context, "선택된 이미지가 없습니다.");
    }
  }

  Future getVideoFromGallery() async {
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      getVideoThumbnail(pickedFile.path);
    } else {
      showSnackBar(context, "선택된 이미지가 없습니다.");
    }
  }

  getVideoThumbnail(String filePath) async {
    final fileName = await VideoThumbnail.thumbnailFile(
        video: filePath,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.JPEG);

    var _videoFile = File(filePath);
    final size = _videoFile.readAsBytesSync().lengthInBytes;
    final kb = size / 1024;
    final mb = kb / 1024;

    if (mb > 100) {
      showSnackBar(context, "100MB 미만의 파일만 업로드 가능합니다.");
    } else {
      requestAddActorVideo(context, _videoFile, fileName);
    }
  }

  /*
  *  메인 위젯
  * */
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          Navigator.pop(context);
          return Future.value(false);
        },
        child: Theme(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ActorProfileWidget.mainImageWidget(
                                          context, true, _actorProfile, () {
                                        getImageFromGallery(0);
                                      }),
                                      ActorProfileWidget.profileWidget(
                                          context,
                                          _myKeywordTagStateKey,
                                          _actorProfile,
                                          _actorAgeStr,
                                          _actorEducationStr,
                                          _actorLanguageStr,
                                          _actorDialectStr,
                                          _actorAbilityStr,
                                          _actorKwdList),
                                      Container(
                                          height: 50,
                                          margin: EdgeInsets.only(
                                              left: 15, right: 15, top: 15),
                                          width: double.infinity,
                                          child: CustomStyles
                                              .greyBorderRound7ButtonStyle(
                                                  '프로필 편집', () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        AgencyActorProfileModifyMainInfo(
                                                            actorProfileSeq:
                                                                _actorProfileSeq,
                                                            actorProfile:
                                                                _actorProfile,
                                                            actorEducation:
                                                                _actorEducation,
                                                            actorLanguage:
                                                                _actorLanguage,
                                                            actorDialect:
                                                                _actorDialect,
                                                            actorAbility:
                                                                _actorAbility,
                                                            actorCastingKwd:
                                                                _actorCastingKwd,
                                                            actorLookKwd:
                                                                _actorLookKwd))).then(
                                                (value) => {
                                                      requestActorProfileApi(
                                                          context)
                                                    });
                                          })),
                                      Container(
                                        margin: EdgeInsets.only(top: 30),
                                        child: Divider(
                                          height: 1,
                                          color:
                                              CustomColors.colorFontLightGrey,
                                        ),
                                      ),
                                      ActorProfileWidget.profileTabBarWidget(
                                          _tabController),
                                      Expanded(
                                        flex: 0,
                                        child: [
                                          Container(
                                              margin:
                                                  EdgeInsets.only(bottom: 30),
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
                                                                    _actorFilmorgraphy
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
                                                                    builder: (context) =>
                                                                        ActorFilmoAdd(
                                                                            actorSeq:
                                                                                _seq)),
                                                              )
                                                                  .then(
                                                                      (value) =>
                                                                          {
                                                                            requestActorProfileApi(context)
                                                                          });
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
                                                                    _actorFilmorgraphy
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
                                                                _actorFilmorgraphy
                                                                    .clear();
                                                                _actorFilmorgraphy
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
                                                                        _actorFilmorgraphy);

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
                                                        _actorFilmorgraphy,
                                                        (index) {
                                                  setState(() {
                                                    _deletedFilmorgraphyList
                                                        .add(_actorFilmorgraphy[
                                                                index]
                                                            [APIConstants.seq]);
                                                    _actorFilmorgraphy
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
                                                          if (status
                                                              .isGranted) {
                                                            if (_actorImage
                                                                    .length ==
                                                                8) {
                                                              showSnackBar(
                                                                  context,
                                                                  '이미지는 최대 8장까지 등록하실 수 있습니다.');
                                                            } else {
                                                              getImageFromGallery(
                                                                  1);
                                                            }
                                                          } else {
                                                            showDialog(
                                                                context:
                                                                    context,
                                                                builder: (BuildContext
                                                                        context) =>
                                                                    CupertinoAlertDialog(
                                                                        title: Text(
                                                                            '저장공간 접근권한'),
                                                                        content:
                                                                            Text(
                                                                                '사진 또는 비디오를 업로드하려면, 기기 사진, 미디어, 파일 접근 권한이 필요합니다.'),
                                                                        actions: <
                                                                            Widget>[
                                                                          CupertinoDialogAction(
                                                                            child:
                                                                                Text('거부'),
                                                                            onPressed: () =>
                                                                                Navigator.of(context).pop(),
                                                                          ),
                                                                          CupertinoDialogAction(
                                                                              child: Text('허용'),
                                                                              onPressed: () => openAppSettings())
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
                                                            _actorImage.clear();
                                                            _actorImage.addAll(
                                                                _originalMyPhotos);

                                                            _deletedVideoList =
                                                                [];

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
                                                            _originalMyPhotos
                                                                .clear();
                                                            _originalMyPhotos
                                                                .addAll(
                                                                    _actorImage);

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
                                            ActorProfileWidget
                                                .imageTabItemWidget(
                                                    _isImageListEditMode,
                                                    _actorImage, (index) {
                                              setState(() {
                                                _deletedImageList.add(
                                                    _actorImage[index]
                                                        [APIConstants.seq]);

                                                _actorImage.removeAt(index);
                                              });
                                            })
                                          ])),
                                          Container(
                                              margin:
                                                  EdgeInsets.only(bottom: 30),
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
                                                                  '추가',
                                                                  () async {
                                                            //
                                                            var status = Platform.isAndroid
                                                                ? await Permission
                                                                    .storage
                                                                    .request()
                                                                : await Permission
                                                                    .photos
                                                                    .request();
                                                            if (status
                                                                .isGranted) {
                                                              if (_actorVideo
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
                                                                  context:
                                                                      context,
                                                                  builder: (BuildContext
                                                                          context) =>
                                                                      CupertinoAlertDialog(
                                                                        title: Text(
                                                                            '저장공간 접근권한'),
                                                                        content:
                                                                            Text('사진 또는 비디오를 업로드하려면, 기기 사진, 미디어, 파일 접근 권한이 필요합니다.'),
                                                                        actions: <
                                                                            Widget>[
                                                                          CupertinoDialogAction(
                                                                            child:
                                                                                Text('거부'),
                                                                            onPressed: () =>
                                                                                Navigator.of(context).pop(),
                                                                          ),
                                                                          CupertinoDialogAction(
                                                                            child:
                                                                                Text('허용'),
                                                                            onPressed: () =>
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
                                                              _isVideoListEditMode =
                                                                  true;
                                                            });
                                                          }))
                                                    ]),
                                                  ),
                                                  visible:
                                                      !_isVideoListEditMode,
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
                                                              _actorVideo
                                                                  .clear();
                                                              _actorVideo.addAll(
                                                                  _originalMyVideos);

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
                                                              _originalMyVideos
                                                                  .clear();
                                                              _originalMyVideos
                                                                  .addAll(
                                                                      _actorVideo);

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
                                                Container(
                                                  margin: EdgeInsets.only(left: 20, right: 20),
                                                  child: Text(
                                                    '* 비디오 업로드는 시간이 소요될 수 있습니다. 업로드하신 비디오 페이지를 찾을 수 없다고 표시되는 경우에는 잠시 후에 다시 실행해 주세요.',
                                                    style: CustomStyles
                                                        .dark12TextStyle(),
                                                  ),
                                                ),
                                                ActorProfileWidget
                                                    .videoTabItemWidget(
                                                        _isVideoListEditMode,
                                                        _actorVideo, (index) {
                                                  setState(() {
                                                    _deletedVideoList.add(
                                                        _actorVideo[index]
                                                            [APIConstants.seq]);
                                                    _actorVideo.removeAt(index);
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
                }))));
  }
}
