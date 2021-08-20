import 'package:cached_network_image/cached_network_image.dart';
import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:casting_call/src/view/audition/common/AuditionDetail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../KCastingAppData.dart';

/*
* 제안한 오디션 상세
* */
class ProposedAuditionDetail extends StatefulWidget {
  final Map<String, dynamic> scoutData;

  const ProposedAuditionDetail({Key key, this.scoutData}) : super(key: key);

  @override
  _ProposedAuditionDetail createState() => _ProposedAuditionDetail();
}

class _ProposedAuditionDetail extends State<ProposedAuditionDetail>
    with BaseUtilMixin {
  bool _isUpload = false;

  Map<String, dynamic> _scoutData;

  @override
  void initState() {
    super.initState();

    _scoutData = widget.scoutData;
  }

  /*
  *  메인 위젯
  * */
  @override
  Widget build(BuildContext context) {
    return Theme(
        data: CustomStyles.defaultTheme(),
        child: Align(
            alignment: Alignment.topCenter,
            child: Container(
                width: KCastingAppData().isWeb
                    ? CustomStyles.appWidth
                    : double.infinity,
                child: Scaffold(
                    appBar: CustomStyles.defaultAppBar('오디션 제안', () {
                      Navigator.pop(context);
                    }),
                    body: Stack(
                      children: [
                        Container(
                            child: Column(children: [
                          Expanded(
                              flex: 1,
                              child: SingleChildScrollView(
                                  child: Container(
                                      padding: EdgeInsets.only(
                                          top: 20,
                                          bottom: 30,
                                          left: 15,
                                          right: 15),
                                      child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              margin: EdgeInsets.only(
                                                  top: 10, bottom: 10),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                      flex: 0,
                                                      child: Container(
                                                        decoration:
                                                            new BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                gradient:
                                                                    LinearGradient(
                                                                        colors: [
                                                                      CustomColors
                                                                          .colorPrimary,
                                                                      CustomColors
                                                                          .colorAccent
                                                                    ])),
                                                        padding:
                                                            EdgeInsets.all(3),
                                                        margin: EdgeInsets.only(
                                                            right: 10),
                                                        alignment:
                                                            Alignment.topCenter,
                                                        child: Container(
                                                            alignment: Alignment
                                                                .center,
                                                            width: 67,
                                                            height: 67,
                                                            decoration: new BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: CustomColors
                                                                    .colorWhite),
                                                            padding:
                                                                EdgeInsets.all(
                                                                    2.0),
                                                            child: ClipOval(
                                                                child: (_scoutData[APIConstants.main_img_url] !=
                                                                        null)
                                                                    ? CachedNetworkImage(
                                                                        fit: BoxFit
                                                                            .cover,
                                                                        placeholder: (context, url) => Container(
                                                                            alignment:
                                                                                Alignment.center,
                                                                            child: CircularProgressIndicator()),
                                                                        imageUrl: _scoutData[APIConstants.main_img_url],
                                                                        errorWidget: (context, url, error) => Image.asset('assets/images/btn_mypage.png', fit: BoxFit.contain, width: 67, color: CustomColors.colorBgGrey),
                                                                        width: 67,
                                                                        height: 67)
                                                                    : Image.asset('assets/images/btn_mypage.png', fit: BoxFit.contain, width: 67, color: CustomColors.colorBgGrey))),
                                                      )),
                                                  Expanded(
                                                      flex: 1,
                                                      child: Text(
                                                        StringUtils.checkedString(
                                                            _scoutData[
                                                                APIConstants
                                                                    .actor_name]),
                                                        style: CustomStyles
                                                            .bold20TextStyle(),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ))
                                                ],
                                              ),
                                            ),
                                            Visibility(
                                              child: Container(
                                                  margin:
                                                      EdgeInsets.only(top: 15),
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text('제안 답변',
                                                      style: CustomStyles
                                                          .bold14TextStyle())),
                                            ),
                                            Visibility(
                                                child: Container(
                                                    margin: EdgeInsets.only(
                                                        top: 10),
                                                    padding: EdgeInsets.all(15),
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                        color: CustomColors
                                                            .colorWhite,
                                                        borderRadius: CustomStyles
                                                            .circle7BorderRadius(),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: CustomColors
                                                                .colorFontLightGrey
                                                                .withAlpha(100),
                                                            blurRadius: 2.0,
                                                            spreadRadius: 2.0,
                                                            offset:
                                                                Offset(2, 1),
                                                          )
                                                        ]),
                                                    child: Text(
                                                        _scoutData[APIConstants
                                                                    .audition_prps_state_type] ==
                                                                "대기"
                                                            ? "답변 대기 중입니다."
                                                            : StringUtils.checkedString(
                                                                _scoutData[
                                                                    APIConstants
                                                                        .audition_prps_reply_contents]),
                                                        style: CustomStyles
                                                            .normal14TextStyle()))),
                                            Container(
                                                margin:
                                                    EdgeInsets.only(top: 15),
                                                alignment: Alignment.centerLeft,
                                                child: Text('제안 내용',
                                                    style: CustomStyles
                                                        .bold14TextStyle())),
                                            Container(
                                                margin:
                                                    EdgeInsets.only(top: 10),
                                                padding: EdgeInsets.all(15),
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                    color:
                                                        CustomColors.colorWhite,
                                                    borderRadius: CustomStyles
                                                        .circle7BorderRadius(),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: CustomColors
                                                            .colorFontLightGrey
                                                            .withAlpha(100),
                                                        blurRadius: 2.0,
                                                        spreadRadius: 2.0,
                                                        offset: Offset(2, 1),
                                                      )
                                                    ]),
                                                child: Text(
                                                    StringUtils.checkedString(
                                                        _scoutData[APIConstants
                                                            .audition_prps_contents]),
                                                    style: CustomStyles
                                                        .normal14TextStyle())),
                                            Container(
                                                margin: EdgeInsets.only(
                                                    top: 20, bottom: 10),
                                                alignment: Alignment.centerLeft,
                                                child: Text('제안한 오디션',
                                                    style: CustomStyles
                                                        .bold14TextStyle())),
                                            GestureDetector(
                                                onTap: () {
                                                  addView(
                                                      context,
                                                      AuditionDetail(
                                                        castingSeq: _scoutData[
                                                            APIConstants
                                                                .casting_seq],
                                                      ));
                                                },
                                                child: Container(
                                                    padding: EdgeInsets.all(15),
                                                    decoration: BoxDecoration(
                                                        color: CustomColors
                                                            .colorWhite,
                                                        borderRadius: CustomStyles
                                                            .circle7BorderRadius(),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: CustomColors
                                                                .colorFontLightGrey
                                                                .withAlpha(100),
                                                            blurRadius: 2.0,
                                                            spreadRadius: 2.0,
                                                            offset:
                                                                Offset(2, 1),
                                                          )
                                                        ]),
                                                    child: Row(children: [
                                                      Expanded(
                                                        flex: 1,
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                                StringUtils.checkedString(
                                                                    _scoutData[
                                                                        APIConstants
                                                                            .project_name]),
                                                                style: CustomStyles
                                                                    .greyBold14TextStyle()),
                                                            Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        top:
                                                                            10),
                                                                child: Text(
                                                                    StringUtils.checkedString(_scoutData[
                                                                        APIConstants
                                                                            .casting_name]),
                                                                    style: CustomStyles
                                                                        .bold20TextStyle()))
                                                          ],
                                                        ),
                                                      ),
                                                      Expanded(
                                                          flex: 0,
                                                          child: Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      left: 10),
                                                              child: Text(
                                                                  '공고보기',
                                                                  style: CustomStyles
                                                                      .bold14TextStyle())))
                                                    ])))
                                          ]))))
                        ])),
                        Visibility(
                          child: Container(
                              color: Colors.black38,
                              alignment: Alignment.center,
                              child: CircularProgressIndicator()),
                          visible: _isUpload,
                        )
                      ],
                    )))));
  }
}
