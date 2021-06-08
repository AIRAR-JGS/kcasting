import 'package:casting_call/res/Constants.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DialogAuditionRefuse extends StatelessWidget {
  final Function(String) onClickedAgree;

  final txtFieldMsg = TextEditingController();

  DialogAuditionRefuse({
    this.onClickedAgree,
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
                    child: Text('거절하기',
                        textAlign: TextAlign.left,
                        style: CustomStyles.normal14TextStyle())),
                Container(
                  margin: EdgeInsets.all(15),
                  child: TextField(
                    maxLines: 8,
                    controller: txtFieldMsg,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      hintText: "캐스팅 제안에 응하지 못한 이유를 말해주세요.",
                      hintStyle: CustomStyles.light14TextStyle(),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: CustomColors.colorFontLightGrey,
                              width: 1.0),
                          borderRadius: CustomStyles.circle7BorderRadius()),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: CustomColors.colorFontLightGrey,
                              width: 1.0),
                          borderRadius: CustomStyles.circle7BorderRadius()),
                    ),
                  ),
                ),
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
                                      style: CustomStyles.dark14TextStyle())))),
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
                                onClickedAgree(txtFieldMsg.text);
                              },
                              child: Container(
                                  alignment: Alignment.center,
                                  child: Text('보내기',
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
