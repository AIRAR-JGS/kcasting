import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:casting_call/src/view/audition/common/AuditionDetail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProposedAuditionDetail extends StatefulWidget {
  final Map<String, dynamic> scoutData;

  const ProposedAuditionDetail({Key key, this.scoutData}) : super(key: key);

  @override
  _ProposedAuditionDetail createState() => _ProposedAuditionDetail();
}

class _ProposedAuditionDetail extends State<ProposedAuditionDetail> {
  Map<String, dynamic> _scoutData;

  @override
  void initState() {
    super.initState();

    _scoutData = widget.scoutData;
  }

  //========================================================================================================================
  // 메인 위젯
  //========================================================================================================================
  @override
  Widget build(BuildContext context) {
    return Theme(
        data: CustomStyles.defaultTheme(),
        child: Scaffold(
            appBar: CustomStyles.defaultAppBar('오디션 제안', () {
              Navigator.pop(context);
            }),
            body: Container(
                child: Column(children: [
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.only(
                        top: 20, bottom: 30, left: 15, right: 15),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 10, bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 0,
                                child: Container(
                                    margin: EdgeInsets.only(right: 5),
                                    alignment: Alignment.topCenter,
                                    child: (_scoutData[
                                                APIConstants.main_img_url] !=
                                            null
                                        ? ClipOval(
                                            child: Image.network(
                                                _scoutData[
                                                    APIConstants.main_img_url],
                                                fit: BoxFit.cover,
                                                width: 67.0,
                                                height: 67.0),
                                          )
                                        : Icon(
                                            Icons.account_circle,
                                            color:
                                                CustomColors.colorFontLightGrey,
                                            size: 67,
                                          ))),
                              ),
                              Expanded(
                                  flex: 1,
                                  child: Text(
                                    StringUtils.checkedString(
                                        _scoutData[APIConstants.actor_name]),
                                    style: CustomStyles.normal16TextStyle(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ))
                            ],
                          ),
                        ),
                        Visibility(
                          child: Container(
                              margin: EdgeInsets.only(top: 15),
                              alignment: Alignment.centerLeft,
                              child: Text('제안 답변',
                                  style: CustomStyles.normal14TextStyle())),
                        ),
                        Visibility(
                            child: Container(
                                margin: EdgeInsets.only(top: 10),
                                padding: EdgeInsets.all(15),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    borderRadius:
                                        CustomStyles.circle7BorderRadius(),
                                    border: Border.all(
                                        width: 1,
                                        color:
                                            CustomColors.colorFontLightGrey)),
                                child: Text(
                                    _scoutData[APIConstants
                                                .audition_prps_state_type] ==
                                            "대기"
                                        ? "답변 대기 중입니다."
                                        : StringUtils.checkedString(_scoutData[
                                            APIConstants
                                                .audition_prps_reply_contents]),
                                    style: CustomStyles.normal14TextStyle()))),
                        Container(
                            margin: EdgeInsets.only(top: 15),
                            alignment: Alignment.centerLeft,
                            child: Text('제안 내용',
                                style: CustomStyles.normal14TextStyle())),
                        Container(
                            margin: EdgeInsets.only(top: 10),
                            padding: EdgeInsets.all(15),
                            width: double.infinity,
                            decoration: BoxDecoration(
                                borderRadius:
                                    CustomStyles.circle7BorderRadius(),
                                border: Border.all(
                                    width: 1,
                                    color: CustomColors.colorFontLightGrey)),
                            child: Text(
                                StringUtils.checkedString(_scoutData[
                                    APIConstants.audition_prps_contents]),
                                style: CustomStyles.normal14TextStyle())),
                        Container(
                            margin: EdgeInsets.only(top: 20, bottom: 10),
                            alignment: Alignment.centerLeft,
                            child: Text('제안한 오디션',
                                style: CustomStyles.normal14TextStyle())),
                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                              borderRadius: CustomStyles.circle7BorderRadius(),
                              border: Border.all(
                                  width: 1,
                                  color: CustomColors.colorFontLightGrey)),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AuditionDetail(
                                          castingSeq: _scoutData[
                                              APIConstants.casting_seq],
                                        )),
                              );
                            },
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          StringUtils.checkedString(_scoutData[
                                              APIConstants.project_name]),
                                          style:
                                              CustomStyles.dark12TextStyle()),
                                      Container(
                                          margin: EdgeInsets.only(top: 10),
                                          child: Text(
                                              StringUtils.checkedString(
                                                  _scoutData[APIConstants
                                                      .casting_name]),
                                              style: CustomStyles
                                                  .dark24TextStyle()))
                                    ],
                                  ),
                                ),
                                Expanded(
                                    flex: 0,
                                    child: Container(
                                        margin: EdgeInsets.only(left: 10),
                                        child: Text('공고보기',
                                            style: CustomStyles
                                                .normal14TextStyle())))
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ]))));
  }
}
