import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/KCastingAppData.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:casting_call/src/view/main/Home.dart';
import 'package:casting_call/src/view/user/common/JoinSelectType.dart';
import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart' as encrtpt;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pointycastle/asymmetric/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*
*  제작사 회원가입 클래스
* */
class JoinProduction extends StatefulWidget {
  final String companyName;
  final String companyCEOName;
  final String companyNum;

  const JoinProduction(
      {Key key, this.companyName, this.companyCEOName, this.companyNum})
      : super(key: key);

  @override
  _JoinProduction createState() => _JoinProduction();
}

class _JoinProduction extends State<JoinProduction> with BaseUtilMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  bool _isUpload = false;

  String _companyName;
  String _companyCEOName;
  String _companyNum;

  final _txtFieldID = TextEditingController();
  final _txtFieldPW = TextEditingController();
  final _txtFieldPWCheck = TextEditingController();
  final _txtFieldCeoName = TextEditingController();
  final _txtFieldHomepage = TextEditingController();
  final _txtFieldEmail = TextEditingController();

  int _agreeTerms = 0;
  int _agreePrivacyPolicy = 0;

  /*Map<String, dynamic> _bankVal;
  bool _isAccountChecked = false;
  final _txtFieldAccountName = TextEditingController();
  final _txtFieldAccountNum = TextEditingController();*/

  @override
  void initState() {
    super.initState();

    _companyName = widget.companyName;
    _companyCEOName = widget.companyCEOName;
    _companyNum = widget.companyNum;

    if (_companyCEOName != null && !StringUtils.isEmpty(_companyCEOName)) {
      _txtFieldCeoName.text = _companyCEOName;
    }
  }

  /*
  *  계좌 소유주 확인 api 호출
  * */
  /*void requestAccountCheckApi(BuildContext context) async {
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
    targetDatas[APIConstants.resId] = _companyNum;

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
  }*/

  /*
  *  메인위젯
  * */
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          // 로그인 페이지 이동
          return Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => JoinSelectType()),
          );
        },
        child: Theme(
            data: CustomStyles.defaultTheme(),
            child: Scaffold(
                key: _scaffoldKey,
                appBar: CustomStyles.defaultAppBar('회원가입', () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => JoinSelectType()),
                  );
                }),
                body: Builder(
                  builder: (BuildContext context) {
                    return Stack(
                      children: [
                        Container(
                            child: Column(
                              children: [
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
                                                      child: Text('회원가입',
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
                                                                TextSpan(text: '아이디'),
                                                                TextSpan(
                                                                    style: TextStyle(
                                                                        color: CustomColors
                                                                            .colorRed),
                                                                    text: '*'),
                                                              ]))),
                                                  Container(
                                                      padding: EdgeInsets.only(
                                                          left: 30, right: 30),
                                                      margin: EdgeInsets.only(top: 5),
                                                      child: CustomStyles
                                                          .greyBorderRound7TextField(
                                                          _txtFieldID,
                                                          '영문, 숫자만 가능합니다.')),
                                                  Container(
                                                      margin: EdgeInsets.only(top: 15),
                                                      padding: EdgeInsets.only(
                                                          left: 30, right: 30),
                                                      alignment: Alignment.centerLeft,
                                                      child: RichText(
                                                          text: TextSpan(
                                                              style: CustomStyles
                                                                  .normal14TextStyle(),
                                                              children: <TextSpan>[
                                                                TextSpan(text: '비밀번호'),
                                                                TextSpan(
                                                                    style: TextStyle(
                                                                        color: CustomColors
                                                                            .colorRed),
                                                                    text: '*'),
                                                              ]))),
                                                  Container(
                                                      margin: EdgeInsets.only(top: 5),
                                                      padding: EdgeInsets.only(
                                                          left: 30, right: 30),
                                                      child: CustomStyles
                                                          .greyBorderRound7PWDTextField(
                                                          _txtFieldPW,
                                                          '대문자, 소문자, 숫자 조합으로 가능합니다.')),
                                                  Container(
                                                      margin: EdgeInsets.only(top: 15),
                                                      padding: EdgeInsets.only(
                                                          left: 30, right: 30),
                                                      alignment: Alignment.centerLeft,
                                                      child: RichText(
                                                          text: TextSpan(
                                                              style: CustomStyles
                                                                  .normal14TextStyle(),
                                                              children: <TextSpan>[
                                                                TextSpan(text: '비밀번호 확인'),
                                                                TextSpan(
                                                                    style: TextStyle(
                                                                        color: CustomColors
                                                                            .colorRed),
                                                                    text: '*'),
                                                              ]))),
                                                  Container(
                                                      margin: EdgeInsets.only(top: 5),
                                                      padding: EdgeInsets.only(
                                                          left: 30, right: 30),
                                                      child: CustomStyles
                                                          .greyBorderRound7PWDTextField(
                                                          _txtFieldPWCheck,
                                                          '비밀번호를 한번 더 입력해 주세요.')),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        top: 30, bottom: 30),
                                                    child: Divider(
                                                      height: 0.1,
                                                      color: CustomColors
                                                          .colorFontLightGrey,
                                                    ),
                                                  ),
                                                  Container(
                                                      padding: EdgeInsets.only(
                                                          left: 30, right: 30),
                                                      alignment: Alignment.centerLeft,
                                                      child: RichText(
                                                          text: TextSpan(
                                                              style: CustomStyles
                                                                  .normal14TextStyle(),
                                                              children: <TextSpan>[
                                                                TextSpan(text: '기업명'),
                                                                TextSpan(
                                                                    style: TextStyle(
                                                                        color: CustomColors
                                                                            .colorRed),
                                                                    text: '*'),
                                                              ]))),
                                                  Container(
                                                      padding: EdgeInsets.only(
                                                          left: 30, right: 30),
                                                      margin: EdgeInsets.only(top: 5),
                                                      child: CustomStyles
                                                          .disabledGreyBorderRound7TextField(
                                                          _companyName)),
                                                  Container(
                                                      margin: EdgeInsets.only(top: 15),
                                                      padding: EdgeInsets.only(
                                                          left: 30, right: 30),
                                                      alignment: Alignment.centerLeft,
                                                      child: RichText(
                                                          text: TextSpan(
                                                              style: CustomStyles
                                                                  .normal14TextStyle(),
                                                              children: <TextSpan>[
                                                                TextSpan(text: '사업자등록번호'),
                                                                TextSpan(
                                                                    style: TextStyle(
                                                                        color: CustomColors
                                                                            .colorRed),
                                                                    text: '*'),
                                                              ]))),
                                                  Container(
                                                      padding: EdgeInsets.only(
                                                          left: 30, right: 30),
                                                      margin: EdgeInsets.only(top: 5),
                                                      child: CustomStyles
                                                          .disabledGreyBorderRound7TextField(
                                                          _companyNum)),
                                                  Container(
                                                      margin: EdgeInsets.only(top: 15),
                                                      padding: EdgeInsets.only(
                                                          left: 30, right: 30),
                                                      alignment: Alignment.centerLeft,
                                                      child: RichText(
                                                          text: TextSpan(
                                                              style: CustomStyles
                                                                  .normal14TextStyle(),
                                                              children: <TextSpan>[
                                                                TextSpan(text: '대표자명'),
                                                                TextSpan(
                                                                    style: TextStyle(
                                                                        color: CustomColors
                                                                            .colorRed),
                                                                    text: '*'),
                                                              ]))),
                                                  Container(
                                                      padding: EdgeInsets.only(
                                                          left: 30, right: 30),
                                                      margin: EdgeInsets.only(top: 5),
                                                      child: CustomStyles
                                                          .greyBorderRound7TextField(
                                                          _txtFieldCeoName,
                                                          '반드시 본명을 입력해 주세요.')),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        top: 25, bottom: 25),
                                                    child: Divider(
                                                      height: 0.1,
                                                      color: CustomColors
                                                          .colorFontLightGrey,
                                                    ),
                                                  ),
                                                  /*Container(
                                              padding: EdgeInsets.only(
                                                  left: 30, right: 30),
                                              alignment: Alignment.centerLeft,
                                              child: Text('법인 은행 계좌',
                                                  style: CustomStyles
                                                      .normal14TextStyle())),
                                          Container(
                                              padding: EdgeInsets.only(
                                                  left: 30, right: 30),
                                              margin: EdgeInsets.only(top: 5),
                                              child: CustomStyles
                                                  .greyBorderRound7TextFieldWithDisableOpt(
                                                      _txtFieldAccountName,
                                                      '예금주명 입력',
                                                      !_isAccountChecked)),
                                          Container(
                                            margin: EdgeInsets.only(top: 5),
                                            padding: EdgeInsets.only(
                                                left: 30, right: 30),
                                            width: double.infinity,
                                            child: DropdownButtonFormField(
                                              //value: _bankVal,
                                              hint: Container(
                                                //and here
                                                child: Text("은행 선택",
                                                    style: CustomStyles
                                                        .light14TextStyle()),
                                              ),
                                              onChanged: _isAccountChecked
                                                  ? null
                                                  : (newValue) {
                                                      setState(() {
                                                        _bankVal = newValue;
                                                      });
                                                    },
                                              items: KCastingAppData().bankCode.map((value) {
                                                return DropdownMenuItem<
                                                    Map<String, dynamic>>(
                                                  value: value,
                                                  child: Text(
                                                      value[APIConstants
                                                          .child_name],
                                                      style: CustomStyles
                                                          .normal14TextStyle()),
                                                );
                                              }).toList(),
                                              decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: CustomColors
                                                              .colorFontLightGrey,
                                                          width: 1.0),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              7.0)),
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          vertical: 5,
                                                          horizontal: 10)),
                                            ),
                                          ),
                                          Container(
                                                  margin: EdgeInsets.only(top: 5),
                                                  padding: EdgeInsets.only(
                                                      left: 30, right: 30),
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
                                                        margin: EdgeInsets.only(
                                                            left: 5),
                                                        child: CustomStyles
                                                            .greyBGRound7ButtonStyle(
                                                                _isAccountChecked
                                                                    ? '인증완료'
                                                                    : '계좌인증',
                                                                () {
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
                                              )),
                                          Container(
                                            margin: EdgeInsets.only(
                                                top: 30, bottom: 30),
                                            child: Divider(
                                              height: 0.1,
                                              color: CustomColors
                                                  .colorFontLightGrey,
                                            ),
                                          ),*/
                                                  Container(
                                                      padding: EdgeInsets.only(
                                                          left: 30, right: 30),
                                                      alignment: Alignment.centerLeft,
                                                      child: Text('홈페이지',
                                                          style: CustomStyles
                                                              .normal14TextStyle())),
                                                  Container(
                                                      padding: EdgeInsets.only(
                                                          left: 30, right: 30),
                                                      margin: EdgeInsets.only(top: 5),
                                                      child: CustomStyles
                                                          .greyBorderRound7TextFieldWithOption(
                                                          _txtFieldHomepage,
                                                          TextInputType.url,
                                                          '')),
                                                  Container(
                                                      margin: EdgeInsets.only(top: 15),
                                                      padding: EdgeInsets.only(
                                                          left: 30, right: 30),
                                                      alignment: Alignment.centerLeft,
                                                      child: RichText(
                                                          text: TextSpan(
                                                              style: CustomStyles
                                                                  .normal14TextStyle(),
                                                              children: <TextSpan>[
                                                                TextSpan(text: '이메일'),
                                                                TextSpan(
                                                                    style: TextStyle(
                                                                        color: CustomColors
                                                                            .colorRed),
                                                                    text: '*'),
                                                              ]))),
                                                  Container(
                                                      padding: EdgeInsets.only(
                                                          left: 30, right: 30),
                                                      margin: EdgeInsets.only(top: 5),
                                                      child: CustomStyles
                                                          .greyBorderRound7TextFieldWithOption(
                                                          _txtFieldEmail,
                                                          TextInputType
                                                              .emailAddress,
                                                          '')),
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
                                                                    text: ' 내용에 동의해 주세요.'),
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
                                    child: CustomStyles.lightGreyBGSquareButtonStyle(
                                        '회원가입', () {
                                      if (checkValidate(context)) {
                                        requestJoinApi(context);
                                      }
                                    }))
                              ],
                            )),
                        Visibility(
                          child: Container(
                              color: Colors.black38,
                              alignment: Alignment.center,
                              child: CircularProgressIndicator()),
                          visible: _isUpload,
                        )
                      ],
                    );
                  },
                ))));
  }

  /*
  * 입력 데이터 유효성 검사
  * */
  bool checkValidate(BuildContext context) {
    if (StringUtils.isEmpty(_txtFieldID.text)) {
      showSnackBar(context, '아이디를 입력해 주세요.');
      return false;
    }

    if (StringUtils.isEmpty(_txtFieldPW.text)) {
      showSnackBar(context, '비밀번호를 입력해 주세요.');
      return false;
    }

    if (_txtFieldPWCheck.text == null || !_txtFieldPWCheck.text.isNotEmpty) {
      showSnackBar(context, '비밀번호를 한번 더 입력해 주세요.');
      return false;
    }

    if (StringUtils.trimmedString(_txtFieldPW.text) !=
        StringUtils.trimmedString(_txtFieldPWCheck.text)) {
      showSnackBar(context, '비밀번호가 일치하지 않습니다.');
      return false;
    }

    if (!RegExp(r"[a-z0-9]").hasMatch(_txtFieldPW.text)) {
      showSnackBar(context, '비밀번호 형식이 올바르지 않습니다.');
      return false;
    }

    if (StringUtils.isEmpty(_txtFieldCeoName.text)) {
      showSnackBar(context, '대표자명을 입력해 주세요.');
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

    if (_agreeTerms == 0) {
      showSnackBar(context, '이용약관에 동의해 주세요.');
      return false;
    }

    if (_agreePrivacyPolicy == 0) {
      showSnackBar(context, '개인정보 수집 이용에 동의해 주세요.');
      return false;
    }

    return true;
  }

  /*
  *  제작사 회원가입 api 호출
  * */
  void requestJoinApi(BuildContext context) async {
    setState(() {
      _isUpload = true;
    });

    // 비밀번호 암호화
    final publicPem =
        await rootBundle.loadString('assets/files/public_key.pem');
    final publicKey = encrtpt.RSAKeyParser().parse(publicPem) as RSAPublicKey;

    final encryptor = encrtpt.Encrypter(encrtpt.RSA(publicKey: publicKey));
    final encrypted =
        encryptor.encrypt(StringUtils.trimmedString(_txtFieldPW.text));

    // 회원가입 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetDatas = new Map();
    targetDatas[APIConstants.id] = StringUtils.trimmedString(_txtFieldID.text);
    targetDatas[APIConstants.pwd] = encrypted.base64;
    targetDatas[APIConstants.member_type] = APIConstants.member_type_product;
    targetDatas[APIConstants.production_name] = _companyName;
    targetDatas[APIConstants.businessRegistration_number] = _companyNum;
    targetDatas[APIConstants.production_CEO_name] = StringUtils.trimmedString(_txtFieldCeoName.text);
    targetDatas[APIConstants.production_bank_code] = "";
    targetDatas[APIConstants.production_account_holder] = "";
    targetDatas[APIConstants.production_account_number] = "";
    targetDatas[APIConstants.production_homepage] = StringUtils.trimmedString(_txtFieldHomepage.text);
    targetDatas[APIConstants.production_email] = StringUtils.trimmedString(_txtFieldEmail.text);
    targetDatas[APIConstants.TOS_isAgree] = 1;
    targetDatas[APIConstants.PPA_isAgree] = 1;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.INS_PRD_JOIN;
    params[APIConstants.target] = targetDatas;

    // 회원가입 api 호출
    RestClient(Dio()).postRequestMainControl(params).then((value) async {
      try {
        if (value == null) {
          // 에러 - 데이터 널 - 서버가 응답하지 않습니다. 다시 시도해 주세요
          showSnackBar(context, APIConstants.error_msg_server_not_response);
        } else {
          if (value[APIConstants.resultVal]) {

            // 회원가입 성공
            var _responseData = value[APIConstants.data];
            var _responseList = _responseData[APIConstants.list];

            // 회원데이터 전역변수에 저장
            KCastingAppData().myInfo =
            _responseList.length > 0 ? _responseList[0] : null;

            // 자동로그인
            final SharedPreferences prefs =
            await SharedPreferences.getInstance();
            prefs.setBool(APIConstants.autoLogin, true);
            prefs.setString(
                APIConstants.member_type, APIConstants.member_type_product);
            prefs.setInt(
                APIConstants.seq, KCastingAppData().myInfo[APIConstants.seq]);

            // 메인 페이지 이동
            replaceView(context, Home(prevPage: APIConstants.INS_PRD_JOIN));

          } else {
            // 회원가입 실패
            switch (StringUtils.checkedString(value[APIConstants.resultMsg])) {
            // 이미 존재하는 아이디입니다.
              case APIConstants.server_error_already_exist:
                showSnackBar(context, APIConstants.error_msg_join_already_exist);
                break;

            // 기타 에러 - 회원가입에 실패하였습니다. 다시 시도해 주세요.
              default:
                showSnackBar(context, APIConstants.error_msg_join_fail);
                break;
            }
          }
        }
      } catch(e) {
        showSnackBar(context, value[APIConstants.error_msg_try_again]);
      } finally {
        setState(() {
          _isUpload = false;
        });
      }
    });
  }
}
