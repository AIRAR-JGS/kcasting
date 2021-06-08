import 'dart:math';

import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/view/audition/common/AuditionListItem.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BookmarkedAuditionList extends StatefulWidget {
  @override
  _BookmarkedAuditionList createState() => _BookmarkedAuditionList();
}

class _BookmarkedAuditionList extends State<BookmarkedAuditionList>
    with SingleTickerProviderStateMixin {
  // 캐스팅보드 리스트 관련 변수
  final _count = 20;
  final _itemsPerPage = 5;
  int _currentPage = 0;

  final _castingBoardList = <String>[];
  bool _isLoading = true;
  bool _hasMore = true;

  Future<List<String>> fetch() async {
    final list = <String>[];
    final n = min(_itemsPerPage, _count - _currentPage * _itemsPerPage);
    await Future.delayed(Duration(seconds: 1), () {
      for (int i = 0; i < n; i++) {
        int realIdx = _castingBoardList.length + i;

        list.add('캐스팅' + realIdx.toString());
      }
    });
    _currentPage++;
    return list;
  }

  @override
  void initState() {
    super.initState();

    _isLoading = true;
    _hasMore = true;
    _loadMore();
  }

  void _loadMore() {
    _isLoading = true;
    fetch().then((List<String> fetchedList) {
      if (fetchedList.isEmpty) {
        setState(() {
          _isLoading = false;
          _hasMore = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _castingBoardList.addAll(fetchedList);
        });
      }
    });
  }

  //========================================================================================================================
  // 메인 위젯
  //========================================================================================================================
  @override
  Widget build(BuildContext context) {
    return Theme(
        data: CustomStyles.defaultTheme(),
        child: Scaffold(
            appBar: CustomStyles.defaultAppBar('마이 스크랩', () {
              Navigator.pop(context);
            }),
            body: Container(
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
                          text: "10", style: CustomStyles.red16TextStyle()),
                      new TextSpan(text: '개'),
                    ],
                  )),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                      padding: EdgeInsets.only(left: 10, bottom: 30),
                      child: ListView.builder(
                        // Need to display a loading tile if more items are coming
                        itemCount: _hasMore
                            ? _castingBoardList.length + 1
                            : _castingBoardList.length,
                        itemBuilder: (BuildContext context, int index) {
                          // Uncomment the following line to see in real time how ListView.builder works
                          // print('ListView.builder is building index $index');
                          if (index >= _castingBoardList.length) {
                            // Don't trigger if one async loading is already under way
                            if (!_isLoading) {
                              _loadMore();
                            }
                            return Center(
                              child: SizedBox(
                                child: CircularProgressIndicator(),
                                height: 24,
                                width: 24,
                              ),
                            );
                          }
                          return Container(
                              margin: EdgeInsets.only(bottom: 10),
                              alignment: Alignment.center,
                              child: AuditionListItem(
                                castingItem: null,
                              ));
                        },
                      )),
                )
              ],
            ))));
  }
}
