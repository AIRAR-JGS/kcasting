import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/ui/DecoratedTabBar.dart';
import 'package:casting_call/src/ui/ImageView.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:casting_call/src/view/mypage/actor/ActorFilmoListItem.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../KCastingAppData.dart';

/*
* 배우 프로필 관련 위젯 모음
* */
class ActorProfileWidget {
  /*
  * 배우 메인 이미지
  * */
  static Widget mainImageWidget(
      BuildContext context,
      bool isEditable,
      Map<String, dynamic> actorProfile,
      VoidCallback onClickGetImageFromGallery) {
    return isEditable
        ? Stack(alignment: Alignment.bottomRight, children: [
            Container(
                width: (KCastingAppData().isWeb)
                    ? CustomStyles.appWidth
                    : MediaQuery.of(context).size.width,
                height: (KCastingAppData().isWeb)
                    ? CustomStyles.appWidth * 0.625
                    : MediaQuery.of(context).size.width * 0.625,
                decoration: BoxDecoration(color: CustomColors.colorBgGrey),
                child: (actorProfile == null ||
                        actorProfile[APIConstants.main_img_url] == null)
                    ? Container(
                        alignment: Alignment.center,
                        child: Text('대표 이미지를 등록해 주세요.',
                            style: CustomStyles.dark20TextStyle()),
                      )
                    : CachedNetworkImage(
                        placeholder: (context, url) => Container(
                            alignment: Alignment.center,
                            child: CircularProgressIndicator()),
                        imageUrl: actorProfile[APIConstants.main_img_url],
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(
                              alignment: Alignment.center,
                              child: Text('대표 이미지를 등록해 주세요.',
                                  style: CustomStyles.dark20TextStyle()),
                            ))),
            Container(
                padding: EdgeInsets.all(5),
                child: GestureDetector(
                    onTap: () async {
                      try {
                        if (Platform.isAndroid || Platform.isIOS) {
                          var status = Platform.isAndroid
                              ? await Permission.storage.request()
                              : await Permission.photos.request();
                          if (status.isGranted) {
                            onClickGetImageFromGallery();
                          } else {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    CupertinoAlertDialog(
                                        title: Text('저장공간 접근권한'),
                                        content: Text(
                                            '사진 또는 비디오를 업로드하려면, 기기 사진, 미디어, 파일 접근 권한이 필요합니다.'),
                                        actions: <Widget>[
                                          CupertinoDialogAction(
                                            child: Text('거부'),
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                          ),
                                          CupertinoDialogAction(
                                            child: Text('허용'),
                                            onPressed: () => openAppSettings(),
                                          )
                                        ]));
                          }
                        } else {
                          onClickGetImageFromGallery();
                        }
                      } catch (e) {
                        onClickGetImageFromGallery();
                      }
                    },
                    child: Icon(Icons.camera_alt,
                        color: CustomColors.colorWhite, size: 30)))
          ])
        : Container(
            width: (KCastingAppData().isWeb)
                ? CustomStyles.appWidth
                : MediaQuery.of(context).size.width,
            height: (KCastingAppData().isWeb)
                ? CustomStyles.appWidth * 0.625
                : MediaQuery.of(context).size.width * 0.625,
            decoration: BoxDecoration(color: CustomColors.colorBgGrey),
            child: actorProfile[APIConstants.main_img_url] != null
                ? CachedNetworkImage(
                    placeholder: (context, url) => Container(
                        alignment: Alignment.center,
                        child: CircularProgressIndicator()),
                    imageUrl: actorProfile[APIConstants.main_img_url],
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container())
                : null,
          );
  }

  /*
  * 프로필 위젯
  * */
  static Widget profileWidget(
      BuildContext context,
      GlobalKey<TagsState> myKeywordTagStateKey,
      Map<String, dynamic> actorProfile,
      String actorAgeStr,
      String actorEducationStr,
      String actorLanguageStr,
      String actorDialectStr,
      String actorAbilityStr,
      List<String> actorKwdList) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          margin: EdgeInsets.only(top: 30.0),
          padding: EdgeInsets.only(left: 15, right: 15),
          child: Text(
              StringUtils.checkedString(actorProfile[APIConstants.actor_name]),
              style: CustomStyles.normal32TextStyle())),
      Container(
          margin: EdgeInsets.only(top: 15),
          padding: EdgeInsets.only(left: 15, right: 15),
          child: Text(
              StringUtils.checkedString(
                  actorProfile[APIConstants.actor_Introduce]),
              style: CustomStyles.normal16TextStyle())),
      Container(
          padding: EdgeInsets.only(left: 15, right: 15),
          margin: EdgeInsets.only(top: 20.0),
          child: Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Container(
                      child: Text('드라마페이',
                          style: CustomStyles.normal14TextStyle()))),
              Expanded(
                  flex: 7,
                  child: Container(
                      child: Text(
                          StringUtils.checkedString(
                                  actorProfile[APIConstants.actor_drama_pay]) +
                              "만원",
                          style: CustomStyles.normal14TextStyle())))
            ],
          )),
      Container(
          padding: EdgeInsets.only(left: 15, right: 15),
          margin: EdgeInsets.only(top: 10.0),
          child: Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Container(
                      child: Text('영화페이',
                          style: CustomStyles.normal14TextStyle()))),
              Expanded(
                  flex: 7,
                  child: Container(
                      child: Text(
                          StringUtils.checkedString(
                                  actorProfile[APIConstants.actor_movie_pay]) +
                              "만원",
                          style: CustomStyles.normal14TextStyle())))
            ],
          )),
      Container(
          padding: EdgeInsets.only(left: 15, right: 15),
          margin: EdgeInsets.only(top: 10.0),
          child: Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Container(
                      child: Text('생년월일',
                          style: CustomStyles.normal14TextStyle()))),
              Expanded(
                  flex: 7,
                  child: Container(
                      child: Text(
                          StringUtils.checkedString(
                              actorProfile[APIConstants.actor_birth]),
                          style: CustomStyles.normal14TextStyle())))
            ],
          )),
      Container(
          padding: EdgeInsets.only(left: 15, right: 15),
          margin: EdgeInsets.only(top: 10.0),
          child: Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Container(
                      child:
                          Text('키', style: CustomStyles.normal14TextStyle()))),
              Expanded(
                  flex: 7,
                  child: Container(
                      child: Text(
                          StringUtils.checkedString(
                                  actorProfile[APIConstants.actor_tall]) +
                              "cm",
                          style: CustomStyles.normal14TextStyle())))
            ],
          )),
      Container(
          padding: EdgeInsets.only(left: 15, right: 15),
          margin: EdgeInsets.only(top: 10.0),
          child: Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Container(
                      child:
                          Text('체중', style: CustomStyles.normal14TextStyle()))),
              Expanded(
                  flex: 7,
                  child: Container(
                      child: Text(
                          StringUtils.checkedString(
                                  actorProfile[APIConstants.actor_weight]) +
                              "kg",
                          style: CustomStyles.normal14TextStyle())))
            ],
          )),
      Container(
          padding: EdgeInsets.only(left: 15, right: 15),
          margin: EdgeInsets.only(top: 10.0),
          child: Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Container(
                      child: Text('전공여부',
                          style: CustomStyles.normal14TextStyle()))),
              Expanded(
                  flex: 7,
                  child: Container(
                      child: Text(
                          actorProfile[APIConstants.actor_major_isAuth] == 0
                              ? "비전공"
                              : "전공",
                          style: CustomStyles.normal14TextStyle())))
            ],
          )),
      Container(
          padding: EdgeInsets.only(left: 15, right: 15),
          margin: EdgeInsets.only(top: 10.0),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                flex: 3,
                child: Container(
                    child:
                        Text('학력사항', style: CustomStyles.normal14TextStyle()))),
            Expanded(
                flex: 7,
                child: Container(
                    child: Text(actorEducationStr,
                        style: CustomStyles.normal14TextStyle())))
          ])),
      Container(
          padding: EdgeInsets.only(left: 15, right: 15),
          margin: EdgeInsets.only(top: 10.0),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                flex: 3,
                child: Container(
                    child:
                        Text('언어', style: CustomStyles.normal14TextStyle()))),
            Expanded(
                flex: 7,
                child: Container(
                    child: Text(actorLanguageStr,
                        style: CustomStyles.normal14TextStyle())))
          ])),
      Container(
          padding: EdgeInsets.only(left: 15, right: 15),
          margin: EdgeInsets.only(top: 10.0),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                flex: 3,
                child: Container(
                    child:
                        Text('사투리', style: CustomStyles.normal14TextStyle()))),
            Expanded(
                flex: 7,
                child: Container(
                    child: Text(actorDialectStr,
                        style: CustomStyles.normal14TextStyle())))
          ])),
      Container(
          padding: EdgeInsets.only(left: 15, right: 15),
          margin: EdgeInsets.only(top: 10.0),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                flex: 3,
                child: Container(
                    child:
                        Text('특기', style: CustomStyles.normal14TextStyle()))),
            Expanded(
                flex: 7,
                child: Container(
                    child: Text(actorAbilityStr,
                        style: CustomStyles.normal14TextStyle())))
          ])),
      Container(
          padding: EdgeInsets.only(left: 15, right: 15),
          margin: EdgeInsets.only(top: 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  flex: 3,
                  child: Container(
                      child: Text('키워드',
                          style: CustomStyles.normal14TextStyle()))),
              Expanded(
                flex: 7,
                child: Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.only(bottom: 10),
                  padding: EdgeInsets.only(
                    right: 15,
                  ),
                  child: Tags(
                    runSpacing: 5,
                    spacing: 1.5,
                    alignment: WrapAlignment.start,
                    runAlignment: WrapAlignment.start,
                    key: myKeywordTagStateKey,
                    itemCount: actorKwdList.length,
                    // required
                    itemBuilder: (int index) {
                      final item = actorKwdList[index];
                      return ItemTags(
                        textStyle: CustomStyles.dark14TextStyle(),
                        textColor: CustomColors.colorFontTitle,
                        activeColor: CustomColors.colorBgGrey,
                        color: CustomColors.colorBgGrey,
                        key: Key(index.toString()),
                        index: index,
                        title: item,
                        active: false,
                        pressEnabled: false,
                        padding: EdgeInsets.only(
                            left: 7, right: 7, top: 3, bottom: 5),
                        combine: ItemTagsCombine.withTextBefore,
                        elevation: 0.0,
                        borderRadius: BorderRadius.circular(3),
                      );
                    },
                  ),
                ),
              )
            ],
          ))
    ]);
  }

  /*
  * 프로필 탭바 위젯
  * */
  static Widget profileTabBarWidget(TabController tabController) {
    return Container(
        child: DecoratedTabBar(
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: CustomColors.colorBgGrey, width: 1.0))),
      tabBar: TabBar(
          controller: tabController,
          indicatorPadding: EdgeInsets.zero,
          labelStyle: CustomStyles.bold14TextStyle(),
          indicatorColor: CustomColors.colorAccent.withAlpha(200),
          indicatorWeight: 3,
          labelColor: CustomColors.colorFontTitle,
          unselectedLabelStyle: CustomStyles.normal14TextStyle(),
          tabs: [
            Tab(text: '필모그래피'),
            Tab(text: '이미지'),
            Tab(text: '비디오'),
          ]),
    ));
  }

  /*
  * 프로필 탭바 아이템 필모그래피
  * */
  static Widget filmorgraphyListWidget(bool isEditMode,
      List<dynamic> actorFilmorgraphy, Function(int) onClickEvent) {
    return Wrap(children: [
      ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 10, right: 10),
          itemCount: actorFilmorgraphy.length,
          itemBuilder: (context, index) {
            final item = actorFilmorgraphy[index];

            return isEditMode
                ? Dismissible(
                    direction: DismissDirection.endToStart,
                    key: Key(item[APIConstants.seq].toString()),
                    onDismissed: (direction) {
                      onClickEvent(index);
                    },
                    background: Container(
                        width: (KCastingAppData().isWeb)
                            ? CustomStyles.appWidth
                            : MediaQuery.of(context).size.width,
                        alignment: Alignment.centerRight,
                        color: CustomColors.colorWhite,
                        child: Container(
                            width: 60,
                            padding: EdgeInsets.all(10),
                            alignment: Alignment.center,
                            height: double.infinity,
                            color: CustomColors.colorRed,
                            child: Icon(
                              Icons.delete,
                              color: CustomColors.colorWhite,
                            ))),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                              margin: EdgeInsets.only(bottom: 10),
                              child: Divider(
                                height: 0.1,
                                color: CustomColors.colorFontLightGrey,
                              )),
                          ActorFilmoListItem(
                              idx: index,
                              data: actorFilmorgraphy[index],
                              isEditMode: true,
                              onClickEvent: () {
                                onClickEvent(index);
                              })
                        ]))
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                        Container(
                            margin: EdgeInsets.only(bottom: 10),
                            child: Divider(
                              height: 0.1,
                              color: CustomColors.colorFontLightGrey,
                            )),
                        ActorFilmoListItem(
                            idx: index,
                            data: actorFilmorgraphy[index],
                            isEditMode: false,
                            onClickEvent: () {})
                      ]);
          })
    ]);
  }

  /*
  * 프로필 탭바 아이템 필모그래피 이미지
  * */
  static Widget imageTabItemWidget(bool isEditMode,
      List<dynamic> actorImageList, Function(int) onClickEvent) {
    return Container(
        margin: EdgeInsets.only(bottom: 30, top: 15),
        child: Column(children: [
          StaggeredGridView.countBuilder(
            padding: EdgeInsets.only(left: 15, right: 15),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            itemCount: actorImageList.length,
            itemBuilder: (BuildContext context, int index) {
              return isEditMode
                  ? Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Container(
                          child: (actorImageList != null &&
                                  actorImageList.length > 0)
                              ? ClipRRect(
                                  borderRadius:
                                      CustomStyles.circle4BorderRadius(),
                                  child: CachedNetworkImage(
                                      placeholder: (context, url) => Container(
                                          alignment: Alignment.center,
                                          child: CircularProgressIndicator()),
                                      imageUrl: actorImageList[index]
                                          [APIConstants.actor_img_url],
                                      fit: BoxFit.cover,
                                      errorWidget: (context, url, error) =>
                                          ClipRRect(
                                              borderRadius: CustomStyles
                                                  .circle4BorderRadius())))
                              : ClipRRect(
                                  borderRadius:
                                      CustomStyles.circle4BorderRadius()),
                        ),
                        GestureDetector(
                            onTap: () {
                              onClickEvent(index);
                            },
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: new BoxDecoration(
                                  color: CustomColors.colorFontTitle,
                                  borderRadius: new BorderRadius.only(
                                    topRight: const Radius.circular(4.0),
                                  )),
                              width: 30,
                              height: 30,
                              child: Image.asset(
                                'assets/images/btn_close.png',
                                width: 15,
                              ),
                            ))
                      ],
                    )
                  : GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ImageView(
                                  imgURL: actorImageList[index]
                                      [APIConstants.actor_img_url])),
                        );
                      },
                      child: Container(
                        child: (actorImageList != null &&
                                actorImageList.length > 0)
                            ? ClipRRect(
                                borderRadius:
                                    CustomStyles.circle4BorderRadius(),
                                child: CachedNetworkImage(
                                    placeholder: (context, url) => Container(
                                        alignment: Alignment.center,
                                        child: CircularProgressIndicator()),
                                    imageUrl: actorImageList[index]
                                        [APIConstants.actor_img_url],
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) =>
                                        ClipRRect(
                                            borderRadius: CustomStyles
                                                .circle4BorderRadius())))
                            : ClipRRect(
                                borderRadius:
                                    CustomStyles.circle4BorderRadius()),
                      ),
                    );
            },
            staggeredTileBuilder: (int index) => new StaggeredTile.fit(2),
            mainAxisSpacing: 5.0,
            crossAxisSpacing: 5.0,
          )
        ]));
  }

  /*
  * 프로필 탭바 아이템 필모그래피 비디오
  * */
  static Widget videoTabItemWidget(bool isEditMode,
      List<dynamic> actorVideoList, Function(int) onClickEvent) {
    return Container(
        margin: EdgeInsets.only(bottom: 30, top: 15),
        child: Column(children: [
          Wrap(children: [
            ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.only(left: 15, right: 15, bottom: 10),
                physics: NeverScrollableScrollPhysics(),
                itemCount: actorVideoList.length,
                itemBuilder: (context, index) {
                  return isEditMode
                      ? Stack(
                          alignment: Alignment.topRight,
                          children: <Widget>[
                            Container(
                              width: (KCastingAppData().isWeb)
                                  ? CustomStyles.appWidth
                                  : MediaQuery.of(context).size.width,
                              margin: EdgeInsets.only(bottom: 10),
                              height: 200,
                              child: ClipRRect(
                                  borderRadius:
                                      CustomStyles.circle7BorderRadius(),
                                  child: CachedNetworkImage(
                                      placeholder: (context, url) => Container(
                                          alignment: Alignment.center,
                                          child: CircularProgressIndicator()),
                                      imageUrl: actorVideoList[index]
                                          [APIConstants.actor_video_url_thumb],
                                      fit: BoxFit.cover,
                                      errorWidget: (context, url, error) =>
                                          ClipRRect(
                                              borderRadius: CustomStyles
                                                  .circle4BorderRadius()))),
                            ),
                            GestureDetector(
                                onTap: () {
                                  onClickEvent(index);
                                },
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: new BoxDecoration(
                                      color: CustomColors.colorFontTitle,
                                      borderRadius: new BorderRadius.only(
                                        topRight: const Radius.circular(4.0),
                                      )),
                                  width: 30,
                                  height: 30,
                                  child: Image.asset(
                                    'assets/images/btn_close.png',
                                    width: 15,
                                  ),
                                ))
                          ],
                        )
                      : Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            Container(
                              width: (KCastingAppData().isWeb)
                                  ? CustomStyles.appWidth
                                  : MediaQuery.of(context).size.width,
                              margin: EdgeInsets.only(bottom: 10),
                              height: 200,
                              child: ClipRRect(
                                  borderRadius:
                                      CustomStyles.circle7BorderRadius(),
                                  child: CachedNetworkImage(
                                      placeholder: (context, url) => Container(
                                          alignment: Alignment.center,
                                          child: CircularProgressIndicator()),
                                      imageUrl: actorVideoList[index]
                                          [APIConstants.actor_video_url_thumb],
                                      fit: BoxFit.cover,
                                      errorWidget: (context, url, error) =>
                                          ClipRRect(
                                              borderRadius: CustomStyles
                                                  .circle4BorderRadius()))),
                            ),
                            GestureDetector(
                              onTap: () async {
                                /*Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => VideoView(
                                          videoURL: actorVideoList[index]
                                          [APIConstants.actor_video_url])),
                                );*/

                                String _url = actorVideoList[index]
                                    [APIConstants.actor_video_url];
                                await canLaunch(_url)
                                    ? await launch(_url)
                                    : throw '$_url을 열 수 없습니다.';
                              },
                              child: Image.asset('assets/images/btn_play.png',
                                  width: 50),
                            ),
                          ],
                        );
                  //return VideosListItem(videoId: _myVideos[index]);
                },
                separatorBuilder: (context, index) {
                  return VerticalDivider();
                })
          ])
        ]));
  }
}
