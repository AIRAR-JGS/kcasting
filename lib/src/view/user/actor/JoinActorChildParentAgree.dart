import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/view/user/actor/JoinActorSelectType.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'JoinActorChild.dart';
import 'JoinActorChildParentAuth.dart';

/*
* 14세 미만 배우 회원가입 시 보호자 인증하기
* */
class JoinActorChildParentAgree extends StatefulWidget {
  @override
  _JoinActorChildParentAgree createState() => _JoinActorChildParentAgree();
}

class _JoinActorChildParentAgree extends State<JoinActorChildParentAgree>
    with BaseUtilMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  final _txtFieldName = TextEditingController();
  final _txtFieldPhone = TextEditingController();
  final _txtFieldBankAccount = TextEditingController();
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
            child: Scaffold(
                key: _scaffoldKey,
                appBar: CustomStyles.defaultAppBar('보호자 동의', () {
                  replaceView(context, JoinActorSelectType());
                }),
                body: Container(
                    child: Column(children: [
                  Expanded(
                      flex: 1,
                      child: SingleChildScrollView(
                          child: Container(
                              padding: EdgeInsets.only(top: 30, bottom: 50),
                              child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                        margin: EdgeInsets.only(bottom: 30),
                                        alignment: Alignment.center,
                                        child: Text('보호자 동의',
                                            style: CustomStyles
                                                .normal24TextStyle())),
                                    Container(
                                        height: 50,
                                        padding: EdgeInsets.only(
                                            left: 30, right: 30),
                                        width: double.infinity,
                                        child: CustomStyles
                                            .greyBorderRound7ButtonStyle(
                                                '보호자 인증하기', () {
                                          addView(context,
                                              JoinActorChildParentAuth());
                                        })),
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
                                                  text: '*')
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
                                                              .bold14TextStyle())
                                                    ])))),
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
                                        child: Row(children: <Widget>[
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
                                              }),
                                          Container(
                                              margin:
                                                  EdgeInsets.only(right: 10),
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
                                              }),
                                          Text('남자',
                                              style: CustomStyles
                                                  .normal14TextStyle())
                                        ])),
                                    Container(
                                      margin:
                                          EdgeInsets.only(top: 25, bottom: 30),
                                      child: Divider(
                                        height: 0.1,
                                        color: CustomColors.colorFontLightGrey,
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
                                                  text: '*')
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
                                            color: CustomColors
                                                .colorFontLightGrey)),
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
                                                    EdgeInsets.symmetric(vertical: 5, horizontal: 10)))),
                                    Container(
                                        margin: EdgeInsets.only(top: 5),
                                        padding: EdgeInsets.only(
                                            left: 30, right: 30),
                                        width: double.infinity,
                                        child: Row(children: [
                                          Expanded(
                                              flex: 7,
                                              child: Container(
                                                  child: CustomStyles
                                                      .greyBorderRound7TextFieldWithOption(
                                                          _txtFieldBankAccount,
                                                          TextInputType.number,
                                                          '계좌번호 입력'))),
                                          Expanded(
                                              flex: 0,
                                              child: Container(
                                                  height: 48,
                                                  margin:
                                                      EdgeInsets.only(left: 5),
                                                  child: CustomStyles
                                                      .greyBGRound7ButtonStyle(
                                                          '계좌인증', () {
                                                    // 인증번호 받기 버튼 클릭
                                                  })))
                                        ])),
                                    Container(
                                        margin: EdgeInsets.only(
                                            top: 30, bottom: 30),
                                        child: Divider(
                                          height: 0.1,
                                          color:
                                              CustomColors.colorFontLightGrey,
                                        )),
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
                                                  text: '*')
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
                                                      color:
                                                          CustomColors.colorRed,
                                                      decoration: TextDecoration
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
                                                      color:
                                                          CustomColors.colorRed,
                                                      decoration: TextDecoration
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
                                                  text: ' 등의 내용에 동의해 주세요.'),
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
                      color: Colors.grey,
                      child: CustomStyles.lightGreyBGSquareButtonStyle(
                          '자녀 회원가입', () {
                        replaceView(context, JoinActorChild());
                      }))
                ])))));
  }
}
