import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:flutter/material.dart';

/*
* 배우 필모그래피 목록 아이템 위젯*/
class ActorFilmoListItem extends StatelessWidget with BaseUtilMixin {
  final int idx;
  final Map<String, dynamic> data;
  final bool isEditMode;
  final VoidCallback onClickEvent;

  ActorFilmoListItem(
      {Key key, this.idx, this.data, this.isEditMode, this.onClickEvent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {},
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        StringUtils.checkedString(
                            data[APIConstants.project_name]),
                        overflow: TextOverflow.ellipsis,
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
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        StringUtils.checkedString(
                            data[APIConstants.casting_name]),
                        style: CustomStyles.grey14TextStyle()),
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      child: Text(
                          StringUtils.checkedString(
                              data[APIConstants.casting_character_name]),
                          style: CustomStyles.dark16TextStyle()),
                    )
                  ],
                ),
              ),
              Expanded(
                  flex: 0,
                  child: Visibility(
                    child: GestureDetector(
                        onTap: () {
                          onClickEvent();
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 10),
                          child: Image.asset('assets/images/btn_close.png',
                              width: 15, color: CustomColors.colorFontTitle),
                        )),
                    visible: isEditMode,
                  ))
            ],
          ),
        ));
  }
}
