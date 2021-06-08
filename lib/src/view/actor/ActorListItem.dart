import 'package:cached_network_image/cached_network_image.dart';
import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:casting_call/src/view/actor/ActorDetail.dart';
import 'package:flutter/material.dart';

/*
* 배우 목록 아이템 위젯
* */
class ActorListItem extends StatelessWidget with BaseUtilMixin {
  final bool isMan;
  final Map<String, dynamic> data;

  ActorListItem({Key key, this.isMan, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
            width: MediaQuery.of(context).size.width,
            child: GestureDetector(
                onTap: () {
                  addView(
                      context,
                      ActorDetail(
                          seq: data[APIConstants.seq],
                          actorProfileSeq:
                              data[APIConstants.actor_profile_seq]));
                },
                child: Column(children: <Widget>[
                  Container(
                      decoration:
                          BoxDecoration(color: CustomColors.colorBgGrey),
                      width: (MediaQuery.of(context).size.width / 2),
                      height: (MediaQuery.of(context).size.width / 2),
                      child: data[APIConstants.main_img_url] != null
                          ? ClipRRect(
                              borderRadius: CustomStyles.circle7BorderRadius(),
                              child: CachedNetworkImage(
                                  imageUrl: data[APIConstants.main_img_url],
                                  fit: BoxFit.cover))
                          : null),
                  Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(top: 5),
                      child: Text(
                          StringUtils.checkedString(
                              data[APIConstants.actor_name]),
                          style: CustomStyles.dark20TextStyle()))
                ]))));
  }
}
