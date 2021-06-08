import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/view/audition/production/RegisteredAuditionList.dart';
import 'package:casting_call/src/view/project/ProjectList.dart';
import 'package:flutter/material.dart';

/*
* 프로젝트 추가 완료
* */
class ProjectAddComplete extends StatefulWidget {
  final int projectSeq;
  final String projectName;

  const ProjectAddComplete({Key key, this.projectSeq, this.projectName})
      : super(key: key);

  @override
  _ProjectAddComplete createState() => _ProjectAddComplete();
}

class _ProjectAddComplete extends State<ProjectAddComplete> with BaseUtilMixin {
  int _projectSeq;
  String _projectName;

  @override
  void initState() {
    super.initState();

    _projectSeq = widget.projectSeq;
    _projectName = widget.projectName;
  }

  /*
  * 메인 위젯
  * */
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          // 오디션 관리 페이지 이동
          replaceView(context, ProjectList());
          return Future.value(false);
        },
        child: Theme(
            data: CustomStyles.defaultTheme(),
            child: Scaffold(
                appBar: CustomStyles.defaultAppBar('프로젝트 추가완료', () {
                  replaceView(context, ProjectList());
                }),
                body: Container(
                  padding: EdgeInsets.only(left: 30, right: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          alignment: Alignment.center,
                          width: double.infinity,
                          child: Text('공고가 등록되었습니다.',
                              textAlign: TextAlign.center,
                              style: CustomStyles.normal24TextStyle())),
                      Container(
                          margin: EdgeInsets.only(top: 30, bottom: 50),
                          alignment: Alignment.center,
                          width: double.infinity,
                          child: Text('내 프로필 > 오디션 관리에서\n세부 설정을 해주세요.',
                              textAlign: TextAlign.center,
                              style: CustomStyles.normal14TextStyle())),
                      Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: CustomStyles.greyBorderRound7ButtonStyle(
                              '등록된 오디션 보기', () {
                            replaceView(
                                context,
                                RegisteredAuditionList(
                                  projectSeq: _projectSeq,
                                  projectName: _projectName,
                                ));
                          })),
                    ],
                  ),
                ))));
  }
}
