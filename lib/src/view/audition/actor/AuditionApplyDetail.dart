import 'dart:io';

import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/ui/DecoratedTabBar.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart' as Encrypt;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:url_launcher/url_launcher.dart';
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

  bool _isUpload = false;

  // 실명인증 관련
  bool _isNameChecked = false;
  final _txtFieldName = TextEditingController();
  final _txtFieldJumin1 = TextEditingController();
  final _txtFieldJumin2 = TextEditingController();
  final _txtFieldAddress = TextEditingController();
  final _txtFieldEmail = TextEditingController();
  final _txtFieldPdfPwd = TextEditingController();

  // 계좌인증 관련
  final _txtFieldAccountName = TextEditingController();
  final _txtFieldAccountBirth = TextEditingController();
  final _txtFieldAccountNum = TextEditingController();
  Map<String, dynamic> _bankVal;
  bool _isAccountChecked = false;

  @override
  void initState() {
    super.initState();

    _applySeq = widget.applySeq;

    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection);

    requestMyApplyDetailApi(context);
  }

  _handleTabSelection() {
    if (_tabController.index == 1) {
      // 2차 오디션
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

    if (_tabController.index == 3) {
      // 계약 완료
      if (_auditionState[APIConstants.result_type] == null ||
          _auditionState[APIConstants.result_type] != "계약완료") {
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

        requestMyApplyDetailApi(context);
      });
    }
  }

  /*
  * 지원현황 조회
  * */
  void requestMyApplyDetailApi(BuildContext context) {
    setState(() {
      _isUpload = true;
    });

    // 지원현황 조회 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetData = new Map();
    targetData[APIConstants.audition_apply_seq] = _applySeq;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.SEL_AAA_STATE;
    params[APIConstants.target] = targetData;

    // 지원현황 조회 api 호출
    RestClient(Dio()).postRequestMainControl(params).then((value) async {
      try {
        if (value != null) {
          if (value[APIConstants.resultVal]) {
            // 지원현황 조회 성공
            var _responseData = value[APIConstants.data];

            setState(() {
              var _responseList = _responseData[APIConstants.list] as List;

              if (_responseList != null && _responseList.length > 0) {
                _auditionState = _responseList[0];
              }
            });
          } else {
            showSnackBar(context, APIConstants.error_msg_try_again);
          }
        } else {
          showSnackBar(context, APIConstants.error_msg_server_not_response);
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

  // 갤러리에서 비디오 가져오기
  Future getVideoFromGallery() async {
    if(KCastingAppData().isWeb){
      Navigator.pop(context);
      final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
      if (pickedFile != null) {
        pickedFile.readAsBytes().then((value){
          List<String> mimeTypeArr = pickedFile.mimeType.split('/');
          List<int> _selectedFile = value;

          MultipartFile _multipartFile =  MultipartFile.fromBytes(
              _selectedFile,
              contentType: new MediaType(mimeTypeArr[0], mimeTypeArr[1]),
              filename: pickedFile.name);

          final size = value.lengthInBytes;
          final kb = size / 1024;
          final mb = kb / 1024;

          if (mb > 100) {
            showSnackBar(context, "100MB 미만의 파일만 업로드 가능합니다.");
          } else {
            requestAddActorVideoWeb(context, _multipartFile);
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
  * 배우 비디오 추가
  * */

  Future<void> requestAddActorVideoWeb(
      BuildContext context, MultipartFile multipartFile) async {
    setState(() {
      _isUpload = true;
    });

    try {
      // 배우 비디오 추가 api 호출 시 보낼 파라미터
      Map<String, dynamic> targetData = new Map();
      targetData[APIConstants.secondAuditionTarget_seq] =
      _auditionState[APIConstants.secondAuditionTarget_seq];

      Map<String, dynamic> params = new Map();
      params[APIConstants.key] = APIConstants.UPD_FAT_SUBMITVIDEO;
      params[APIConstants.target] = targetData;

      var files = [];
      files.add(multipartFile);

      params[APIConstants.target_video] = files;

      // 배우 비디오 추가 api 호출
      RestClient(Dio())
          .postRequestMainControlFormData(params)
          .then((value) async {
        if (value == null) {
          // 에러 - 데이터 널
          showSnackBar(context, '다시 시도해 주세요.');
        } else {
          if (value[APIConstants.resultVal]) {
            // 배우 비디오 추가 성공
            setState(() {
              _isUpload = false;
              showSnackBar(context, "비디오 제출 완료!");

              requestMyApplyDetailApi(context);
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

  Future<void> requestAddActorVideo(
      BuildContext context, File videoFile, String thumbFilePath) async {
    setState(() {
      _isUpload = true;
    });

    try {
      // 배우 비디오 추가 api 호출 시 보낼 파라미터
      Map<String, dynamic> targetData = new Map();
      targetData[APIConstants.secondAuditionTarget_seq] =
          _auditionState[APIConstants.secondAuditionTarget_seq];

      Map<String, dynamic> params = new Map();
      params[APIConstants.key] = APIConstants.UPD_FAT_SUBMITVIDEO;
      params[APIConstants.target] = targetData;

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

      params[APIConstants.target_video] = files;
      params[APIConstants.target_video_thumb] = thums;

      // 배우 비디오 추가 api 호출
      RestClient(Dio())
          .postRequestMainControlFormData(params)
          .then((value) async {
        if (value == null) {
          // 에러 - 데이터 널
          showSnackBar(context, '다시 시도해 주세요.');
        } else {
          if (value[APIConstants.resultVal]) {
            // 배우 비디오 추가 성공
            setState(() {
              _isUpload = false;
              showSnackBar(context, "비디오 제출 완료!");

              requestMyApplyDetailApi(context);
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

  /*
  * 배우 연락처 공개 동의
  * */
  void requestAcceptContact(BuildContext context) {
    setState(() {
      _isUpload = true;
    });

    // 지원현황 조회 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetData = new Map();
    targetData[APIConstants.thirdAuditionTarget_seq] =
        _auditionState[APIConstants.thirdAuditionTarget_seq];

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.UPD_SAT_ACCEPTCONTACT;
    params[APIConstants.target] = targetData;

    // 지원현황 조회 api 호출
    RestClient(Dio()).postRequestMainControl(params).then((value) async {
      try {
        if (value != null) {
          if (value[APIConstants.resultVal]) {
            // 지원현황 조회 성공
            var _responseData = value[APIConstants.data];

            setState(() {
              var _responseList = _responseData[APIConstants.list] as List;

              if (_responseList != null && _responseList.length > 0) {
                _auditionState = _responseList[0];

                requestMyApplyDetailApi(context);
              }
            });
          } else {
            showSnackBar(context, APIConstants.error_msg_try_again);
          }
        } else {
          showSnackBar(context, APIConstants.error_msg_server_not_response);
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

  /*
  * 배우 실명인증
  * */
  void requestCheckRealName(BuildContext context) {
    setState(() {
      _isUpload = true;
    });

    // 배우 실명인증 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetData = new Map();
    targetData[APIConstants.jumin1] =
        StringUtils.trimmedString(_txtFieldJumin1.text);
    targetData[APIConstants.jumin2] =
        StringUtils.trimmedString(_txtFieldJumin2.text);
    targetData[APIConstants.name] =
        StringUtils.trimmedString(_txtFieldName.text);

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.CHK_TOT_REALNAME;
    params[APIConstants.target] = targetData;

    // 배우 실명인증 api 호출
    RestClient(Dio()).postRequestMainControl(params).then((value) async {
      try {
        if (value != null) {
          if (value[APIConstants.resultVal]) {
            // 배우 실명인증 성공
            var _responseData = value[APIConstants.data];

            if (_responseData != null) {
              var returnCode = _responseData[APIConstants.iReturnCode];
              switch (returnCode) {
                case "1":
                  // 성공
                  setState(() {
                    _isNameChecked = true;
                  });
                  break;

                default:
                  // 실패
                  showSnackBar(context, APIConstants.error_msg_try_again);
                  break;
              }
            }
          } else {
            showSnackBar(context, APIConstants.error_msg_try_again);
          }
        } else {
          showSnackBar(context, APIConstants.error_msg_server_not_response);
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

  /*
  *  계좌 소유주 확인 api 호출
  * */
  void requestAccountCheckApi(BuildContext context) async {
    final dio = Dio();

    // 계좌 소유주 확인 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetDatas = new Map();
    targetDatas[APIConstants.bankCode] = _bankVal[APIConstants.child_code];
    targetDatas[APIConstants.accountNo] =
        StringUtils.trimmedString(_txtFieldAccountNum.text);
    targetDatas[APIConstants.name] =
        StringUtils.trimmedString(_txtFieldAccountName.text);
    targetDatas[APIConstants.isPersonalAccount] = true;
    targetDatas[APIConstants.resId] =
        StringUtils.trimmedString(_txtFieldAccountBirth.text);

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.CHK_TOT_ACCOUNT;
    params[APIConstants.target] = targetDatas;

    // 계좌 소유주 확인 api 호출
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value == null) {
        // 에러 - 데이터 널 - 서버가 응답하지 않습니다. 다시 시도해 주세요
        showSnackBar(context, APIConstants.error_msg_server_not_response);
      } else {
        if (value[APIConstants.resultVal]) {
          try {
            // 계좌 소유주 확인 성공
            var _responseData = value[APIConstants.data];

            if (_responseData[APIConstants.resultCode] == "0000") {
              setState(() {
                _isAccountChecked = true;
                showSnackBar(context, "계좌 인증이 완료되었습니다.");
              });
            } else {
              if (_responseData[APIConstants.resultMsg] != null) {
                showSnackBar(context, _responseData[APIConstants.resultMsg]);
              }
            }
          } catch (e) {
            showSnackBar(context, "계좌 소유주 확인 실패");
          }
        } else {
          // 기업 실명확인 실패
          showSnackBar(context, "계좌 소유주 확인 실패");
        }
      }
    });
  }

  /*
  * 배우 계약서 작성하기
  * */
  Future<void> requestWriteContract(BuildContext context) async {
    setState(() {
      _isUpload = true;
    });

    // 계좌번호 암호화
    final publicPem =
        await rootBundle.loadString('assets/files/public_key.pem');
    final publicKey = Encrypt.RSAKeyParser().parse(publicPem) as RSAPublicKey;

    final encryptor = Encrypt.Encrypter(Encrypt.RSA(publicKey: publicKey));
    final encryptedAccountNum =
        encryptor.encrypt(StringUtils.trimmedString(_txtFieldAccountNum.text));
    String juminNum = _txtFieldJumin1.text + _txtFieldJumin2.text;
    final encryptedJumin =
        encryptor.encrypt(StringUtils.trimmedString(juminNum));

    // 배우 계약서 작성하기 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetData = new Map();
    targetData[APIConstants.thirdAuditionTarget_seq] =
        _auditionState[APIConstants.thirdAuditionTarget_seq];
    targetData[APIConstants.actor_name] =
        _auditionState[APIConstants.actor_name];
    targetData[APIConstants.sign_type] = "EMAIL";
    targetData[APIConstants.sign_value] =
        StringUtils.trimmedString(_txtFieldEmail.text);
    targetData[APIConstants.pdf_pwd] =
        StringUtils.trimmedString(_txtFieldPdfPwd.text);
    targetData[APIConstants.production_name] =
        _auditionState[APIConstants.production_name];
    targetData[APIConstants.release_planDate] =
        _auditionState[APIConstants.release_planDate].substring(0, 10);
    targetData[APIConstants.project_name] =
        _auditionState[APIConstants.project_name];
    targetData[APIConstants.casting_name] =
        _auditionState[APIConstants.casting_name];
    targetData[APIConstants.casting_pay] =
        _auditionState[APIConstants.final_pay];
    targetData[APIConstants.actor_account] = encryptedAccountNum.base64;
    targetData[APIConstants.actor_account_bank] =
        _bankVal[APIConstants.child_name];
    targetData[APIConstants.actor_account_name] =
        StringUtils.trimmedString(_txtFieldAccountName.text);
    targetData[APIConstants.actor_jumin] = encryptedJumin.base64;
    targetData[APIConstants.actor_address] =
        StringUtils.trimmedString(_txtFieldAddress.text);

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.INS_TOT_MODUOPEN;
    params[APIConstants.target] = targetData;

    // 배우 계약서 작성하기 api 호출
    RestClient(Dio()).postRequestMainControl(params).then((value) async {
      try {
        if (value != null) {
          if (value[APIConstants.resultVal]) {
            // 배우 계약서 작성하기 성공
            var _responseData = value[APIConstants.data];

            setState(() {
              showSnackBar(
                  context, "계약서 작성 완료! 작성된 계약서는 계약완료 탭에서 확인하실 수 있습니다.");

              requestMyApplyDetailApi(context);
            });
          } else {
            showSnackBar(context, APIConstants.error_msg_try_again);
          }
        } else {
          showSnackBar(context, APIConstants.error_msg_server_not_response);
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

  /*
  * 배우 3차 합격 데이터 저장
  * */
  Future<void> requestSaveContract(BuildContext context) async {
    setState(() {
      _isUpload = true;
    });

    // 계좌번호 암호화
    final publicPem =
        await rootBundle.loadString('assets/files/public_key.pem');
    final publicKey = Encrypt.RSAKeyParser().parse(publicPem) as RSAPublicKey;

    final encryptor = Encrypt.Encrypter(Encrypt.RSA(publicKey: publicKey));
    final encryptedAccountNum =
        encryptor.encrypt(StringUtils.trimmedString(_txtFieldAccountNum.text));
    String juminNum = _txtFieldJumin1.text + _txtFieldJumin2.text;
    final encryptedJumin =
        encryptor.encrypt(StringUtils.trimmedString(juminNum));

    // 배우 3차 합격 데이터 저장 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetData = new Map();
    targetData[APIConstants.thirdAuditionTarget_seq] =
        _auditionState[APIConstants.thirdAuditionTarget_seq];
    targetData[APIConstants.actor_bank_code] =
        _bankVal[APIConstants.child_code];
    targetData[APIConstants.actor_account_number] = encryptedAccountNum.base64;
    targetData[APIConstants.actor_account_name] =
        StringUtils.trimmedString(_txtFieldAccountName.text);
    targetData[APIConstants.actor_jumin] = encryptedJumin.base64;
    targetData[APIConstants.final_pay] =
        _auditionState[APIConstants.casting_pay];

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.UPD_TAT_AGREEMENTCOMPLETION;
    params[APIConstants.target] = targetData;

    // 배우 3차 합격 데이터 저장 api 호출
    RestClient(Dio()).postRequestMainControl(params).then((value) async {
      try {
        if (value != null) {
          if (value[APIConstants.resultVal]) {
            // 배우 3차 합격 데이터 저장 성공
            var _responseData = value[APIConstants.data];

            setState(() {
              var _responseList = _responseData[APIConstants.list] as List;

              if (_responseList != null && _responseList.length > 0) {
                _auditionState = _responseList[0];

                requestMyApplyDetailApi(context);
              }
            });
          } else {
            showSnackBar(context, APIConstants.error_msg_try_again);
          }
        } else {
          showSnackBar(context, APIConstants.error_msg_server_not_response);
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

  /*
  * 1차 오디션 현황
  * */
  Widget tabFirstAudition() {
    String state = StringUtils.checkedString(
        _auditionState[APIConstants.firstAuditionTarget_result_type]);

    switch (state) {
      case "대기":
        return Container(
            padding: EdgeInsets.all(15),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                  margin: EdgeInsets.only(bottom: 15, top: 15),
                  child: Text(state, style: CustomStyles.dark20TextStyle())),
              Container(
                  child: Text('오디션 결과를 기다리는 중입니다.',
                      style: CustomStyles.dark16TextStyle()))
            ]));
        break;

      case "합격":
        if (_auditionState[APIConstants.secondAudition_state_type] == null) {
          // 2차 오디션 오픈 전
          return Container(
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
                            '1차 오디션 합격을 진심으로 축하드립니다.\n2차 오디션이 오픈될 때까지 기다려 주세요.',
                            style: CustomStyles.dark16TextStyle()))
                  ]));
        } else {
          // 2차 오디션 오픈 후
          return Container(
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
                        child: Text(
                            _auditionState[APIConstants
                                        .script_securityPledge_isAgree] ==
                                    0
                                ? '서약'
                                : '비밀 유지 서약에 동의하셨습니다.',
                            style: CustomStyles.darkBold16TextStyle())),
                    Visibility(
                        child: Container(
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
                                              MaterialTapTargetSize
                                                  .shrinkWrap)),
                                  Container(
                                      child: Text('대본 비밀 유지 서약에 대해 동의합니다.',
                                          style:
                                              CustomStyles.dark14TextStyle()))
                                ])),
                        visible: _auditionState[APIConstants
                                    .script_securityPledge_isAgree] ==
                                1
                            ? false
                            : true),
                    Visibility(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  margin: EdgeInsets.only(top: 30),
                                  child: Text('대본',
                                      style:
                                          CustomStyles.darkBold16TextStyle())),
                              Container(
                                  margin: EdgeInsets.only(top: 15),
                                  padding: EdgeInsets.only(
                                      left: 10, right: 10, top: 12, bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                  ),
                                  child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                            flex: 1,
                                            child: Text('대본파일',
                                                style: CustomStyles
                                                    .dark14TextStyle(),
                                                overflow: TextOverflow.clip)),
                                        Expanded(
                                            flex: 0,
                                            child: CustomStyles
                                                .darkBold14TextButtonStyle(
                                                    '다운로드', () async {
                                              String _url = _auditionState[
                                                  APIConstants
                                                      .secondAudition_script_url];
                                              await canLaunch(_url)
                                                  ? await launch(_url)
                                                  : throw '$_url을 열 수 없습니다.';
                                            }))
                                      ]))
                            ]),
                        visible: _agreeTerms == 0 ? false : true),
                    Container(
                        margin: EdgeInsets.only(top: 30),
                        child: Text('비디오 제출 기간',
                            style: CustomStyles.darkBold16TextStyle())),
                    Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Text(
                            StringUtils.checkedString(_auditionState[
                                    APIConstants.secondAudition_endDate])
                                .substring(0, 10),
                            style: CustomStyles.dark16TextStyle())),
                    Visibility(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                margin: EdgeInsets.only(top: 30),
                                child: Text('비디오 제출완료!',
                                    style: CustomStyles.darkBold20TextStyle())),
                            Container(
                                margin: EdgeInsets.only(top: 10),
                                child: Text('제출한 비디오는 제출 프로필>비디오에 추가되었습니다.',
                                    style: CustomStyles.dark16TextStyle()))
                          ]),
                      visible: _auditionState[APIConstants.isSubmitVideo] == 1
                          ? true
                          : false,
                    )
                  ]));
        }

        break;

      case "불합격":
        return Container(
            padding: EdgeInsets.all(15),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                  margin: EdgeInsets.only(bottom: 15, top: 15),
                  child: Text('불합격', style: CustomStyles.dark20TextStyle())),
              Container(
                  child: Text(
                      '아쉽게도 1차 오디션에 합격하지 못했습니다.\n다음에 더 좋은 배역으로 만나길 바랍니다.\n감사힙니다.',
                      style: CustomStyles.dark16TextStyle())),
            ]));
        break;

      default:
        return Container(
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
        );
        break;
    }
  }

  /*
  * 비디오 제출 위젯
  * */
  Widget submitVideoWidget() {
    return Container(
        width: (KCastingAppData().isWeb)
            ? CustomStyles.appWidth
            : MediaQuery.of(context).size.width,
        height: 55,
        child: CustomStyles.blueBGSquareButtonStyle('비디오 제출', () {
          showModalBottomSheet(
              elevation: 5,
              context: context,
              builder: (context) {
                return Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ListTile(
                          title: Text(
                            '갤러리에서 선택',
                            textAlign: TextAlign.center,
                          ),
                          onTap: () async {
                            if(KCastingAppData().isWeb){
                              getVideoFromGallery();
                            }else{
                              var status = Platform.isAndroid
                                  ? await Permission.storage.request()
                                  : await Permission.photos.request();
                              if (status.isGranted) {
                                getVideoFromGallery();
                                Navigator.pop(context);
                              } else {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        CupertinoAlertDialog(
                                            title: Text('저장공간 접근권한'),
                                            content: Text(
                                                '사진 또는 비디오를 업로드하려면, 기기 사진, 미디어, 파일 접근 권한이 필요합니다.'),
                                            actions: <Widget>[
                                              CupertinoDialogAction(
                                                child: Text('거부'),
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                              ),
                                              CupertinoDialogAction(
                                                  child: Text('허용'),
                                                  onPressed: () =>
                                                      openAppSettings())
                                            ]));
                              }
                            }
                          }),
                      Divider(),
                      ListTile(
                          title: Text('취소', textAlign: TextAlign.center),
                          onTap: () {
                            Navigator.pop(context);
                          })
                    ]);
              });
        }));
  }

  /*
  * 2차 오디션 현황
  * */
  Widget tabSecondAudition() {
    String state = StringUtils.checkedString(
        _auditionState[APIConstants.secondAuditionTarget_result_type]);

    switch (state) {
      case "대기":
        if (_auditionState[APIConstants.isSubmitVideo] == 1) {
          return Container(
              padding: EdgeInsets.all(15),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        margin: EdgeInsets.only(bottom: 15, top: 15),
                        child:
                            Text(state, style: CustomStyles.dark20TextStyle())),
                    Container(
                        child: Text('오디션 결과를 기다리는 중입니다.',
                            style: CustomStyles.dark16TextStyle()))
                  ]));
        } else {
          return Container(
              padding: EdgeInsets.all(15),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        margin: EdgeInsets.only(bottom: 15, top: 15),
                        child:
                            Text(state, style: CustomStyles.dark20TextStyle())),
                    Container(
                        child: Text('2차 오디션 심사를 위해 비디오를 제출해 주세요.',
                            style: CustomStyles.dark16TextStyle()))
                  ]));
        }
        break;
      case "합격":
        return Container(
            padding: EdgeInsets.only(top: 20, left: 15, right: 15, bottom: 20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                  margin: EdgeInsets.only(bottom: 15, top: 15),
                  child: Text('2차 합격', style: CustomStyles.dark20TextStyle())),
              Container(
                  child: Text(
                      '2차 오디션 합격을 진심으로 축하드립니다.\n3차 오디션은 자유 면접입니다.\n일정안내를 위해 나의 전화번호가 공유됩니다.',
                      style: CustomStyles.dark16TextStyle())),
              Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Text(
                      StringUtils.checkedString(
                              _auditionState[APIConstants.actor_phone]) +
                          '로 면접일정이 안내됩니다.',
                      style: CustomStyles.dark16TextStyle()))
            ]));
        break;
      case "불합격":
        return Container(
            padding: EdgeInsets.all(15),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                  margin: EdgeInsets.only(bottom: 15, top: 15),
                  child: Text('불합격', style: CustomStyles.dark20TextStyle())),
              Container(
                  child: Text(
                      '아쉽게도 2차 오디션에 합격하지 못했습니다.\n다음에 더 좋은 배역으로 만나길 바랍니다.\n감사힙니다.',
                      style: CustomStyles.dark16TextStyle())),
            ]));
        break;
      default:
        return Container();
        break;
    }
  }

  /*
  * 3차 오디션 현황
  * */
  Widget tabThirdAudition() {
    String state = StringUtils.checkedString(
        _auditionState[APIConstants.thirdAuditionTarget_result_type]);

    switch (state) {
      case "대기":
        return Container(
            padding: EdgeInsets.all(15),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                  margin: EdgeInsets.only(bottom: 15, top: 15),
                  child: Text('면접안내', style: CustomStyles.dark20TextStyle())),
              Container(
                  child: Text(
                      '면접 일정은 담당자가 확인하는대로\n해당 연락처의 문자로 갈 예정입니다.\n잠시만 기다려주세요.\n\n면접 후, 면접관이 합격 또는 불합격 통보시\n해당 화면에 결과가 나타납니다.',
                      style: CustomStyles.dark16TextStyle()))
            ]));
        break;
      case "합격":
        switch (StringUtils.checkedString(
            _auditionState[APIConstants.result_type])) {
          case "계약서대기중":
            return Container(
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
                          child: Text(
                              '최종합격을 축하드립니다.\n제작사에서 최종 출연료를 확정하면 계약서를 작성하실 수 있습니다. 조금만 기다려 주세요.',
                              style: CustomStyles.dark16TextStyle()))
                    ]));
            break;
          case "계약서미작성":
            return Container(
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
                          child: Text(
                              '최종합격을 축하드립니다.\n출연 확정을 위해 본인 명의의 주민등록번호와\n입금받을 계좌와 주소를 확인 후 아래의 계약서를\n작성해주세요.',
                              style: CustomStyles.dark16TextStyle())),
                      Container(
                        margin: EdgeInsets.only(top: 30),
                        child: Divider(
                          height: 0.1,
                          color: CustomColors.colorFontLightGrey,
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.only(top: 30),
                          child: Text('출연료',
                              style: CustomStyles.darkBold16TextStyle())),
                      Container(
                          margin: EdgeInsets.only(top: 15),
                          child: Text(
                              StringUtils.checkedString(
                                  _auditionState[APIConstants.final_pay]),
                              style: CustomStyles.dark16TextStyle())),
                      Container(
                        margin: EdgeInsets.only(top: 30),
                        child: Divider(
                          height: 0.1,
                          color: CustomColors.colorFontLightGrey,
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.only(top: 30),
                          child: Text('실명인증',
                              style: CustomStyles.darkBold16TextStyle())),
                      Visibility(
                          child: Column(children: [
                            Container(
                                margin: EdgeInsets.only(top: 10),
                                alignment: Alignment.centerLeft,
                                child: Text('* 입력하신 정보는 실명인증을 위해서만 사용됩니다.',
                                    style: CustomStyles.normal14TextStyle())),
                            Container(
                                margin: EdgeInsets.only(top: 10),
                                alignment: Alignment.centerLeft,
                                child: Text('이름',
                                    style: CustomStyles.normal14TextStyle())),
                            Container(
                                margin: EdgeInsets.only(top: 5),
                                child: CustomStyles
                                    .greyBorderRound7TextFieldWithDisableOpt(
                                        _txtFieldName,
                                        '본명 입력',
                                        !_isAccountChecked)),
                            Container(
                                margin: EdgeInsets.only(top: 10),
                                alignment: Alignment.centerLeft,
                                child: Text('주민등록번호',
                                    style: CustomStyles.normal14TextStyle())),
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
                                          child: CustomStyles
                                              .greyBorderRound7TextFieldWithOption(
                                                  _txtFieldJumin1,
                                                  TextInputType.number,
                                                  '앞 6자리')),
                                    ),
                                    Expanded(
                                      flex: 0,
                                      child: Container(
                                        alignment: Alignment.center,
                                        margin:
                                            EdgeInsets.only(left: 5, right: 5),
                                        child: Text("-",
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: CustomColors
                                                    .colorFontGrey)),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Container(
                                          child: CustomStyles
                                              .greyBorderRound7PWDTextFieldOnlyNumber(
                                                  _txtFieldJumin2, '뒷 7자리')),
                                    ),
                                    Expanded(
                                        flex: 3,
                                        child: Container(
                                            height: 48,
                                            margin: EdgeInsets.only(left: 5),
                                            child: CustomStyles
                                                .greyBGRound7ButtonStyle('인증하기',
                                                    () {
                                              setState(() {
                                                if (StringUtils.isEmpty(
                                                    _txtFieldName.text)) {
                                                  showSnackBar(
                                                      context, '이름을 입력해 주세요.');
                                                  return false;
                                                }

                                                if (StringUtils.isEmpty(
                                                    _txtFieldJumin1.text)) {
                                                  showSnackBar(context,
                                                      '주민번호 앞자리를 입력해 주세요.');
                                                  return false;
                                                }

                                                if (StringUtils.isEmpty(
                                                    _txtFieldJumin2.text)) {
                                                  showSnackBar(context,
                                                      '주민번호 뒷자리를 입력해 주세요.');
                                                  return false;
                                                }

                                                requestCheckRealName(context);
                                              });
                                            })))
                                  ],
                                ))
                          ]),
                          visible: !_isNameChecked),
                      Visibility(
                          child: Container(
                              margin: EdgeInsets.only(top: 10),
                              alignment: Alignment.centerLeft,
                              child: Text('실명인증이 완료되었습니다.',
                                  style: CustomStyles.normal14TextStyle())),
                          visible: _isNameChecked),
                      Container(
                        margin: EdgeInsets.only(top: 30),
                        child: Divider(
                          height: 0.1,
                          color: CustomColors.colorFontLightGrey,
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.only(top: 30),
                          child: Text('계좌인증',
                              style: CustomStyles.darkBold16TextStyle())),
                      Container(
                          margin: EdgeInsets.only(top: 5),
                          child: CustomStyles
                              .greyBorderRound7TextFieldWithDisableOpt(
                                  _txtFieldAccountName,
                                  '예금주명 입력',
                                  !_isAccountChecked)),
                      Container(
                          margin: EdgeInsets.only(top: 5),
                          child: CustomStyles
                              .greyBorderRound7NumbersOnlyTextFieldWithDisableOpt(
                                  _txtFieldAccountBirth,
                                  '예금주 생년월일 6자리 입력(숫자만)',
                                  !_isAccountChecked)),
                      Container(
                        margin: EdgeInsets.only(top: 5),
                        width: double.infinity,
                        child: DropdownButtonFormField(
                          //value: _bankVal,
                          hint: Container(
                            //and here
                            child: Text("은행 선택",
                                style: CustomStyles.light14TextStyle()),
                          ),
                          onChanged: _isAccountChecked
                              ? null
                              : (newValue) {
                                  setState(() {
                                    _bankVal = newValue;
                                  });
                                },
                          items: KCastingAppData().bankCode.map((value) {
                            return DropdownMenuItem<Map<String, dynamic>>(
                              value: value,
                              child: Text(value[APIConstants.child_name],
                                  style: CustomStyles.normal14TextStyle()),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: CustomColors.colorFontLightGrey,
                                      width: 1.0),
                                  borderRadius: BorderRadius.circular(7.0)),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10)),
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.only(top: 5),
                          width: double.infinity,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 7,
                                child: Container(
                                    child: CustomStyles
                                        .greyBorderRound7NumbersOnlyTextFieldWithDisableOpt(
                                            _txtFieldAccountNum,
                                            '계좌번호 입력',
                                            !_isAccountChecked)),
                              ),
                              Expanded(
                                flex: 0,
                                child: Container(
                                    height: 48,
                                    margin: EdgeInsets.only(left: 5),
                                    child: CustomStyles.greyBGRound7ButtonStyle(
                                        _isAccountChecked ? '인증완료' : '계좌인증',
                                        () {
                                      // 인증번호 받기 버튼 클릭
                                      if (_isAccountChecked) {
                                        showSnackBar(context, "이미 인증되었습니다.");
                                      } else {
                                        if (StringUtils.isEmpty(
                                            _txtFieldAccountName.text)) {
                                          showSnackBar(
                                              context, '예금주명을 입력해 주세요.');
                                          return false;
                                        }

                                        if (StringUtils.isEmpty(
                                            _txtFieldAccountBirth.text)) {
                                          showSnackBar(context,
                                              '예금주 생년월일 6자리를 입력해 주세요.');
                                          return false;
                                        }

                                        if (_bankVal == null) {
                                          showSnackBar(context, '은행을 선택해 주세요.');
                                          return false;
                                        }

                                        if (_bankVal[APIConstants.child_code] ==
                                            null) {
                                          showSnackBar(context, '은행을 선택해 주세요.');
                                          return false;
                                        }

                                        if (StringUtils.isEmpty(
                                            _txtFieldAccountNum.text)) {
                                          showSnackBar(
                                              context, '계좌번호를 입력해 주세요.');
                                          return false;
                                        }

                                        requestAccountCheckApi(context);
                                      }
                                    })),
                              )
                            ],
                          )),
                      Container(
                        margin: EdgeInsets.only(top: 30),
                        child: Divider(
                          height: 0.1,
                          color: CustomColors.colorFontLightGrey,
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.only(top: 30),
                          child: Text('주소지 입력',
                              style: CustomStyles.darkBold16TextStyle())),
                      Container(
                          margin: EdgeInsets.only(top: 5),
                          child: CustomStyles.greyBorderRound7TextField(
                              _txtFieldAddress, '주소 입력')),
                      Container(
                        margin: EdgeInsets.only(top: 30),
                        child: Divider(
                          height: 0.1,
                          color: CustomColors.colorFontLightGrey,
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.only(top: 30),
                          child: Text('계약서 수신 이메일주소',
                              style: CustomStyles.darkBold16TextStyle())),
                      Container(
                          margin: EdgeInsets.only(top: 5),
                          child:
                              CustomStyles.greyBorderRound7TextFieldWithOption(
                                  _txtFieldEmail,
                                  TextInputType.emailAddress,
                                  '정확하게 입력해 주세요.')),
                      Container(
                          margin: EdgeInsets.only(top: 5),
                          child: Text('* 계약서를 수신할 이메일 주소를 정확하게 입력해 주세요.',
                              style: CustomStyles.grey14TextStyle())),
                      Container(
                        margin: EdgeInsets.only(top: 30),
                        child: Divider(
                          height: 0.1,
                          color: CustomColors.colorFontLightGrey,
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.only(top: 30),
                          child: Text('계약서 파일 비밀번호',
                              style: CustomStyles.darkBold16TextStyle())),
                      Container(
                          margin: EdgeInsets.only(top: 5),
                          child: CustomStyles.greyBorderRound7PWDTextField(
                              _txtFieldPdfPwd, '영어, 숫자 조합 10자리 입력')),
                      Container(
                          margin: EdgeInsets.only(top: 5, bottom: 50),
                          child: Text(
                              '* 작성하신 계약서 파일을 열어볼 때 필요한 비밀번호 입니다. 비밀번호 분실 시 계약서 파일 조회가 불가능하오니, 꼭 메모해 두시길 바랍니다.',
                              style: CustomStyles.grey14TextStyle())),
                    ]));
            break;
          case "서명대기중":
            return Container(
                padding:
                    EdgeInsets.only(top: 20, left: 15, right: 15, bottom: 20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          margin: EdgeInsets.only(bottom: 15, top: 15),
                          child: Text('계약서 서명대기중',
                              style: CustomStyles.dark20TextStyle())),
                      Container(
                          child: Text(
                              '작성하신 계약서가 \'' +
                                  _auditionState[APIConstants.paper_email] +
                                  '\'로 발송되었습니다.\n계약서에 서명하시면 계약이 완료됩니다.',
                              style: CustomStyles.dark16TextStyle()))
                    ]));
            break;
          case "계약완료":
            return Container(
              padding:
                  EdgeInsets.only(top: 20, left: 15, right: 15, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      margin: EdgeInsets.only(top: 30),
                      child: Text('계약서 작성완료',
                          style: CustomStyles.darkBold20TextStyle())),
                  Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Text('계약완료 탭에서 작성하신 계약서를 확인하실 수 있습니다.',
                          style: CustomStyles.dark16TextStyle()))
                ],
              ),
            );
            break;
        }

        break;
      case "불합격":
        return Container(
            padding: EdgeInsets.all(15),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                  margin: EdgeInsets.only(bottom: 15, top: 15),
                  child: Text('불합격', style: CustomStyles.dark20TextStyle())),
              Container(
                  child: Text(
                      '아쉽게도 3차 오디션에 합격하지 못했습니다.\n다음에 더 좋은 배역으로 만나길 바랍니다.\n감사합니다.',
                      style: CustomStyles.dark16TextStyle())),
            ]));
        break;
      case "면접완료":
        return Container(
            padding: EdgeInsets.all(15),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                  margin: EdgeInsets.only(bottom: 15, top: 15),
                  child: Text('면접완료', style: CustomStyles.dark20TextStyle())),
              Container(
                  child: Text('면접결과 대기 중입니다.',
                      style: CustomStyles.dark16TextStyle())),
            ]));
        break;
      default:
        return Container();
        break;
    }
  }

  /*
  * 최종 합격
  * */
  Widget tabPassAudition() {
    return (_auditionState[APIConstants.isPayment] == 0)
        // 최종합격
        ? Container(
            padding: EdgeInsets.all(15),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                  margin: EdgeInsets.only(bottom: 15, top: 15),
                  child: Text('계약완료', style: CustomStyles.dark20TextStyle())),
              Container(
                  child: Text('계약완료를 축하드립니다.\n아래의 버튼으로 계약서를 확인할 수 있습니다.',
                      style: CustomStyles.dark16TextStyle())),
              Container(
                  margin: EdgeInsets.only(top: 30),
                  child:
                      Text('출연료', style: CustomStyles.darkBold16TextStyle())),
              Container(
                  margin: EdgeInsets.only(top: 15),
                  child: Text(
                      StringUtils.checkedString(
                          _auditionState[APIConstants.final_pay]),
                      style: CustomStyles.dark16TextStyle()))
            ]))
        : Container(
            padding: EdgeInsets.only(top: 20, left: 15, right: 15, bottom: 20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                  margin: EdgeInsets.only(bottom: 15, top: 15),
                  child: Text('계약완료', style: CustomStyles.dark20TextStyle())),
              Container(
                  child: Text('계약서에 작성하신 계좌로 출연료가 지급되었습니다.\n확인 부탁드립니다.',
                      style: CustomStyles.dark16TextStyle())),
              Container(
                  margin: EdgeInsets.only(top: 30),
                  child:
                      Text('출연료', style: CustomStyles.darkBold16TextStyle())),
              Container(
                  margin: EdgeInsets.only(top: 15),
                  child: Text(
                      StringUtils.checkedString(
                          _auditionState[APIConstants.final_pay]),
                      style: CustomStyles.dark16TextStyle()))
            ]));
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
                    appBar: CustomStyles.defaultAppBar('지원현황', () {
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
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                        Container(
                                            margin: EdgeInsets.only(
                                                top: 30.0, bottom: 10),
                                            padding: EdgeInsets.only(
                                                left: 16,
                                                right: 16,
                                                bottom: 15),
                                            child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Expanded(
                                                      flex: 1,
                                                      child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Container(
                                                                child: Text(
                                                                    StringUtils.checkedString(_auditionState[
                                                                        APIConstants
                                                                            .project_name]),
                                                                    style: CustomStyles
                                                                        .darkBold10TextStyle())),
                                                            Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        top: 5),
                                                                child: Text(
                                                                    StringUtils.checkedString(_auditionState[
                                                                        APIConstants
                                                                            .casting_name]),
                                                                    style: CustomStyles
                                                                        .dark20TextStyle())),
                                                            Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        top: 5),
                                                                child: CustomStyles
                                                                    .underline14TextButtonStyle(
                                                                        StringUtils.checkedString(_auditionState[APIConstants.actor_name]) +
                                                                            '님의 제출 프로필',
                                                                        () {
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) => AuditionApplyProfile(
                                                                              applySeq: _auditionState[APIConstants.auditionApply_seq],
                                                                              isProduction: false)));
                                                                }))
                                                          ])),
                                                  Expanded(
                                                      flex: 0,
                                                      child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Container(
                                                                child: Text(
                                                                    StringUtils.checkedString(_auditionState[
                                                                        APIConstants
                                                                            .auditionApply_state_type]),
                                                                    style: CustomStyles
                                                                        .dark16TextStyle()))
                                                          ]))
                                                ])),
                                        Container(
                                            child: DecoratedTabBar(
                                                decoration: BoxDecoration(
                                                    border: Border(
                                                        bottom: BorderSide(
                                                            color: CustomColors
                                                                .colorBgGrey,
                                                            width: 1.0))),
                                                tabBar: TabBar(
                                                    controller: _tabController,
                                                    indicatorPadding:
                                                        EdgeInsets.zero,
                                                    indicatorColor: CustomColors
                                                        .colorAccent
                                                        .withAlpha(200),
                                                    labelStyle: CustomStyles
                                                        .bold14TextStyle(),
                                                    indicatorWeight: 3,
                                                    labelColor: CustomColors
                                                        .colorFontTitle,
                                                    unselectedLabelStyle:
                                                        CustomStyles
                                                            .normal14TextStyle(),
                                                    tabs: [
                                                      Tab(text: '1차 오디션'),
                                                      Tab(text: '2차 오디션'),
                                                      Tab(text: '3차 오디션'),
                                                      Tab(text: '계약완료')
                                                    ]))),
                                        Expanded(
                                            flex: 0,
                                            child: [
                                              tabFirstAudition(),
                                              tabSecondAudition(),
                                              tabThirdAudition(),
                                              tabPassAudition()
                                            ][_tabIndex])
                                      ]))),
                              Visibility(
                                child: submitVideoWidget(),
                                visible: (_tabIndex == 0 &&
                                        _auditionState[APIConstants
                                                .firstAuditionTarget_result_type] ==
                                            '합격' &&
                                        _auditionState[APIConstants
                                                .secondAudition_state_type] !=
                                            null &&
                                        _auditionState[
                                                APIConstants.isSubmitVideo] ==
                                            0)
                                    ? true
                                    : false,
                              ),
                              Visibility(
                                child: Container(
                                    width: (KCastingAppData().isWeb)
                                        ? CustomStyles.appWidth
                                        : MediaQuery.of(context).size.width,
                                    height: 55,
                                    child: CustomStyles.blueBGSquareButtonStyle(
                                        '연락처 공개 동의', () {
                                      requestAcceptContact(context);
                                    })),
                                visible: (_tabIndex == 1 &&
                                        (_auditionState[APIConstants
                                                    .secondAuditionTarget_result_type] ==
                                                '합격' ||
                                            _auditionState[APIConstants
                                                    .secondAuditionTarget_result_type] ==
                                                '대기') &&
                                        _auditionState[APIConstants
                                                .thirdAudition_phone_use_isAgree] ==
                                            0)
                                    ? true
                                    : false,
                              ),
                              Visibility(
                                  child: Container(
                                      width: (KCastingAppData().isWeb)
                                          ? CustomStyles.appWidth
                                          : MediaQuery.of(context).size.width,
                                      height: 55,
                                      child:
                                          CustomStyles.blueBGSquareButtonStyle(
                                              '계약서 작성하기', () {
                                        if (!_isNameChecked) {
                                          showSnackBar(context, '실명인증을 해주세요.');
                                          return false;
                                        }

                                        if (!_isAccountChecked) {
                                          showSnackBar(context, '계좌인증을 해주세요.');
                                          return false;
                                        }

                                        if (StringUtils.isEmpty(
                                            _txtFieldAddress.text)) {
                                          showSnackBar(
                                              context, '주소지를 입력해 주세요.');
                                          return false;
                                        }

                                        if (StringUtils.isEmpty(
                                            _txtFieldEmail.text)) {
                                          showSnackBar(
                                              context, '이메일을 입력해 주세요.');
                                          return false;
                                        }

                                        if (!RegExp(
                                                r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                                            .hasMatch(_txtFieldEmail.text)) {
                                          showSnackBar(
                                              context, '이메일 주소 형식이 올바르지 않습니다.');
                                          return false;
                                        }

                                        if (StringUtils.isEmpty(
                                            _txtFieldPdfPwd.text)) {
                                          showSnackBar(
                                              context, '비밀번호를 입력해 주세요.');
                                          return false;
                                        }

                                        if (!RegExp(r"[a-z0-9]")
                                            .hasMatch(_txtFieldPdfPwd.text)) {
                                          showSnackBar(
                                              context, '비밀번호 형식이 올바르지 않습니다.');
                                          return false;
                                        }

                                        if (_txtFieldPdfPwd.text.length < 10) {
                                          showSnackBar(
                                              context, '비밀번호는 10자리로 설정해 주세요.');
                                          return false;
                                        }

                                        requestWriteContract(context);
                                      })),
                                  visible: (_tabIndex == 2 &&
                                          _auditionState[APIConstants
                                                  .thirdAuditionTarget_result_type] ==
                                              '합격' &&
                                          StringUtils.checkedString(
                                                  _auditionState[APIConstants
                                                      .result_type]) ==
                                              "계약서미작성")
                                      ? true
                                      : false),
                              Visibility(
                                  child: Container(
                                      width: (KCastingAppData().isWeb)
                                          ? CustomStyles.appWidth
                                          : MediaQuery.of(context).size.width,
                                      height: 55,
                                      child:
                                          CustomStyles.blueBGSquareButtonStyle(
                                              '계약서 보기', () async {
                                        String _url = _auditionState[
                                            APIConstants.paper_url];
                                        await canLaunch(_url)
                                            ? await launch(_url)
                                            : throw '$_url을 열 수 없습니다.';
                                      })),
                                  visible: (_tabIndex == 3 &&
                                          StringUtils.checkedString(
                                                  _auditionState[APIConstants
                                                      .result_type]) ==
                                              "계약완료")
                                      ? true
                                      : false)
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
}
