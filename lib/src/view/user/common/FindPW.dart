import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:casting_call/src/view/user/common/FindPWResult.dart';
import 'package:casting_call/src/view/user/common/Login.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'FindPWAuth.dart';

/*
* 비밀번호 찾기
* */
class FindPW extends StatefulWidget {
  @override
  _FindPW createState() => _FindPW();
}

class _FindPW extends State<FindPW> with BaseUtilMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  final _txtFieldID = TextEditingController();
  final _txtFieldEmail = TextEditingController();

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
          replaceView(context, Login());
          return Future.value(false);
        },
        child: Theme(
            data: CustomStyles.defaultTheme(),
            child: Scaffold(
                key: _scaffoldKey,
                appBar: CustomStyles.defaultAppBar('비밀번호 찾기', () {
                  replaceView(context, Login());
                  return Future.value(false);
                }),
                body: Container(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                      Expanded(
                          flex: 1,
                          child: Container(
                              padding: EdgeInsets.only(left: 30, right: 30),
                              child: Column(children: [
                                Container(
                                    margin: EdgeInsets.only(top: 30),
                                    alignment: Alignment.center,
                                    width: double.infinity,
                                    child: Text('비밀번호 찾기',
                                        textAlign: TextAlign.center,
                                        style:
                                            CustomStyles.normal24TextStyle())),
                                Container(
                                  margin: EdgeInsets.only(top: 30),
                                  width: double.infinity,
                                  child: Text(
                                      '가입 시 등록한 아이디와 이메일 주소를 입력해 주세요.\n임시 비밀번호가 입력하신 이메일 주소로 전송됩니다.',
                                      textAlign: TextAlign.start,
                                      style: CustomStyles.normal14TextStyle()),
                                ),
                                Container(
                                    margin: EdgeInsets.only(top: 10),
                                    child:
                                        CustomStyles.greyBorderRound7TextField(
                                            _txtFieldID, '아이디')),
                                Container(
                                    margin: EdgeInsets.only(top: 5),
                                    child: CustomStyles
                                        .greyBorderRound7TextFieldWithOption(
                                            _txtFieldEmail,
                                            TextInputType.emailAddress,
                                            '이메일 주소'))
                              ]))),
                      Container(
                          height: 50,
                          width: double.infinity,
                          child: CustomStyles.lightGreyBGSquareButtonStyle('다음',
                              () {
                            if (checkValidate(context)) {
                              requestFindPWApi(context);
                            }
                          }))
                    ])) /*Container(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                      Expanded(
                          flex: 1,
                          child: Container(
                              padding: EdgeInsets.only(left: 30, right: 30),
                              child: Column(children: [
                                Container(
                                    margin: EdgeInsets.only(top: 30),
                                    alignment: Alignment.center,
                                    width: double.infinity,
                                    child: Text('비밀번호 찾기',
                                        textAlign: TextAlign.center,
                                        style:
                                            CustomStyles.normal24TextStyle())),
                                Container(
                                  margin: EdgeInsets.only(top: 30),
                                  width: double.infinity,
                                  child: Text('비밀번호를 찾고자 하는 아이디를 입력해 주세요.',
                                      textAlign: TextAlign.center,
                                      style: CustomStyles.normal14TextStyle()),
                                ),
                                Container(
                                    margin: EdgeInsets.only(top: 30),
                                    child:
                                        CustomStyles.greyBorderRound7TextField(
                                            _txtFieldID, '아이디'))
                              ]))),
                      Container(
                          height: 50,
                          width: double.infinity,
                          child: CustomStyles.lightGreyBGSquareButtonStyle('다음',
                              () {
                            replaceView(context, FindPWAuth());
                          }))
                    ]))*/
                )));
  }

  /*
  * 입력 데이터 유효성 검사
  * */
  bool checkValidate(BuildContext context) {
    if (StringUtils.isEmpty(_txtFieldID.text)) {
      showSnackBar(context, '아이디를 입력해 주세요.');
      return false;
    }

    if (StringUtils.isEmpty(_txtFieldEmail.text)) {
      showSnackBar(context, '이메일 주소를 입력해 주세요.');
      return false;
    }

    return true;
  }

  /*
  * 임시비밀번호 이메일 발송 api 호출
  * */
  void requestFindPWApi(BuildContext context) {
    final dio = Dio();

    // 임시비밀번호 이메일 발송 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetDatas = new Map();
    targetDatas[APIConstants.id] = StringUtils.trimmedString(_txtFieldID.text);
    //targetDatas[APIConstants.email] = StringUtils.trimmedString(_txtFieldEmail.text);

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.UPD_TOT_RANDPWD;
    params[APIConstants.target] = targetDatas;

    // 임시비밀번호 이메일 발송 api 호출
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value == null) {
        // 에러 - 데이터 널
        showSnackBar(context, APIConstants.error_msg_server_not_response);
      } else {
        if (value[APIConstants.resultVal]) {
          replaceView(context, FindPWResult(id: StringUtils.trimmedString(_txtFieldEmail.text)));
        } else {
          showSnackBar(context, value[APIConstants.resultMsg]);
        }
      }
    });
  }
}
