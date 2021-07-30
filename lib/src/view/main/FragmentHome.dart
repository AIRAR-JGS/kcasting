import 'package:carousel_slider/carousel_slider.dart';
import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/KCastingAppData.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:casting_call/src/view/actor/ActorListItem.dart';
import 'package:casting_call/src/view/audition/common/AuditionListItem.dart';
import 'package:casting_call/src/view/board/UsageGuide.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_tags/flutter_tags.dart';

/*
* 프레그먼트 홈 클래스(메인 화면)
* */
class FragmentHome extends StatefulWidget {
  final VoidCallback onClickedOpenCastingBoard;

  //final VoidCallback onClickedOpenCastingActor;
  final Function(String) onClickedOpenCastingActor;

  FragmentHome(
      {Key key,
      this.onClickedOpenCastingBoard,
      this.onClickedOpenCastingActor});

  @override
  _FragmentHome createState() => _FragmentHome();
}

class _FragmentHome extends State<FragmentHome> with BaseUtilMixin {
  // 메인 배너 관련 변수
  List<dynamic> _bannerList = [];

  // 새로운 캐스팅 목록
  List<dynamic> _newCastingList = [];

  // 마감임박 캐스팅 목록
  List<dynamic> _oldCastingList = [];

  // 남배우, 여배우 리스트 관련 변수
  final GlobalKey<TagsState> _actorTagStateKey = GlobalKey<TagsState>();
  List<dynamic> _actorKeywordList = [];
  List<dynamic> _actorList = [];

  final GlobalKey<TagsState> _actressTagStateKey = GlobalKey<TagsState>();
  List<dynamic> _actressKeywordList = [];
  List<dynamic> _actressList = [];

  void initState() {
    super.initState();

    requestNewCastingListApi(context);
    requestOldCastingListApi(context);
    requestActorListApi(context, APIConstants.SEL_MKM_LIST);
    requestActorListApi(context, APIConstants.SEL_MKW_LIST);
  }

