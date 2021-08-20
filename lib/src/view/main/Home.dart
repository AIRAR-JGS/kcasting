import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/KCastingAppData.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/view/actor/ActorList.dart';
import 'package:casting_call/src/view/audition/common/AuditionList.dart';
import 'package:casting_call/src/view/main/FragmentHome.dart';
import 'package:casting_call/src/view/main/HomeAppBar.dart';
import 'package:casting_call/src/view/main/HomeDrawer.dart';
import 'package:casting_call/src/view/mypage/actor/ActorMemberPage.dart';
import 'package:casting_call/src/view/mypage/management/AgencyMemberPage.dart';
import 'package:casting_call/src/view/mypage/production/ProductionMemberPage.dart';
import 'package:casting_call/src/view/user/common/JoinComplete.dart';
import 'package:flutter/material.dart';

/*
* 홈 클래스(메인 화면)
* */

class Home extends StatefulWidget {
  final String prevPage;

  const Home({Key key, this.prevPage}) : super(key: key);

  @override
  _Home createState() => _Home();
}

class _Home extends State<Home> with BaseUtilMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  String _prevPage;
  DateTime currentBackPressTime;
  String _actorGenderType;

  @override
  void initState() {
    super.initState();

    _prevPage = widget.prevPage;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // 회원가입 후 메인화면으로 넘어 온 경우, 회원가입 완료 페이지 띄우기
      if (_prevPage != null) {
        addView(context, JoinComplete());
      }
    });
  }

  // 0: 메인 홈, 1: 캐스팅 보드, 2: 배우 캐스팅, 3: 마이페이지
  int _currentFragmentIndex = 0;

  // ignore: missing_return
  Widget body() {
    switch (_currentFragmentIndex) {
      case 0:
        return FragmentHome(
          onClickedOpenCastingBoard: () {
            _onTap(1);
          },
          onClickedOpenCastingActor: (type) {
            _actorGenderType = type;
            _onTap(2);
          },
        );
      case 1:
        return AuditionList();
      case 2:
        return ActorList(
          genderType: _actorGenderType,
        );
      case 3:
        return KCastingAppData().myInfo[APIConstants.member_type] ==
                APIConstants.member_type_actor
            ? ActorMemberPage()
            : KCastingAppData().myInfo[APIConstants.member_type] ==
                    APIConstants.member_type_product
                ? ProductionMemberPage()
                : AgencyMemberPage();
    }
  }

  void _onTap(int index) {
    setState(() {
      _currentFragmentIndex = index;
    });
  }

  /*
  * 메인 위젯
  * */
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          // 메뉴 열려있는 경우 닫기
          if (_scaffoldKey.currentState.isDrawerOpen) {
            _scaffoldKey.currentState.openEndDrawer();
            return Future.value(false);
          }

          // 메인홈이 아닐 경우 백버튼 입력 시 메인으로 이동
          if (_currentFragmentIndex != 0) {
            _onTap(0);
            return Future.value(false);
          }
          // 메인일 경우 앱 종료
          else {
            DateTime now = DateTime.now();
            if (currentBackPressTime == null ||
                now.difference(currentBackPressTime) > Duration(seconds: 2)) {
              currentBackPressTime = now;

              showSnackBar(context, '뒤로 버튼을 한번 더 누르시면 앱이 종료됩니다.');

              return Future.value(false);
            }
          }

          return Future.value(true);
        },
        child: Align(
            alignment: Alignment.topCenter,
            child: Container(
                width: KCastingAppData().isWeb
                    ? CustomStyles.appWidth
                    : double.infinity,
                child: Scaffold(
                    key: _scaffoldKey,
                    appBar: HomeAppBar(
                      onClickedOpenDrawer: () {
                        _scaffoldKey.currentState.openDrawer();
                      },
                      onClickedOpenHome: () {
                        if (_currentFragmentIndex != 0) {
                          _onTap(0);
                        } else {
                          FragmentHome.globalKey.currentState.scrollToTop();
                        }
                      },
                      onClickedOpenMyPage: () {
                        _onTap(3);
                      },
                    ),
                    // 상단 앱바
                    body: body(),
                    drawer: HomeDrawer(onClickedCloseDrawer: () {
                      _scaffoldKey.currentState.openEndDrawer();
                    }, onClickedOpenHome: () {
                      _onTap(0);
                    }, onClickedOpenCastingBoard: () {
                      _onTap(1);
                    }, onClickedOpenCastingActor: (value) {
                      _actorGenderType = value;
                      _onTap(2);
                    }))))); // 네비게이션 드로어
  }
}
