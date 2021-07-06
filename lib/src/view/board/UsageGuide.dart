import 'dart:math';

import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/view/board/UsageGuideDetail.dart';
import 'package:flutter/material.dart';

class UsageGuide extends StatefulWidget {
  @override
  _UsageGuide createState() => _UsageGuide();
}

class _UsageGuide extends State<UsageGuide> with BaseUtilMixin {
  // 알림 리스트 관련 변수
  final _count = 12;
  final _itemsPerPage = 10;
  int _currentPage = 0;

  final _pushList = <String>[];
  bool _isLoading = true;
  bool _hasMore = true;

  Future<List<String>> fetch() async {
    final list = <String>[];
    final n = min(_itemsPerPage, _count - _currentPage * _itemsPerPage);
    await Future.delayed(Duration(seconds: 1), () {
      for (int i = 0; i < n; i++) {
        int realIdx = _pushList.length + i;

        list.add('이용안내' + realIdx.toString());
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
          _pushList.addAll(fetchedList);
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
            appBar: CustomStyles.defaultAppBar('', () {
              Navigator.pop(context);
            }),
            body: Column(
              children: [
                Container(
                    margin: EdgeInsets.only(
                        top: 30, left: 10, right: 10, bottom: 30),
                    padding: EdgeInsets.only(left: 10, right: 10),
                    height: 50,
                    decoration: BoxDecoration(
                        borderRadius: CustomStyles.circle7BorderRadius(),
                        border: Border.all(
                            width: 1, color: CustomColors.colorFontLightGrey)),
                    child: Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                              child: TextField(
                                  decoration: InputDecoration(
                                      isDense: true,
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 0, horizontal: 0),
                                      hintText: "궁금한 점이 있으면 검색해 주세요!",
                                      hintStyle:
                                          CustomStyles.normal16TextStyle()),
                                  style: CustomStyles.dark16TextStyle())),
                          Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: GestureDetector(
                                  onTap: () {},
                                  child: Image.asset(
                                      'assets/images/btn_search.png',
                                      width: 20,
                                      fit: BoxFit.contain)))
                        ])),
                Container(
                    margin: EdgeInsets.only(bottom: 15),
                    padding: EdgeInsets.only(left: 15, right: 15),
                    child: Row(
                      children: [
                        Text("전체 이용안내", style: CustomStyles.bold17TextStyle()),
                        Icon(Icons.arrow_drop_down_sharp)
                      ],
                    )),
                Container(
                  padding: EdgeInsets.only(left: 15, right: 15),
                  child: Divider(
                    height: 2,
                    color: CustomColors.colorFontTitle,
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: Container(
                        child: ListView.separated(
                            itemCount: _hasMore
                                ? _pushList.length + 1
                                : _pushList.length,
                            itemBuilder: (BuildContext context, int index) {
                              if (index >= _pushList.length) {
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
                                  alignment: Alignment.centerLeft,
                                  child: GestureDetector(
                                      onTap: () {
                                        addView(context, UsageGuideDetail());
                                      },
                                      child: Container(
                                          alignment: Alignment.centerLeft,
                                          padding: EdgeInsets.only(
                                              left: 15,
                                              right: 15,
                                              top: 20,
                                              bottom: 20),
                                          child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                    flex: 1,
                                                    child: Container(
                                                        child: Text(
                                                            _pushList[index],
                                                            style: CustomStyles
                                                                .normal16TextStyle()))),
                                                Container(
                                                    child: Text('2021.03.17',
                                                        style: CustomStyles
                                                            .grey14TextStyle())),
                                              ]))));
                            },
                            separatorBuilder: (context, index) {
                              return Container(
                                padding: EdgeInsets.only(left: 15, right: 15),
                                child: Divider(
                                  height: 2,
                                  color: CustomColors.colorFontTitle,
                                ),
                              );
                            })))
              ],
            )));
  }
}
