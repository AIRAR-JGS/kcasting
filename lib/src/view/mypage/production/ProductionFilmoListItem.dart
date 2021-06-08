import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:flutter/material.dart';

class ProductionFilmoListItem extends StatelessWidget {
  final int idx;
  final Map<String, dynamic> data;
  final bool isEditMode;
  final VoidCallback onClickEvent;

  ProductionFilmoListItem(
      {Key key, this.idx, this.data, this.isEditMode, this.onClickEvent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          /* Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CastingBoardDetail()),
          );*/
        },
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        StringUtils.checkedString(
                            data[APIConstants.project_name]),
                        style: CustomStyles.dark16TextStyle()),
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      child: Text(
                          StringUtils.checkedString(
                                  data[APIConstants.project_releaseYear]) +
                              ' | ' +
                              StringUtils.checkedString(
                                  data[APIConstants.project_type]),
                          style: CustomStyles.dark14TextStyle()),
                    )
                  ],
                ),
              ),
              Expanded(
                  flex: 0,
                  child: Visibility(
                    child: Container(
                      margin: EdgeInsets.only(left: 10),
                      child: GestureDetector(
                        onTap: () {
                          onClickEvent();
                        },
                        child: Image.asset('assets/images/btn_close.png',
                            width: 15, color: CustomColors.colorFontTitle),
                      ),
                    ),
                    visible: isEditMode,
                  ))
            ],
          ),
        ));
  }
}
