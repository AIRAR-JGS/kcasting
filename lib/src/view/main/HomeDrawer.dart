import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';

/*
 *  메인 드로어 메뉴 클래스
 */
class HomeDrawer extends StatelessWidget {
  final VoidCallback onClickedCloseDrawer;

  final VoidCallback onClickedOpenHome;
  final VoidCallback onClickedOpenCastingBoard;
  final Function(String) onClickedOpenCastingActor;

  HomeDrawer(
      {Key key,
      this.onClickedCloseDrawer,
      this.onClickedOpenHome,
      this.onClickedOpenCastingBoard,
      this.onClickedOpenCastingActor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Container(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Drawer(
            child: Column(children: [
          Container(
              margin: EdgeInsets.only(top: 50, right: 15),
              alignment: Alignment.centerRight,
              child: GestureDetector(
                  onTap: () {
                    onClickedCloseDrawer();
                  },
                  child: Image.asset('assets/images/btn_close.png',
                      fit: BoxFit.contain,
                      color: CustomColors.colorFontTitle,
                      width: 20))),
          Container(
              margin: EdgeInsets.only(top: 30, left: 10, right: 10),
              padding: EdgeInsets.only(left: 10, right: 10),
              height: 50,
              decoration: BoxDecoration(
                  borderRadius: CustomStyles.circle7BorderRadius(),
                  border: Border.all(
                      width: 1, color: CustomColors.colorFontLightGrey)),
              child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                        child: TextField(
                            decoration: InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 0),
                                hintText: "배역을 검색해보세요",
                                hintStyle: CustomStyles.normal16TextStyle()),
                            style: CustomStyles.dark16TextStyle())),
                    Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: GestureDetector(
                            onTap: () {
                              onClickedOpenCastingBoard();
                              Navigator.pop(context);
                            },
                            child: Image.asset('assets/images/btn_search.png',
                                width: 20, fit: BoxFit.contain)))
                  ])),
          Container(
              margin: EdgeInsets.only(top: 30, bottom: 20),
              child:
                  Divider(height: 0.1, color: CustomColors.colorFontLightGrey)),
          GestureDetector(
              onTap: () {
                onClickedOpenHome();
                Navigator.pop(context);
              },
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 15, right: 15),
                  child: Text('홈', style: CustomStyles.normal16TextStyle()))),
          Container(
              margin: EdgeInsets.only(top: 20, bottom: 20),
              child:
                  Divider(height: 0.1, color: CustomColors.colorFontLightGrey)),
          GestureDetector(
              onTap: () {
                onClickedOpenCastingBoard();
                Navigator.pop(context);
              },
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 15, right: 15),
                  child:
                      Text('캐스팅 보드', style: CustomStyles.normal16TextStyle()))),
          Container(
              margin: EdgeInsets.only(top: 20, bottom: 20),
              child:
                  Divider(height: 0.1, color: CustomColors.colorFontLightGrey)),
          GestureDetector(
              onTap: () {
                onClickedOpenCastingActor(null);
                Navigator.pop(context);
              },
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 15, right: 15),
                  child:
                      Text('배우 캐스팅', style: CustomStyles.normal16TextStyle()))),
          Container(
            margin: EdgeInsets.only(top: 20, bottom: 20),
            child: Divider(height: 0.1, color: CustomColors.colorFontLightGrey),
          ),
          /*GestureDetector(
              onTap: () async {
                await LaunchApp.openApp(
                    androidPackageName: 'us.zoom.videomeetings',
                    openStore: false,
                    appStoreLink:
                        'https://play.google.com/store/apps/details?id=us.zoom.videomeetings&hl=ko&gl=US');
              },
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 15, right: 15),
                  child:
                      Text('영상회의', style: CustomStyles.normal16TextStyle()))),
          Container(
              margin: EdgeInsets.only(top: 20, bottom: 20),
              child:
                  Divider(height: 0.1, color: CustomColors.colorFontLightGrey))*/
        ])));
  }
}
