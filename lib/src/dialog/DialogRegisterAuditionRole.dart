import 'package:casting_call/res/Constants.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../KCastingAppData.dart';

class DialogRegisterAuditionRole extends StatelessWidget {
  final VoidCallback onClickedAddCertainRole;
  final VoidCallback onClickedAddLargeRole;

  DialogRegisterAuditionRole({this.onClickedAddCertainRole, this.onClickedAddLargeRole});

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
            padding: EdgeInsets.all(15),
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
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Image.asset('assets/images/btn_close.png',
                            width: 19, color: CustomColors.colorFontTitle))),
                Container(
                    margin: EdgeInsets.all(15),
                    alignment: Alignment.center,
                    child: Text('배역 추가',
                        textAlign: TextAlign.center,
                        style: CustomStyles.dark20TextStyle())),
                GestureDetector(
                  onTap: () {
                    onClickedAddCertainRole();
                  },
                  child: Container(
                      margin: EdgeInsets.only(top: 15),
                      padding: EdgeInsets.all(15),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: 1,
                              color: CustomColors.colorFontLightGrey)),
                      child: Text('특정 배역',
                          textAlign: TextAlign.center,
                          style: CustomStyles.normal16TextStyle())),
                ),
                GestureDetector(
                  onTap: () {
                    onClickedAddLargeRole();
                  },
                  child: Container(
                      margin: EdgeInsets.only(top: 15, bottom: 30),
                      padding: EdgeInsets.all(15),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: 1,
                              color: CustomColors.colorFontLightGrey)),
                      child: Text('다수 배역',
                          textAlign: TextAlign.center,
                          style: CustomStyles.normal16TextStyle())),
                ),
              ],
            ),
          ),
        ],
      ),
    )));
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
