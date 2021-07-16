import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/KCastingAppData.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:casting_call/src/view/mypage/production/ProductionMemberInfo.dart';
import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pointycastle/asymmetric/api.dart';

class ProductionMemberInfoModify extends StatefulWidget {
  @override
  _ProductionMemberInfoModify createState() => _ProductionMemberInfoModify();
}

class _ProductionMemberInfoModify extends State<ProductionMemberInfoModify>
    with BaseUtilMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  final _txtFieldPW = TextEditingController();
  final _txtFieldNewPW = TextEditingController();
  final _txtFieldPWCheck = TextEditingController();
  final _txtFieldHomepage = TextEditingController();
  final _txtFieldEmail = TextEditingController();
  final _txtFieldAccountName = TextEditingController();
  final _txtFieldAccountNum = TextEditingController();

  Map<String, dynamic> _bankVal;
  bool _isAccountChecked = false;

  @override
  void initState() {
    super.initState();

    _txtFieldHomepage.text = StringUtils.isEmpty(
            KCastingAppData().myInfo[APIConstants.production_homepage])
        ? ''
        : KCastingAppData().myInfo[APIConstants.production_homepage];

    _txtFieldEmail.text = StringUtils.isEmpty(
            KCastingAppData().myInfo[APIConstants.production_email])
        ? ''
        : KCastingAppData().myInfo[APIConstants.production_email];

    /*for(int i = 0; i < KCastingAppData().bankCode.length; i++) {
      Map<String, dynamic> bankItem = KCastingAppData().bankCode[i];

      if(bankItem[APIConstants.child_code] == KCastingAppData().myInfo[APIConstants.production_bank_code]){
        setState(() {
          _bankVal = bankItem;
        });
      }
    }
    _txtFieldAccountName.text = StringUtils.isEmpty(
        KCastingAppData().myInfo[APIConstants.production_account_holder])
        ? ''
        : KCastingAppData().myInfo[APIConstants.production_account_holder];

    _txtFieldAccountNum.text = StringUtils.isEmpty(
        KCastingAppData().myInfo[APIConstants.production_account_number])
        ? ''
        : KCastingAppData().myInfo[APIConstants.production_account_number];*/
  }

  /*
  *  계좌 소유주 확인 api 호출
  * */
  void requestAccountCheckApi(BuildContext context) async {
    final dio = Dio();

    // 계좌 소유주 확인 api 호출 시 보낼 파라미터
    // 은행코드조회 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetDatas = new Map();
    targetDatas[APIConstants.bankCode] = _bankVal[APIConstants.child_code];
    targetDatas[APIConstants.accountNo] =
        StringUtils.trimmedString(_txtFieldAccountNum.text);
    targetDatas[APIConstants.name] =
        StringUtils.trimmedString(_txtFieldAccountName.text);
    targetDatas[APIConstants.isPersonalAccount] = false;
    targetDatas[APIConstants.resId] = KCastingAppData().myInfo[APIConstants.businessRegistration_number];

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
    return WillPopScope(
        onWillPop: () {
          // 개인정보 관리 페이지 이동
          replaceView(context, ProductionMemberInfo());
          return Future.value(false);
        },
        child: Theme(
            data: CustomStyles.defaultTheme(),
            child: Scaffold(
                key: _scaffoldKey,
                appBar: CustomStyles.defaultAppBar('개인정보 수정', () {
                  replaceView(context, ProductionMemberInfo());
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
                                child: RichText(
                                    text: TextSpan(
                                        style: CustomStyles.normal14TextStyle(),
                                        children: <TextSpan>[
                                      TextSpan(text: '아이디')
                                    ]))),
                            Container(
                                margin: EdgeInsets.only(top: 15.0),
                                padding: EdgeInsets.only(left: 18, right: 18),
                                child: Text(
                                    StringUtils.checkedString(KCastingAppData()
                                        .myInfo[APIConstants.id]),
                                    style: CustomStyles.normal16TextStyle())),
                            Container(
                                margin: EdgeInsets.only(top: 20.0),
                                padding: EdgeInsets.only(left: 18, right: 18),
                                child: RichText(
                                    text: TextSpan(
                                        style: CustomStyles.normal14TextStyle(),
                                        children: <TextSpan>[
                                      TextSpan(text: '현재 비밀번호'),
                                      TextSpan(
                                          style: TextStyle(
                                              color: CustomColors.colorRed),
                                          text: '*'),
                                    ]))),
                            Container(
                                margin: EdgeInsets.only(top: 5),
                                padding: EdgeInsets.only(left: 18, right: 18),
                                child:
                                    CustomStyles.greyBorderRound7PWDTextField(
                                        _txtFieldPW,
                                        '대문자, 소문자, 숫자 조합으로 가능합니다.')),
                            Container(
                                margin: EdgeInsets.only(top: 15.0),
                                padding: EdgeInsets.only(left: 18, right: 18),
                                child: RichText(
                                    text: TextSpan(
                                        style: CustomStyles.normal14TextStyle(),
                                        children: <TextSpan>[
                                      TextSpan(text: '새 비밀번호'),
                                      TextSpan(
                                          style: TextStyle(
                                              color: CustomColors.colorRed),
                                          text: '*'),
                                    ]))),
                            Container(
                                margin: EdgeInsets.only(top: 5),
                                padding: EdgeInsets.only(left: 18, right: 18),
                                child:
                                    CustomStyles.greyBorderRound7PWDTextField(
                                        _txtFieldNewPW,
                                        '대문자, 소문자, 숫자 조합으로 가능합니다.')),
                            Container(
                                margin: EdgeInsets.only(top: 15),
                                padding: EdgeInsets.only(left: 18, right: 18),
                                alignment: Alignment.centerLeft,
                                child: RichText(
                                    text: TextSpan(
                                        style: CustomStyles.normal14TextStyle(),
                                        children: <TextSpan>[
                                      TextSpan(text: '비밀번호 확인'),
                                      TextSpan(
                                          style: TextStyle(
                                              color: CustomColors.colorRed),
                                          text: '*'),
                                    ]))),
                            Container(
                                margin: EdgeInsets.only(top: 5),
                                padding: EdgeInsets.only(left: 18, right: 18),
                                child:
                                    CustomStyles.greyBorderRound7PWDTextField(
                                        _txtFieldPWCheck,
                                        '비밀번호를 한번 더 입력해 주세요.')),
                            Container(
                              margin: EdgeInsets.only(top: 30, bottom: 30),
                              child: Divider(
                                height: 0.1,
                                color: CustomColors.colorFontLightGrey,
                              ),
                            ),
                            Container(
                                padding: EdgeInsets.only(left: 18, right: 18),
                                child: Text('기업명',
                                    style: CustomStyles.bold14TextStyle())),
                            Container(
                                margin: EdgeInsets.only(top: 5),
                                padding: EdgeInsets.only(left: 18, right: 18),
                                child: CustomStyles
                                    .disabledGreyBorderRound7TextField(
                                        KCastingAppData().myInfo[
                                            APIConstants.production_name])),
                            Container(
                                margin: EdgeInsets.only(top: 15),
                                padding: EdgeInsets.only(left: 18, right: 18),
                                child: Text('사업자등록번호',
                                    style: CustomStyles.bold14TextStyle())),
                            Container(
                                margin: EdgeInsets.only(top: 5),
                                padding: EdgeInsets.only(left: 18, right: 18),
                                child: CustomStyles
                                    .disabledGreyBorderRound7TextField(
                                        StringUtils.checkedString(
                                            KCastingAppData().myInfo[APIConstants
                                                .businessRegistration_number]))),
                            Container(
                                margin: EdgeInsets.only(top: 15),
                                padding: EdgeInsets.only(left: 18, right: 18),
                                child: Text('대표자명',
                                    style: CustomStyles.bold14TextStyle())),
                            Container(
                                margin: EdgeInsets.only(top: 5),
                                padding: EdgeInsets.only(left: 18, right: 18),
                                child: CustomStyles
                                    .disabledGreyBorderRound7TextField(
                                        KCastingAppData().myInfo[
                                            APIConstants.production_CEO_name])),
                            /*Container(
                              margin: EdgeInsets.only(top: 30, bottom: 30),
                              child: Divider(
                                height: 0.1,
                                color: CustomColors.colorFontLightGrey,
                              ),
                            ),
                            Container(
                                padding: EdgeInsets.only(left: 18, right: 18),
                                alignment: Alignment.centerLeft,
                                child: Text('법인 은행 계좌',
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
                                        style:
                                            CustomStyles.normal14TextStyle()),
                                  );
                                }).toList(),
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color:
                                                CustomColors.colorFontLightGrey,
                                            width: 1.0),
                                        borderRadius:
                                            BorderRadius.circular(7.0)),
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
                                          child: CustomStyles
                                              .greyBGRound7ButtonStyle(
                                                  _isAccountChecked
                                                      ? '인증완료'
                                                      : '계좌인증', () {
                                            // 인증번호 받기 버튼 클릭
                                            if (_isAccountChecked) {
                                              showSnackBar(
                                                  context,
                                                  "이미 인증되었습니다.");
                                            } else {
                                              if (StringUtils.isEmpty(
                                                  _txtFieldAccountName
                                                      .text)) {
                                                showSnackBar(
                                                    context,
                                                    '예금주명을 입력해 주세요.');
                                                return false;
                                              }

                                              if (_bankVal ==
                                                  null) {
                                                showSnackBar(
                                                    context,
                                                    '은행을 선택해 주세요.');
                                                return false;
                                              }

                                              if (_bankVal[
                                              APIConstants
                                                  .child_code] ==
                                                  null) {
                                                showSnackBar(
                                                    context,
                                                    '은행을 선택해 주세요.');
                                                return false;
                                              }

                                              if (StringUtils.isEmpty(
                                                  _txtFieldAccountNum
                                                      .text)) {
                                                showSnackBar(
                                                    context,
                                                    '계좌번호를 입력해 주세요.');
                                                return false;
                                              }

                                              requestAccountCheckApi(
                                                  context);
                                            }
                                          })),
                                    )
                                  ],
                                )),*/
                            Container(
                              margin: EdgeInsets.only(top: 30, bottom: 30),
                              child: Divider(
                                height: 0.1,
                                color: CustomColors.colorFontLightGrey,
                              ),
                            ),
                            Container(
                                padding: EdgeInsets.only(left: 18, right: 18),
                                alignment: Alignment.centerLeft,
                                child: Text('홈페이지',
                                    style: CustomStyles.normal14TextStyle())),
                            Container(
                                padding: EdgeInsets.only(left: 18, right: 18),
                                margin: EdgeInsets.only(top: 5),
                                child: CustomStyles
                                    .greyBorderRound7TextFieldWithOption(
                                        _txtFieldHomepage,
                                        TextInputType.url,
                                        '')),
                            Container(
                                margin: EdgeInsets.only(top: 15),
                                padding: EdgeInsets.only(left: 18, right: 18),
                                alignment: Alignment.centerLeft,
                                child: RichText(
                                    text: TextSpan(
                                        style: CustomStyles.normal14TextStyle(),
                                        children: <TextSpan>[
                                      TextSpan(text: '이메일'),
                                      TextSpan(
                                          style: TextStyle(
                                              color: CustomColors.colorRed),
                                          text: '*'),
                                    ]))),
                            Container(
                                padding: EdgeInsets.only(left: 18, right: 18),
                                margin: EdgeInsets.only(top: 5),
                                child: CustomStyles
                                    .greyBorderRound7TextFieldWithOption(
                                        _txtFieldEmail,
                                        TextInputType.emailAddress,
                                        '')),
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
                ))));
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

    if (!RegExp(r"[a-z0-9]").hasMatch(_txtFieldNewPW.text)) {
      showSnackBar(context, '비밀번호 형식이 올바르지 않습니다.');
      return false;
    }

    if (StringUtils.isEmpty(_txtFieldEmail.text)) {
      showSnackBar(context, '이메일을 입력해 주세요.');
      return false;
    }

    if (!RegExp(
            r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
        .hasMatch(_txtFieldEmail.text)) {
      showSnackBar(context, '이메일 주소 형식이 올바르지 않습니다.');
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
  * 제작사 회원정보 수정
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

    // 회원가입 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetDatas = new Map();
    targetDatas[APIConstants.seq] = KCastingAppData().myInfo[APIConstants.seq];
    targetDatas[APIConstants.pwd] = encrypted.base64;
    targetDatas[APIConstants.production_homepage] =
        StringUtils.trimmedString(_txtFieldHomepage.text);
    targetDatas[APIConstants.production_email] =
        StringUtils.trimmedString(_txtFieldEmail.text);

    /*if (_isAccountChecked) {
      targetDatas[APIConstants.production_bank_code] =
      _bankVal[APIConstants.child_code];
      targetDatas[APIConstants.production_account_number] =
          StringUtils.trimmedString(_txtFieldAccountNum.text);
      targetDatas[APIConstants.production_account_holder] =
          StringUtils.trimmedString(_txtFieldAccountName.text);
    }*/

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.UPD_PRD_INFO;
    params[APIConstants.target] = targetDatas;

    // 회원정보 수정 api 호출
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value == null) {
        showSnackBar(context, APIConstants.error_msg_server_not_response);
      } else {
        if (value[APIConstants.resultVal]) {
          try {
            // 회원정보 수정 성공
            var _responseData = value[APIConstants.data];
            var _responseList = _responseData[APIConstants.list] as List;

            // 수정된 회원정보 전역변수에 저장
            if (_responseList.length > 0) {
              KCastingAppData().myInfo = _responseList[0];
            }

            // 회원정보 수정 후 개인정보 관리 페이지로 이동
            replaceView(context, ProductionMemberInfo());
          } catch (e) {
            showSnackBar(context, APIConstants.error_msg_try_again);
          }
        } else {
          // 회원정보 수정 실패
          showSnackBar(context, APIConstants.error_msg_try_again);
        }
      }
    });
  }
}
