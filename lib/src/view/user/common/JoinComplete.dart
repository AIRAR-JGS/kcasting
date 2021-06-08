import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/KCastingAppData.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/view/mypage/actor/ActorProfile.dart';
import 'package:casting_call/src/view/project/ProjectList.dart';
import 'package:flutter/material.dart';

/*
* 회원가입 완료 클래스
* */
class JoinComplete extends StatefulWidget {
  @override
  _JoinComplete createState() => _JoinComplete();
}

class _JoinComplete extends State<JoinComplete> with BaseUtilMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  String _userName = "";
  String _msg = "";
  String _btnName = "";
  Widget _nextWidget;

  @override
  void initState() {
    super.initState();

    setState(() {
      try {
        switch (KCastingAppData().myInfo[APIConstants.member_type]) {
          // 배우 회원
          case APIConstants.member_type_actor:
            _userName = KCastingAppData().myInfo[APIConstants.actor_name];
            _msg = '캐스팅을 위한 프로필을 작성해 주세요.';
            _btnName = "프로필 작성하기";
            _nextWidget = ActorProfile();
            break;
          // 제작사 회원
          case APIConstants.member_type_product:
            _userName = KCastingAppData().myInfo[APIConstants.production_name];
            _msg = '캐스팅을 위해 오디션 공고를 올려주세요.';
            _btnName = "오디션 관리";
            _nextWidget = ProjectList();
            break;
          // 매니지먼트 회원
          case APIConstants.member_type_management:
            _userName = KCastingAppData().myInfo[APIConstants.production_name];
            _msg = '캐스팅을 위한 보유배우를 추가해 주세요.';
            _btnName = "보유배우";
            _nextWidget = ProjectList();
            break;
        }
      } catch (e) {}
    });
  }

  /*
  *  메인위젯
  * */
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          return Future.value(true);
        },
        child: Theme(
            data: CustomStyles.defaultTheme(),
            child: Scaffold(
                key: _scaffoldKey,
                appBar: CustomStyles.defaultAppBar('가입완료', () {
                  Navigator.pop(context);
                }),
                body: Container(
                    padding: EdgeInsets.only(left: 30, right: 30),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              alignment: Alignment.center,
                              width: double.infinity,
                              child: Text(_userName + ' 님,\n회원가입이 완료되었습니다.',
                                  textAlign: TextAlign.center,
                                  style: CustomStyles.normal24TextStyle())),
                          Container(
                              margin: EdgeInsets.only(top: 30, bottom: 50),
                              alignment: Alignment.center,
                              width: double.infinity,
                              child: Text(_msg,
                                  textAlign: TextAlign.center,
                                  style: CustomStyles.normal14TextStyle())),
                          Container(
                              height: 50,
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: CustomStyles.greyBorderRound7ButtonStyle(
                                  _btnName, () {
                                replaceView(context, _nextWidget);
                              }))
                        ])))));
  }
}
