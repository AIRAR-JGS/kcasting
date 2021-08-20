import 'dart:io';

import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/view/user/actor/JoinActorSelectType.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../KCastingAppData.dart';
import 'JoinActorChild.dart';

/*
* 14세 미만 배우 회원가입 시 보호자 인증하기
* */
class JoinActorChildParentAgree extends StatefulWidget {
  final String authName;
  final String authPhone;
  final String authBirth;
  final String authGender;

  const JoinActorChildParentAgree(
      {Key key, this.authName, this.authPhone, this.authBirth, this.authGender})
      : super(key: key);

  @override
  _JoinActorChildParentAgree createState() => _JoinActorChildParentAgree();
}

class _JoinActorChildParentAgree extends State<JoinActorChildParentAgree>
    with BaseUtilMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  String _authName;
  String _authPhone;
  String _authBirth;
  String _authGender;

  final _txtFieldName = TextEditingController();
  final _txtFieldPhone = TextEditingController();

  int _agreeTerms = 0;
  int _agreePrivacyPolicy = 0;

  File _scriptFile;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    _authName = widget.authName;
    _authPhone = widget.authPhone;
    _authBirth = widget.authBirth;
    _authGender = widget.authGender;

    if (_authName != null) {
      _txtFieldName.text = _authName;
    }

    if (_authPhone != null) {
      _txtFieldPhone.text = _authPhone;
    }

    if (_authPhone != null) {
      _txtFieldPhone.text = _authPhone;
    }
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
          _scriptFile = file;
        });
      }
    } else {
      showSnackBar(context, "선택된 이미지가 없습니다.");
    }
  }

  _pickDocument() async {
    String result;
    try {
      FlutterDocumentPickerParams params = FlutterDocumentPickerParams(
        allowedFileExtensions: ['doc', 'pdf', 'docx'],
        allowedUtiTypes: [
          'com.adobe.pdf',
          'com.microsoft.word.doc',
          'org.openxmlformats.wordprocessingml.document'
        ],
        allowedMimeTypes: [
          'application/pdf',
          'application/msword',
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
        ],
        invalidFileNameSymbols: ['/'],
      );

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
            _scriptFile = file;
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
  *메인 위젯
  *  */
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          replaceView(context, JoinActorSelectType());
          return Future.value(false);
        },
        child: Theme(
            data: CustomStyles.defaultTheme(),
            child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: KCastingAppData().isWeb
                      ? CustomStyles.appWidth
                      : double.infinity,
                  child: Scaffold(
                      key: _scaffoldKey,
                      appBar: CustomStyles.defaultAppBar('보호자 동의', () {
                        replaceView(context, JoinActorSelectType());
                      }),
                      body: Column(children: [
                        Expanded(
                            flex: 1,
                            child: SingleChildScrollView(
                                child: Container(
                                    padding:
                                        EdgeInsets.only(top: 30, bottom: 50),
                                    child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                              margin:
                                                  EdgeInsets.only(bottom: 30),
                                              alignment: Alignment.center,
                                              child: Text('보호자 동의',
                                                  style: CustomStyles
                                                      .normal24TextStyle())),
                                          Container(
                                              padding: EdgeInsets.only(
                                                  left: 30, right: 30),
                                              alignment: Alignment.centerLeft,
                                              child: RichText(
                                                  text: TextSpan(
                                                      style: CustomStyles
                                                          .normal14TextStyle(),
                                                      children: <TextSpan>[
                                                    TextSpan(
                                                        text: '보호자 인증서류 제출'),
                                                    TextSpan(
                                                        style: TextStyle(
                                                            color: CustomColors
                                                                .colorRed),
                                                        text: '*')
                                                  ]))),
                                          Container(
                                              padding: EdgeInsets.only(
                                                  left: 30, right: 30),
                                              width: double.infinity,
                                              child: Text(
                                                  '14세 미만 배우회원가입은 제출하신 보호자 인증서류 검토를 위해 최대 1-2일이 소요될 수 있습니다.\n제출가능한 보호자 인증서류의 종류는 법적대리인의 주민등록등본, 건강보험증, 가족관계증명서입니다. ',
                                                  textAlign: TextAlign.start,
                                                  style: CustomStyles
                                                      .normal14TextStyle())),
                                          Container(
                                              margin: EdgeInsets.only(
                                                  top: 10, left: 30, right: 30),
                                              padding: EdgeInsets.only(
                                                  left: 15,
                                                  right: 15,
                                                  top: 12,
                                                  bottom: 12),
                                              decoration: BoxDecoration(
                                                borderRadius: CustomStyles
                                                    .circle7BorderRadius(),
                                                color: CustomColors.colorBgGrey,
                                              ),
                                              child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text('첨부파일 또는 이미지',
                                                        style: CustomStyles
                                                            .dark16TextStyle()),
                                                    GestureDetector(
                                                        onTap: () async {
                                                          showModalBottomSheet(
                                                              elevation: 5,
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                return Wrap(
                                                                    crossAxisAlignment:
                                                                        WrapCrossAlignment
                                                                            .center,
                                                                    children: [
                                                                      ListTile(
                                                                          title:
                                                                              Text(
                                                                            '이미지 선택',
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                          ),
                                                                          onTap:
                                                                              () async {
                                                                            var status = Platform.isAndroid
                                                                                ? await Permission.storage.request()
                                                                                : await Permission.photos.request();
                                                                            if (status.isGranted) {
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
                                                                          title:
                                                                              Text(
                                                                            '파일 선택',
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                          ),
                                                                          onTap:
                                                                              () async {
                                                                            var status = Platform.isAndroid
                                                                                ? await Permission.storage.request()
                                                                                : await Permission.photos.request();
                                                                            if (status.isGranted) {
                                                                              _pickDocument();
                                                                              Navigator.pop(context);
                                                                            } else {
                                                                              showDialog(
                                                                                  context: context,
                                                                                  builder: (BuildContext context) => CupertinoAlertDialog(
                                                                                        title: Text('저장공간 접근권한'),
                                                                                        content: Text('사진 또는 비디오를 업로드하려면, 기기 사진, 미디어, 파일 접근 권한이 필요합니다.'),
                                                                                        actions: <Widget>[
                                                                                          CupertinoDialogAction(
                                                                                            child: Text('거부'),
                                                                                            onPressed: () => Navigator.of(context).pop(),
                                                                                          ),
                                                                                          CupertinoDialogAction(
                                                                                            child: Text('허용'),
                                                                                            onPressed: () => openAppSettings(),
                                                                                          ),
                                                                                        ],
                                                                                      ));
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
                                                                            Navigator.pop(context);
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
                                                  padding: EdgeInsets.only(
                                                      left: 30, right: 30),
                                                  margin:
                                                      EdgeInsets.only(top: 15),
                                                  width: (KCastingAppData().isWeb)
                                                      ? CustomStyles.appWidth
                                                      : MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  decoration: BoxDecoration(
                                                      color: CustomColors
                                                          .colorWhite),
                                                  child: (_scriptFile == null
                                                      ? null
                                                      : Text(
                                                          _scriptFile.path))),
                                              visible: _scriptFile == null
                                                  ? false
                                                  : true),
                                          Container(
                                              margin: EdgeInsets.only(top: 30),
                                              padding: EdgeInsets.only(
                                                  left: 30, right: 30),
                                              alignment: Alignment.centerLeft,
                                              child: RichText(
                                                  text: TextSpan(
                                                      style: CustomStyles
                                                          .normal14TextStyle(),
                                                      children: <TextSpan>[
                                                    TextSpan(text: '이름'),
                                                    TextSpan(
                                                        style: TextStyle(
                                                            color: CustomColors
                                                                .colorRed),
                                                        text: '*')
                                                  ]))),
                                          Container(
                                              padding: EdgeInsets.only(
                                                  left: 30, right: 30),
                                              margin: EdgeInsets.only(top: 5),
                                              child: CustomStyles
                                                  .greyBorderRound7TextFieldWithDisableOpt(
                                                      _txtFieldName,
                                                      '반드시 본명을 입력해 주세요.',
                                                      false)),
                                          Container(
                                              padding: EdgeInsets.only(
                                                  left: 30, right: 30),
                                              margin: EdgeInsets.only(top: 15),
                                              alignment: Alignment.centerLeft,
                                              child: RichText(
                                                  text: TextSpan(
                                                      style: CustomStyles
                                                          .normal14TextStyle(),
                                                      children: <TextSpan>[
                                                    TextSpan(text: '연락처'),
                                                    TextSpan(
                                                        style: TextStyle(
                                                            color: CustomColors
                                                                .colorRed),
                                                        text: '*')
                                                  ]))),
                                          Container(
                                              padding: EdgeInsets.only(
                                                  left: 30, right: 30),
                                              margin: EdgeInsets.only(top: 5),
                                              child: CustomStyles
                                                  .greyBorderRound7TextFieldWithDisableOpt(
                                                      _txtFieldPhone,
                                                      '숫자로만 입력해 주세요.',
                                                      false)),
                                          Container(
                                              margin: EdgeInsets.only(top: 30),
                                              padding: EdgeInsets.only(
                                                  left: 30, right: 30),
                                              alignment: Alignment.centerLeft,
                                              child: Text('이용약관',
                                                  style: CustomStyles
                                                      .normal14TextStyle())),
                                          Container(
                                              margin: EdgeInsets.only(top: 20),
                                              padding: EdgeInsets.only(
                                                  left: 30, right: 30),
                                              alignment: Alignment.centerLeft,
                                              child: RichText(
                                                  text: TextSpan(
                                                      style: CustomStyles
                                                          .normal14TextStyle(),
                                                      children: <TextSpan>[
                                                    TextSpan(
                                                        text: '서비스 제공을 위해 '),
                                                    TextSpan(
                                                        style: TextStyle(
                                                            color: CustomColors
                                                                .colorRed,
                                                            decoration:
                                                                TextDecoration
                                                                    .underline),
                                                        text: '이용약관',
                                                        recognizer:
                                                            TapGestureRecognizer()
                                                              ..onTap = () {
                                                                // 엔터로뱅 홈페이지 내의 개인정보 처리방침 페이지로 이동
                                                                launchInBrowser(
                                                                    APIConstants
                                                                        .URL_PRIVACY_POLICY);
                                                              }),
                                                    TextSpan(text: ' 및 '),
                                                    TextSpan(
                                                        style: TextStyle(
                                                            color: CustomColors
                                                                .colorRed,
                                                            decoration:
                                                                TextDecoration
                                                                    .underline),
                                                        text: '개인정보 수집, 이용',
                                                        recognizer:
                                                            TapGestureRecognizer()
                                                              ..onTap = () {
                                                                // 엔터로뱅 홈페이지 내의 개인정보 처리방침 페이지로 이동
                                                                launchInBrowser(
                                                                    APIConstants
                                                                        .URL_PRIVACY_POLICY);
                                                              }),
                                                    TextSpan(
                                                        text:
                                                            ' 등의 내용에 동의해 주세요.'),
                                                  ]))),
                                          Container(
                                              margin: EdgeInsets.only(top: 10),
                                              padding: EdgeInsets.only(
                                                  left: 30, right: 30),
                                              child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
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
                                                          if (_agreeTerms ==
                                                              0) {
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
                                                    Text('이용약관에 동의합니다.(필수)',
                                                        style: CustomStyles
                                                            .normal14TextStyle())
                                                  ])),
                                          Container(
                                              padding: EdgeInsets.only(
                                                  left: 30, right: 30),
                                              child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Radio<int>(
                                                      value:
                                                          _agreePrivacyPolicy,
                                                      visualDensity:
                                                          VisualDensity.compact,
                                                      groupValue: 1,
                                                      toggleable: true,
                                                      onChanged: (_) {
                                                        setState(() {
                                                          if (_agreePrivacyPolicy ==
                                                              0) {
                                                            _agreePrivacyPolicy =
                                                                1;
                                                          } else {
                                                            _agreePrivacyPolicy =
                                                                0;
                                                          }
                                                        });
                                                      },
                                                      materialTapTargetSize:
                                                          MaterialTapTargetSize
                                                              .shrinkWrap,
                                                    ),
                                                    Text(
                                                        '개인정보 수집 이용에 동의합니다.(필수)',
                                                        style: CustomStyles
                                                            .normal14TextStyle())
                                                  ]))
                                        ])))),
                        Container(
                            height: 50,
                            width: double.infinity,
                            color: Colors.grey,
                            child: CustomStyles.lightGreyBGSquareButtonStyle(
                                '자녀 회원가입', () async {
                              // 서류 첨부
                              if (_scriptFile == null) {
                                showSnackBar(context, '보호자 인증서류를 첨부해 주세요.');
                                return false;
                              }

                              if (_agreeTerms == 0) {
                                showSnackBar(context, '이용약관에 동의해 주세요.');
                                return false;
                              }

                              if (_agreePrivacyPolicy == 0) {
                                showSnackBar(context, '개인정보 수집 이용에 동의해 주세요.');
                                return false;
                              }

                              Map<String, dynamic> targetData = new Map();
                              targetData[APIConstants.guardian_name] =
                                  _txtFieldName.text;
                              targetData[APIConstants.guardian_phone] =
                                  _txtFieldPhone.text;

                              replaceView(
                                  context,
                                  JoinActorChild(
                                      targetData: targetData,
                                      scriptFile: _scriptFile));
                            }))
                      ])),
                ))));
  }
}
