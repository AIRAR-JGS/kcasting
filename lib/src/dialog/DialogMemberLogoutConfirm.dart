import 'package:casting_call/res/Constants.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../KCastingAppData.dart';

class DialogMemberLogoutConfirm extends StatelessWidget {
  final VoidCallback onClickedAgree;

  DialogMemberLogoutConfirm({
    this.onClickedAgree,
  });

  dialogContent(BuildContext context) {
    return Theme(
      data: ThemeData(fontFamily: Constants.appFont),
      child: Align(
      alignment: Alignment.center,
      child: Container(
      width: KCastingAppData().isWeb
      ? CustomStyles.appWidth * 0.8
          : double.infinity,
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
                    margin: EdgeInsets.all(15),
                    alignment: Alignment.center,
                    height: 100,
                    child: Text('로그아웃하시겠습니까?',
                        textAlign: TextAlign.center,
                        style: CustomStyles.normal16TextStyle())),
                Container(
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
                                      style: CustomStyles.dark16TextStyle())))),
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
                                  child: Text('로그아웃',
                                      style: CustomStyles.dark16TextStyle()))))
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ))),
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
