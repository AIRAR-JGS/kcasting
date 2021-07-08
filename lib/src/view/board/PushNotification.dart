import 'dart:math';

import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:flutter/material.dart';

class PushNotification extends StatefulWidget {
  @override
  _PushNotification createState() => _PushNotification();
}

class _PushNotification extends State<PushNotification> with BaseUtilMixin {
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

        list.add('알림이 있습니다. 오디션 제안이 있습니다.' + realIdx.toString());
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

  /*
  * 메인 위젯
  * */
  @override
  Widget build(BuildContext context) {
    return Theme(
        data: CustomStyles.defaultTheme(),
        child: Scaffold(
            appBar: CustomStyles.defaultAppBar('', () {
              Navigator.pop(context);
            }),
            body: Container(
                child: ListView.separated(
                    itemCount:
                        _hasMore ? _pushList.length + 1 : _pushList.length,
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
                                /*Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MyApplyDetail()),
                                    );*/
                              },
                              child: Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.only(
                                      left: 15, right: 15, top: 20, bottom: 20),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                            margin: EdgeInsets.only(bottom: 5),
                                            child: Text(_pushList[index],
                                                style: CustomStyles
                                                    .normal16TextStyle())),
                                        Container(
                                            child: Text('2021.03.17 14:00',
                                                style: CustomStyles
                                                    .normal14TextStyle()))
                                      ]))));
                    },
                    separatorBuilder: (context, index) {
                      return Divider(
                        height: 0.1,
                        color: CustomColors.colorFontLightGrey,
                      );
                    }))));
  }
}
