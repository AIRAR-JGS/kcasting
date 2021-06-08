import 'package:casting_call/res/CustomStyles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'AuditionApplyList.dart';

/*
* 오디션 지원 완료 화면
* */
class AuditionApplyComplete extends StatefulWidget {
  @override
  _AuditionApplyComplete createState() => _AuditionApplyComplete();
}

class _AuditionApplyComplete extends State<AuditionApplyComplete> {
  @override
  void initState() {
    super.initState();
  }

  /*
  * 메인 위젯
  * */
  @override
  Widget build(BuildContext context) {
    return Theme(
        data: CustomStyles.defaultTheme(),
        child: Scaffold(
            appBar: CustomStyles.defaultAppBar('지원완료', () {
              Navigator.pop(context);
            }),
            body: Container(
                alignment: Alignment.center,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        child: Text('지원완료!',
                            style: CustomStyles.normal24TextStyle()),
                      ),
                      Container(
                          margin: EdgeInsets.only(top: 15, bottom: 30),
                          child: Text('캐스팅 과정은\n지원현황에서 확인하실 수 있습니다.',
                              textAlign: TextAlign.center,
                              style: CustomStyles.normal14TextStyle())),
                      Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: CustomStyles.greyBorderRound7ButtonStyle(
                              '지원현황', () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AuditionApplyList()));
                          }))
                    ]))));
  }
}