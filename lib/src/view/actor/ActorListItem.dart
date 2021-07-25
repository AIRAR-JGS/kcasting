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
class ActorListItem extends StatefulWidget {
  final Map<String, dynamic> data;
  final VoidCallback onClickedBookmark;

  const ActorListItem({Key key, this.data, this.onClickedBookmark})
      : super(key: key);

  @override
  _ActorListItem createState() => _ActorListItem();
}

class _ActorListItem extends State<ActorListItem> with BaseUtilMixin {
  Map<String, dynamic> _data;
  VoidCallback _onClickedBookmark;

  @override
  void initState() {
    super.initState();

    _data = widget.data;
    _onClickedBookmark = widget.onClickedBookmark;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
            width: MediaQuery.of(context).size.width,
            child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ActorDetail(
                            seq: _data[APIConstants.actor_seq],
                            actorProfileSeq:
                                _data[APIConstants.actorProfile_seq])),
                  ).then((value) =>
                      {if (_onClickedBookmark != null) _onClickedBookmark()});

                  /*addView(
                      context,
                      ActorDetail(
                          seq: _data[APIConstants.actor_seq],
                          actorProfileSeq:
                              _data[APIConstants.actorProfile_seq]));*/
                },
                child: Column(children: <Widget>[
                  Container(
                      decoration:
                          BoxDecoration(color: CustomColors.colorBgGrey),
                      width: (MediaQuery.of(context).size.width / 2),
                      height: (MediaQuery.of(context).size.width / 2),
                      child: _data[APIConstants.main_img_url] != null
                          ? ClipRRect(
                              borderRadius: CustomStyles.circle7BorderRadius(),
                              child: CachedNetworkImage(
                                  imageUrl: _data[APIConstants.main_img_url],
                                  fit: BoxFit.cover))
                          : null),
                  Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(top: 5),
                      child: Text(
                          StringUtils.checkedString(
                              _data[APIConstants.actor_name]),
                          style: CustomStyles.dark20TextStyle()))
                ]))));
  }
}
