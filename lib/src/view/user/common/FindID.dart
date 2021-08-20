import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:casting_call/src/view/user/common/FindIDResult.dart';
import 'package:casting_call/src/view/user/common/Login.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../KCastingAppData.dart';

/*
* 아이디 찾기
* */
class FindID extends StatefulWidget {
  @override
  _FindID createState() => _FindID();
}

class _FindID extends State<FindID> with BaseUtilMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  bool _isUpload = false;

  final _txtFieldName = TextEditingController();
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
            child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: KCastingAppData().isWeb
                      ? CustomStyles.appWidth
                      : double.infinity,
                  child: Scaffold(
                    key: _scaffoldKey,
                    appBar: CustomStyles.defaultAppBar('아이디 찾기', () {
                      replaceView(context, Login());
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
                                            child: Text('아이디 찾기',
                                                textAlign: TextAlign.center,
                                                style: CustomStyles
                                                    .normal24TextStyle())),
                                        Container(
                                            margin: EdgeInsets.only(top: 30),
                                            width: double.infinity,
                                            child: Text(
                                                '회원가입 시 등록한 이름과 이메일 주소를 입력해 주세요.',
                                                textAlign: TextAlign.start,
                                                style: CustomStyles
                                                    .normal14TextStyle())),
                                        Container(
                                            margin: EdgeInsets.only(top: 15),
                                            child: CustomStyles
                                                .greyBorderRound7TextField(
                                                    _txtFieldName, '이름')),
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
                                  child:
                                      CustomStyles.lightGreyBGSquareButtonStyle(
                                          '다음', () {
                                    if (checkValidate(context)) {
                                      requestFindIDApi(context);
                                    }
                                  }))
                            ],
                          ),
                        ),
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
    if (StringUtils.isEmpty(_txtFieldName.text)) {
      showSnackBar(context, '이름을 입력해 주세요.');
      return false;
    }

    if (StringUtils.isEmpty(_txtFieldEmail.text)) {
      showSnackBar(context, '이메일 주소를 입력해 주세요.');
      return false;
    }

    return true;
  }

  /*
  * 아이디찾기 api 호출
  * */
  void requestFindIDApi(BuildContext context) {
    setState(() {
      _isUpload = true;
    });

    // 아이디찾기 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetDatas = new Map();
    targetDatas[APIConstants.name] =
        StringUtils.trimmedString(_txtFieldName.text);
    targetDatas[APIConstants.email] =
        StringUtils.trimmedString(_txtFieldEmail.text);

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.FID_TOT_FINDID;
    params[APIConstants.target] = targetDatas;

    // 아이디찾기 api 호출
    RestClient(Dio()).postRequestMainControl(params).then((value) async {
      try {
        if (value == null) {
          // 에러 - 데이터 널
          showSnackBar(context, APIConstants.error_msg_server_not_response);
        } else {
          if (value[APIConstants.resultVal]) {
            var _responseList = value[APIConstants.data];
            var _listData = _responseList[APIConstants.list];

            String id = _listData[APIConstants.id];

            if (id != null) {
              replaceView(context, FindIDResult(id: id));
            } else {
              showSnackBar(context, value[APIConstants.error_msg_try_again]);
            }
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
