import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/view/actor/ActorListItem.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../../KCastingAppData.dart';

/*
* 제작사 - 마이스크랩
* */
class BookmarkedActorList extends StatefulWidget {
  @override
  _BookmarkedActorList createState() => _BookmarkedActorList();
}

class _BookmarkedActorList extends State<BookmarkedActorList>
    with SingleTickerProviderStateMixin, BaseUtilMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool _isUpload = false;

  // 배우 리스트 관련 변수
  ScrollController _scrollController;

  int _total = 0;
  int _limit = 20;

  List<dynamic> _actorList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // 배우 목록 api 조회
    requestActorListApi(context);

    // 리스트뷰 스크롤 컨트롤러
    _scrollController = new ScrollController(initialScrollOffset: 5.0)
      ..addListener(_scrollListener);
  }

  // 리스트뷰 스크롤 컨트롤러 이벤트 리스너
  _scrollListener() {
    if (_total == 0 || _actorList.length >= _total) return;

    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      setState(() {
        _isLoading = true;

        if (_isLoading) {
          requestActorListApi(context);
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
  * 배우목록조회 api 호출
  * */
  void requestActorListApi(BuildContext context) {
    setState(() {
      _isUpload = true;
    });

    // 배우목록조회 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetData = new Map();
    targetData[APIConstants.production_seq] =
        KCastingAppData().myInfo[APIConstants.seq];

    Map<String, dynamic> paging = new Map();
    paging[APIConstants.offset] = _actorList.length;
    paging[APIConstants.limit] = _limit;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.SEL_PAS_LIST;
    params[APIConstants.target] = targetData;
    params[APIConstants.paging] = paging;

    // 배우목록조회 api 호출
    RestClient(Dio()).postRequestMainControl(params).then((value) async {
      try {
        if (value != null) {
          if (value[APIConstants.resultVal]) {
            // 배우목록조회 성공
            setState(() {
              var _responseList = value[APIConstants.data];
              var _pagingData = _responseList[APIConstants.paging];

              _total = _pagingData[APIConstants.total];

              if (_responseList != null && _responseList.length > 0) {
                _actorList.addAll(_responseList[APIConstants.list]);
              }

              _isLoading = false;
            });
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

  /*
  * 메인 위젯
  * */
  @override
  Widget build(BuildContext context) {
    return Theme(
        data: CustomStyles.defaultTheme(),
        child: Scaffold(
            key: _scaffoldKey,
            appBar: CustomStyles.defaultAppBar('마이 스크랩', () {
              Navigator.pop(context);
            }),
            body: Stack(
              children: [
                Container(
                    child: SingleChildScrollView(
                        child: Column(
                  children: [
                    Container(
                        margin: EdgeInsets.only(top: 15),
                        padding: EdgeInsets.all(15),
                        alignment: Alignment.topLeft,
                        child: Text('마이 스크랩',
                            style: CustomStyles.normal24TextStyle())),
                    Container(
                        padding:
                            EdgeInsets.only(left: 15, right: 15, bottom: 15),
                        alignment: Alignment.topLeft,
                        child: RichText(
                            text: new TextSpan(
                                style: CustomStyles.dark16TextStyle(),
                                children: <TextSpan>[
                              new TextSpan(text: '내 스크랩 '),
                              new TextSpan(
                                  text: _total.toString(),
                                  style: CustomStyles.red16TextStyle()),
                              new TextSpan(text: '개')
                            ]))),
                    _actorList.length > 0
                        ? Wrap(children: [
                            GridView.count(
                                padding: EdgeInsets.only(
                                    left: 16, right: 16, bottom: 50),
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                crossAxisCount: 2,
                                controller: _scrollController,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 5,
                                childAspectRatio: (0.76),
                                children:
                                    List.generate(_actorList.length, (index) {
                                  return ActorListItem(data: _actorList[index],
                                  onClickedBookmark: (){
                                    _total = 0;
                                    _actorList = [];

                                    requestActorListApi(context);
                                  });
                                }))
                          ])
                        : Container(
                            margin: EdgeInsets.only(top: 30),
                            child: Text('스크랩한 배우가 없습니다.',
                                style: CustomStyles.normal16TextStyle()))
                  ],
                ))),
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
