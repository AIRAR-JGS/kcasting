import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../../KCastingAppData.dart';
import 'AuditionApplyProfile.dart';

/*
* 오디션 지원 현황 상세 화면*/
class AuditionApplyDetail extends StatefulWidget {
  final int applySeq;

  const AuditionApplyDetail({Key key, this.applySeq}) : super(key: key);

  @override
  _AuditionApplyDetail createState() => _AuditionApplyDetail();
}

class _AuditionApplyDetail extends State<AuditionApplyDetail>
    with SingleTickerProviderStateMixin, BaseUtilMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final picker = ImagePicker();

  int _applySeq;
  int _agreeTerms = 0;

  TabController _tabController;
  int _tabIndex = 0;

  // 지원현황 리스트 관련 변수
  Map<String, dynamic> _auditionState = new Map();

  bool _isSubmitVideo = false;
  bool _isUpload = false;

  @override
  void initState() {
    super.initState();

    _applySeq = widget.applySeq;

    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);

    requestMyApplyDetailApi(context);
  }

  _handleTabSelection() {
    if (_tabController.index == 1) {
      // 2차 오디션
      print(_auditionState[APIConstants.secondAudition_state_type]);
      if (_auditionState[APIConstants.secondAudition_state_type] == null) {
        int index = _tabController.previousIndex;
        setState(() {
          _tabController.index = index;
          _tabIndex = index;
        });
        return;
      }
    }

    if (_tabController.index == 2) {
      // 3차 오디션
      if (_auditionState[APIConstants.thirdAudition_state_type] == null) {
        int index = _tabController.previousIndex;
        setState(() {
          _tabController.index = index;
          _tabIndex = index;
        });
        return;
      }
    }

    if (_tabController.indexIsChanging) {
      setState(() {
        _tabIndex = _tabController.index;
      });
    }
  }

  // 갤러리에서 비디오 가져오기
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

    if (mb > 100) {
      showSnackBar(context, "100MB 미만의 파일만 업로드 가능합니다.");
    } else {
      requestAddActorVideo(context, _videoFile, bytes);
    }
  }

  /*
  * 지원현황 조회
  * */
  void requestMyApplyDetailApi(BuildContext context) {
    final dio = Dio();

    // 지원현황 조회 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetData = new Map();
    targetData[APIConstants.audition_apply_seq] = _applySeq;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.SEL_AAA_STATE;
    params[APIConstants.target] = targetData;

    // 지원현황 조회 api 호출
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value != null) {
        if (value[APIConstants.resultVal]) {
          try {
            // 지원현황 조회 성공
            var _responseData = value[APIConstants.data];

            setState(() {
              var _responseList = _responseData[APIConstants.list] as List;

              if (_responseList != null && _responseList.length > 0) {
                _auditionState = _responseList[0];

                if (_auditionState[APIConstants.isSubmitVideo] == 0) {
                  _isSubmitVideo = false;
                } else {
                  _isSubmitVideo = true;
                }
              }
            });
          } catch (e) {
            showSnackBar(context, APIConstants.error_msg_try_again);
          }
        } else {
          showSnackBar(context, APIConstants.error_msg_try_again);
        }
      } else {
        showSnackBar(context, APIConstants.error_msg_server_not_response);
      }
    });
  }

  /*
  * 배우 비디오 등록 및 연락처 공개 동의
  * */
  void requestUploadVideoResume(BuildContext context) {
    final dio = Dio();

    // 지원현황 조회 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetData = new Map();
    targetData[APIConstants.seq] =
        _auditionState[APIConstants.secondAudition_seq];

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.SEL_AAA_STATE;
    params[APIConstants.target] = targetData;

    // 지원현황 조회 api 호출
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value != null) {
        if (value[APIConstants.resultVal]) {
          try {
            // 지원현황 조회 성공
            var _responseData = value[APIConstants.data];

            setState(() {
              var _responseList = _responseData[APIConstants.list] as List;

              if (_responseList != null && _responseList.length > 0) {
                _auditionState = _responseList[0];

                if (_auditionState[_isSubmitVideo] == 0) {
                  _isSubmitVideo = false;
                } else {
                  _isSubmitVideo = true;
                }
              }
            });
          } catch (e) {
            showSnackBar(context, APIConstants.error_msg_try_again);
          }
        } else {
          showSnackBar(context, APIConstants.error_msg_try_again);
        }
      } else {
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
      targetData[APIConstants.seq] =
          _auditionState[APIConstants.secondAuditionTarget_seq];

      Map<String, dynamic> fileData = new Map();
      fileData[APIConstants.base64string] =
          APIConstants.data_file + videoFile64;
      fileData[APIConstants.base64string_thumb] =
          APIConstants.data_image + thumbnailFile62;

      targetData[APIConstants.file] = fileData;

      Map<String, dynamic> params = new Map();
      params[APIConstants.key] = APIConstants.UPD_SAT_SUBMIT;
      params[APIConstants.target] = targetData;

      // 배우 비디오 추가 api 호출
      RestClient(dio).postRequestMainControl(params).then((value) async {
        if (value == null) {
          // 에러 - 데이터 널
          showSnackBar(context, '다시 시도해 주세요.');
        } else {
          if (value[APIConstants.resultVal]) {
            // 배우 비디오 추가 성공
            setState(() {
              _isUpload = false;
              _isSubmitVideo = true;
              showSnackBar(context, "비디오 제출 완료!");
            });
          } else {
            // 배우 비디오 추가 실패
            showSnackBar(context, value[APIConstants.resultMsg]);
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

  Widget tabFirstAudition() {
    String state = StringUtils.checkedString(
        _auditionState[APIConstants.firstAuditionTarget_result_type]);
    return (state == "대기")
        // 1차 오디션 결과 대기중
        ? Container(
            padding: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    margin: EdgeInsets.only(bottom: 15, top: 15),
                    child: Text(state, style: CustomStyles.dark20TextStyle())),
                Container(
                    child: Text('오디션 결과를 기다리는 중입니다.',
                        style: CustomStyles.dark16TextStyle())),
              ],
            ),
          )
        : ((state == "합격")
            // 1차 오디션 합격
            ? Container(
                padding:
                    EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 30),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 15, top: 15),
                        child: Text('1차 합격',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      Container(
                          child: Text(
                              '1차 오디션 합격을 진심으로 축하드립니다.\n2차 오디션은 대본 오디션입니다.\n대본을 다운받아 영상 촬영 후 등록해 주세요.\n\n대본의 내용 유출 방지를 위해,\n비밀 유지 서약에 동의하신 후에, 대본을 확인할 수 있습니다.',
                              style: CustomStyles.dark16TextStyle())),
                      Container(
                          margin: EdgeInsets.only(top: 30),
                          child: Text('서약',
                              style: CustomStyles.darkBold16TextStyle())),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                                width: 24,
                                height: 24,
                                child: Radio<int>(
                                    value: _agreeTerms,
                                    visualDensity: VisualDensity.compact,
                                    groupValue: 1,
                                    toggleable: true,
                                    onChanged: (_) {
                                      setState(() {
                                        if (_agreeTerms == 0) {
                                          // 동의
                                          _agreeTerms = 1;
                                        } else {
                                          // 비동의
                                          _agreeTerms = 0;
                                        }
                                      });
                                    },
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap)),
                            Container(
                                child: Text('대본 비밀 유지 서약에 대해 동의합니다.',
                                    style: CustomStyles.dark14TextStyle()))
                          ],
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.only(top: 30),
                          child: Text('대본',
                              style: CustomStyles.darkBold16TextStyle())),
                      Container(
                        margin: EdgeInsets.only(top: 15),
                        padding: EdgeInsets.only(
                            left: 10, right: 10, top: 12, bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('첨부파일 : 모집요강 안내.pdf',
                                style: CustomStyles.dark14TextStyle()),
                            CustomStyles.darkBold14TextButtonStyle(
                                '다운로드', () {})
                          ],
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.only(top: 30),
                          child: Text('기간',
                              style: CustomStyles.darkBold16TextStyle())),
                      Container(
                          margin: EdgeInsets.only(top: 10),
                          child: Text('2020.12.30일까지',
                              style: CustomStyles.dark16TextStyle())),
                      Visibility(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                margin: EdgeInsets.only(top: 30),
                                child: Text('제출완료!',
                                    style: CustomStyles.darkBold20TextStyle())),
                            /*Container(
                                margin: EdgeInsets.only(top: 10),
                                child: Text('제출한 비디오는 제출 프로필>비디오에\n추가되었습니다.',
                                    style: CustomStyles.dark16TextStyle()))*/
                          ],
                        ),
                        visible: _isSubmitVideo ? true : false,
                      )
                    ]),
              )
            // 1차 오디션 불합격
            : Container(
                padding: EdgeInsets.all(15),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          margin: EdgeInsets.only(bottom: 15, top: 15),
                          child: Text('불합격',
                              style: CustomStyles.dark20TextStyle())),
                      Container(
                          child: Text(
                              '안녕하세요, 김배우님\n저희 오디션에 참가해 주셔서 감사합니다.\n\n아쉽게도 1차 오디션에 합격하지 못했습니다.\n다음에 더 좋은 배역으로 만나길 바랍니다.\n감사힙니다.',
                              style: CustomStyles.dark16TextStyle())),
                    ])));
  }

  Widget tabSecondAudition() {
    String state = StringUtils.checkedString(
        _auditionState[APIConstants.secondAuditionTarget_result_type]);

    return (state == "대기")
        // 1차 오디션 결과 대기중
        ? (_isSubmitVideo
            ? Container(
                padding: EdgeInsets.all(15),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          margin: EdgeInsets.only(bottom: 15, top: 15),
                          child: Text(state,
                              style: CustomStyles.dark20TextStyle())),
                      Container(
                          child: Text('오디션 결과를 기다리는 중입니다.',
                              style: CustomStyles.dark16TextStyle()))
                    ]))
            : Container(
                padding: EdgeInsets.all(15),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          margin: EdgeInsets.only(bottom: 15, top: 15),
                          child: Text(state,
                              style: CustomStyles.dark20TextStyle())),
                      Container(
                          child: Text('2차 오디션 심사를 위해 비디오를 제출해 주세요.',
                              style: CustomStyles.dark16TextStyle()))
                    ])))
        : (state == "합격"
            // 1차 오디션 합격
            ? Container(
                padding:
                    EdgeInsets.only(top: 20, left: 15, right: 15, bottom: 20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          margin: EdgeInsets.only(bottom: 15, top: 15),
                          child: Text('2차 합격',
                              style: CustomStyles.dark20TextStyle())),
                      Container(
                          child: Text(
                              '2차 오디션 합격을 진심으로 축하드립니다.\n3차 오디션은 자유 면접입니다.\n일정안내를 위해 나의 연락처가 공유됩니다.',
                              style: CustomStyles.dark16TextStyle())),
                      Container(
                          margin: EdgeInsets.only(top: 10),
                          child: Text(
                              KCastingAppData()
                                      .myInfo[APIConstants.actor_phone] +
                                  '로 면접일정이 안내됩니다.',
                              style: CustomStyles.dark16TextStyle()))
                    ]))
            // 2차 오디션 불합격
            : Container(
                padding: EdgeInsets.all(15),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          margin: EdgeInsets.only(bottom: 15, top: 15),
                          child: Text('불합격',
                              style: CustomStyles.dark20TextStyle())),
                      Container(
                          child: Text(
                              '안녕하세요, 김배우님\n저희 오디션에 참가해 주셔서 감사합니다.\n\n아쉽게도 2차 오디션에 합격하지 못했습니다.\n다음에 더 좋은 배역으로 만나길 바랍니다.\n감사힙니다.',
                              style: CustomStyles.dark16TextStyle())),
                    ])));
  }

  Widget tabThirdAudition() {
    String state = StringUtils.checkedString(
        _auditionState[APIConstants.thirdAuditionTarget_result_type]);

    return (state == "대기")
        // 3차 오디션 결과 대기중
        ? Container(
            padding: EdgeInsets.all(15),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                  margin: EdgeInsets.only(bottom: 15, top: 15),
                  child: Text('면접안내', style: CustomStyles.dark20TextStyle())),
              Container(
                  child: Text(
                      '서배우님의 면접 일정은 담당자가 확인하는대로\n해당 연락처의 문자로 갈 예정입니다.\n잠시만 기다려주세요.\n\n면접 후, 면접관이 합격 또는 불합격 통보시\n해당 화면에 결과가 나타납니다.',
                      style: CustomStyles.dark16TextStyle()))
            ]))
        : (state == "합격"
            // 3차 오디션 합격
            ? Container(
                padding:
                    EdgeInsets.only(top: 20, left: 15, right: 15, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        margin: EdgeInsets.only(bottom: 15, top: 15),
                        child: Text('최종합격',
                            style: CustomStyles.dark20TextStyle())),
                    Container(
                        child: Text('서배우님! 최종합격을 축하드립니다.',
                            style: CustomStyles.dark16TextStyle())),
                    /*Container(
                        child: Text(
                            '서배우님! 최종합격을 축하드립니다.\n출연 확정을 위해 본인 명의의 주민등록번호와\n입금받을 계좌를 확인 후 아래의 계약서를\n작성해주세요.',
                            style: CustomStyles.dark16TextStyle())),*/
                    /*Container(
                        margin: EdgeInsets.only(top: 30),
                        child: Text('출연료',
                            style: CustomStyles.darkBold16TextStyle())),
                    Container(
                        margin: EdgeInsets.only(top: 15),
                        child: Text('500,000',
                            style: CustomStyles.dark16TextStyle())),
                    Container(
                        margin: EdgeInsets.only(top: 30),
                        child: Text('실명 인증',
                            style: CustomStyles.darkBold16TextStyle())),
                    Container(
                        margin: EdgeInsets.only(top: 15),
                        child:
                            Text('서이쁨', style: CustomStyles.dark16TextStyle())),
                    Container(
                        margin: EdgeInsets.only(top: 10),
                        width: double.infinity,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(
                                  child: CustomStyles.greyBorderRound7TextField(TextEditingController(),
                                      '')),
                            ),
                            Expanded(
                              flex: 0,
                              child: Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.only(left: 5, right: 5),
                                child: Text("-",
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: CustomColors.colorFontGrey)),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Container(
                                  child: CustomStyles.greyBorderRound7TextField(TextEditingController(),
                                      '')),
                            ),
                            Expanded(
                                flex: 3,
                                child: Container(
                                    height: 48,
                                    margin: EdgeInsets.only(left: 5),
                                    child: CustomStyles.greyBGRound7ButtonStyle(
                                        '인증하기', () {
                                      // 인증번호 받기 버튼 클릭
                                    })))
                          ],
                        )),
                    Container(
                        margin: EdgeInsets.only(top: 30),
                        child: Text('입금받을 계좌',
                            style: CustomStyles.darkBold16TextStyle())),
                    Container(
                        margin: EdgeInsets.only(top: 10),
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            borderRadius: CustomStyles.circle7BorderRadius(),
                            border: Border.all(
                                width: 1,
                                color: CustomColors.colorFontLightGrey)),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('우리은행',
                                  style: CustomStyles.dark12TextStyle()),
                              Container(
                                  margin: EdgeInsets.only(top: 10),
                                  child: Text('000-0000-0000',
                                      style: CustomStyles.dark24TextStyle()))
                            ])),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                              width: 24,
                              height: 24,
                              child: Radio<int>(
                                value: _agreeTerms,
                                visualDensity: VisualDensity.compact,
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
                                    MaterialTapTargetSize.shrinkWrap,
                              )),
                          Container(
                              child: Text('이 계좌로 출연료를 지급받겠습니다.',
                                  style: CustomStyles.dark16TextStyle())),
                        ],
                      ),
                    ),*/
                    /*Visibility(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              margin: EdgeInsets.only(top: 30),
                              child: Text('계약서 작성완료',
                                  style: CustomStyles.darkBold20TextStyle())),
                          Container(
                              margin: EdgeInsets.only(top: 10),
                              child: Text('최종합격 메뉴에서 작성하신 계약서를 확인하실 수 있습니다.',
                                  style: CustomStyles.dark16TextStyle()))
                        ],
                      ),
                      visible: isSubmitContract ? true : false,
                    )*/
                  ],
                ),
              )
            // 3차 오디션 불합격
            : Container(
                padding: EdgeInsets.all(15),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          margin: EdgeInsets.only(bottom: 15, top: 15),
                          child: Text('불합격',
                              style: CustomStyles.dark20TextStyle())),
                      Container(
                          child: Text(
                              '안녕하세요, 김배우님\n저희 오디션에 참가해 주셔서 감사합니다.\n\n아쉽게도 3차 오디션에 합격하지 못했습니다.\n다음에 더 좋은 배역으로 만나길 바랍니다.\n감사힙니다.',
                              style: CustomStyles.dark16TextStyle())),
                    ])));
  }

  /*Widget tabPassAudition(int resultVal) {
    return (resultVal == 0)
        // 최종합격
        ? Container(
            padding: EdgeInsets.all(15),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                  margin: EdgeInsets.only(bottom: 15, top: 15),
                  child: Text('계약완료', style: CustomStyles.dark20TextStyle())),
              Container(
                  child: Text('서배우님! 계약완료를 축하드립니다.\n아래의 버튼으로 계약서를 확인할 수 있습니다.',
                      style: CustomStyles.dark16TextStyle())),
              Container(
                  margin: EdgeInsets.only(top: 30),
                  child:
                      Text('출연료', style: CustomStyles.darkBold16TextStyle())),
              Container(
                  margin: EdgeInsets.only(top: 15),
                  child:
                      Text('500,000', style: CustomStyles.dark16TextStyle())),
              Container(
                  margin: EdgeInsets.only(top: 30),
                  child: Text('입금받을 계좌',
                      style: CustomStyles.darkBold16TextStyle())),
              Container(
                  margin: EdgeInsets.only(top: 15),
                  child: Text('우리은행 000-0000-00000',
                      style: CustomStyles.dark16TextStyle())),
            ]))
        : Container(
            padding: EdgeInsets.only(top: 20, left: 15, right: 15, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    margin: EdgeInsets.only(bottom: 15, top: 15),
                    child: Text('지급완료', style: CustomStyles.dark20TextStyle())),
                Container(
                    child: Text('서배우님! 제출하신 계좌로 출연료가 지급되었습니다.\n확인 부탁드립니다.',
                        style: CustomStyles.dark16TextStyle())),
                Container(
                    margin: EdgeInsets.only(top: 30),
                    child:
                        Text('출연료', style: CustomStyles.darkBold16TextStyle())),
                Container(
                    margin: EdgeInsets.only(top: 15),
                    child:
                        Text('500,000', style: CustomStyles.dark16TextStyle())),
                Container(
                    margin: EdgeInsets.only(top: 30),
                    child: Text('입금받을 계좌',
                        style: CustomStyles.darkBold16TextStyle())),
                Container(
                    margin: EdgeInsets.only(top: 15),
                    child: Text('우리은행 000-0000-00000',
                        style: CustomStyles.dark16TextStyle())),
                Container(
                    margin: EdgeInsets.only(top: 30),
                    child: Text('해당 제작사 연락처',
                        style: CustomStyles.darkBold16TextStyle())),
                Container(
                    margin: EdgeInsets.only(top: 15),
                    child: Text('K 엔터테인먼트 02)111-1111',
                        style: CustomStyles.dark16TextStyle())),
              ],
            ),
          );
  }*/

  /*
  * 메인 위젯
  * */
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: CustomStyles.defaultTheme(),
      child: Scaffold(
          key: _scaffoldKey,
          appBar: CustomStyles.defaultAppBar('지원현황', () {
            Navigator.pop(context);
          }),
          body: Builder(
            builder: (context) {
              return Stack(
                children: [
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    margin:
                                        EdgeInsets.only(top: 30.0, bottom: 10),
                                    padding: EdgeInsets.only(
                                        left: 16, right: 16, bottom: 15),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                  child: Text(
                                                      StringUtils.checkedString(
                                                          _auditionState[
                                                              APIConstants
                                                                  .project_name]),
                                                      style: CustomStyles
                                                          .darkBold10TextStyle())),
                                              Container(
                                                  margin:
                                                      EdgeInsets.only(top: 5),
                                                  child: Text(
                                                      StringUtils.checkedString(
                                                          _auditionState[
                                                              APIConstants
                                                                  .casting_name]),
                                                      style: CustomStyles
                                                          .dark20TextStyle())),
                                              Container(
                                                  margin:
                                                      EdgeInsets.only(top: 5),
                                                  child: CustomStyles
                                                      .underline14TextButtonStyle(
                                                          '제출 프로필', () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              AuditionApplyProfile(
                                                                applySeq: _auditionState[
                                                                    APIConstants
                                                                        .audition_apply_seq],
                                                                isProduction:
                                                                    false,
                                                              )),
                                                    );
                                                  }))
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 0,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                  child: Text(
                                                      StringUtils.checkedString(
                                                          _auditionState[
                                                              APIConstants
                                                                  .state_type]),
                                                      style: CustomStyles
                                                          .dark16TextStyle())),
                                              /*Container(
                                              margin: EdgeInsets.only(top: 5),
                                              child: Text('D-32',
                                                  style: CustomStyles
                                                      .darkBold16TextStyle()))*/
                                            ],
                                          ),
                                        )
                                      ],
                                    )),
                                Container(
                                  color: CustomColors.colorWhite,
                                  child: TabBar(
                                    controller: _tabController,
                                    indicatorPadding: EdgeInsets.zero,
                                    labelStyle: CustomStyles.bold14TextStyle(),
                                    unselectedLabelStyle:
                                        CustomStyles.normal14TextStyle(),
                                    tabs: [
                                      Tab(text: '1차 오디션'),
                                      Tab(text: '2차 오디션'),
                                      Tab(text: '3차 오디션'),
                                      //Tab(text: '최종합격'),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 0,
                                  child: [
                                    tabFirstAudition(),
                                    tabSecondAudition(),
                                    tabThirdAudition(),
                                    //tabPassAudition(0)
                                  ][_tabIndex],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Visibility(
                          child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 55,
                              child: CustomStyles.blueBGSquareButtonStyle(
                                  '비디오 제출', () {
                                showModalBottomSheet(
                                    elevation: 5,
                                    context: context,
                                    builder: (context) {
                                      return Wrap(
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          children: [
                                            /* ListTile(
                                          title: Text(
                                            '동영상 촬영',
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Divider(),*/
                                            ListTile(
                                              title: Text(
                                                '갤러리에서 선택',
                                                textAlign: TextAlign.center,
                                              ),
                                              onTap: () async {
                                                //
                                                var status = Platform.isAndroid
                                                    ? await Permission.storage
                                                        .request()
                                                    : await Permission.photos
                                                        .request();
                                                if (status.isGranted) {
                                                  getVideoFromGallery();
                                                  Navigator.pop(context);
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
                                                            actions: <Widget>[
                                                              CupertinoDialogAction(
                                                                child:
                                                                    Text('거부'),
                                                                onPressed: () =>
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop(),
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
                                              },
                                            ),
                                            Divider(),
                                            ListTile(
                                                title: Text(
                                                  '취소',
                                                  textAlign: TextAlign.center,
                                                ),
                                                onTap: () {
                                                  Navigator.pop(context);
                                                })
                                          ]);
                                    });
                              })),
                          visible: (_tabIndex == 0 &&
                                  _auditionState[
                                          APIConstants.second_audition_seq] !=
                                      null &&
                                  !_isSubmitVideo)
                              ? true
                              : false,
                        ),
                        /* Visibility(
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 55,
                          child: CustomStyles.blueBGSquareButtonStyle(
                              '연락처 공개 동의', () {})),
                      visible: (_tabIndex == 1 && !isAgreeOpenContact)
                          ? true
                          : false,
                    ),
                    Visibility(
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 55,
                          child: CustomStyles.blueBGSquareButtonStyle(
                              '계약서 작성하기', () {})),
                      visible:
                          (_tabIndex == 2 && !isSubmitContract) ? true : false,
                    ),
                    Visibility(
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 55,
                          child: CustomStyles.blueBGSquareButtonStyle(
                              '계약서 보기', () {})),
                      visible: (_tabIndex == 3) ? true : false,
                    ),*/
                      ],
                    ),
                  ),
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
            },
          )),
    );
  }
}
