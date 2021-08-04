import 'dart:io';

import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../KCastingAppData.dart';
import 'ProjectAddComplete.dart';

/*
* 프로젝트 추가
* */
class ProjectAdd extends StatefulWidget {
  @override
  _ProjectAdd createState() => _ProjectAdd();
}

class _ProjectAdd extends State<ProjectAdd> with BaseUtilMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  bool _isUpload = false;

  final _txtFieldProjectName = TextEditingController();
  final _txtFieldProjectGenre = TextEditingController();
  final _txtFieldProjectIntoduce = TextEditingController();
  final _txtFieldShootingPlace = TextEditingController();

  String _projectType = APIConstants.project_type_drama;

  String _startDate;
  String _endDate;
  String _openDate;

  File _profileImgFile;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');

    _startDate = formatter.format(now);
    _endDate = formatter.format(DateTime(now.year + 1, now.month, now.day));
    _openDate = formatter.format(DateTime(now.year + 1, now.month, now.day));
  }

  // 갤러리에서 이미지 가져오기
  Future getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File file = File(pickedFile.path);

      final size = file.readAsBytesSync().lengthInBytes;
      final kb = size / 1024;
      final mb = kb / 1024;

      if (mb > 100) {
        showSnackBar(context, "100MB 미만의 파일만 업로드 가능합니다.");
      } else {
        setState(() {
          _profileImgFile = file;
        });
      }
    } else {
      showSnackBar(context, "선택된 이미지가 없습니다.");
    }
  }

  _pickDocument() async {
    String result;
    try {
      FlutterDocumentPickerParams params =
          FlutterDocumentPickerParams(allowedFileExtensions: [
        'doc',
        'pdf',
        'docx'
      ], allowedUtiTypes: [
        'com.adobe.pdf',
        'com.microsoft.word.doc',
        'org.openxmlformats.wordprocessingml.document'
      ], allowedMimeTypes: [
        'application/pdf',
        'application/msword',
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
      ], invalidFileNameSymbols: [
        '/'
      ]);

      result = await FlutterDocumentPicker.openDocument(params: params);

      if (result != null) {
        File file = File(result);

        final size = file.readAsBytesSync().lengthInBytes;
        final kb = size / 1024;
        final mb = kb / 1024;

        if (mb > 100) {
          showSnackBar(context, "100MB 미만의 파일만 업로드 가능합니다.");
        } else {
          setState(() {
            _profileImgFile = file;
          });
        }
      } else {
        showSnackBar(context, "선택된 파일이 없습니다.");
      }
    } catch (e) {
      showSnackBar(context, APIConstants.error_msg_try_again);
    } finally {}
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
            appBar: CustomStyles.defaultAppBar('프로젝트 추가', () {
              Navigator.pop(context);
            }),
            body: Builder(builder: (context) {
              return Stack(children: [
                Container(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Expanded(
                          flex: 1,
                          child: SingleChildScrollView(
                              child: Container(
                                  padding: EdgeInsets.only(top: 30, bottom: 80),
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
                                            alignment: Alignment.centerLeft,
                                            child: Text('작품정보',
                                                style: CustomStyles
                                                    .dark16TextStyle())),
                                        Container(
                                            padding: EdgeInsets.only(
                                                left: 15, right: 15),
                                            margin: EdgeInsets.only(top: 15),
                                            alignment: Alignment.centerLeft,
                                            child: Text('작품제목',
                                                style: CustomStyles
                                                    .bold14TextStyle())),
                                        Container(
                                            padding: EdgeInsets.only(
                                                left: 15, right: 15),
                                            margin: EdgeInsets.only(top: 5),
                                            child: CustomStyles
                                                .greyBorderRound7TextField(
                                                    _txtFieldProjectName, '')),
                                        Container(
                                            margin: EdgeInsets.only(
                                                top: 15.0, left: 15, right: 15),
                                            padding: EdgeInsets.only(
                                                left: 15,
                                                right: 15,
                                                top: 12,
                                                bottom: 12),
                                            decoration: BoxDecoration(
                                                borderRadius: CustomStyles
                                                    .circle7BorderRadius(),
                                                color:
                                                    CustomColors.colorBgGrey),
                                            child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text('이미지 또는 첨부파일',
                                                      style: CustomStyles
                                                          .dark16TextStyle()),
                                                  GestureDetector(
                                                      onTap: () async {
                                                        showModalBottomSheet(
                                                            elevation: 5,
                                                            context: context,
                                                            builder: (context) {
                                                              return Wrap(
                                                                  crossAxisAlignment:
                                                                      WrapCrossAlignment
                                                                          .center,
                                                                  children: [
                                                                    ListTile(
                                                                        title: Text(
                                                                            '이미지 선택',
                                                                            textAlign: TextAlign
                                                                                .center),
                                                                        onTap:
                                                                            () async {
                                                                          var status = Platform.isAndroid
                                                                              ? await Permission.storage.request()
                                                                              : await Permission.photos.request();
                                                                          if (status
                                                                              .isGranted) {
                                                                            getImageFromGallery();
                                                                            Navigator.pop(context);
                                                                          } else {
                                                                            showDialog(
                                                                                context: context,
                                                                                builder: (BuildContext context) => CupertinoAlertDialog(title: Text('저장공간 접근권한'), content: Text('사진 또는 비디오를 업로드하려면, 기기 사진, 미디어, 파일 접근 권한이 필요합니다.'), actions: <Widget>[
                                                                                      CupertinoDialogAction(
                                                                                        child: Text('거부'),
                                                                                        onPressed: () => Navigator.of(context).pop(),
                                                                                      ),
                                                                                      CupertinoDialogAction(child: Text('허용'), onPressed: () => openAppSettings())
                                                                                    ]));
                                                                          }
                                                                        }),
                                                                    Divider(),
                                                                    ListTile(
                                                                        title: Text(
                                                                            '첨부파일 선택',
                                                                            textAlign: TextAlign
                                                                                .center),
                                                                        onTap:
                                                                            () async {
                                                                          var status = Platform.isAndroid
                                                                              ? await Permission.storage.request()
                                                                              : await Permission.photos.request();
                                                                          if (status
                                                                              .isGranted) {
                                                                            _pickDocument();
                                                                            Navigator.pop(context);
                                                                          } else {
                                                                            showDialog(
                                                                                context: context,
                                                                                builder: (BuildContext context) => CupertinoAlertDialog(title: Text('저장공간 접근권한'), content: Text('사진 또는 비디오를 업로드하려면, 기기 사진, 미디어, 파일 접근 권한이 필요합니다.'), actions: <Widget>[
                                                                                      CupertinoDialogAction(child: Text('거부'), onPressed: () => Navigator.of(context).pop()),
                                                                                      CupertinoDialogAction(child: Text('허용'), onPressed: () => openAppSettings())
                                                                                    ]));
                                                                          }
                                                                        }),
                                                                    Divider(),
                                                                    ListTile(
                                                                        title:
                                                                            Text(
                                                                          '취소',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                        ),
                                                                        onTap:
                                                                            () {
                                                                          Navigator.pop(
                                                                              context);
                                                                        })
                                                                  ]);
                                                            });
                                                      },
                                                      child: Text('업로드',
                                                          style: CustomStyles
                                                              .blue16TextStyle()))
                                                ])),
                                        Visibility(
                                            child: Container(
                                                margin: EdgeInsets.only(
                                                    left: 15,
                                                    right: 15,
                                                    top: 15),
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                decoration: BoxDecoration(
                                                    color: CustomColors
                                                        .colorWhite),
                                                child: (_profileImgFile == null
                                                    ? null
                                                    : Text(
                                                        _profileImgFile.path))),
                                            visible: _profileImgFile == null
                                                ? false
                                                : true),
                                        Container(
                                            margin: EdgeInsets.only(
                                                top: 30, bottom: 30),
                                            child: Divider(
                                                height: 0.1,
                                                color: CustomColors
                                                    .colorFontLightGrey)),
                                        Container(
                                            padding: EdgeInsets.only(
                                                left: 15, right: 15),
                                            alignment: Alignment.centerLeft,
                                            child: Text('제작유형',
                                                style: CustomStyles
                                                    .bold14TextStyle())),
                                        Container(
                                            margin: EdgeInsets.only(top: 5),
                                            padding: EdgeInsets.only(
                                                left: 15, right: 15),
                                            width: double.infinity,
                                            child: DropdownButtonFormField(
                                                value: _projectType,
                                                onChanged: (String newValue) {
                                                  setState(() {
                                                    _projectType = newValue;
                                                  });
                                                },
                                                items: <String>[
                                                  APIConstants
                                                      .project_type_drama,
                                                  APIConstants
                                                      .project_type_movie
                                                ].map<DropdownMenuItem<String>>(
                                                    (String value) {
                                                  return DropdownMenuItem<
                                                          String>(
                                                      value: value,
                                                      child: Text(value,
                                                          style: CustomStyles
                                                              .normal14TextStyle()));
                                                }).toList(),
                                                decoration: InputDecoration(
                                                    contentPadding:
                                                        EdgeInsets.only(
                                                            left: 15,
                                                            right: 15,
                                                            top: 0,
                                                            bottom: 0),
                                                    border: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: CustomColors.colorFontGrey,
                                                            width: 1.0),
                                                        borderRadius: CustomStyles.circle7BorderRadius()),
                                                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: CustomColors.colorFontGrey, width: 1.0), borderRadius: CustomStyles.circle7BorderRadius())))),
                                        Container(
                                            margin: EdgeInsets.only(top: 15),
                                            padding: EdgeInsets.only(
                                                left: 15, right: 15),
                                            alignment: Alignment.centerLeft,
                                            child: Text('장르',
                                                style: CustomStyles
                                                    .bold14TextStyle())),
                                        Container(
                                            padding: EdgeInsets.only(
                                                left: 15, right: 15),
                                            margin: EdgeInsets.only(top: 5),
                                            child: CustomStyles
                                                .greyBorderRound7TextField(
                                                    _txtFieldProjectGenre, '')),
                                        Container(
                                            margin: EdgeInsets.only(top: 15),
                                            padding: EdgeInsets.only(
                                                left: 15, right: 15),
                                            alignment: Alignment.centerLeft,
                                            child: Text('작품소개',
                                                style: CustomStyles
                                                    .bold14TextStyle())),
                                        Container(
                                            padding: EdgeInsets.only(
                                                left: 15, right: 15),
                                            margin: EdgeInsets.only(top: 5),
                                            child: TextField(
                                                controller:
                                                    _txtFieldProjectIntoduce,
                                                maxLines: 8,
                                                decoration: InputDecoration(
                                                    isDense: true,
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 10,
                                                            horizontal: 10),
                                                    hintText: "",
                                                    hintStyle: CustomStyles
                                                        .light14TextStyle(),
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
                                                        borderRadius:
                                                            CustomStyles.circle7BorderRadius())))),
                                        Container(
                                            margin: EdgeInsets.only(top: 30),
                                            padding: EdgeInsets.only(
                                                left: 15, right: 15),
                                            alignment: Alignment.centerLeft,
                                            child: Text('일정안내',
                                                style: CustomStyles
                                                    .dark16TextStyle())),
                                        Container(
                                            margin: EdgeInsets.only(top: 15),
                                            padding: EdgeInsets.only(
                                                left: 15, right: 15),
                                            alignment: Alignment.centerLeft,
                                            child: Text('촬영기간',
                                                style: CustomStyles
                                                    .bold14TextStyle())),
                                        Container(
                                            padding: EdgeInsets.only(
                                                left: 15, right: 15),
                                            margin: EdgeInsets.only(top: 5),
                                            child: Row(children: [
                                              Expanded(
                                                  child: GestureDetector(
                                                      onTap: () {
                                                        showDatePickerForDday(
                                                            context, (date) {
                                                          setState(() {
                                                            var _birthY = date
                                                                .year
                                                                .toString();
                                                            var _birthM = date
                                                                .month
                                                                .toString()
                                                                .padLeft(
                                                                    2, '0');
                                                            var _birthD = date
                                                                .day
                                                                .toString()
                                                                .padLeft(
                                                                    2, '0');

                                                            _startDate =
                                                                _birthY +
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
                                                              EdgeInsets.only(
                                                                  right: 5),
                                                          padding:
                                                              EdgeInsets.all(5),
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  CustomStyles
                                                                      .circle7BorderRadius(),
                                                              border: Border.all(
                                                                  width: 1,
                                                                  color: CustomColors
                                                                      .colorFontGrey)),
                                                          child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Container(
                                                                    margin: EdgeInsets.only(
                                                                        right:
                                                                            10),
                                                                    child: Icon(
                                                                        Icons
                                                                            .date_range,
                                                                        color: CustomColors
                                                                            .colorFontTitle)),
                                                                Text(_startDate,
                                                                    style: CustomStyles
                                                                        .bold14TextStyle())
                                                              ])))),
                                              Container(
                                                  margin: EdgeInsets.only(
                                                      left: 10, right: 10),
                                                  child: Text('-',
                                                      style: CustomStyles
                                                          .normal16TextStyle())),
                                              Expanded(
                                                  child: GestureDetector(
                                                      onTap: () {
                                                        showDatePickerForDday(
                                                            context, (date) {
                                                          setState(() {
                                                            var _birthY = date
                                                                .year
                                                                .toString();
                                                            var _birthM = date
                                                                .month
                                                                .toString()
                                                                .padLeft(
                                                                    2, '0');
                                                            var _birthD = date
                                                                .day
                                                                .toString()
                                                                .padLeft(
                                                                    2, '0');

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
                                                              EdgeInsets.only(
                                                                  right: 5),
                                                          padding:
                                                              EdgeInsets.all(5),
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  CustomStyles
                                                                      .circle7BorderRadius(),
                                                              border: Border.all(
                                                                  width: 1,
                                                                  color: CustomColors
                                                                      .colorFontGrey)),
                                                          child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Container(
                                                                    margin: EdgeInsets.only(
                                                                        right:
                                                                            10),
                                                                    child: Icon(
                                                                        Icons
                                                                            .date_range,
                                                                        color: CustomColors
                                                                            .colorFontTitle)),
                                                                Text(_endDate,
                                                                    style: CustomStyles
                                                                        .bold14TextStyle())
                                                              ]))))
                                            ])),
                                        Container(
                                            margin: EdgeInsets.only(top: 15),
                                            padding: EdgeInsets.only(
                                                left: 15, right: 15),
                                            alignment: Alignment.centerLeft,
                                            child: Text('촬영장소',
                                                style: CustomStyles
                                                    .bold14TextStyle())),
                                        Container(
                                            padding: EdgeInsets.only(
                                                left: 15, right: 15),
                                            margin: EdgeInsets.only(top: 5),
                                            child: CustomStyles
                                                .greyBorderRound7TextField(
                                                    _txtFieldShootingPlace,
                                                    '')),
                                        Container(
                                            margin: EdgeInsets.only(top: 15),
                                            padding: EdgeInsets.only(
                                                left: 15, right: 15),
                                            alignment: Alignment.centerLeft,
                                            child: Text('작품 오픈 예정일',
                                                style: CustomStyles
                                                    .bold14TextStyle())),
                                        Container(
                                            padding: EdgeInsets.only(
                                                left: 15, right: 15),
                                            margin: EdgeInsets.only(top: 5),
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

                                                      _openDate = _birthY +
                                                          '-' +
                                                          _birthM +
                                                          '-' +
                                                          _birthD;
                                                    });
                                                  });
                                                },
                                                child: Container(
                                                    height: 48,
                                                    margin: EdgeInsets.only(
                                                        right: 5),
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
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      right:
                                                                          10),
                                                              child: Icon(
                                                                  Icons
                                                                      .date_range,
                                                                  color: CustomColors
                                                                      .colorFontTitle)),
                                                          Text(_openDate,
                                                              style: CustomStyles
                                                                  .bold14TextStyle())
                                                        ]))))
                                      ])))),
                      Container(
                          width: double.infinity,
                          height: 55,
                          color: Colors.grey,
                          child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 55,
                              child: CustomStyles.blueBGSquareButtonStyle(
                                  '프로젝트 추가', () {
                                if (checkValidate(context)) {
                                  requestAddProjectApi(context);
                                }
                              })))
                    ])),
                Visibility(
                    child: Container(
                        color: Colors.black38,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator()),
                    visible: _isUpload)
              ]);
            })));
  }

  /*
  * 입력 데이터 유효성 검사
  * */
  bool checkValidate(BuildContext context) {
    if (StringUtils.isEmpty(_txtFieldProjectName.text)) {
      showSnackBar(context, '작품명을 입력해 주세요.');
      return false;
    }

    if (StringUtils.isEmpty(_txtFieldProjectGenre.text)) {
      showSnackBar(context, '장르를 입력해 주세요.');
      return false;
    }

    if (StringUtils.isEmpty(_txtFieldProjectIntoduce.text)) {
      showSnackBar(context, '작품소개글을 입력해 주세요.');
      return false;
    }

    if (StringUtils.isEmpty(_txtFieldShootingPlace.text)) {
      showSnackBar(context, '촬영장소를 입력해 주세요.');
      return false;
    }

    return true;
  }

  /*
  * 제작사 필모그래피 추가
  * */
  Future<void> requestAddProjectApi(BuildContext context) async {
    setState(() {
      _isUpload = true;
    });

    // 제작사 필모그래피 추가 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetDatas = new Map();
    targetDatas[APIConstants.production_seq] =
        KCastingAppData().myInfo[APIConstants.seq];
    targetDatas[APIConstants.project_name] = _txtFieldProjectName.text;
    targetDatas[APIConstants.project_type] = _projectType;
    targetDatas[APIConstants.genre_type] = _txtFieldProjectGenre.text;
    targetDatas[APIConstants.project_Introduce] = _txtFieldProjectIntoduce.text;
    targetDatas[APIConstants.shooting_place] = _txtFieldShootingPlace.text;
    targetDatas[APIConstants.shooting_startDate] = _startDate;
    targetDatas[APIConstants.shooting_endDate] = _endDate;
    targetDatas[APIConstants.release_planDate] = _openDate;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.INS_PPJ_INFO_FormData;
    params[APIConstants.target] = targetDatas;

    if (_profileImgFile != null) {
      var temp = _profileImgFile.path.split('/');
      String fileName = temp[temp.length - 1];
      params[APIConstants.target_files_array] = await MultipartFile.fromFile(
          _profileImgFile.path,
          filename: fileName);
    }

    // 제작사 필모그래피 추가 api 호출
    RestClient(Dio())
        .postRequestMainControlFormData(params)
        .then((value) async {
      try {
        if (value == null) {
          // 에러 - 데이터 널
          showSnackBar(context, APIConstants.error_msg_server_not_response);
        } else {
          if (value[APIConstants.resultVal]) {
            // 제작사 필모그래피 추가 성공

            var _responseData = value[APIConstants.data];
            var _responseList = _responseData[APIConstants.list] as List;

            if (_responseList.length > 0) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProjectAddComplete(
                          projectSeq: _responseList[0][APIConstants.seq],
                          projectName: _responseList[0]
                              [APIConstants.project_name])));
            }
          } else {
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
}