  /*
  * 새로운 캐스팅 목록
  * */
  void requestNewCastingListApi(BuildContext context) {
    final dio = Dio();

    // 새로운 캐스팅 목록 api 호출 시 보낼 파라미터
    // 캐스팅 목록 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetDate = new Map();
    targetDate[APIConstants.order_type] = APIConstants.order_type_new;
    if(KCastingAppData().myInfo[APIConstants.member_type] == APIConstants.member_type_actor) {
      targetDate[APIConstants.actor_seq] = KCastingAppData().myInfo[APIConstants.seq];
    }

    if(KCastingAppData().myInfo[APIConstants.member_type] == APIConstants.member_type_management) {
      targetDate[APIConstants.management_seq] = KCastingAppData().myInfo[APIConstants.seq];
    }

    Map<String, dynamic> paging = new Map();
    paging[APIConstants.offset] = 0;
    paging[APIConstants.limit] = 3;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.SEL_PCT_LIST;
    params[APIConstants.target] = targetDate;
    params[APIConstants.paging] = paging;

    // 새로운 캐스팅 목록 api 호출
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value != null) {
        if (value[APIConstants.resultVal]) {
          // 새로운 캐스팅 목록 성공
          var _responseData = value[APIConstants.data];
          var _responseList = _responseData[APIConstants.list] as List;

          setState(() {
            if (_responseList != null && _responseList.length > 0) {
              _newCastingList = _responseList;
            }
          });
        }
      }
    });
  }

  /*
  * 마감임박 캐스팅 목록
  * */
  void requestOldCastingListApi(BuildContext context) {
    final dio = Dio();

    // 마감임박 캐스팅 목록 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetDate = new Map();
    targetDate[APIConstants.order_type] = APIConstants.order_type_fin;
    if(KCastingAppData().myInfo[APIConstants.member_type] == APIConstants.member_type_actor) {
      targetDate[APIConstants.actor_seq] = KCastingAppData().myInfo[APIConstants.seq];
    }

    if(KCastingAppData().myInfo[APIConstants.member_type] == APIConstants.member_type_management) {
      targetDate[APIConstants.management_seq] = KCastingAppData().myInfo[APIConstants.seq];
    }

    Map<String, dynamic> paging = new Map();
    paging[APIConstants.offset] = 0;
    paging[APIConstants.limit] = 3;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.SEL_PCT_LIST;
    params[APIConstants.target] = targetDate;
    params[APIConstants.paging] = paging;

    // 마감임박 캐스팅 목록 api 호출
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value != null) {
        if (value[APIConstants.resultVal]) {
          // 마감임박 캐스팅 목록 성공
          var _responseData = value[APIConstants.data];
          var _responseList = _responseData[APIConstants.list] as List;

          setState(() {
            if (_responseList != null && _responseList.length > 0) {
              _oldCastingList = _responseList;
            }
          });
        }
      }
    });
  }

  /*
  * 남배우 목록
  * */
  void requestActorListApi(BuildContext context, String apiKey) {
    final dio = Dio();

    // 남배우 목록 api 호출 시 보낼 파라미터
    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = apiKey;

    // 남배우 목록 api 호출
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value != null) {
        if (value[APIConstants.resultVal]) {
          // 남배우 목록 성공
          var _responseData = value[APIConstants.data] as List;

          setState(() {
            for (int i = 0; i < _responseData.length; i++) {
              var data = _responseData[i];

              var keyData = data[APIConstants.data];
              if (keyData != null) {
                var keyList = keyData[APIConstants.list];

                switch (data[APIConstants.table]) {
                  case APIConstants.KeywordM:
                    {
                      _actorKeywordList = keyList;

                      break;
                    }

                  case APIConstants.ActorLookKwd:
                    {
                      if (apiKey == APIConstants.SEL_MKM_LIST) {
                        _actorList = keyList;
                      } else {
                        _actressList = keyList;
                      }

                      break;
                    }

                  case APIConstants.KeywordW:
                    {
                      _actressKeywordList = keyList;
                      break;
                    }
                }
              }
            }
          });
        }
      }
    });
  }

  // 메인 배너 아이템 위젯
  Widget _bannerItemWidget(int idx) {
    return Container(
      height: 160,
      width: 160 * 1.75,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: CustomStyles.circle7BorderRadius(),
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0, 1],
            colors: [CustomColors.colorPrimary, CustomColors.colorAccent]),
      ),
      child: Text(_bannerList[idx].toString(),
          style: CustomStyles.bold17TextStyle()),
    );
  }

  // 태그 아이템 위젯
  Widget _tagListWidget(
      bool isMan, GlobalKey<TagsState> tagStateKey, List<dynamic> tagData) {
    return Tags(
      key: tagStateKey,
      itemCount: tagData.length, // required
      itemBuilder: (int index) {
        final item = tagData[index];
        return ItemTags(
            textStyle: CustomStyles.dark14TextStyle(),
            textColor:
                isMan ? CustomColors.colorPrimary : CustomColors.colorAccent,
            activeColor:
                isMan ? CustomColors.colorPrimary : CustomColors.colorAccent,
            textActiveColor: CustomColors.colorWhite,
            key: Key(index.toString()),
            index: index,
            title: StringUtils.checkedString(item[APIConstants.child_name]),
            active: false,
            pressEnabled: false,
            combine: ItemTagsCombine.withTextBefore,
            elevation: 0.0,
            borderRadius: BorderRadius.circular(50));
      },
    );
  }

  /*
  * 메인 위젯
  * */
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: EdgeInsets.only(top: 20),
        child: Column(children: [
          // 메인 배너
          Visibility(
            child: Container(
                margin: EdgeInsets.only(bottom: 20),
                child: CarouselSlider.builder(
                  options: CarouselOptions(
                      height: 160.0,
                      autoPlay: true,
                      autoPlayInterval: Duration(seconds: 3),
                      autoPlayAnimationDuration: Duration(milliseconds: 800),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      pauseAutoPlayOnTouch: true,
                      aspectRatio: 1.75),
                  itemCount: _bannerList.length,
                  itemBuilder: (context, index, realIndex) =>
                      _bannerItemWidget(index),
                )),
            visible: _bannerList.length > 0 ? true : false,
          ),

          // 새로운 캐스팅
          Visibility(
              child: Container(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  alignment: Alignment.centerLeft,
                  child:
                      Text('새로운 캐스팅', style: CustomStyles.dark14TextStyle())),
              visible: _newCastingList.length > 0 ? true : false),

          // 새로운 캐스팅 목록
          Visibility(
              child: Container(
                  margin: EdgeInsets.only(bottom: 20, left: 16, top: 10),
                  height: 180,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _newCastingList.length,
                      itemBuilder: (context, index) {
                        return Container(
                            margin: EdgeInsets.only(right: 10),
                            child: AuditionListItem(
                                castingItem: _newCastingList[index],
                            isMyScrapList: false,
                            onClickedBookmark: (){
                              if (KCastingAppData()
                                  .myInfo[APIConstants.member_type] ==
                                  APIConstants.member_type_actor) {
                                requestActorBookmarkEditApi(context, index, true);
                              } else if (KCastingAppData()
                                  .myInfo[APIConstants.member_type] ==
                                  APIConstants.member_type_management) {
                                requestManagementBookmarkEditApi(
                                    context, index, true);
                              }

                            }));
                      })),
              visible: _newCastingList.length > 0 ? true : false),

          // 마감임박 캐스팅
          Visibility(
              child: Container(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  alignment: Alignment.centerLeft,
                  child:
                      Text('마감임박 캐스팅', style: CustomStyles.dark14TextStyle())),
              visible: _oldCastingList.length > 0 ? true : false),

          // 마감임박 캐스팅 목록
          Visibility(
              child: Container(
                  margin: EdgeInsets.only(bottom: 10, left: 16, top: 10),
                  height: 180,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _oldCastingList.length,
                      itemBuilder: (context, index) {
                        return Container(
                            margin: EdgeInsets.only(right: 10),
                            child: AuditionListItem(
                                castingItem: _oldCastingList[index],
                            isMyScrapList: false,
                            onClickedBookmark: (){
                              if (KCastingAppData()
                                  .myInfo[APIConstants.member_type] ==
                                  APIConstants.member_type_actor) {
                                requestActorBookmarkEditApi(context, index, false);
                              } else if (KCastingAppData()
                                  .myInfo[APIConstants.member_type] ==
                                  APIConstants.member_type_management) {
                                requestManagementBookmarkEditApi(
                                    context, index, false);
                              }
                            }));
                      })),
              visible: _oldCastingList.length > 0 ? true : false),

          // 캐스팅 더보기
          Visibility(
              child: Container(
                  margin: EdgeInsets.only(bottom: 10),
                  alignment: Alignment.center,
                  child:
                      CustomStyles.greyBorderRound21ButtonStyle('캐스팅 더보기', () {
                    widget.onClickedOpenCastingBoard();
                  })),
              visible: _oldCastingList.length > 0 || _newCastingList.length > 0
                  ? true
                  : false),

          Visibility(
              child: Container(
                  margin: EdgeInsets.only(bottom: 15),
                  child: Divider(color: CustomColors.colorFontLightGrey)),
              visible: _oldCastingList.length > 0 || _newCastingList.length > 0
                  ? true
                  : false),

          // 남배우 프로필
          Visibility(
              child: Container(
                  margin: EdgeInsets.only(bottom: 15),
                  padding: EdgeInsets.only(left: 16, right: 16),
                  alignment: Alignment.centerLeft,
                  child:
                      Text('남배우 프로필', style: CustomStyles.dark14TextStyle())),
              visible: _actorList.length > 0 ? true : false),

          // 남배우 프로필 태그
          Visibility(
              child: Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.only(bottom: 10),
                  padding: EdgeInsets.only(left: 16, right: 16),
                  child: _tagListWidget(
                      true, _actorTagStateKey, _actorKeywordList)),
              visible: _actorList.length > 0 ? true : false),

          /*
          *  [2021.02.08] Dev Jennie
          *  그리드뷰 스크롤 막고(NeverScrollableScrollPhysics) Wrap으로 감싸면
          *  그리드뷰의 height을 wrapContent으로 설정할 수 있음
          * */
          Visibility(
              child: Wrap(children: [
                GridView.count(
                    padding: EdgeInsets.only(left: 16, right: 16),
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 5,
                    childAspectRatio: (0.76),
                    children: List.generate(_actorList.length, (index) {
                      return ActorListItem(data: _actorList[index]);
                    }))
              ]),
              visible: _actorList.length > 0 ? true : false),

          Visibility(
              child: Container(
                  margin: EdgeInsets.only(bottom: 10, top: 15),
                  alignment: Alignment.center,
                  child:
                      CustomStyles.blueBorderRound21ButtonStyle('남배우 더보기', () {
                    widget
                        .onClickedOpenCastingActor(APIConstants.actor_sex_male);
                  })),
              visible: _actorList.length > 0 ? true : false),

          Visibility(
              child: Container(
                  margin: EdgeInsets.only(bottom: 15),
                  child: Divider(color: CustomColors.colorFontLightGrey)),
              visible: _actorList.length > 0 ? true : false),

          // 여배우 프로필
          Visibility(
              child: Container(
                  margin: EdgeInsets.only(bottom: 15),
                  padding: EdgeInsets.only(left: 15, right: 15),
                  alignment: Alignment.centerLeft,
                  child:
                      Text('여배우 프로필', style: CustomStyles.dark14TextStyle())),
              visible: _actressList.length > 0 ? true : false),

          // 여배우 프로필 태그
          Visibility(
              child: Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.only(bottom: 10),
                  padding: EdgeInsets.only(left: 15, right: 15),
                  child: _tagListWidget(
                      false, _actressTagStateKey, _actressKeywordList)),
              visible: _actressList.length > 0 ? true : false),

          /*
          *  [2021.02.08] Dev Jennie
          *  그리드뷰 스크롤 막고(NeverScrollableScrollPhysics) Wrap으로 감싸면
          *  그리드뷰의 height을 wrapContent으로 설정할 수 있음
          * */
          Visibility(
              child: Wrap(children: [
                GridView.count(
                    padding: EdgeInsets.only(left: 16, right: 16),
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 5,
                    childAspectRatio: (0.76),
                    children: List.generate(_actressList.length, (index) {
                      return ActorListItem(data: _actressList[index]);
                    }))
              ]),
              visible: _actressList.length > 0 ? true : false),

          Visibility(
              child: Container(
                  margin: EdgeInsets.only(bottom: 10, top: 15),
                  alignment: Alignment.center,
                  child:
                      CustomStyles.purpleBorderRound21ButtonStyle('여배우 더보기', () {
                    widget.onClickedOpenCastingActor(
                        APIConstants.actor_sex_female);
                  })),
              visible: _actressList.length > 0 ? true : false),

          // 풋터
          Container(
              color: CustomColors.colorBgGrey,
              margin: EdgeInsets.only(top: 20),
              child: Column(children: [
                // 회사소개
                Container(
                    margin: EdgeInsets.only(top: 30, left: 15, right: 15),
                    alignment: Alignment.topLeft,
                    child: CustomStyles.normal16TextButtonStyle('회사소개', () {
                      launchInBrowser(
                          'https://www.enterrobang.com/entry/companyinfo');
                    })),

                // 회원약관
                Container(
                    margin: EdgeInsets.only(top: 5, left: 15, right: 15),
                    alignment: Alignment.topLeft,
                    child: CustomStyles.normal16TextButtonStyle('회원약관', () {
                      launchInBrowser(
                          'https://www.enterrobang.com/entry/companyinfo');
                    })),

                // 개인정보처리방침
                Container(
                    margin: EdgeInsets.only(
                        top: 10, bottom: 30, left: 15, right: 15),
                    alignment: Alignment.topLeft,
                    child: CustomStyles.normal16TextButtonStyle('개인정보처리방침', () {
                      launchInBrowser(
                          'https://enterrobang.tistory.com/pages/privacy');
                    })),

                // 이용안내
                Container(
                    margin: EdgeInsets.only(
                        top: 25, left: 15, right: 15, bottom: 30),
                    alignment: Alignment.topLeft,
                    child: CustomStyles.underline16TextButtonStyle('이용안내', () {
                      addView(context, UsageGuide());
                    }))
              ]))
        ]));
  }

  /*
  * 배우 북마크 목록
  * */
  void requestActorBookmarkEditApi(
      BuildContext context, int idx, bool isNew) {
    final dio = Dio();

    // 배우 북마크 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetDate = new Map();
    targetDate[APIConstants.actor_seq] =
    KCastingAppData().myInfo[APIConstants.seq];
    if(isNew) {
      targetDate[APIConstants.casting_seq] = _newCastingList[idx][APIConstants.casting_seq];
    } else {
      targetDate[APIConstants.casting_seq] = _oldCastingList[idx][APIConstants.casting_seq];
    }

    Map<String, dynamic> params = new Map();
    if(isNew) {
      if (_newCastingList[idx][APIConstants.isActorCastringScrap] == 1) {
        params[APIConstants.key] = APIConstants.DEA_ACS_INFO;
      } else {
        params[APIConstants.key] = APIConstants.INS_ACS_INFO;
      }
    } else {
      if (_oldCastingList[idx][APIConstants.isActorCastringScrap] == 1) {
        params[APIConstants.key] = APIConstants.DEA_ACS_INFO;
      } else {
        params[APIConstants.key] = APIConstants.INS_ACS_INFO;
      }
    }

    params[APIConstants.target] = targetDate;

    // 배우 북마크 api 호출
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value != null) {
        if (value[APIConstants.resultVal]) {
          _newCastingList = [];
          _oldCastingList = [];

          requestNewCastingListApi(context);
          requestOldCastingListApi(context);
        }
      }
    });
  }

  /*
  * 매니지먼트 북마크 목록
  * */
  void requestManagementBookmarkEditApi(
      BuildContext context, int idx, bool isNew) {
    final dio = Dio();

    // 매니지먼트 북마크 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetDate = new Map();
    targetDate[APIConstants.management_seq] =KCastingAppData().myInfo[APIConstants.seq];
    if(isNew) {
      targetDate[APIConstants.casting_seq] = _newCastingList[idx][APIConstants.casting_seq];
    } else {
      targetDate[APIConstants.casting_seq] = _oldCastingList[idx][APIConstants.casting_seq];
    }

    Map<String, dynamic> params = new Map();
    if(isNew) {
      if (_newCastingList[idx][APIConstants.isActorCastringScrap] == 1) {
        params[APIConstants.key] = APIConstants.DEA_MCS_INFO;
      } else {
        params[APIConstants.key] = APIConstants.INS_MCS_INFO;
      }
    } else {
      if (_oldCastingList[idx][APIConstants.isActorCastringScrap] == 1) {
        params[APIConstants.key] = APIConstants.DEA_MCS_INFO;
      } else {
        params[APIConstants.key] = APIConstants.INS_MCS_INFO;
      }
    }

    params[APIConstants.target] = targetDate;

    // 매니지먼트 북마크 api 호출
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value != null) {
        if (value[APIConstants.resultVal]) {
          _newCastingList = [];
          _oldCastingList = [];

          requestNewCastingListApi(context);
          requestOldCastingListApi(context);
        }
      }
    });
  }
}
