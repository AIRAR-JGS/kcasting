import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/Constants.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:flutter/material.dart';

import '../../KCastingAppData.dart';

class DialogAddActor extends StatefulWidget {
  final Function(String, int, String) onClickedAgree;

  const DialogAddActor({Key key, this.onClickedAgree}) : super(key: key);

  @override
  _DialogAddActor createState() => _DialogAddActor();
}

class _DialogAddActor extends State<DialogAddActor> with BaseUtilMixin {
  Function(String, int, String) _onClickedAgree;

  final _txtActorName = TextEditingController();
  final _txtActorPhone = TextEditingController();
  int _actorGender = 0;

  @override
  void initState() {
    super.initState();

    _onClickedAgree = widget.onClickedAgree;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        child: Theme(
            data: ThemeData(
                canvasColor: CustomColors.colorCanvas,
                fontFamily: Constants.appFont),
            child: Align(
            alignment: Alignment.center,
            child: Container(
            width: KCastingAppData().isWeb
            ? CustomStyles.appWidth * 0.8
                : double.infinity,
            child: Stack(children: <Widget>[
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                            padding: EdgeInsets.only(
                                left: 15, top: 20, right: 15, bottom: 20),
                            alignment: Alignment.topLeft,
                            height: 350,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                    margin: EdgeInsets.only(bottom: 20),
                                    child: Text('배우추가',
                                        textAlign: TextAlign.start,
                                        style:
                                            CustomStyles.normal16TextStyle())),
                                Container(
                                  margin: EdgeInsets.only(bottom: 30),
                                  child: TextField(
                                    maxLines: 1,
                                    controller: _txtActorName,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 10),
                                      hintText: "배우의 활동명",
                                      hintStyle:
                                          CustomStyles.light14TextStyle(),
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: CustomColors
                                                  .colorFontLightGrey,
                                              width: 1.0),
                                          borderRadius: CustomStyles
                                              .circle7BorderRadius()),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: CustomColors
                                                  .colorFontLightGrey,
                                              width: 1.0),
                                          borderRadius: CustomStyles
                                              .circle7BorderRadius()),
                                    ),
                                  ),
                                ),
                                Container(
                                    margin: EdgeInsets.only(bottom: 5),
                                    child: Text('성별',
                                        textAlign: TextAlign.start,
                                        style:
                                            CustomStyles.normal16TextStyle())),
                                Container(
                                    margin: EdgeInsets.only(bottom: 30),
                                    width: double.infinity,
                                    child: Row(children: <Widget>[
                                      Radio(
                                          visualDensity: VisualDensity.compact,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          value: 0,
                                          groupValue: _actorGender,
                                          onChanged: (_) {
                                            setState(() {
                                              _actorGender = 0;
                                            });
                                          }),
                                      Container(
                                          margin: EdgeInsets.only(right: 10),
                                          child: Text('남자',
                                              style: CustomStyles
                                                  .normal14TextStyle())),
                                      Radio(
                                          visualDensity: VisualDensity.compact,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          value: 1,
                                          groupValue: _actorGender,
                                          onChanged: (_) {
                                            setState(() {
                                              _actorGender = 1;
                                            });
                                          }),
                                      Text('여자',
                                          style:
                                              CustomStyles.normal14TextStyle())
                                    ])),
                                Container(
                                    margin: EdgeInsets.only(bottom: 5),
                                    child: Text('연락처',
                                        textAlign: TextAlign.start,
                                        style:
                                            CustomStyles.normal16TextStyle())),
                                Container(
                                    margin: EdgeInsets.only(bottom: 5),
                                    child: Text(
                                        '오디션 결과 연락을 받을 수 있는 정확한 전화번호를 입력해 주세요.',
                                        textAlign: TextAlign.start,
                                        style:
                                            CustomStyles.normal14TextStyle())),
                                Container(
                                  margin: EdgeInsets.only(bottom: 0),
                                  child: TextField(
                                    maxLines: 1,
                                    controller: _txtActorPhone,
                                    keyboardType: TextInputType.phone,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 10),
                                      hintText: "전화번호",
                                      hintStyle:
                                          CustomStyles.light14TextStyle(),
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: CustomColors
                                                  .colorFontLightGrey,
                                              width: 1.0),
                                          borderRadius: CustomStyles
                                              .circle7BorderRadius()),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: CustomColors
                                                  .colorFontLightGrey,
                                              width: 1.0),
                                          borderRadius: CustomStyles
                                              .circle7BorderRadius()),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                        Container(
                          child: Divider(
                            color: CustomColors.colorFontGrey,
                            height: 0.1,
                            thickness: 0.5,
                          ),
                        ),
                        Container(
                            alignment: Alignment.center,
                            child: Row(children: [
                              Expanded(
                                  child: GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Container(
                                          alignment: Alignment.center,
                                          child: Text('취소',
                                              style: CustomStyles
                                                  .dark16TextStyle())))),
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
                                        if (StringUtils.isEmpty(
                                            _txtActorName.text)) {
                                          showSnackBar(
                                              context, '배우의 이름을 입력해 주세요.');
                                          return false;
                                        }

                                        if (StringUtils.isEmpty(
                                            _txtActorName.text)) {
                                          showSnackBar(
                                              context, '연락처를 입력해 주세요.');
                                          return false;
                                        }

                                        Navigator.of(context).pop();

                                        _onClickedAgree(
                                            _txtActorName.text.toString(),
                                            _actorGender,
                                            _txtActorPhone.text.toString());
                                      },
                                      child: Container(
                                          alignment: Alignment.center,
                                          child: Text('추가',
                                              style: CustomStyles
                                                  .dark16TextStyle()))))
                            ]))
                      ]))
            ])))));
  }
}
