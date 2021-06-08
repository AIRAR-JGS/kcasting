import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/KCastingAppData.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:casting_call/src/view/main/Home.dart';
import 'package:casting_call/src/view/user/actor/JoinActorSelectType.dart';
import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*
*  14세 이상 배우 회원가입
* */
class JoinActorAdult extends StatefulWidget {
  @override
  _JoinActorAdult createState() => _JoinActorAdult();
}

class _JoinActorAdult extends State<JoinActorAdult> with BaseUtilMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  final _txtFieldID = TextEditingController();
  final _txtFieldPW = TextEditingController();
  final _txtFieldPWCheck = TextEditingController();
  final _txtFieldName = TextEditingController();
  final _txtFieldPhone = TextEditingController();
  final _txtFieldEmail = TextEditingController();

  int _userGender = 0;
  String _bankVal = '은행선택';
  int _agreeTerms = 0;
  int _agreePrivacyPolicy = 0;
  String _birthDate = '2000-01-01';

  @override
  void initState() {
    super.initState();
  }

  /*
  *  메인위젯
  * */
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          // 로그인 페이지 이동
          replaceView(context, JoinActorSelectType());
          return Future.value(false);
        },
        child: Theme(
            data: CustomStyles.defaultTheme(),
            child: Scaffold(
                key: _scaffoldKey,
                appBar: CustomStyles.defaultAppBar('회원가입', () {
                  replaceView(context, JoinActorSelectType());
                  return Future.value(false);
                }),
                body: Container(
                    child: Column(
                  children: [
                    Expanded(
                        flex: 1,
                        child: SingleChildScrollView(
                            child: Container(
                                padding: EdgeInsets.only(top: 30, bottom: 50),
                                child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                          margin: EdgeInsets.only(bottom: 30),
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
                                          color:
                                              CustomColors.colorFontLightGrey,
                                        ),
                                      ),
                                      Container(
                                          height: 50,
                                          padding: EdgeInsets.only(
                                              left: 30, right: 30),
                                          width: double.infinity,
                                          child: CustomStyles
                                              .greyBorderRound7ButtonStyle(
                                                  '본인 인증하기', () {})),
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
                                                    text: '*'),
                                              ]))),
                                      Container(
                                          padding: EdgeInsets.only(
                                              left: 30, right: 30),
                                          margin: EdgeInsets.only(top: 5),
                                          child: CustomStyles
                                              .greyBorderRound7TextField(
                                                  _txtFieldName,
                                                  '반드시 본명을 입력해 주세요.')),
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
                                                TextSpan(text: '생년월일'),
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
                                          child: GestureDetector(
                                            onTap: () {
                                              showDatePickerForBirthDay(context,
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

                                                  _birthDate = _birthY +
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
                                                    EdgeInsets.only(right: 5),
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
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          right: 10),
                                                      child: Icon(
                                                          Icons.date_range,
                                                          color: CustomColors
                                                              .colorFontTitle),
                                                    ),
                                                    Text(_birthDate,
                                                        style: CustomStyles
                                                            .bold14TextStyle()),
                                                  ],
                                                )),
                                          )),
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
                                                TextSpan(text: '성별'),
                                                TextSpan(
                                                    style: TextStyle(
                                                        color: CustomColors
                                                            .colorRed),
                                                    text: '*'),
                                              ]))),
                                      Container(
                                          width: double.infinity,
                                          margin: EdgeInsets.only(top: 5),
                                          padding: EdgeInsets.only(
                                              left: 30, right: 30),
                                          child: Row(
                                            children: <Widget>[
                                              Radio(
                                                visualDensity:
                                                    VisualDensity.compact,
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                value: 0,
                                                groupValue: _userGender,
                                                onChanged: (_) {
                                                  setState(() {
                                                    _userGender = 0;
                                                  });
                                                },
                                              ),
                                              Container(
                                                  margin: EdgeInsets.only(
                                                      right: 10),
                                                  child: Text('여자',
                                                      style: CustomStyles
                                                          .normal14TextStyle())),
                                              Radio(
                                                visualDensity:
                                                    VisualDensity.compact,
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                value: 1,
                                                groupValue: _userGender,
                                                onChanged: (_) {
                                                  setState(() {
                                                    _userGender = 1;
                                                  });
                                                },
                                              ),
                                              Text('남자',
                                                  style: CustomStyles
                                                      .normal14TextStyle())
                                            ],
                                          )),
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: 25, bottom: 30),
                                        child: Divider(
                                          height: 0.1,
                                          color:
                                              CustomColors.colorFontLightGrey,
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
                                                TextSpan(text: '연락처'),
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
                                                  _txtFieldPhone,
                                                  TextInputType.number,
                                                  '숫자로만 입력해 주세요.')),
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: 30, bottom: 30),
                                        child: Divider(
                                          height: 0.1,
                                          color:
                                              CustomColors.colorFontLightGrey,
                                        ),
                                      ),
                                      Container(
                                          padding: EdgeInsets.only(
                                              left: 30, right: 30),
                                          alignment: Alignment.centerLeft,
                                          child: Text('은행 계좌',
                                              style: CustomStyles
                                                  .normal14TextStyle())),
                                      Container(
                                        margin: EdgeInsets.only(top: 5),
                                        padding: EdgeInsets.only(
                                            left: 30, right: 30),
                                        width: double.infinity,
                                        child: DropdownButtonFormField(
                                          value: _bankVal,
                                          onChanged: (String newValue) {
                                            setState(() {
                                              _bankVal = newValue;
                                            });
                                          },
                                          items: <String>[
                                            '은행선택',
                                            '국민',
                                            '기업',
                                            '농협'
                                          ].map<DropdownMenuItem<String>>(
                                              (String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value,
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
                                                        .greyBorderRound7TextField(
                                                            TextEditingController(),
                                                            '계좌번호 입력')),
                                              ),
                                              Expanded(
                                                flex: 0,
                                                child: Container(
                                                    height: 48,
                                                    margin: EdgeInsets.only(
                                                        left: 5),
                                                    child: CustomStyles
                                                        .greyBGRound7ButtonStyle(
                                                            '계좌인증', () {
                                                      // 인증번호 받기 버튼 클릭
                                                    })),
                                              )
                                            ],
                                          )),
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: 30, bottom: 30),
                                        child: Divider(
                                          height: 0.1,
                                          color:
                                              CustomColors.colorFontLightGrey,
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
                                                  TextInputType.emailAddress,
                                                  '이메일주소를 입력해 주세요.')),
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
                                                TextSpan(text: '서비스 제공을 위해 '),
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
                                                TextSpan(text: ' 내용에 동의해 주세요.'),
                                              ]))),
                                      Container(
                                          margin: EdgeInsets.only(top: 10),
                                          padding: EdgeInsets.only(
                                              left: 30, right: 30),
                                          child: Row(
                                              mainAxisSize: MainAxisSize.max,
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
                                                      if (_agreeTerms == 0) {
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
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Radio<int>(
                                                  value: _agreePrivacyPolicy,
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                  groupValue: 1,
                                                  toggleable: true,
                                                  onChanged: (_) {
                                                    setState(() {
                                                      if (_agreePrivacyPolicy ==
                                                          0) {
                                                        _agreePrivacyPolicy = 1;
                                                      } else {
                                                        _agreePrivacyPolicy = 0;
                                                      }
                                                    });
                                                  },
                                                  materialTapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
                                                ),
                                                Text('개인정보 수집 이용에 동의합니다.(필수)',
                                                    style: CustomStyles
                                                        .normal14TextStyle())
                                              ]))
                                    ])))),
                    Container(
                        height: 50,
                        width: double.infinity,
                        child: CustomStyles.lightGreyBGSquareButtonStyle('회원가입',
                            () {
                          if (checkValidate(context)) {
                            requestJoinApi(context);
                          }
                        }))
                  ],
                )))));
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

    if (StringUtils.isEmpty(_txtFieldPWCheck.text)) {
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

    if (StringUtils.isEmpty(_txtFieldName.text)) {
      showSnackBar(context, '이름(실명)을 입력해 주세요.');
      return false;
    }

    if (StringUtils.isEmpty(_txtFieldPhone.text)) {
      showSnackBar(context, '연락처를 입력해 주세요.');
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
  *  배우 회원가입 api 호출
  * */
  void requestJoinApi(BuildContext context) {
    final dio = Dio();

    // 회원가입 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetDatas = new Map();
    targetDatas[APIConstants.id] = StringUtils.trimmedString(_txtFieldID.text);
    targetDatas[APIConstants.pwd] = StringUtils.trimmedString(_txtFieldPW.text);
    targetDatas[APIConstants.member_type] = APIConstants.member_type_actor;
    targetDatas[APIConstants.actor_name] =
        StringUtils.trimmedString(_txtFieldName.text);
    targetDatas[APIConstants.actor_isAuth] = "";
    targetDatas[APIConstants.guardian_isAuth] = "";
    targetDatas[APIConstants.guardian_RR_url] = "";
    targetDatas[APIConstants.guardian_COH_url] = "";
    targetDatas[APIConstants.guardian_COFR_url] = "";
    targetDatas[APIConstants.actor_bank_code] = "";
    targetDatas[APIConstants.actor_account_number] = "";
    targetDatas[APIConstants.actor_birth] = _birthDate;
    targetDatas[APIConstants.sex_type] = _userGender == 0 ? "여자" : "남자";
    targetDatas[APIConstants.actor_phone] =
        StringUtils.trimmedString(_txtFieldPhone.text);
    targetDatas[APIConstants.actor_email] =
        StringUtils.trimmedString(_txtFieldEmail.text);
    targetDatas[APIConstants.TOS_isAgree] = 1;
    targetDatas[APIConstants.PPA_isAgree] = 1;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.INS_ACT_JOIN;
    params[APIConstants.target] = targetDatas;

    // 회원가입 api 호출
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value == null) {
        // 에러 - 데이터 널 - 서버가 응답하지 않습니다. 다시 시도해 주세요
        showSnackBar(context, APIConstants.error_msg_server_not_response);
      } else {
        if (value[APIConstants.resultVal]) {
          try {
            // 회원가입 성공
            var _responseList = value[APIConstants.data];
            List<dynamic> _listData = _responseList[APIConstants.list];

            // 회원데이터 전역변수에 저장
            KCastingAppData().myInfo =
                _listData.length > 0 ? _listData[0] : null;

            // 자동로그인
            final SharedPreferences prefs =
                await SharedPreferences.getInstance();
            prefs.setBool(APIConstants.autoLogin, true);
            prefs.setString(
                APIConstants.member_type, APIConstants.member_type_actor);
            prefs.setInt(
                APIConstants.seq, KCastingAppData().myInfo[APIConstants.seq]);

            requestActorProfileApi(context);
          } catch (e) {
            showSnackBar(context, APIConstants.error_msg_join_fail);
          }
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
    });
  }

  /*
  * 배우프로필조회
  * */
  void requestActorProfileApi(BuildContext context) {
    print('actor only');
    final dio = Dio();

    // 배우프로필조회 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetData = new Map();
    targetData[APIConstants.actor_seq] =
        KCastingAppData().myInfo[APIConstants.seq];
    targetData[APIConstants.actor_profile_seq] =
        KCastingAppData().myInfo[APIConstants.actorProfile_seq];

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.SAR_APR_INFO;
    params[APIConstants.target] = targetData;

    // 배우프로필조회 api 호출
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value != null) {
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
                        KCastingAppData().myProfile =
                            _actorProfileList.length > 0
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
                      KCastingAppData().myEducation =
                          _listData[APIConstants.list] as List;
                    } else {
                      KCastingAppData().myEducation = [];
                    }
                    break;
                  }

                // 배우 언어
                case APIConstants.table_actor_languge:
                  {
                    var _listData = _data[APIConstants.data];
                    if (_listData != null) {
                      KCastingAppData().myLanguage =
                          _listData[APIConstants.list] as List;
                    } else {
                      KCastingAppData().myLanguage = [];
                    }
                    break;
                  }

                // 배우 사투리
                case APIConstants.table_actor_dialect:
                  {
                    var _listData = _data[APIConstants.data];
                    if (_listData != null) {
                      KCastingAppData().myDialect =
                          _listData[APIConstants.list] as List;
                    } else {
                      KCastingAppData().myDialect = [];
                    }
                    break;
                  }

                // 배우 특기
                case APIConstants.table_actor_ability:
                  {
                    var _listData = _data[APIConstants.data];
                    if (_listData != null) {
                      KCastingAppData().myAbility =
                          _listData[APIConstants.list] as List;
                    } else {
                      KCastingAppData().myAbility = [];
                    }
                    break;
                  }

                // 배우 외모 키워드
                case APIConstants.table_actor_lookkwd:
                  {
                    var _listData = _data[APIConstants.data];
                    if (_listData != null) {
                      KCastingAppData().myLookKwd =
                          _listData[APIConstants.list] as List;
                    } else {
                      KCastingAppData().myLookKwd = [];
                    }
                    break;
                  }

                // 배우 캐스팅 키워드
                case APIConstants.table_actor_castingKwd:
                  {
                    var _listData = _data[APIConstants.data];

                    if (_listData != null) {
                      KCastingAppData().myCastingKwd =
                          _listData[APIConstants.list] as List;
                    } else {
                      KCastingAppData().myCastingKwd = [];
                    }

                    break;
                  }

                // 배우 필모그래피
                case APIConstants.table_actor_filmography:
                  {
                    var _listData = _data[APIConstants.data];
                    if (_listData != null) {
                      KCastingAppData()
                        ..myFilmorgraphy = _listData[APIConstants.list] as List;
                    } else {
                      KCastingAppData().myFilmorgraphy = [];
                    }
                    break;
                  }

                // 배우 이미지
                case APIConstants.table_actor_image:
                  {
                    var _listData = _data[APIConstants.data];
                    if (_listData != null) {
                      KCastingAppData().myImage =
                          _listData[APIConstants.list] as List;
                    } else {
                      KCastingAppData().myImage = [];
                    }

                    break;
                  }

                // 배우 비디오
                case APIConstants.table_actor_video:
                  {
                    var _listData = _data[APIConstants.data];
                    if (_listData != null) {
                      KCastingAppData().myVideo =
                          _listData[APIConstants.list] as List;
                    } else {
                      KCastingAppData().myVideo = [];
                    }

                    break;
                  }
              }
            }
          });
        }
      }

      replaceView(context, Home(prevPage: APIConstants.INS_PRD_JOIN));
    });
  }
}
