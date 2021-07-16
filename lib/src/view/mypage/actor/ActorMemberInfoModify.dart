import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:casting_call/src/view/mypage/actor/ActorMemberInfo.dart';
import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pointycastle/asymmetric/api.dart';

import '../../../../KCastingAppData.dart';

/*
* 배우 개인정보 수정
* */
class ActorMemberInfoModify extends StatefulWidget {
  @override
  _ActorMemberInfoModify createState() => _ActorMemberInfoModify();
}

class _ActorMemberInfoModify extends State<ActorMemberInfoModify>
    with BaseUtilMixin {
  final _txtFieldPW = TextEditingController();
  final _txtFieldNewPW = TextEditingController();
  final _txtFieldPWCheck = TextEditingController();
  final _txtFieldPhone = TextEditingController();
  final _txtFieldEmail = TextEditingController();
  final _txtFieldAccountName = TextEditingController();
  final _txtFieldAccountBirth = TextEditingController();
  final _txtFieldAccountNum = TextEditingController();

  Map<String, dynamic> _bankVal;
  bool _isAccountChecked = false;

  @override
  void initState() {
    super.initState();

    _txtFieldPhone.text =
        StringUtils.isEmpty(KCastingAppData().myInfo[APIConstants.actor_phone])
            ? ''
            : KCastingAppData().myInfo[APIConstants.actor_phone];

    _txtFieldEmail.text =
        StringUtils.isEmpty(KCastingAppData().myInfo[APIConstants.actor_email])
            ? ''
            : KCastingAppData().myInfo[APIConstants.actor_email];

    /*for (int i = 0; i < KCastingAppData().bankCode.length; i++) {
      Map<String, dynamic> bankItem = KCastingAppData().bankCode[i];

      if (bankItem[APIConstants.child_code] ==
          KCastingAppData().myInfo[APIConstants.actor_bank_code]) {
        setState(() {
          _bankVal = bankItem;
        });
      }
    }
    _txtFieldAccountNum.text = StringUtils.isEmpty(
            KCastingAppData().myInfo[APIConstants.actor_account_number])
        ? ''
        : KCastingAppData().myInfo[APIConstants.actor_account_number];

    _txtFieldAccountName.text = StringUtils.isEmpty(
            KCastingAppData().myInfo[APIConstants.actor_account_holder])
        ? ''
        : KCastingAppData().myInfo[APIConstants.actor_account_holder];

    _txtFieldAccountBirth.text = StringUtils.isEmpty(
            KCastingAppData().myInfo[APIConstants.actor_account_holder_birth])
        ? ''
        : KCastingAppData().myInfo[APIConstants.actor_account_holder_birth];*/
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
  * 메인 위젯
  * */
  @override
  Widget build(BuildContext context) {
    return Theme(
        data: CustomStyles.defaultTheme(),
        child: Scaffold(
            appBar: CustomStyles.defaultAppBar('개인정보 수정', () {
              Navigator.pop(context);
            }),
            body: Builder(
              builder: (BuildContext context) {
                return Container(
                    child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.only(top: 30, bottom: 30),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.only(left: 18, right: 18),
                            child: Text('개인정보 수정',
                                style: CustomStyles.normal24TextStyle())),
                        Container(
                            margin: EdgeInsets.only(top: 30.0),
                            padding: EdgeInsets.only(left: 18, right: 18),
                            child: Text('아이디',
                                style: CustomStyles.bold14TextStyle())),
                        Container(
                            margin: EdgeInsets.only(top: 15.0),
                            padding: EdgeInsets.only(left: 18, right: 18),
                            child: Text(
                                KCastingAppData().myInfo[APIConstants.id],
                                style: CustomStyles.normal16TextStyle())),
                        Container(
                            margin: EdgeInsets.only(top: 20.0),
                            padding: EdgeInsets.only(left: 18, right: 18),
                            child: Text('현재 비밀번호',
                                style: CustomStyles.bold14TextStyle())),
                        Container(
                            margin: EdgeInsets.only(top: 5),
                            padding: EdgeInsets.only(left: 18, right: 18),
                            child: CustomStyles.greyBorderRound7PWDTextField(
                                _txtFieldPW, '대문자, 소문자, 숫자 조합으로 가능합니다.')),
                        Container(
                            margin: EdgeInsets.only(top: 15.0),
                            padding: EdgeInsets.only(left: 18, right: 18),
                            child: Text('새 비밀번호',
                                style: CustomStyles.bold14TextStyle())),
                        Container(
                            margin: EdgeInsets.only(top: 5),
                            padding: EdgeInsets.only(left: 18, right: 18),
                            child: CustomStyles.greyBorderRound7PWDTextField(
                                _txtFieldNewPW, '대문자, 소문자, 숫자 조합으로 가능합니다.')),
                        Container(
                            margin: EdgeInsets.only(top: 15),
                            padding: EdgeInsets.only(left: 18, right: 18),
                            alignment: Alignment.centerLeft,
                            child: Text('비밀번호 확인',
                                style: CustomStyles.bold14TextStyle())),
                        Container(
                            margin: EdgeInsets.only(top: 5),
                            padding: EdgeInsets.only(left: 18, right: 18),
                            child: CustomStyles.greyBorderRound7PWDTextField(
                                _txtFieldPWCheck, '비밀번호를 한번 더 입력해 주세요.')),
                        Container(
                          margin: EdgeInsets.only(top: 30, bottom: 30),
                          child: Divider(
                            height: 0.1,
                            color: CustomColors.colorFontLightGrey,
                          ),
                        ),
                        Container(
                            padding: EdgeInsets.only(left: 18, right: 18),
                            child: Text('이름',
                                style: CustomStyles.bold14TextStyle())),
                        Container(
                            margin: EdgeInsets.only(top: 15),
                            padding: EdgeInsets.only(left: 18, right: 18),
                            child: Text(
                                KCastingAppData()
                                    .myInfo[APIConstants.actor_name],
                                style: CustomStyles.normal16TextStyle())),
                        Container(
                            margin: EdgeInsets.only(top: 20),
                            padding: EdgeInsets.only(left: 18, right: 18),
                            child: Text('생년월일',
                                style: CustomStyles.bold14TextStyle())),
                        Container(
                            margin: EdgeInsets.only(top: 15),
                            padding: EdgeInsets.only(left: 18, right: 18),
                            child: Text(
                                KCastingAppData()
                                    .myInfo[APIConstants.actor_birth],
                                style: CustomStyles.normal16TextStyle())),
                        Container(
                            margin: EdgeInsets.only(top: 20),
                            padding: EdgeInsets.only(left: 18, right: 18),
                            child: Text('성별',
                                style: CustomStyles.bold14TextStyle())),
                        Container(
                            margin: EdgeInsets.only(top: 15),
                            padding: EdgeInsets.only(left: 18, right: 18),
                            child: Text(
                                KCastingAppData().myInfo[APIConstants.sex_type],
                                style: CustomStyles.normal16TextStyle())),
                        Container(
                          margin: EdgeInsets.only(top: 30, bottom: 30),
                          child: Divider(
                            height: 0.1,
                            color: CustomColors.colorFontLightGrey,
                          ),
                        ),
                        Container(
                            padding: EdgeInsets.only(left: 18, right: 18),
                            child: Text('연락처',
                                style: CustomStyles.bold14TextStyle())),
                        Container(
                            margin: EdgeInsets.only(top: 15),
                            padding: EdgeInsets.only(left: 18, right: 18),
                            child: CustomStyles.greyBorderRound7TextField(
                                _txtFieldPhone, '')),
                        Container(
                          margin: EdgeInsets.only(top: 30, bottom: 30),
                          child: Divider(
                            height: 0.1,
                            color: CustomColors.colorFontLightGrey,
                          ),
                        ),
                        /*Container(
                            padding: EdgeInsets.only(left: 18, right: 18),
                            alignment: Alignment.centerLeft,
                            child: Text('은행 계좌',
                                style: CustomStyles.normal14TextStyle())),
                        Container(
                            padding: EdgeInsets.only(left: 18, right: 18),
                            margin: EdgeInsets.only(top: 5),
                            child: CustomStyles
                                .greyBorderRound7TextFieldWithDisableOpt(
                                    _txtFieldAccountName,
                                    '예금주명 입력',
                                    !_isAccountChecked)),
                        Container(
                            padding: EdgeInsets.only(left: 18, right: 18),
                            margin: EdgeInsets.only(top: 5),
                            child: CustomStyles
                                .greyBorderRound7NumbersOnlyTextFieldWithDisableOpt(
                                    _txtFieldAccountBirth,
                                    '예금주 생년월일 6자리 입력(숫자만)',
                                    !_isAccountChecked)),
                        Container(
                          margin: EdgeInsets.only(top: 5),
                          padding: EdgeInsets.only(left: 18, right: 18),
                          width: double.infinity,
                          child: DropdownButtonFormField(
                            value: _bankVal,
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
                            padding: EdgeInsets.only(left: 18, right: 18),
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
                                      child:
                                          CustomStyles.greyBGRound7ButtonStyle(
                                              _isAccountChecked
                                                  ? '인증완료'
                                                  : '계좌인증', () {
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
                                            showSnackBar(
                                                context, '은행을 선택해 주세요.');
                                            return false;
                                          }

                                          if (_bankVal[
                                                  APIConstants.child_code] ==
                                              null) {
                                            showSnackBar(
                                                context, '은행을 선택해 주세요.');
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
                          margin: EdgeInsets.only(top: 30, bottom: 30),
                          child: Divider(
                            height: 0.1,
                            color: CustomColors.colorFontLightGrey,
                          ),
                        ),*/
                        Container(
                            padding: EdgeInsets.only(left: 18, right: 18),
                            alignment: Alignment.centerLeft,
                            child: Text('이메일',
                                style: CustomStyles.normal14TextStyle())),
                        Container(
                            padding: EdgeInsets.only(left: 18, right: 18),
                            margin: EdgeInsets.only(top: 5),
                            child: CustomStyles.greyBorderRound7TextField(
                                _txtFieldEmail, '')),
                        Container(
                            height: 50,
                            margin: EdgeInsets.only(top: 30.0),
                            padding: EdgeInsets.only(left: 18, right: 18),
                            width: double.infinity,
                            child: CustomStyles.greyBorderRound7ButtonStyle(
                                '수정완료', () {
                              if (checkValidate(context)) {
                                requestComparePwdApi(context);
                              }
                            })),
                      ],
                    ),
                  ),
                ));
              },
            )));
  }

  /*
  * 입력 데이터 유효성 검사
  * */
  bool checkValidate(BuildContext context) {
    if (StringUtils.isEmpty(_txtFieldPW.text)) {
      showSnackBar(context, '기존 비밀번호를 입력해 주세요.');
      return false;
    }

    if (StringUtils.isEmpty(_txtFieldNewPW.text)) {
      showSnackBar(context, '새 비밀번호를 입력해 주세요.');
      return false;
    }

    if (_txtFieldPWCheck.text == null || !_txtFieldPWCheck.text.isNotEmpty) {
      showSnackBar(context, '비밀번호를 한번 더 입력해 주세요.');
      return false;
    }

    if (StringUtils.trimmedString(_txtFieldNewPW.text) !=
        StringUtils.trimmedString(_txtFieldPWCheck.text)) {
      showSnackBar(context, '비밀번호가 일치하지 않습니다.');
      return false;
    }

    if (!RegExp(r"[a-z0-9]").hasMatch(_txtFieldPW.text)) {
      showSnackBar(context, '비밀번호 형식이 올바르지 않습니다.');
      return false;
    }

    if (!RegExp(
            r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
        .hasMatch(_txtFieldEmail.text)) {
      showSnackBar(context, '이메일 형식이 올바르지 않습니다.');
      return false;
    }

    return true;
  }

  /*
  * 기존 비밀번호 체크
  * */
  void requestComparePwdApi(BuildContext context) async {
    final dio = Dio();

    // 비밀번호 암호화
    final publicPem =
        await rootBundle.loadString('assets/files/public_key.pem');
    final publicKey = RSAKeyParser().parse(publicPem) as RSAPublicKey;

    final encryptor = Encrypter(RSA(publicKey: publicKey));
    final encrypted =
        encryptor.encrypt(StringUtils.trimmedString(_txtFieldPW.text));

    // 기존 비밀번호 체크 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetDatas = new Map();
    targetDatas[APIConstants.seq] = KCastingAppData().myInfo[APIConstants.seq];
    targetDatas[APIConstants.member_type] =
        KCastingAppData().myInfo[APIConstants.member_type];
    targetDatas[APIConstants.input_pwd] = encrypted.base64;

    Map<String, dynamic> params = new Map();

    params[APIConstants.key] = APIConstants.CHK_TOT_COMPAREPWD;
    params[APIConstants.target] = targetDatas;

    // 기존 비밀번호 체크 api 호출
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value == null) {
        // 에러 - 데이터 널
        showSnackBar(context, '다시 시도해 주세요.');
      } else {
        if (value[APIConstants.resultVal]) {
          // 기존 비밀번호 체크 성공
          var _responseData = value[APIConstants.data];

          if (_responseData != null &&
              _responseData[APIConstants.isCorrectPassword]) {
            requestUpdateApi(context);
          } else {
            showSnackBar(context, value[APIConstants.resultMsg]);
          }
        } else {
          // 기존 비밀번호 체크 실패
          showSnackBar(context, value[APIConstants.resultMsg]);
        }
      }
    });
  }

  /*
  * 배우 회원정보 수정
  * */
  void requestUpdateApi(BuildContext context) async {
    final dio = Dio();

    // 비밀번호 암호화
    final publicPem =
        await rootBundle.loadString('assets/files/public_key.pem');
    final publicKey = RSAKeyParser().parse(publicPem) as RSAPublicKey;

    final encryptor = Encrypter(RSA(publicKey: publicKey));
    final encrypted =
        encryptor.encrypt(StringUtils.trimmedString(_txtFieldPW.text));

    // 배우 회원정보 수정 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetDatas = new Map();
    targetDatas[APIConstants.seq] = KCastingAppData().myInfo[APIConstants.seq];
    targetDatas[APIConstants.pwd] = encrypted.base64;
    targetDatas[APIConstants.actor_phone] =
        StringUtils.trimmedString(_txtFieldPhone.text);
    targetDatas[APIConstants.actor_email] =
        StringUtils.trimmedString(_txtFieldEmail.text);

    /*if (_isAccountChecked) {
      targetDatas[APIConstants.actor_bank_code] =
          _bankVal[APIConstants.child_code];
      targetDatas[APIConstants.actor_account_number] =
          StringUtils.trimmedString(_txtFieldAccountNum.text);
      targetDatas[APIConstants.actor_account_holder] =
          StringUtils.trimmedString(_txtFieldAccountName.text);
      targetDatas[APIConstants.actor_account_holder_birth] =
          StringUtils.trimmedString(_txtFieldAccountBirth.text);
    }*/

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.UPD_ACT_INFO;
    params[APIConstants.target] = targetDatas;

    // 배우 회원정보 수정 api 호출
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value == null) {
        // 에러 - 데이터 널
        showSnackBar(context, '다시 시도해 주세요.');
      } else {
        if (value[APIConstants.resultVal]) {
          // 배우 회원정보 수정 성공
          var _responseData = value[APIConstants.data];
          var _responseList = _responseData[APIConstants.list];

          // 수정된 회원정보 전역변수에 저장
          if (_responseList.length > 0) {
            KCastingAppData().myInfo = _responseList[0];
          }

          // 배우 회원정보 페이지 이동
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => ActorMemberInfo()));
        } else {
          // 회원정보 수정 실패
          showSnackBar(context, value[APIConstants.resultMsg]);
        }
      }
    });
  }
}
