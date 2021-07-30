import 'package:cached_network_image/cached_network_image.dart';
import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../../KCastingAppData.dart';
import 'ProposedAuditionDetail.dart';

/*
* 제안한 오디션
* */
class ProposedAuditionList extends StatefulWidget {
  @override
  _ProposedAuditionList createState() => _ProposedAuditionList();
}

class _ProposedAuditionList extends State<ProposedAuditionList>
    with SingleTickerProviderStateMixin, BaseUtilMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool _isUpload = false;

  // 프로젝트 리스트 관련 변수
  ScrollController _scrollController;

  int _total = 0;
  int _limit = 20;

  List<dynamic> _proposalList = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    requestProjectListApi(context);

    _scrollController = new ScrollController(initialScrollOffset: 5.0)
      ..addListener(_scrollListener);
  }

  _scrollListener() {
    if (_total == 0 || _proposalList.length >= _total) return;

    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      setState(() {
        _isLoading = true;

        if (_isLoading) {
          requestProjectListApi(context);
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /*
  * 오디션 제안 목록 조회
  * */
  void requestProjectListApi(BuildContext context) {
    setState(() {
      _isUpload = true;
    });

    // 오디션 제안 목록 조회 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetData = new Map();
    targetData[APIConstants.production_seq] =
        KCastingAppData().myInfo[APIConstants.seq];

    Map<String, dynamic> paging = new Map();
    paging[APIConstants.offset] = _proposalList.length;
    paging[APIConstants.limit] = _limit;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.SEL_APP_PRODUCTIONSLIST;
    params[APIConstants.target] = targetData;
    params[APIConstants.paging] = paging;

    // 오디션 제안 목록 조회 api 호출
    RestClient(Dio()).postRequestMainControl(params).then((value) async {
      try {
        if (value == null) {
          // 에러 - 데이터 널
          showSnackBar(context, '다시 시도해 주세요.');
        } else {
          if (value[APIConstants.resultVal]) {
            // 오디션 제안 목록 조회 성공
            var _responseList = value[APIConstants.data];

            var _pagingData = _responseList[APIConstants.paging];
            setState(() {
              _total = _pagingData[APIConstants.total];

              _proposalList.addAll(_responseList[APIConstants.list]);

              _isLoading = false;
            });
          } else {
            // 오디션 제안 목록 조회 실패
            showSnackBar(context, value[APIConstants.resultMsg]);
          }
        }
      } catch (e) {
        showSnackBar(context, APIConstants.error_msg_try_again);
      } finally {
        setState(() {
          _isUpload = false;
        });
      }
    });
  }

  Widget tabItem() {
    return Container(
        child: Column(children: [
      Wrap(children: [
        ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            primary: false,
            itemCount: _proposalList.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                  alignment: Alignment.center,
                  child: GestureDetector(
                      onTap: () {
                        addView(
                            context,
                            ProposedAuditionDetail(
                                scoutData: _proposalList[index]));
                      },
                      child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(
                              left: 16, right: 16, top: 10, bottom: 10),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    margin:
                                        EdgeInsets.only(top: 10, bottom: 15),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 0,
                                            child: Container(
                                                width: 30,
                                                height: 30,
                                                margin:
                                                    EdgeInsets.only(right: 5),
                                                child: (_proposalList[index][
                                                            APIConstants
                                                                .main_img_url] !=
                                                        null
                                                    ? ClipOval(
                                                        child:
                                                            CachedNetworkImage(
                                                              placeholder: (context, url) => Container(
                                                                  alignment: Alignment.center,
                                                                  child: CircularProgressIndicator()),
                                                        fit: BoxFit.cover,
                                                        imageUrl: _proposalList[
                                                                index][
                                                            APIConstants
                                                                .main_img_url],
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Image.asset(
                                                                'assets/images/btn_mypage.png',
                                                                fit: BoxFit
                                                                    .cover,
                                                                color: CustomColors
                                                                    .colorBgGrey),
                                                      ))
                                                    : Image.asset(
                                                        'assets/images/btn_mypage.png',
                                                        fit: BoxFit.cover,
                                                        color: CustomColors
                                                            .colorBgGrey)),
                                                decoration: BoxDecoration(
                                                  color:
                                                      CustomColors.colorWhite,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              50.0)),
                                                  border: Border.all(
                                                    color: CustomColors
                                                        .colorAccent,
                                                    width: 1.0,
                                                  ),
                                                )),
                                          ),
                                          Expanded(
                                              flex: 1,
                                              child: Column(children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 1,
                                                      child: Text(
                                                        StringUtils.checkedString(
                                                            _proposalList[index]
                                                                [APIConstants
                                                                    .actor_name]),
                                                        style: CustomStyles
                                                            .normal16TextStyle(),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 0,
                                                      child: Text(
                                                        StringUtils.checkedString(
                                                            _proposalList[index]
                                                                [APIConstants
                                                                    .audition_prps_state_type]),
                                                        style: CustomStyles
                                                            .normal16TextStyle(),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                Container(
                                                    margin: EdgeInsets.only(
                                                        top: 10),
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      StringUtils.checkedString(
                                                          _proposalList[index][
                                                              APIConstants
                                                                  .audition_prps_contents]),
                                                      style: CustomStyles
                                                          .normal14TextStyle(),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ))
                                              ]))
                                        ])),
                                Container(
                                    padding:
                                        EdgeInsets.only(left: 10, right: 10),
                                    margin: EdgeInsets.only(bottom: 10),
                                    alignment: Alignment.centerLeft,
                                    width: MediaQuery.of(context).size.width,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            CustomStyles.circle7BorderRadius(),
                                        border: Border.all(
                                            width: 0.5,
                                            color: CustomColors.colorBgGrey)),
                                    child: Row(children: [
                                      Expanded(
                                        child: Text(
                                            StringUtils.checkedString(
                                                _proposalList[index][
                                                    APIConstants.project_name]),
                                            style:
                                                CustomStyles.dark12TextStyle()),
                                      ),
                                      Expanded(
                                          flex: 0,
                                          child: Text(
                                              StringUtils.checkedString(
                                                  _proposalList[index][
                                                      APIConstants
                                                          .casting_name]),
                                              style: CustomStyles
                                                  .normal14TextStyle()))
                                    ]))
                              ]))));
            },
            separatorBuilder: (context, index) {
              return Divider(
                  height: 0.1, color: CustomColors.colorFontLightGrey);
            })
      ])
    ]));
  }

  /*
  * 메인 위젯
  * */
  @override
  Widget build(BuildContext context) {
    return Theme(
        data: CustomStyles.defaultTheme(),
        child: Scaffold(
            key: _scaffoldKey,
            appBar: CustomStyles.defaultAppBar('제안한 오디션', () {
              Navigator.pop(context);
            }),
            body: Stack(
              children: [
                Container(
                    child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: AlwaysScrollableScrollPhysics(),
                        key: ObjectKey(_proposalList.length > 0 ? _proposalList[0] : ""),
                        child: Container(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                      Container(
                          margin: EdgeInsets.only(top: 30.0, bottom: 30),
                          padding: EdgeInsets.only(left: 16, right: 16),
                          child: Text('제안한 오디션',
                              style: CustomStyles.normal24TextStyle())),
                      Expanded(flex: 0, child: tabItem()),
                      Visibility(
                          child: Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(top: 50),
                              child: Text('제안한 오디션이 없습니다.\n배우들에게 오디션 제안을 해보세요!',
                                  style: CustomStyles.normal16TextStyle(),
                                  textAlign: TextAlign.center)),
                          visible: _proposalList.length > 0 ? false : true)
                    ])))),
                Visibility(
                  child: Container(
                      color: Colors.black38,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator()),
                  visible: _isUpload,
                )
              ],
            )));
  }
}
