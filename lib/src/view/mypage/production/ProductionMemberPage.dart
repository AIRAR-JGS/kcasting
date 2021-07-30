import 'package:cached_network_image/cached_network_image.dart';
import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/KCastingAppData.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/dialog/DialogMemberLogoutConfirm.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:casting_call/src/view/actor/BookmarkedActorList.dart';
import 'package:casting_call/src/view/audition/production/ProposedAuditionList.dart';
import 'package:casting_call/src/view/mypage/production/ProductionMemberInfo.dart';
import 'package:casting_call/src/view/mypage/production/ProductionProfile.dart';
import 'package:casting_call/src/view/project/ProjectList.dart';
import 'package:casting_call/src/view/user/common/Login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductionMemberPage extends StatefulWidget {
  @override
  _ProductionMemberPage createState() => _ProductionMemberPage();
}

class _ProductionMemberPage extends State<ProductionMemberPage>
    with BaseUtilMixin {
  @override
  void initState() {
    super.initState();
  }

  void initData() {
    setState(() {});
  }

  Widget _headerView() {
    return Container(
      child: Column(
        children: [
          Container(
              margin: EdgeInsets.only(top: 30, bottom: 15),
              child: KCastingAppData().myInfo == null
                  ? Icon(
                      Icons.account_circle,
                      color: CustomColors.colorFontLightGrey,
                      size: 100,
                    )
                  : (KCastingAppData()
                              .myInfo[APIConstants.production_img_url] !=
                          null
                      ? ClipOval(
                          child: CachedNetworkImage(
                              placeholder: (context, url) => Container(
                                  alignment: Alignment.center,
                                  child: CircularProgressIndicator()),
                              imageUrl: KCastingAppData()
                                  .myInfo[APIConstants.production_img_url],
                              fit: BoxFit.cover,
                              width: 100.0,
                              height: 100.0,
                              errorWidget: (context, url, error) => Icon(
                                    Icons.account_circle,
                                    color: CustomColors.colorFontLightGrey,
                                    size: 100,
                                  )))
                      : Icon(
                          Icons.account_circle,
                          color: CustomColors.colorFontLightGrey,
                          size: 100,
                        ))),
          Container(
              margin: EdgeInsets.only(bottom: 30),
              child: Text(
                  StringUtils.checkedString(
                      KCastingAppData().myInfo[APIConstants.production_name]),
                  style: CustomStyles.normal32TextStyle())),
        ],
      ),
    );
  }

  Widget _listItemView(int idx) {
    var _mypageMenu = [
      '헤더',
      '프로필 관리',
      '오디션 관리',
      '제안한 오디션',
      '마이 스크랩',
      '개인정보 관리',
      '로그아웃',
      ''
    ];

    return Container(
        padding: EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 10),
        child: Text(_mypageMenu[idx].toString(),
            style: CustomStyles.normal16TextStyle()));
  }

  /*
  * 메인 위젯
  * */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      alignment: Alignment.center,
      child: ListView.separated(
        scrollDirection: Axis.vertical,
        itemCount: 7,
        itemBuilder: (context, index) {
          return (index == 0)
              ? _headerView()
              : GestureDetector(
                  onTap: () {
                    switch (index) {
                      // 프로필 관리
                      case 1:
                        // 프로필 관리 페이지 이동
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProductionProfile()))
                            .then((value) => {initData()});

                        //addView(context, ProductionProfile());
                        break;

                      // 오디션 관리
                      case 2:
                        // 오디션 관리 페이지 이동
                        addView(context, ProjectList());
                        break;

                      // 제안한 오디션
                      case 3:
                        // 제안한 오디션 페이지 이동
                        addView(context, ProposedAuditionList());
                        break;

                      // 마이스크랩
                      case 4:
                        // 마이스크랩 페이지 이동
                        addView(context, BookmarkedActorList());
                        break;

                      // 개인정보 관리
                      case 5:
                        // 개인정보 관리 페이지 이동
                        addView(context, ProductionMemberInfo());
                        break;

                      // 로그아웃
                      case 6:
                        showDialog(
                          context: context,
                          builder: (BuildContext context) =>
                              DialogMemberLogoutConfirm(
                            onClickedAgree: () async {
                              KCastingAppData().clearData();

                              final SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              prefs.remove(APIConstants.autoLogin);
                              prefs.remove(APIConstants.id);
                              prefs.remove(APIConstants.pwd);

                              // 로그인 페이지 이동
                              replaceView(context, Login());
                            },
                          ),
                        );

                        break;

                      default:
                        break;
                    }
                  },
                  child: _listItemView(index),
                );
        },
        separatorBuilder: (context, index) {
          return Divider();
        },
      ),
    ));
  }
}
