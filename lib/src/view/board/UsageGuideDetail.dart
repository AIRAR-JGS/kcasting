import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:flutter/material.dart';

class UsageGuideDetail extends StatefulWidget {
  @override
  _UsageGuideDetail createState() => _UsageGuideDetail();
}

class _UsageGuideDetail extends State<UsageGuideDetail> with BaseUtilMixin {
  @override
  void initState() {
    super.initState();
  }

  /*
  * 메인위젯
  * */
  @override
  Widget build(BuildContext context) {
    return Theme(
        data: CustomStyles.defaultTheme(),
        child: Scaffold(
            appBar: CustomStyles.defaultAppBar('', () {
              Navigator.pop(context);
            }),
            body: SingleChildScrollView(
                child: Container(
                    padding: EdgeInsets.only(
                        left: 15, right: 15, top: 30, bottom: 30),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              margin: EdgeInsets.only(bottom: 15),
                              padding: EdgeInsets.only(left: 15, right: 15),
                              child: Text("배우 이용안내",
                                  style: CustomStyles.bold16TextStyle())),
                          Container(
                              padding: EdgeInsets.only(left: 15, right: 15),
                              child: Divider(
                                  height: 2,
                                  color: CustomColors.colorFontTitle)),
                          Container(
                              margin: EdgeInsets.only(
                                  left: 20, right: 20, bottom: 15, top: 20),
                              child: Text("제목 영역",
                                  style: CustomStyles.darkBold20TextStyle())),
                          Container(
                              margin: EdgeInsets.only(
                                  left: 20, right: 20, bottom: 25),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("등록일: 2021.02.01",
                                      style: CustomStyles.normal14TextStyle()),
                                  Text("조회수: 1111",
                                      style: CustomStyles.normal14TextStyle())
                                ],
                              )),
                          Container(
                              padding: EdgeInsets.only(left: 15, right: 15),
                              child: Divider(
                                  height: 2,
                                  color: CustomColors.colorFontTitle)),
                          Container(
                              margin: EdgeInsets.only(
                                  left: 20, right: 20, bottom: 15, top: 20),
                              child: Text("본문 영역\n본문 영역\n본문 영역\n본문 영역\n본문 영역\n본문 영역\n본문 영역\n본문 영역\n본문 영역\n본문 영역\n본문 영역\n본문 영역\n본문 영역\n본문 영역\n본문 영역\n본문 영역\n본문 영역\n본문 영역\n본문 영역\n본문 영역\n본문 영역\n본문 영역\n본문 영역\n본문 영역\n본문 영역\n본문 영역\n본문 영역\n본문 영역\n본문 영역\n본문 영역\n",
                                  style: CustomStyles.dark14TextStyle())),
                        ])))));
  }
}
