import 'package:casting_call/res/Constants.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DialogAuditionQuit extends StatelessWidget {
  final Function() onClickedAgree;

  DialogAuditionQuit({
    this.onClickedAgree
  });

  dialogContent(BuildContext context) {
    return Theme(
      data: ThemeData(fontFamily: Constants.appFont),
      child: Stack(
        children: <Widget>[
          Container(
            decoration: new BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: const Offset(0.0, 10.0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                    margin: EdgeInsets.only(
                        left: 15, right: 15, bottom: 15, top: 30),
                    alignment: Alignment.topLeft,
                    child: Text('오디션 마감하기',
                        textAlign: TextAlign.left,
                        style: CustomStyles.normal14TextStyle())),
                Container(
                    margin: EdgeInsets.only(left: 15, right: 15, bottom: 20),
                    alignment: Alignment.center,
                    child: Text(
                        '오디션을 마감하시겠습니까?\n오디션을 마감하면 심사대기 중인 지원자들은 자동으로 불합격 처리됩니다.',
                        textAlign: TextAlign.center,
                        style: CustomStyles.normal14TextStyle())),
                Container(
                  margin: EdgeInsets.only(top: 15),
                  child: Divider(
                    color: CustomColors.colorFontGrey,
                    height: 0.1,
                    thickness: 0.5,
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      Expanded(
                          child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                            alignment: Alignment.center,
                            child: Text('취소',
                                style: CustomStyles.dark14TextStyle())),
                      )),
                      Container(
                        height: 50,
                        child: VerticalDivider(
                          color: CustomColors.colorFontGrey,
                          width: 0.1,
                          thickness: 0.5,
                        ),
                      ),
                      Expanded(
                          flex: 1,
                          child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                                onClickedAgree();
                              },
                              child: Container(
                                  alignment: Alignment.center,
                                  child: Text('마감하기',
                                      style: CustomStyles.dark14TextStyle()))))
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }
}
