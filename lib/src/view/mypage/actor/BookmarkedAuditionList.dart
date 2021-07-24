import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/KCastingAppData.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/view/audition/common/AuditionListItem.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/*
* 배우 마이스크랩*/
class BookmarkedAuditionList extends StatefulWidget {
  @override
  _BookmarkedAuditionList createState() => _BookmarkedAuditionList();
}

class _BookmarkedAuditionList extends State<BookmarkedAuditionList>
    with SingleTickerProviderStateMixin, BaseUtilMixin {
  // 캐스팅보드 리스트 관련 변수
  ScrollController _scrollController;

  int _total = 0;
  int _limit = 20;

  List<dynamic> _castingBoardList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    requestCastingListApi(context);

    _scrollController = new ScrollController(initialScrollOffset: 5.0)
      ..addListener(_scrollListener);
  }

  _scrollListener() {
    if (_total == 0 || _castingBoardList.length >= _total) return;

    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      setState(() {
        _isLoading = true;

        if (_isLoading) {
          requestCastingListApi(context);
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
  * 배우 북마크 목록
  * */
  void requestCastingListApi(BuildContext context) {
    final dio = Dio();

    // 배우 북마크 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetDate = new Map();
    targetDate[APIConstants.actor_seq] = KCastingAppData().myInfo[APIConstants.seq];

    Map<String, dynamic> paging = new Map();
    paging[APIConstants.offset] = _castingBoardList.length;
    paging[APIConstants.limit] = _limit;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.SEL_ACS_LIST;
    params[APIConstants.target] = targetDate;
    params[APIConstants.paging] = paging;

    // 배우 북마크 api 호출
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value != null) {
        if (value[APIConstants.resultVal]) {
          try {
            // 배우 북마크 성공
            setState(() {
              var _responseData = value[APIConstants.data];
              var _responseList = _responseData[APIConstants.list] as List;
              var _pagingData = _responseData[APIConstants.paging];

              _total = _pagingData[APIConstants.total];

              if (_responseList != null && _responseList.length > 0) {
                _castingBoardList.addAll(_responseList);
              }

              _isLoading = false;
            });
          } catch (e) {}
        }
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
            appBar: CustomStyles.defaultAppBar('마이 스크랩', () {
              Navigator.pop(context);
            }),
            body: Container(
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
                  padding: EdgeInsets.only(left: 15, right: 15, bottom: 15),
                  alignment: Alignment.topLeft,
                  child: RichText(
                      text: new TextSpan(
                    style: CustomStyles.dark16TextStyle(),
                    children: <TextSpan>[
                      new TextSpan(text: '내 스크랩 '),
                      new TextSpan(
                          text: _castingBoardList.length.toString(),
                          style: CustomStyles.red16TextStyle()),
                      new TextSpan(text: '개'),
                    ],
                  )),
                ),
                _castingBoardList.length > 0
                    ? (Wrap(children: [
                        ListView.builder(
                            padding: EdgeInsets.only(bottom: 50),
                            controller: _scrollController,
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: _castingBoardList.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                  margin: EdgeInsets.only(bottom: 10),
                                  alignment: Alignment.center,
                                  child: AuditionListItem(
                                    castingItem: _castingBoardList[index],
                                  ));
                            })
                      ]))
                    : Container(
                        margin: EdgeInsets.only(top: 30),
                        child: Text('캐스팅이 없습니다.',
                            style: CustomStyles.normal16TextStyle()))
              ],
            )))));
  }
}
