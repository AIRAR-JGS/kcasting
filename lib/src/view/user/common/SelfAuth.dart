import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/view/user/actor/JoinActorAdult.dart';
import 'package:casting_call/src/view/user/common/AuthWebView.dart';
import 'package:casting_call/src/view/user/common/JoinSelectType.dart';
import 'package:flutter/material.dart';

/*
*  개인 본인인증
* */
class SelfAuth extends StatefulWidget {
  final String authRes;
  final String authName;
  final String authPhone;
  final String authBirth;
  final String authGender;
  final String memberType;

  const SelfAuth(
      {Key key,
      this.authRes,
      this.authName,
      this.authPhone,
      this.authBirth,
      this.authGender,
      this.memberType})
      : super(key: key);

  @override
  _SelfAuth createState() => _SelfAuth();
}

class _SelfAuth extends State<SelfAuth> with BaseUtilMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  bool _isUpload = false;

  String _authComplete; // before, success, fail
  String _authRes;
  String _authName;
  String _authPhone;
  String _authBirth;
  String _authGender;
  String _memberType;

  @override
  void initState() {
    super.initState();

    _authRes = widget.authRes;
    _authName = widget.authName;
    _authPhone = widget.authPhone;
    _authBirth = widget.authBirth;
    _authGender = widget.authGender;
    _memberType = widget.memberType;

    if (_authComplete == "TRUE") {
      showSnackBar(context, "본인인증이 완료되었습니다.");
    } else if (_authComplete == "FALSE") {
      showSnackBar(context, "본인인증에 실패하였습니다. 다시 시도해 주세요.");
    }
  }

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
                appBar: CustomStyles.defaultAppBar('본인 인증', () {
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
                            child: Column(children: [
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
                                                child: Text('본인인증',
                                                    style: CustomStyles
                                                        .normal24TextStyle())),
                                            Visibility(
                                                child: Container(
                                                    padding: EdgeInsets.only(
                                                        left: 15, right: 15),
                                                    margin: EdgeInsets.only(
                                                        bottom: 30),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                        '배우 회원은 오디션 지원 및 계약 시 실명과 연락처 정보가 필요합니다.\n\n따라서 배우회원가입을 하시려면 본인인증을 해주셔야 합니다.\n\n실명과 연락처 정보는 대면면접 일정안내 또는 계약서 작성 이외의 다른 용도로 사용되지 않습니다.',
                                                        style: CustomStyles
                                                            .normal16TextStyle())),
                                                visible: _authRes == ''
                                                    ? true
                                                    : false),
                                            Visibility(
                                                child: Container(
                                                    padding: EdgeInsets.only(
                                                        left: 15, right: 15),
                                                    margin: EdgeInsets.only(
                                                        bottom: 30),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                        '본인인증이 완료되었습니다!\n회원가입을 진행해 주세요.',
                                                        style: CustomStyles
                                                            .normal16TextStyle())),
                                                visible: _authRes == 'TRUE'
                                                    ? true
                                                    : false),
                                            Visibility(
                                                child: Container(
                                                    padding: EdgeInsets.only(
                                                        left: 15, right: 15),
                                                    margin: EdgeInsets.only(
                                                        bottom: 30),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                        '본인인증에 실패하였습니다. 다시 시도해 주세요.',
                                                        style: CustomStyles
                                                            .normal16TextStyle())),
                                                visible: _authRes == 'FALSE'
                                                    ? true
                                                    : false)
                                          ])))),
                          Visibility(
                              child: Container(
                                  height: 50,
                                  width: double.infinity,
                                  child:
                                      CustomStyles.lightGreyBGSquareButtonStyle(
                                          '본인인증하기', () {
                                    replaceView(context, AuthWebView());
                                  })),
                              visible: _authRes == 'TRUE' ? false : true),
                          Visibility(
                              child: Container(
                                  height: 50,
                                  width: double.infinity,
                                  child:
                                      CustomStyles.lightGreyBGSquareButtonStyle(
                                          '배우 회원가입', () {
                                    replaceView(
                                        context,
                                        JoinActorAdult(
                                            authName: _authName,
                                            authPhone: _authPhone,
                                            authBirth: _authBirth,
                                            authGender: _authGender));
                                  })),
                              visible: _authRes == 'TRUE' ? true : false)
                        ])),
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
}
