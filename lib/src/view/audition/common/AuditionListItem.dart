import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/KCastingAppData.dart';
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
  final bool isMyScrapList;
  final VoidCallback onClickedBookmark;

  AuditionListItem(
      {Key key, this.castingItem, this.isMyScrapList, this.onClickedBookmark})
      : super(key: key);

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
                        width: 0.5, color: CustomColors.colorFontLightGrey),
                    borderRadius: CustomStyles.circle7BorderRadius()),
                child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 15,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(5),
                              topLeft: Radius.circular(5)),
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              stops: [
                                0,
                                1
                              ],
                              colors: [
                                CustomColors.colorPrimary.withAlpha(180),
                                CustomColors.colorAccent.withAlpha(180)
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
                                child: Text(
                                    StringUtils.checkedString(
                                        castingItem[APIConstants.d_day]),
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
                                                      child: Text(
                                                          StringUtils.checkedString(
                                                              castingItem[
                                                                  APIConstants
                                                                      .production_name]),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: CustomStyles
                                                              .darkBold16TextStyle()))
                                                  /*Container(
                                                    width: 60,
                                                      margin: EdgeInsets.only(
                                                          top: 10),
                                                      child: castingItem[
                                                                  APIConstants
                                                                      .production_img_url] !=
                                                              null
                                                          ? ClipRRect(
                                                          child: CachedNetworkImage(
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
                                                                  .fitWidth,
                                                            ))
                                                          : null)*/
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
                            Visibility(
                                child: VerticalDivider(
                                    color: CustomColors.colorFontLightGrey,
                                    width: 0.1,
                                    thickness: 0.5),
                                visible: (KCastingAppData().myInfo[
                                            APIConstants.member_type]) ==
                                        APIConstants.member_type_product
                                    ? false
                                    : true),
                            Visibility(
                                child: GestureDetector(
                                    onTap: () {
                                      onClickedBookmark();
                                    },
                                    child: Container(
                                        width: 30,
                                        margin: EdgeInsets.only(left: 10),
                                        alignment: Alignment.center,
                                        child: isMyScrapList
                                            ? (Image.asset(
                                                'assets/images/toggle_like_on.png',
                                                width: 20,
                                                color: CustomColors.colorAccent
                                                    .withAlpha(200)))
                                            : (KCastingAppData().myInfo[APIConstants.member_type] ==
                                                    APIConstants
                                                        .member_type_actor)
                                                ? ((castingItem[APIConstants.isActorCastringScrap] == 1)
                                                    ? Image.asset(
                                                        'assets/images/toggle_like_on.png',
                                                        width: 20,
                                                        color: CustomColors.colorAccent
                                                            .withAlpha(200))
                                                    : Image.asset(
                                                        'assets/images/toggle_like_off.png',
                                                        width: 20))
                                                : ((castingItem[APIConstants.isManagementCastringScrap] == 1)
                                                    ? Image.asset(
                                                        'assets/images/toggle_like_on.png',
                                                        width: 20,
                                                        color: CustomColors.colorAccent
                                                            .withAlpha(200))
                                                    : Image.asset('assets/images/toggle_like_off.png', width: 20)))),
                                visible: (KCastingAppData().myInfo[APIConstants.member_type]) == APIConstants.member_type_product ? false : true)
                          ]))
                    ]))
          ]),
          Container(
              margin: EdgeInsets.only(right: 10),
              alignment: Alignment.topRight,
              //color: CustomColors.colorFontDarkGrey.withAlpha(240),
              width: 32,
              height: 32,
              child: Stack(children: [
                StringUtils.checkedString(
                            castingItem[APIConstants.project_type]) ==
                        '드라마'
                    ? Image.asset('assets/images/ic_movie.png',
                        color: CustomColors.colorBlack.withAlpha(200))
                    : Image.asset('assets/images/ic_movie.png',
                        color: CustomColors.colorBlack.withAlpha(200)),
                Container(
                    margin: EdgeInsets.only(top: 3),
                    child: Center(
                        child: Text(
                            StringUtils.checkedString(
                                castingItem[APIConstants.project_type]),
                            style: CustomStyles.white10TextStyle(),
                            textAlign: TextAlign.center)))
              ]))
        ]));
  }
}
