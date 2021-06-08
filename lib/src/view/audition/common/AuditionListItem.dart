import 'package:cached_network_image/cached_network_image.dart';
import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:flutter/material.dart';

import 'AuditionDetail.dart';

/*
* 캐스팅보드 목록 아이템 위젯
* */
class AuditionListItem extends StatelessWidget with BaseUtilMixin {
  final Map<String, dynamic> castingItem;

  AuditionListItem({Key key, this.castingItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          addView(
              context,
              AuditionDetail(
                  castingSeq: castingItem[APIConstants.casting_seq]));
        },
        child: Stack(alignment: Alignment.topRight, children: [
          Wrap(children: [
            Container(
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                    border: Border.all(
                        width: 1, color: CustomColors.colorFontLightGrey)),
                child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 15,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              stops: [
                                0,
                                1
                              ],
                              colors: [
                                CustomColors.colorAccent,
                                CustomColors.colorBgGrey
                              ]),
                        ),
                      ),
                      Container(
                        height: 70,
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Container(
                                  padding: EdgeInsets.only(left: 10, right: 10),
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                          margin: EdgeInsets.only(bottom: 5),
                                          child: Text(
                                              StringUtils.checkedString(
                                                  castingItem[APIConstants
                                                      .project_name]),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: CustomStyles
                                                  .dark12TextStyle())),
                                      Text(
                                          StringUtils.checkedString(castingItem[
                                              APIConstants.casting_name]),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: CustomStyles
                                              .darkBold24TextStyle())
                                    ],
                                  )),
                            ),
                            Container(
                                margin: EdgeInsets.only(top: 18, right: 10),
                                alignment: Alignment.center,
                                child: Text('D-0',
                                    style: CustomStyles.normal14TextStyle()))
                          ],
                        ),
                      ),
                      Divider(
                        height: 0.1,
                        color: CustomColors.colorFontLightGrey,
                      ),
                      Container(
                          height: 50,
                          child: Row(children: [
                            Expanded(
                                flex: 0,
                                child: Container(
                                    padding:
                                        EdgeInsets.only(left: 10, right: 10),
                                    child: FittedBox(
                                        fit: BoxFit.fitWidth,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                  child: Text('배역',
                                                      style: CustomStyles
                                                          .dark10TextStyle())),
                                              Container(
                                                  margin:
                                                      EdgeInsets.only(top: 10),
                                                  child: Text(
                                                      StringUtils.checkedString(
                                                          castingItem[APIConstants
                                                              .casting_type]),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: CustomStyles
                                                          .darkBold16TextStyle()))
                                            ])))),
                            VerticalDivider(
                                color: CustomColors.colorFontLightGrey,
                                width: 0.1,
                                thickness: 0.5),
                            Expanded(
                                flex: 0,
                                child: Container(
                                    padding:
                                        EdgeInsets.only(left: 10, right: 10),
                                    child: FittedBox(
                                        fit: BoxFit.fitWidth,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                  child: Text('성별',
                                                      style: CustomStyles
                                                          .dark10TextStyle())),
                                              Container(
                                                  margin:
                                                      EdgeInsets.only(top: 10),
                                                  child: Text(
                                                      StringUtils.checkedString(
                                                          castingItem[
                                                              APIConstants
                                                                  .sex_type]),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: CustomStyles
                                                          .darkBold16TextStyle()))
                                            ])))),
                            VerticalDivider(
                                color: CustomColors.colorFontLightGrey,
                                width: 0.1,
                                thickness: 0.5),
                            Expanded(
                                flex: 0,
                                child: Container(
                                    padding:
                                        EdgeInsets.only(left: 10, right: 10),
                                    child: FittedBox(
                                        fit: BoxFit.fitWidth,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                  child: Text('나이',
                                                      style: CustomStyles
                                                          .dark10TextStyle())),
                                              Container(
                                                  margin:
                                                      EdgeInsets.only(top: 10),
                                                  child: RichText(
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      text: (castingItem[APIConstants
                                                                      .casting_min_age] ==
                                                                  null &&
                                                              castingItem[APIConstants
                                                                      .casting_max_age] ==
                                                                  null)
                                                          ? new TextSpan(
                                                              text: "무관",
                                                              style: CustomStyles
                                                                  .darkBold16TextStyle(),
                                                            )
                                                          : new TextSpan(
                                                              style: CustomStyles
                                                                  .dark16TextStyle(),
                                                              children: <
                                                                  TextSpan>[
                                                                  new TextSpan(
                                                                      text: StringUtils
                                                                          .checkedString(
                                                                              castingItem[APIConstants.casting_min_age])),
                                                                  new TextSpan(
                                                                      text:
                                                                          '이상~',
                                                                      style: CustomStyles
                                                                          .dark12TextStyle()),
                                                                  new TextSpan(
                                                                      text: StringUtils
                                                                          .checkedString(
                                                                              castingItem[APIConstants.casting_max_age])),
                                                                  new TextSpan(
                                                                      text:
                                                                          '이하',
                                                                      style: CustomStyles
                                                                          .dark12TextStyle())
                                                                ])))
                                            ])))),
                            VerticalDivider(
                                color: CustomColors.colorFontLightGrey,
                                width: 0.1,
                                thickness: 0.5),
                            Expanded(
                                flex: 0,
                                child: Visibility(
                                    child: Container(
                                        padding: EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: FittedBox(
                                            fit: BoxFit.fitWidth,
                                            child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                      child: Text('제작사',
                                                          style: CustomStyles
                                                              .dark10TextStyle())),
                                                  Container(
                                                      margin: EdgeInsets.only(
                                                          top: 10),
                                                      child: castingItem[
                                                                  APIConstants
                                                                      .production_img_url] !=
                                                              null
                                                          ? CachedNetworkImage(
                                                              imageUrl: castingItem[
                                                                  APIConstants
                                                                      .production_img_url],
                                                              errorWidget: (context,
                                                                      url,
                                                                      error) =>
                                                                  Text("",
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style: CustomStyles
                                                                          .darkBold16TextStyle()),
                                                              height: 15,
                                                              fit: BoxFit
                                                                  .contain,
                                                            )
                                                          : null)
                                                ]))),
                                    visible: castingItem[APIConstants
                                                .production_img_url] !=
                                            null
                                        ? true
                                        : false))
                          ])),
                      Divider(
                          height: 0.0,
                          thickness: 0.5,
                          color: CustomColors.colorFontLightGrey),
                      Container(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          height: 40,
                          child: Row(children: [
                            Expanded(
                                flex: 1,
                                child: Container(
                                    child: RichText(
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        text: new TextSpan(
                                            style:
                                                CustomStyles.dark16TextStyle(),
                                            children: <TextSpan>[
                                              new TextSpan(
                                                  text: "특징\t\t",
                                                  style: CustomStyles
                                                      .dark8TextStyle()),
                                              new TextSpan(
                                                  text: StringUtils.checkedString(
                                                      castingItem[APIConstants
                                                          .casting_uniqueness]))
                                            ])))),
                            VerticalDivider(
                                color: CustomColors.colorFontLightGrey,
                                width: 0.1,
                                thickness: 0.5),
                            Container(
                                width: 30,
                                margin: EdgeInsets.only(left: 10),
                                alignment: Alignment.center,
                                child: Image.asset(
                                    'assets/images/toggle_like_off.png',
                                    width: 20))
                          ]))
                    ]))
          ]),
          Container(
              margin: EdgeInsets.only(right: 20),
              alignment: Alignment.center,
              color: CustomColors.colorFontDarkGrey,
              width: 50,
              height: 30,
              child: Text(
                  StringUtils.checkedString(
                      castingItem[APIConstants.project_type]),
                  style: CustomStyles.white10TextStyle()))
        ]));
  }
}
