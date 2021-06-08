import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:casting_call/src/view/mypage/actor/ActorMemberInfo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../../../KCastingAppData.dart';

class ActorMemberInfoModify extends StatefulWidget {
  @override
  _ActorMemberInfoModify createState() => _ActorMemberInfoModify();
}

class _ActorMemberInfoModify extends State<ActorMemberInfoModify> {
  String _bankVal = '은행선택';

  final _txtFieldPW = TextEditingController();
  final _txtFieldNewPW = TextEditingController();
  final _txtFieldPWCheck = TextEditingController();
  final _txtFieldName = TextEditingController();
  final _txtFieldBirth = TextEditingController();
  final _txtFieldSex = TextEditingController();
  final _txtFieldPhone = TextEditingController();
  final _txtFieldEmail = TextEditingController();

  @override
  void initState() {
    super.initState();

    _txtFieldPhone.text = StringUtils.isEmpty(
        KCastingAppData().myInfo[APIConstants.actor_phone])
        ? ''
        : KCastingAppData().myInfo[APIConstants.actor_phone];

    _txtFieldEmail.text = StringUtils.isEmpty(
        KCastingAppData().myInfo[APIConstants.actor_email])
        ? ''
        : KCastingAppData().myInfo[APIConstants.actor_email];
  }

  //========================================================================================================================
  // 메인 위젯
  //========================================================================================================================
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
                                child:
                                Text('아이디', style: CustomStyles.bold14TextStyle())),
                            Container(
                                margin: EdgeInsets.only(top: 15.0),
                                padding: EdgeInsets.only(left: 18, right: 18),
                                child: Text(KCastingAppData().myInfo[APIConstants.id],
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
                                child:
                                Text('이름', style: CustomStyles.bold14TextStyle())),
                            Container(
                                margin: EdgeInsets.only(top: 15),
                                padding: EdgeInsets.only(left: 18, right: 18),
                                child: Text(KCastingAppData().myInfo[APIConstants.actor_name],
                                    style: CustomStyles.normal16TextStyle())),
                            Container(
                                margin: EdgeInsets.only(top: 20),
                                padding: EdgeInsets.only(left: 18, right: 18),
                                child: Text('생년월일',
                                    style: CustomStyles.bold14TextStyle())),
                            Container(
                                margin: EdgeInsets.only(top: 15),
                                padding: EdgeInsets.only(left: 18, right: 18),
                                child: Text(KCastingAppData().myInfo[APIConstants.actor_birth],
                                    style: CustomStyles.normal16TextStyle())),
                            Container(
                                margin: EdgeInsets.only(top: 20),
                                padding: EdgeInsets.only(left: 18, right: 18),
                                child:
                                Text('성별', style: CustomStyles.bold14TextStyle())),
                            Container(
                                margin: EdgeInsets.only(top: 15),
                                padding: EdgeInsets.only(left: 18, right: 18),
                                child: Text(KCastingAppData().myInfo[APIConstants.sex_type],
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
                                child:
                                Text('연락처', style: CustomStyles.bold14TextStyle())),
                            Container(
                                margin: EdgeInsets.only(top: 15),
                                padding: EdgeInsets.only(left: 18, right: 18),
                                child:
                                CustomStyles.greyBorderRound7TextField(
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
                      margin: EdgeInsets.only(top: 5),
                      padding: EdgeInsets.only(left: 18, right: 18),
                      width: double.infinity,
                      child: DropdownButtonFormField(
                        value: _bankVal,
                        onChanged: (String newValue) {
                          setState(() {
                            _bankVal = newValue;
                          });
                        },
                        items: <String>['은행선택', '국민', '기업', '농협']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value,
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
                                  child: CustomStyles.greyBorderRound7TextField(TextEditingController(),
                                      '계좌번호 입력')),
                            ),
                            Expanded(
                              flex: 0,
                              child: Container(
                                  height: 48,
                                  margin: EdgeInsets.only(left: 5),
                                  child: CustomStyles.greyBGRound7ButtonStyle(
                                      '계좌인증', () {
                                    // 인증번호 받기 버튼 클릭
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
                                child: CustomStyles.greyBorderRound7ButtonStyle('수정완료',
                                        () {
                                      if (checkValidate(context)) {
                                        requestUpdateApi(context);
                                      }
                                    })),
                          ],
                        ),
                      ),
                    ));
              },
            )));
  }

  //========================================================================================================================
  // 입력 데이터 유효성 검사
  //========================================================================================================================
  bool checkValidate(BuildContext context) {
    if (StringUtils.isEmpty(_txtFieldPW.text)) {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('기존 비밀번호를 입력해 주세요.')));
      return false;
    }

    if (KCastingAppData().myInfo[APIConstants.pwd] !=
        StringUtils.trimmedString(_txtFieldPW.text)) {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('기존 비밀번호가 올바르지 않습니다.')));
      return false;
    }

    if (StringUtils.isEmpty(_txtFieldNewPW.text)) {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('새 비밀번호를 입력해 주세요.')));
      return false;
    }

    if (_txtFieldPWCheck.text == null || !_txtFieldPWCheck.text.isNotEmpty) {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('비밀번호를 한번 더 입력해 주세요.')));
      return false;
    }

    if (StringUtils.trimmedString(_txtFieldNewPW.text) !=
        StringUtils.trimmedString(_txtFieldPWCheck.text)) {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('비밀번호가 일치하지 않습니다.')));

      return false;
    }

    /*if (!RegExp(r"[a-z0-9]").hasMatch(_txtFieldPW.text)) {
                            Scaffold.of(context).showSnackBar(
                                SnackBar(content: Text('비밀번호 형식이 올바르지 않습니다.')));

                            return;
                          }*/

    /*if (!RegExp(
                                  r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                              .hasMatch(_txtFieldEmail.text)) {
                            Scaffold.of(context).showSnackBar(
                                SnackBar(content: Text('이메일 형식이 올바르지 않습니다.')));

                            return;
                          }*/

    return true;
  }

  //========================================================================================================================
  // 제작사 회원정보 수정
  //========================================================================================================================
  void requestUpdateApi(BuildContext context) {
    final dio = Dio();

    // 회원가입 api 호출 시 보낼 파라미터

    Map<String, dynamic> targetDatas = new Map();
    targetDatas[APIConstants.seq] = KCastingAppData().myInfo[APIConstants.seq];
    targetDatas[APIConstants.pwd] = StringUtils.trimmedString(_txtFieldNewPW.text);
    targetDatas[APIConstants.actor_phone] = StringUtils.trimmedString(_txtFieldPhone.text);
    targetDatas[APIConstants.actor_email] = StringUtils.trimmedString(_txtFieldEmail.text);

    Map<String, dynamic> params = new Map();

    params[APIConstants.key] = APIConstants.UPD_ACT_INFO;
    params[APIConstants.target] = targetDatas;

    // 회원정보 수정 api 호출
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value == null) {
        // 에러 - 데이터 널
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text('다시 시도해 주세요.')));
      } else {
        if (value[APIConstants.resultVal]) {
          // 회원정보 수정 성공
          var _responseData = value[APIConstants.data];
          var _responseList = _responseData[APIConstants.list];

          // 수정된 회원정보 전역변수에 저장
          if(_responseList.length > 0) {
            KCastingAppData().myInfo = _responseList[0];
          }

          // 제작사 필모그래피 추가 완료 페이지 이동
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ActorMemberInfo()));
        } else {
          // 회원정보 수정 실패
          Scaffold.of(context).showSnackBar(
              SnackBar(content: Text(value[APIConstants.resultMsg])));
        }
      }
    });
  }
}
