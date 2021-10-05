import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/model/VideoListModel.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../../KCastingAppData.dart';
import 'AuditionApplyUploadImage.dart';
import 'AuditionApplyUploadProfile.dart';

/*
* 오디션 지원하기 - 비디오 업로드
* */
class AuditionApplyUploadVideo extends StatefulWidget {
  final int castingSeq;
  final String projectName;
  final String castingName;
  final List<Map<String, dynamic>> dbImgages;
  final List<File> newImgages;
  final List<MultipartFile> newImageMultipartFiles;
  final int actorSeq;
  final int actorProfileSeq;

  const AuditionApplyUploadVideo(
      {Key key,
      this.castingSeq,
      this.projectName,
      this.castingName,
      this.dbImgages,
      this.newImgages,
      this.newImageMultipartFiles,
      this.actorSeq,
      this.actorProfileSeq})
      : super(key: key);

  @override
  _AuditionApplyUploadVideo createState() => _AuditionApplyUploadVideo();
}

class _AuditionApplyUploadVideo extends State<AuditionApplyUploadVideo>
    with BaseUtilMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  bool _kIsWeb;

  final picker = ImagePicker();

  int _castingSeq;
  String _projectName;
  String _castingName;
  List<Map<String, dynamic>> _dbImgages;
  List<File> _newImgages;
  List<MultipartFile> _newImageMultipartFiles;
  int _actorSeq;
  int _actorProfileSeq;

  List<VideoListModel> _myVideos = [];

  bool _isUpload = false;

  var actorVideo = [];

  @override
  void initState() {
    super.initState();

    try {
      if (Platform.isAndroid || Platform.isIOS) {
        _kIsWeb = false;
      } else {
        _kIsWeb = true;
      }
    } catch (e) {
      _kIsWeb = true;
    }

    _castingSeq = widget.castingSeq;
    _projectName = widget.projectName;
    _castingName = widget.castingName;
    _dbImgages = widget.dbImgages;
    _newImgages = widget.newImgages;
    _newImageMultipartFiles = widget.newImageMultipartFiles;
    _actorSeq = widget.actorSeq;
    _actorProfileSeq = widget.actorProfileSeq;

    if (KCastingAppData().myInfo[APIConstants.member_type] ==
        APIConstants.member_type_actor) {
      actorVideo = KCastingAppData().myVideo;

      // 배우 비디오
      for (int i = 0; i < actorVideo.length; i++) {
        _myVideos
            .add(new VideoListModel(false, false, null, null, actorVideo[i], null, null));
      }
    } else {
      // 매니지먼트 보유 배우 비디오 목록 api 호출
      requestActorListApi(context);
    }
  }

  /*
  * 매니지먼트 보유 배우 비디오 목록 api 호출
  * */
  void requestActorListApi(BuildContext context) {
    final dio = Dio();

    // 매니지먼트 보유 배우 비디오 목록 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetData = new Map();
    targetData[APIConstants.actor_seq] = _actorSeq;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.SEL_AVD_LIST;
    params[APIConstants.target] = targetData;

    // 매니지먼트 보유 배우 비디오 목록 api 호출
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value != null) {
        if (value[APIConstants.resultVal]) {
          try {
            // 매니지먼트 보유 배우 비디오 목록 성공
            setState(() {
              var _responseList = value[APIConstants.data];
              if (_responseList != null && _responseList.length > 0) {
                actorVideo.addAll(_responseList[APIConstants.list]);

                for (int i = 0; i < actorVideo.length; i++) {
                  _myVideos.add(new VideoListModel(
                      false, false, null, null, actorVideo[i], null, null));
                }
              }
            });
          } catch (e) {}
        }
      }
    });
  }

  // 갤러리에서 비디오 가져오기
  Future getVideoFromGallery() async {
    if(KCastingAppData().isWeb){
      final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
      if (pickedFile != null) {

        pickedFile.readAsBytes().then((value){
          List<String> mimeTypeArr = pickedFile.mimeType.split('/');
          List<int> _selectedFile = value;

          MultipartFile _multipartFileThumb =  MultipartFile.fromBytes(
              _selectedFile,
              contentType: new MediaType(mimeTypeArr[0], mimeTypeArr[1]),
              filename: pickedFile.name);

          MultipartFile _multipartFileVideo =  MultipartFile.fromBytes(
              _selectedFile,
              contentType: new MediaType(mimeTypeArr[0], mimeTypeArr[1]),
              filename: pickedFile.name);

          final size = value.lengthInBytes;
          final kb = size / 1024;
          final mb = kb / 1024;

          if (mb > 100) {
            showSnackBar(context, "100MB 미만의 파일만 업로드 가능합니다.");
          } else {
            getVideoThumbnailWeb(context, _multipartFileThumb, _multipartFileVideo);
          }
        });
      } else {
        showSnackBar(context, "선택된 비디오가 없습니다.");
      }
    }else{
      final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
      if (pickedFile != null) {
        //print(pickedFile.path);

        getVideoThumbnail(pickedFile.path);
      } else {
        showSnackBar(context, "선택된 비디오가 없습니다.");
      }
    }
  }

  getVideoThumbnailWeb(BuildContext context, MultipartFile thumbMultipartFile, MultipartFile videoMultipartFile){
    setState(() {
      _isUpload = true;
    });

    // 배우 비디오 추가 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetData = new Map();
    targetData[APIConstants.actor_seq] =
        KCastingAppData().myInfo[APIConstants.seq].toString();

    var files = [];
    files.add(thumbMultipartFile);

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.SEL_TOT_VIDEOTHUMBNAIL;
    params[APIConstants.target] = targetData;
    params[APIConstants.target_video] = files;

    // 배우 비디오 추가 api 호출
    RestClient(Dio())
        .postRequestMainControlFormData(params)
        .then((value) async {
      try {
        if (value == null) {
          // 에러 - 데이터 널
          showSnackBar(context, APIConstants.error_msg_server_not_response);
        } else {
          if (value[APIConstants.resultVal]) {
            // 배우 비디오 추가 성공
            var _responseData = value[APIConstants.data];
            print("_responseData : $_responseData}");

            setState(() {
              _isUpload = false;
                  _myVideos.add(
                      new VideoListModel(true, false, null, null, null, videoMultipartFile, _responseData['url_thumbnail']));
            });
          } else {
            // 배우 비디오 추가 실패
            showSnackBar(context, APIConstants.error_msg_try_again);
          }
        }
      } catch (e) {
        showSnackBar(context, APIConstants.error_msg_try_again);
      } finally {
        setState(() {
          _isUpload = false;
        });
      }
    });
  }

  getVideoThumbnail(String filePath) async {
    /*var _videoFile = File(filePath);

    Uint8List _thumbnailBytes = await VideoThumbnail.thumbnailData(
        video: filePath, imageFormat: ImageFormat.JPEG);*/

    final thumbFileName = await VideoThumbnail.thumbnailFile(
        video: filePath,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.JPEG);

    var _videoFile = File(filePath);
    var _videoThumbFile = File(thumbFileName);

    setState(() {
      final size = _videoFile.readAsBytesSync().lengthInBytes;
      final kb = size / 1024;
      final mb = kb / 1024;

      if (mb > 100) {
        showSnackBar(context, "100MB 미만의 파일만 업로드 가능합니다.");
      } else {
        _myVideos.add(
            new VideoListModel(true, false, _videoFile, _videoThumbFile, null, null, null));
      }
    });
  }

  /*
  * 메인 위젯
  * */
  @override
  Widget build(BuildContext context) {
    return Theme(
        data: CustomStyles.defaultTheme(),
        child: Align(
            alignment: Alignment.topCenter,
            child: Container(
                width: KCastingAppData().isWeb
                    ? CustomStyles.appWidth
                    : double.infinity,
                child: Scaffold(
                    key: _scaffoldKey,
                    appBar: CustomStyles.defaultAppBar('비디오 업로드', () {
                      Navigator.pop(context);
                    }),
                    body: Builder(builder: (BuildContext context) {
                      return Stack(children: [
                        Container(
                            child: Column(children: [
                          Expanded(
                              flex: 1,
                              child: SingleChildScrollView(
                                  child: Container(
                                      padding:
                                          EdgeInsets.only(top: 20, bottom: 30),
                                      child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
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
                                                margin:
                                                    EdgeInsets.only(top: 5.0),
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
                                                color: CustomColors
                                                    .colorFontLightGrey,
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.only(
                                                  left: 15, right: 15),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                decoration: new BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: CustomColors
                                                      .colorFontTitle,
                                                ),
                                                child: new Text('2',
                                                    style: new TextStyle(
                                                        color: Colors.white,
                                                        fontSize:
                                                            20.0)), // You can add a Icon instead of text also, like below.
                                                //child: new Icon(Icons.arrow_forward, size: 50.0, color: Colors.black38)),
                                              ),
                                            ),
                                            Container(
                                                margin:
                                                    EdgeInsets.only(top: 5.0),
                                                padding: EdgeInsets.only(
                                                    left: 15, right: 15),
                                                child: Text('비디오 업로드',
                                                    style: CustomStyles
                                                        .bold14TextStyle())),
                                            Container(
                                                margin: EdgeInsets.only(top: 5),
                                                padding: EdgeInsets.only(
                                                    left: 15, right: 15),
                                                child: Text(
                                                    '나를 잘 나타내는 비디오 2개을 선택 또는 업로드 해주세요.',
                                                    style: CustomStyles
                                                        .normal14TextStyle())),
                                            Container(
                                              margin: EdgeInsets.only(
                                                  top: 15, bottom: 20),
                                              padding: EdgeInsets.only(
                                                  left: 15, right: 15),
                                              child: ElevatedButton.icon(
                                                  icon: Icon(Icons.camera_alt,
                                                      color: CustomColors
                                                          .colorFontTitle),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    primary: Colors.white,
                                                    padding: EdgeInsets.only(
                                                        left: 15,
                                                        right: 20,
                                                        top: 10,
                                                        bottom: 10),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                CustomStyles
                                                                    .circle7BorderRadius(),
                                                            side: BorderSide(
                                                              color: CustomColors
                                                                  .colorFontGrey,
                                                            )),
                                                    elevation: 0.0,
                                                  ),
                                                  onPressed: () async {
                                                    if (_kIsWeb) {
                                                      getVideoFromGallery();
                                                    } else {
                                                      var status = Platform
                                                              .isAndroid
                                                          ? await Permission
                                                              .storage
                                                              .request()
                                                          : await Permission
                                                              .photos
                                                              .request();
                                                      if (status.isGranted) {
                                                        getVideoFromGallery();
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
                                                    }
                                                  },
                                                  label: Text("업로드",
                                                      style: CustomStyles
                                                          .normal16TextStyle())),
                                            ),
                                            ListView.separated(
                                                shrinkWrap: true,
                                                padding: EdgeInsets.only(
                                                    left: 15,
                                                    right: 15,
                                                    bottom: 10),
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                itemCount: _myVideos.length,
                                                itemBuilder: (context, index) {
                                                  if(KCastingAppData().isWeb){
                                                    return Stack(
                                                      alignment: Alignment.center,
                                                      children: <Widget>[
                                                        Container(
                                                            width: (KCastingAppData().isWeb)
                                                                ? CustomStyles.appWidth
                                                                : MediaQuery.of(context)
                                                                .size
                                                                .width,
                                                            margin:
                                                            EdgeInsets.only(
                                                                bottom: 10),
                                                            height: 200,
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                CustomStyles
                                                                    .circle7BorderRadius(),
                                                                border: Border.all(
                                                                    width: 5,
                                                                    color: (_myVideos[index]
                                                                        .isSelected
                                                                        ? CustomColors
                                                                        .colorAccent
                                                                        : CustomColors
                                                                        .colorFontLightGrey))),
                                                            child: _myVideos[index]
                                                                .isFile
                                                                ? CachedNetworkImage(
                                                                placeholder: (context, url) => Container(
                                                                    alignment:
                                                                    Alignment.center,
                                                                    child: CircularProgressIndicator()),
                                                                imageUrl: _myVideos[index].thumbnailUrl,
                                                                fit: BoxFit.cover,
                                                                errorWidget: (context, url, error) => Container())
                                                                : CachedNetworkImage(
                                                                placeholder: (context, url) => Container(
                                                                    alignment:
                                                                    Alignment.center,
                                                                    child: CircularProgressIndicator()),
                                                                imageUrl: _myVideos[index].videoData[APIConstants.actor_video_url_thumb],
                                                                fit: BoxFit.cover,
                                                                errorWidget: (context, url, error) => Container())),
                                                        Container(
                                                            width: (KCastingAppData().isWeb)
                                                                ? CustomStyles.appWidth
                                                                : MediaQuery.of(
                                                                context)
                                                                .size
                                                                .width,
                                                            height: 200,
                                                            margin:
                                                            EdgeInsets.all(
                                                                10),
                                                            alignment: Alignment
                                                                .topRight,
                                                            child: InkWell(
                                                              onTap: () {
                                                                setState(() {
                                                                  _myVideos[index]
                                                                      .isSelected =
                                                                  !_myVideos[
                                                                  index]
                                                                      .isSelected;
                                                                });
                                                              },
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    color: (_myVideos[
                                                                    index]
                                                                        .isSelected
                                                                        ? CustomColors
                                                                        .colorAccent
                                                                        : CustomColors
                                                                        .colorFontLightGrey)),
                                                                child: Padding(
                                                                  padding:
                                                                  const EdgeInsets
                                                                      .all(
                                                                      5.0),
                                                                  child: _myVideos[
                                                                  index]
                                                                      .isSelected
                                                                      ? Icon(
                                                                    Icons
                                                                        .check,
                                                                    size:
                                                                    15.0,
                                                                    color: CustomColors
                                                                        .colorWhite,
                                                                  )
                                                                      : Icon(
                                                                    Icons
                                                                        .check_box_outline_blank,
                                                                    size:
                                                                    15.0,
                                                                    color: CustomColors
                                                                        .colorFontLightGrey,
                                                                  ),
                                                                ),
                                                              ),
                                                            )),
                                                        GestureDetector(
                                                            onTap: () {},
                                                            child: Container(
                                                                alignment:
                                                                Alignment
                                                                    .center,
                                                                width: 50,
                                                                height: 50,
                                                                child: Image.asset(
                                                                    'assets/images/btn_play.png',
                                                                    width: 50))),
                                                      ],
                                                    );
                                                  }else{
                                                    return Stack(
                                                      alignment: Alignment.center,
                                                      children: <Widget>[
                                                        Container(
                                                            width: (KCastingAppData().isWeb)
                                                                ? CustomStyles.appWidth
                                                                : MediaQuery.of(context)
                                                                .size
                                                                .width,
                                                            margin:
                                                            EdgeInsets.only(
                                                                bottom: 10),
                                                            height: 200,
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                CustomStyles
                                                                    .circle7BorderRadius(),
                                                                border: Border.all(
                                                                    width: 5,
                                                                    color: (_myVideos[index]
                                                                        .isSelected
                                                                        ? CustomColors
                                                                        .colorAccent
                                                                        : CustomColors
                                                                        .colorFontLightGrey))),
                                                            child: _myVideos[index]
                                                                .isFile
                                                                ? Image.file(
                                                              _myVideos[
                                                              index]
                                                                  .thumbnailFile,
                                                              fit: BoxFit
                                                                  .cover,
                                                            )
                                                                : CachedNetworkImage(
                                                                placeholder: (context, url) => Container(
                                                                    alignment:
                                                                    Alignment.center,
                                                                    child: CircularProgressIndicator()),
                                                                imageUrl: _myVideos[index].videoData[APIConstants.actor_video_url_thumb],
                                                                fit: BoxFit.cover,
                                                                errorWidget: (context, url, error) => Container())),
                                                        Container(
                                                            width: (KCastingAppData().isWeb)
                                                                ? CustomStyles.appWidth
                                                                : MediaQuery.of(
                                                                context)
                                                                .size
                                                                .width,
                                                            height: 200,
                                                            margin:
                                                            EdgeInsets.all(
                                                                10),
                                                            alignment: Alignment
                                                                .topRight,
                                                            child: InkWell(
                                                              onTap: () {
                                                                setState(() {
                                                                  _myVideos[index]
                                                                      .isSelected =
                                                                  !_myVideos[
                                                                  index]
                                                                      .isSelected;
                                                                });
                                                              },
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    color: (_myVideos[
                                                                    index]
                                                                        .isSelected
                                                                        ? CustomColors
                                                                        .colorAccent
                                                                        : CustomColors
                                                                        .colorFontLightGrey)),
                                                                child: Padding(
                                                                  padding:
                                                                  const EdgeInsets
                                                                      .all(
                                                                      5.0),
                                                                  child: _myVideos[
                                                                  index]
                                                                      .isSelected
                                                                      ? Icon(
                                                                    Icons
                                                                        .check,
                                                                    size:
                                                                    15.0,
                                                                    color: CustomColors
                                                                        .colorWhite,
                                                                  )
                                                                      : Icon(
                                                                    Icons
                                                                        .check_box_outline_blank,
                                                                    size:
                                                                    15.0,
                                                                    color: CustomColors
                                                                        .colorFontLightGrey,
                                                                  ),
                                                                ),
                                                              ),
                                                            )),
                                                        GestureDetector(
                                                            onTap: () {},
                                                            child: Container(
                                                                alignment:
                                                                Alignment
                                                                    .center,
                                                                width: 50,
                                                                height: 50,
                                                                child: Image.asset(
                                                                    'assets/images/btn_play.png',
                                                                    width: 50))),
                                                      ],
                                                    );
                                                  }
                                                },
                                                separatorBuilder:
                                                    (context, index) {
                                                  return VerticalDivider();
                                                })
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
                                          width:
                                          (KCastingAppData().isWeb)
                                              ? CustomStyles.appWidth
                                              : MediaQuery.of(context).size.width,
                                          height: 55,
                                          child: CustomStyles
                                              .greyBGSquareButtonStyle('이전단계',
                                                  () {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      AuditionApplyUploadImage(
                                                          castingSeq:
                                                              _castingSeq,
                                                          projectName:
                                                              _projectName,
                                                          castingName:
                                                              _castingName,
                                                          actorSeq: _actorSeq,
                                                          actorProfileSeq:
                                                              _actorProfileSeq)),
                                            );
                                          }))),
                                  Expanded(
                                      child: Container(
                                          width:
                                          (KCastingAppData().isWeb)
                                              ? CustomStyles.appWidth
                                              : MediaQuery.of(context).size.width,
                                          height: 55,
                                          child: CustomStyles
                                              .blueBGSquareButtonStyle('다음단계',
                                                  () {
                                            saveImageDataAndGoNextPage(context);
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
                            visible: _isUpload)
                      ]);
                    })))));
  }

  void saveImageDataAndGoNextPage(BuildContext context) {
    int totalVideoCnt = 0;

    for (int i = 0; i < _myVideos.length; i++) {
      if (_myVideos[i].isSelected) {
        totalVideoCnt++;
      }
    }

    if (totalVideoCnt < 1) {
      showSnackBar(context, '비디오를 선택해 주세요.');
      return;
    }

    if (totalVideoCnt > 2) {
      showSnackBar(context, '비디오는 최대 2개까지만 업로드할 수 있습니다.');
      return;
    }

    //List<Map<String, dynamic>> videoFile = [];
    List<Map<String, dynamic>> dbVideoFiles = [];
    List<File> newVideoFiles = [];
    List<File> newVideoThumbFiles = [];
    List<MultipartFile> newVideoMultipartFiles = [];

    for (int i = 0; i < _myVideos.length; i++) {
      if (_myVideos[i].isSelected) {
        if (_myVideos[i].isFile) {
          /*final bytes = _myVideos[i].videoFile.readAsBytesSync();
          String videoFile64 = base64Encode(bytes);

          String thumbnailFile64 = base64Encode(_myVideos[i].thumbnailFile);

          Map<String, dynamic> fileData = new Map();
          fileData[APIConstants.base64string] =
              APIConstants.data_file + videoFile64;
          fileData[APIConstants.base64string_thumb] =
              APIConstants.data_image + thumbnailFile64;

          videoFile.add(fileData);*/

          newVideoFiles.add(_myVideos[i].videoFile);
          newVideoThumbFiles.add(_myVideos[i].thumbnailFile);
          newVideoMultipartFiles.add((_myVideos[i].multipartFile));
        } else {
          // url 비디오 업로드
          Map<String, dynamic> fileData = new Map();
          fileData[APIConstants.url] =
              _myVideos[i].videoData[APIConstants.actor_video_url];
          fileData[APIConstants.thumb_url] =
              _myVideos[i].videoData[APIConstants.actor_video_url_thumb];

          dbVideoFiles.add(fileData);
        }
      }
    }

    replaceView(
        context,
        AuditionApplyUploadProfile(
          castingSeq: _castingSeq,
          projectName: _projectName,
          castingName: _castingName,
          dbImgages: _dbImgages,
          newImgages: _newImgages,
          newImageMultipartFiles: _newImageMultipartFiles,
          newVideoMultipartFiles: newVideoMultipartFiles,
          dbVideos: dbVideoFiles,
          newVideos: newVideoFiles,
          newVideoThumbs: newVideoThumbFiles,
          actorSeq: _actorSeq,
          actorProfileSeq: _actorProfileSeq,
        ));
  }
}
