import 'dart:math';

import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'ActorDetail.dart';

class BookmarkedActorList extends StatefulWidget {
  @override
  _BookmarkedActorList createState() => _BookmarkedActorList();
}

class _BookmarkedActorList extends State<BookmarkedActorList>
    with SingleTickerProviderStateMixin, BaseUtilMixin {
  // 캐스팅보드 리스트 관련 변수
  final _count = 20;
  final _itemsPerPage = 10;
  int _currentPage = 0;

  final _actorList = <String>[];
  bool _isLoading = true;
  bool _hasMore = true;

  Future<List<String>> fetch() async {
    final list = <String>[];
    final n = min(_itemsPerPage, _count - _currentPage * _itemsPerPage);
    await Future.delayed(Duration(seconds: 1), () {
      for (int i = 0; i < n; i++) {
        int realIdx = _actorList.length + i;

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
          _actorList.addAll(fetchedList);
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
                      child: GridView.count(
                    padding: EdgeInsets.only(left: 16, right: 16),
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 5,
                    childAspectRatio: (0.76),
                    children: List.generate(
                        _hasMore ? _actorList.length + 1 : _actorList.length,
                        (index) {
                      if (index >= _actorList.length) {
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
                      return Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ActorDetail()),
                              );
                            },
                            child: Column(
                              children: <Widget>[
                                Container(
                                  decoration: BoxDecoration(
                                      color: CustomColors.colorPrimary,
                                      borderRadius:
                                          CustomStyles.circle7BorderRadius()),
                                  height:
                                      (MediaQuery.of(context).size.width / 2),
                                ),
                                Container(
                                    alignment: Alignment.centerLeft,
                                    margin: EdgeInsets.only(top: 5),
                                    child: Text(
                                      '배우 $index',
                                      style: CustomStyles.normal16TextStyle(),
                                    )),
                                Container()
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  )),
                )
              ],
            ))));
  }
}
