import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:casting_call/src/view/user/common/FindPWResult.dart';
import 'package:casting_call/src/view/user/common/Login.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../KCastingAppData.dart';

/*
* 비밀번호 찾기
* */
class FindPW extends StatefulWidget {
  @override
  _FindPW createState() => _FindPW();
}

class _FindPW extends State<FindPW> with BaseUtilMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  bool _isUpload = false;

  final _txtFieldID = TextEditingController();

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
            child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: KCastingAppData().isWeb
                      ? CustomStyles.appWidth
                      : double.infinity,
                  child: Scaffold(
                    key: _scaffoldKey,
                    appBar: CustomStyles.defaultAppBar('비밀번호 찾기', () {
                      replaceView(context, Login());
                      return Future.value(false);
                    }),
                    body: Stack(
                      children: [
                        Container(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                              Expanded(
                                  flex: 1,
                                  child: Container(
                                      padding:
                                          EdgeInsets.only(left: 30, right: 30),
                                      child: Column(children: [
                                        Container(
                                            margin: EdgeInsets.only(top: 30),
                                            alignment: Alignment.center,
                                            width: double.infinity,
                                            child: Text('비밀번호 찾기',
                                                textAlign: TextAlign.center,
                                                style: CustomStyles
                                                    .normal24TextStyle())),
                                        Container(
                                          margin: EdgeInsets.only(top: 30),
                                          width: double.infinity,
                                          child: Text(
                                              '가입 시 등록한 이메일 주소로 임시 비밀번호가 발송됩니다.',
                                              textAlign: TextAlign.start,
                                              style: CustomStyles
                                                  .normal14TextStyle()),
                                        ),
                                        Container(
                                            margin: EdgeInsets.only(top: 10),
                                            child: CustomStyles
                                                .greyBorderRound7TextField(
                                                    _txtFieldID, '아이디'))
                                      ]))),
                              Container(
                                  height: 50,
                                  width: double.infinity,
                                  child:
                                      CustomStyles.lightGreyBGSquareButtonStyle(
                                          '다음', () {
                                    if (checkValidate(context)) {
                                      requestFindPWApi(context);
                                    }
                                  }))
                            ])),
                        Visibility(
                          child: Container(
                              color: Colors.black38,
                              alignment: Alignment.center,
                              child: CircularProgressIndicator()),
                          visible: _isUpload,
                        )
                      ],
                    ),
                  ),
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

    return true;
  }

  /*
  * 임시비밀번호 이메일 발송 api 호출
  * */
  void requestFindPWApi(BuildContext context) {
    setState(() {
      _isUpload = true;
    });

    // 임시비밀번호 이메일 발송 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetDatas = new Map();
    targetDatas[APIConstants.id] = StringUtils.trimmedString(_txtFieldID.text);

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.UPD_TOT_RANDPWD;
    params[APIConstants.target] = targetDatas;

    // 임시비밀번호 이메일 발송 api 호출
    RestClient(Dio()).postRequestMainControl(params).then((value) async {
      try {
        if (value == null) {
          // 에러 - 데이터 널
          showSnackBar(context, APIConstants.error_msg_server_not_response);
        } else {
          if (value[APIConstants.resultVal]) {
            var _responseData = value[APIConstants.data];
            var _responseList = _responseData[APIConstants.list];

            replaceView(context, FindPWResult());
          } else {
            showSnackBar(context, value[APIConstants.resultMsg]);
          }
        }
      } catch (e) {
        showSnackBar(context, value[APIConstants.error_msg_try_again]);
      } finally {
        setState(() {
          _isUpload = false;
        });
      }
    });
  }
}
