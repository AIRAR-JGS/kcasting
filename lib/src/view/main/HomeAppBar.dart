import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/KCastingAppData.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/view/board/PushNotification.dart';
import 'package:flutter/material.dart';

/*
 *  메인 상단 바 (App bar) 클래스
 */
class HomeAppBar extends StatelessWidget
    with BaseUtilMixin
    implements PreferredSizeWidget {
  final VoidCallback onClickedOpenDrawer;
  final VoidCallback onClickedOpenHome;
  final VoidCallback onClickedOpenMyPage;

  HomeAppBar(
      {Key key,
      this.onClickedOpenDrawer,
      this.onClickedOpenHome,
      this.onClickedOpenMyPage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        bottomOpacity: 0.0,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
            decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.topRight,
              colors: [
                CustomColors.colorPrimary,
                CustomColors.colorAccent,
              ]),
        )),

        // 앱 타이틀(로고)
        title: GestureDetector(
          onTap: () {
            onClickedOpenHome();
          },
          child: Padding(
              padding: EdgeInsets.zero,
              child: Image.asset('assets/images/logo_white.png', width: 80)),
        ),
        centerTitle: true,

        // 메뉴 버튼
        leading: IconButton(
          icon: Image.asset('assets/images/btn_menu.png', width: 24),
          onPressed: () {
            onClickedOpenDrawer();
          },
        ),

        // 앱 오른쪽 상단 액션 버튼
        actions: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 알림 버튼
              Container(
                  width: 25,
                  height: 25,
                  margin: EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.all(0.0),
                  child: GestureDetector(
                      onTap: () {
                        addView(context, PushNotification());
                      },
                      child: (KCastingAppData()
                                      .myInfo[APIConstants.newAlertCnt] !=
                                  null &&
                              KCastingAppData()
                                      .myInfo[APIConstants.newAlertCnt] >
                                  0)
                          ? Badge(
                              badgeContent: Text(
                                  KCastingAppData()
                                      .myInfo[APIConstants.newAlertCnt]
                                      .toString(),
                                  style: TextStyle(color: Colors.white)),
                              badgeColor: CustomColors.colorAccent,
                              child: Image.asset('assets/images/btn_push.png',
                                  fit: BoxFit.fitHeight))
                          : Image.asset('assets/images/btn_push.png',
                              fit: BoxFit.fitHeight))),

              // 마이페이지 버튼
              Container(
                  width: 27,
                  height: 27,
                  margin: EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.all(0.0),
                  child: GestureDetector(
                      onTap: () {
                        onClickedOpenMyPage();
                      },
                      child: KCastingAppData().myInfo[APIConstants.member_type] ==
                              APIConstants.member_type_actor
                          ? (KCastingAppData().myProfile != null
                              ? (KCastingAppData().myProfile[APIConstants.main_img_url] != null
                                  ? ClipOval(
                                      child: CachedNetworkImage(
                                          imageUrl: KCastingAppData().myProfile[
                                              APIConstants.main_img_url],
                                          fit: BoxFit.cover,
                                          errorWidget: (context, url, error) =>
                                              Image.asset('assets/images/btn_mypage.png',
                                                  fit: BoxFit.fitHeight)))
                                  : Image.asset('assets/images/btn_mypage.png',
                                      fit: BoxFit.fitHeight))
                              : Image.asset('assets/images/btn_mypage.png',
                                  fit: BoxFit.fitHeight))
                          : KCastingAppData().myInfo[APIConstants.member_type] ==
                                  APIConstants.member_type_product
                              ? (KCastingAppData().myInfo != null ? (KCastingAppData().myInfo[APIConstants.production_img_url] != null ? ClipOval(child: CachedNetworkImage(imageUrl: KCastingAppData().myInfo[APIConstants.production_img_url], fit: BoxFit.cover, width: 40.0, height: 40.0, errorWidget: (context, url, error) => Image.asset('assets/images/btn_mypage.png', fit: BoxFit.fitHeight))) : Image.asset('assets/images/btn_mypage.png', fit: BoxFit.fitHeight)) : Image.asset('assets/images/btn_mypage.png', fit: BoxFit.fitHeight))
                              : (KCastingAppData().myInfo != null ? (KCastingAppData().myInfo[APIConstants.management_logo_img_url] != null ? ClipOval(child: CachedNetworkImage(imageUrl: KCastingAppData().myInfo[APIConstants.management_logo_img_url], fit: BoxFit.cover, width: 40.0, height: 40.0, errorWidget: (context, url, error) => Image.asset('assets/images/btn_mypage.png', fit: BoxFit.fitHeight))) : Image.asset('assets/images/btn_mypage.png', fit: BoxFit.fitHeight)) : Image.asset('assets/images/btn_mypage.png', fit: BoxFit.fitHeight))))
            ],
          )
        ]);
  }

  @override
  Size get preferredSize => new Size.fromHeight(kToolbarHeight);
}
