import 'package:casting_call/res/Constants.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:flutter/material.dart';

class CustomStyles {
  //===========================================================================
  // 앱 테마 스타일
  //===========================================================================
  static ThemeData defaultTheme() {
    return ThemeData(
        primaryColor: CustomColors.colorPrimary,
        canvasColor: CustomColors.colorWhite,
        accentColor: CustomColors.colorAccent,
        fontFamily: Constants.appFont);
  }

  //===========================================================================
  // 앱바 스타일
  //===========================================================================
  static AppBar defaultAppBar(String txtTitle, VoidCallback onClickEvent) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      bottomOpacity: 0.0,
      flexibleSpace: Container(
          decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.topRight,
            colors: [
              CustomColors.colorPrimary,
              CustomColors.colorAccent,
            ]),
      )),
      automaticallyImplyLeading: false,
      title:
          /*Text(
        txtTitle,
        style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: CustomColors.colorWhite),
      )*/
          Image.asset('assets/images/logo_white.png', width: 80),
      centerTitle: true,
      actions: <Widget>[
        IconButton(
          icon: Image.asset('assets/images/btn_close.png', width: 15),
          onPressed: () {
            onClickEvent();
          },
        )
      ],
    );
  }

  static AppBar appBarWithoutBtn() {
    return AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        bottomOpacity: 0.0,
        flexibleSpace: Container(
            decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.topRight,
              colors: [
                CustomColors.colorPrimary,
                CustomColors.colorAccent,
              ]),
        )),
        automaticallyImplyLeading: false,
        title: Image.asset('assets/images/logo_white.png', width: 80),
        centerTitle: true);
  }

  //===========================================================================
  // 텍스트필드 스타일
  //===========================================================================

  // 테투리있는 텍스트필드
  static TextField greyBorderRound7TextField(
      TextEditingController controller, String txtHint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        hintText: txtHint,
        hintStyle:
            TextStyle(fontSize: 16, color: CustomColors.colorFontLightGrey),
        border: OutlineInputBorder(
            borderSide:
                BorderSide(color: CustomColors.colorFontGrey, width: 1.0),
            borderRadius: circle7BorderRadius()),
        focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: CustomColors.colorFontGrey, width: 1.0),
            borderRadius: circle7BorderRadius()),
      ),
      style: normal16TextStyle(),
    );
  }

  static TextField greyBorderRound7TextFieldWithDisableOpt(
      TextEditingController controller, String txtHint, bool isEnable) {
    return TextField(
      enabled: isEnable,
      controller: controller,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        hintText: txtHint,
        hintStyle:
        TextStyle(fontSize: 16, color: CustomColors.colorFontLightGrey),
        border: OutlineInputBorder(
            borderSide:
            BorderSide(color: CustomColors.colorFontGrey, width: 1.0),
            borderRadius: circle7BorderRadius()),
        focusedBorder: OutlineInputBorder(
            borderSide:
            BorderSide(color: CustomColors.colorFontGrey, width: 1.0),
            borderRadius: circle7BorderRadius()),
      ),
      style: normal16TextStyle(),
    );
  }

  // 테투리있는 텍스트필드 - 숫자만 입력
  static TextField greyBorderRound7NumbersOnlyTextField(
      TextEditingController controller, String txtHint) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        hintText: txtHint,
        hintStyle:
            TextStyle(fontSize: 16, color: CustomColors.colorFontLightGrey),
        border: OutlineInputBorder(
            borderSide:
                BorderSide(color: CustomColors.colorFontGrey, width: 1.0),
            borderRadius: circle7BorderRadius()),
        focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: CustomColors.colorFontGrey, width: 1.0),
            borderRadius: circle7BorderRadius()),
      ),
      style: normal16TextStyle(),
    );
  }

  static TextField greyBorderRound7NumbersOnlyTextFieldWithDisableOpt(
      TextEditingController controller, String txtHint, bool isEnable) {
    return TextField(
      enabled: isEnable,
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        hintText: txtHint,
        hintStyle:
        TextStyle(fontSize: 16, color: CustomColors.colorFontLightGrey),
        border: OutlineInputBorder(
            borderSide:
            BorderSide(color: CustomColors.colorFontGrey, width: 1.0),
            borderRadius: circle7BorderRadius()),
        focusedBorder: OutlineInputBorder(
            borderSide:
            BorderSide(color: CustomColors.colorFontGrey, width: 1.0),
            borderRadius: circle7BorderRadius()),
      ),
      style: normal16TextStyle(),
    );
  }

  // 테투리있는 텍스트필드 - 옵션
  static TextField greyBorderRound7TextFieldWithOption(
      TextEditingController controller, TextInputType type, String txtHint) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        hintText: txtHint,
        hintStyle:
            TextStyle(fontSize: 16, color: CustomColors.colorFontLightGrey),
        border: OutlineInputBorder(
            borderSide:
                BorderSide(color: CustomColors.colorFontGrey, width: 1.0),
            borderRadius: circle7BorderRadius()),
        focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: CustomColors.colorFontGrey, width: 1.0),
            borderRadius: circle7BorderRadius()),
      ),
      style: normal16TextStyle(),
    );
  }

  // 테투리있는 텍스트필드 - 옵션
  static TextField greyBorderRound7TextFieldWithOptionNoPadding(
      TextEditingController controller, TextInputType type, String txtHint) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
        hintText: txtHint,
        hintStyle:
        TextStyle(fontSize: 16, color: CustomColors.colorFontLightGrey),
        border: OutlineInputBorder(
            borderSide:
            BorderSide(color: CustomColors.colorFontGrey, width: 1.0),
            borderRadius: circle7BorderRadius()),
        focusedBorder: OutlineInputBorder(
            borderSide:
            BorderSide(color: CustomColors.colorFontGrey, width: 1.0),
            borderRadius: circle7BorderRadius()),
      ),
      style: normal16TextStyle(),
    );
  }

  static TextField greyBorderRound7PWDTextField(
      TextEditingController controller, String txtHint) {
    return TextField(
      controller: controller,
      obscureText: true,
      obscuringCharacter: "*",
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        hintText: txtHint,
        hintStyle:
            TextStyle(fontSize: 16, color: CustomColors.colorFontLightGrey),
        border: OutlineInputBorder(
            borderSide:
                BorderSide(color: CustomColors.colorFontGrey, width: 1.0),
            borderRadius: circle7BorderRadius()),
        focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: CustomColors.colorFontGrey, width: 1.0),
            borderRadius: circle7BorderRadius()),
      ),
      style: normal16TextStyle(),
    );
  }

  static TextField greyBorderRound7PWDTextFieldOnlyNumber(
      TextEditingController controller, String txtHint) {
    return TextField(
      keyboardType: TextInputType.number,
      controller: controller,
      obscureText: true,
      obscuringCharacter: "*",
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        hintText: txtHint,
        hintStyle:
        TextStyle(fontSize: 16, color: CustomColors.colorFontLightGrey),
        border: OutlineInputBorder(
            borderSide:
            BorderSide(color: CustomColors.colorFontGrey, width: 1.0),
            borderRadius: circle7BorderRadius()),
        focusedBorder: OutlineInputBorder(
            borderSide:
            BorderSide(color: CustomColors.colorFontGrey, width: 1.0),
            borderRadius: circle7BorderRadius()),
      ),
      style: normal16TextStyle(),
    );
  }

  static TextField disabledGreyBorderRound7TextField(String txtHint) {
    return TextField(
      enabled: false,
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: CustomColors.colorTextFieldBgGrey,
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        hintText: txtHint,
        hintStyle: normal16TextStyle(),
        border: OutlineInputBorder(
            borderSide: BorderSide(
                color: CustomColors.colorTextFieldBgGrey, width: 0.0),
            borderRadius: circle7BorderRadius()),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: CustomColors.colorTextFieldBgGrey, width: 0.0),
            borderRadius: circle7BorderRadius()),
      ),
      style: normal16TextStyle(),
    );
  }

  //===========================================================================
  // 버튼 스타일
  //===========================================================================

  // 기본 텍스트 버튼
  static InkWell normal16TextButtonStyle(
      String txtButton, VoidCallback onClickEvent) {
    return InkWell(
        child: Text(txtButton, style: normal16TextStyle()),
        onTap: () {
          onClickEvent();
        });
  }

  static InkWell blue16TextButtonStyle(
      String txtButton, VoidCallback onClickEvent) {
    return InkWell(
        child: Text(txtButton, style: blue16TextStyle()),
        onTap: () {
          onClickEvent();
        });
  }

  // 밑줄 텍스트 버튼
  static InkWell underline16TextButtonStyle(
      String txtButton, VoidCallback onClickEvent) {
    return InkWell(
        child: Text(txtButton, style: underline16TextStyle()),
        onTap: () {
          onClickEvent();
        });
  }

  static InkWell darkBold14TextButtonStyle(
      String txtButton, VoidCallback onClickEvent) {
    return InkWell(
        child: Text(txtButton, style: bold14TextStyle()),
        onTap: () {
          onClickEvent();
        });
  }

  static InkWell underline14TextButtonStyle(
      String txtButton, VoidCallback onClickEvent) {
    return InkWell(
        child: Text(txtButton, style: underline14TextStyle()),
        onTap: () {
          onClickEvent();
        });
  }

  static InkWell underline10TextButtonStyle(
      String txtButton, VoidCallback onClickEvent) {
    return InkWell(
        child: Text(txtButton, style: underline10TextStyle()),
        onTap: () {
          onClickEvent();
        });
  }

  // 배경 있는 사각형 텍스트 버튼
  static RaisedButton lightGreyBGSquareButtonStyle(
      String txtButton, VoidCallback onClickEvent) {
    return RaisedButton(
      elevation: 0.0,
      onPressed: () {
        onClickEvent();
      },
      padding: EdgeInsets.all(10.0),
      color: CustomColors.colorButtonLightGrey,
      textColor: CustomColors.colorWhite,
      child: Text(txtButton, style: bold17TextStyle()),
    );
  }

  // 배경 있는 사각형 텍스트 버튼 - 회색
  static RaisedButton greyBGSquareButtonStyle(
      String txtButton, VoidCallback onClickEvent) {
    return RaisedButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      elevation: 0.0,
      onPressed: () {
        onClickEvent();
      },
      padding: EdgeInsets.all(10.0),
      color: CustomColors.colorButtonGrey,
      child: Text(txtButton, style: whiteBold16TextStyle()),
    );
  }

  // 배경 있는 사각형 텍스트 버튼 - 진한 회색
  static RaisedButton darkGreyBGSquareButtonStyle(
      String txtButton, VoidCallback onClickEvent) {
    return RaisedButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      elevation: 0.0,
      onPressed: () {
        onClickEvent();
      },
      padding: EdgeInsets.all(10.0),
      color: CustomColors.colorFontDarkGrey,
      child: Text(txtButton, style: whiteBold16TextStyle()),
    );
  }

  // 배경 있는 사각형 텍스트 버튼 - 파란색
  static RaisedButton blueBGSquareButtonStyle(
      String txtButton, VoidCallback onClickEvent) {
    return RaisedButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      elevation: 0.0,
      onPressed: () {
        onClickEvent();
      },
      padding: EdgeInsets.all(10.0),
      color: CustomColors.colorPrimary,
      child: Text(txtButton, style: whiteBold16TextStyle()),
    );
  }

  // 배경 있는 라운드 텍스트 버튼
  static RaisedButton greyBGRound7ButtonStyle(
      String txtButton, VoidCallback onClickEvent) {
    return RaisedButton(
      elevation: 0.0,
      onPressed: () {
        onClickEvent();
      },
      padding: EdgeInsets.all(10.0),
      color: CustomColors.colorButtonLightGrey,
      textColor: CustomColors.colorWhite,
      shape: RoundedRectangleBorder(borderRadius: circle7BorderRadius()),
      child: Text(txtButton, style: normal16TextStyle()),
    );
  }

  // 테두리있는 라운드 텍스트 버튼
  static RaisedButton greyBorderRound7ButtonStyle(
      String txtButton, VoidCallback onClickEvent) {
    return RaisedButton(
      elevation: 0.0,
      onPressed: () {
        onClickEvent();
      },
      padding: EdgeInsets.all(10.0),
      color: CustomColors.colorWhite,
      textColor: CustomColors.colorFontGrey,
      shape: RoundedRectangleBorder(
          borderRadius: circle7BorderRadius(),
          side: BorderSide(color: CustomColors.colorFontGrey)),
      child: Text(txtButton, style: normal16TextStyle()),
    );
  }

  static RaisedButton greyBorderRound7ButtonStyleNoPadding(
      String txtButton, VoidCallback onClickEvent) {
    return RaisedButton(
      elevation: 0.0,
      onPressed: () {
        onClickEvent();
      },
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: EdgeInsets.all(0.0),
      color: CustomColors.colorWhite,
      textColor: CustomColors.colorFontGrey,
      shape: RoundedRectangleBorder(
          borderRadius: circle7BorderRadius(),
          side: BorderSide(color: CustomColors.colorFontGrey)),
      child: Text(txtButton, style: normal16TextStyle()),
    );
  }

  // 테두리있는 라운드 텍스트 버튼 - 21
  static RaisedButton greyBorderRound21ButtonStyle(
      String txtButton, VoidCallback onClickEvent) {
    return RaisedButton(
      elevation: 0.0,
      onPressed: () {
        onClickEvent();
      },
      padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
      color: CustomColors.colorWhite,
      textColor: CustomColors.colorFontGrey,
      shape: RoundedRectangleBorder(
          borderRadius: circle21BorderRadius(),
          side: BorderSide(color: CustomColors.colorFontGrey)),
      child: Text(txtButton, style: dark16TextStyle()),
    );
  }

  // 파란색 테두리있는 라운드 텍스트 버튼 - 21
  static RaisedButton blueBorderRound21ButtonStyle(
      String txtButton, VoidCallback onClickEvent) {
    return RaisedButton(
      elevation: 0.0,
      onPressed: () {
        onClickEvent();
      },
      padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
      color: CustomColors.colorWhite,
      textColor: CustomColors.colorPrimary,
      shape: RoundedRectangleBorder(
          borderRadius: circle21BorderRadius(),
          side: BorderSide(color: CustomColors.colorPrimary)),
      child: Text(txtButton, style: blue16TextStyle()),
    );
  }

  // 보라색 테두리있는 라운드 텍스트 버튼 - 21
  static RaisedButton purpleBorderRound21ButtonStyle(
      String txtButton, VoidCallback onClickEvent) {
    return RaisedButton(
      elevation: 0.0,
      onPressed: () {
        onClickEvent();
      },
      padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
      color: CustomColors.colorWhite,
      textColor: CustomColors.colorAccent,
      shape: RoundedRectangleBorder(
          borderRadius: circle21BorderRadius(),
          side: BorderSide(color: CustomColors.colorAccent)),
      child: Text(txtButton, style: purple16TextStyle()),
    );
  }

  //===========================================================================
  // 레디어스 스타일
  //===========================================================================

  static BorderRadius circle4BorderRadius() {
    return BorderRadius.circular(4.0);
  }

  static BorderRadius circle7BorderRadius() {
    return BorderRadius.circular(7.0);
  }

  static BorderRadius circle21BorderRadius() {
    return BorderRadius.circular(21.0);
  }

  //===========================================================================
  // 텍스트 스타일
  //===========================================================================

  static TextStyle dark8TextStyle() {
    return TextStyle(
        fontSize: 8,
        color: CustomColors.colorFontDarkGrey,
        fontWeight: FontWeight.normal);
  }

  static TextStyle white10TextStyle() {
    return TextStyle(
        fontSize: 10,
        color: CustomColors.colorWhite,
        fontWeight: FontWeight.normal);
  }

  static TextStyle dark10TextStyle() {
    return TextStyle(
        fontSize: 10,
        color: CustomColors.colorFontDarkGrey,
        fontWeight: FontWeight.normal);
  }

  static TextStyle darkBold10TextStyle() {
    return TextStyle(
        fontSize: 10,
        color: CustomColors.colorFontDarkGrey,
        fontWeight: FontWeight.bold);
  }

  static TextStyle underline10TextStyle() {
    return TextStyle(
        decoration: TextDecoration.underline,
        fontSize: 10,
        color: CustomColors.colorFontDarkGrey,
        fontWeight: FontWeight.normal);
  }

  static TextStyle white12TextStyle() {
    return TextStyle(
        fontSize: 12,
        color: CustomColors.colorWhite,
        fontWeight: FontWeight.normal);
  }

  static TextStyle light12TextStyle() {
    return TextStyle(
        fontSize: 12,
        color: CustomColors.colorFontTitle,
        fontWeight: FontWeight.normal);
  }

  static TextStyle dark12TextStyle() {
    return TextStyle(
        fontSize: 12,
        color: CustomColors.colorFontDarkGrey,
        fontWeight: FontWeight.normal);
  }

  static TextStyle darkBold12TextStyle() {
    return TextStyle(
        fontSize: 12,
        color: CustomColors.colorFontDarkGrey,
        fontWeight: FontWeight.bold);
  }

  static TextStyle underline14TextStyle() {
    return TextStyle(
        decoration: TextDecoration.underline,
        fontSize: 14,
        color: CustomColors.colorFontGrey,
        fontWeight: FontWeight.normal);
  }

  static TextStyle normal14TextStyle() {
    return TextStyle(
        fontSize: 14,
        height: 1.5,
        color: CustomColors.colorFontGrey,
        fontWeight: FontWeight.normal);
  }

  static TextStyle darkBold14TextStyle() {
    return TextStyle(
        fontSize: 14,
        color: CustomColors.colorFontDarkGrey,
        fontWeight: FontWeight.bold);
  }

  static TextStyle bold14TextStyle() {
    return TextStyle(
        fontSize: 14,
        color: CustomColors.colorFontGrey,
        fontWeight: FontWeight.bold);
  }

  static TextStyle grey14TextStyle() {
    return TextStyle(
        fontSize: 14,
        color: CustomColors.colorFontTitle,
        fontWeight: FontWeight.normal);
  }

  static TextStyle light14TextStyle() {
    return TextStyle(
        fontSize: 14,
        color: CustomColors.colorFontLightGrey,
        fontWeight: FontWeight.normal);
  }

  static TextStyle dark14TextStyle() {
    return TextStyle(
        fontSize: 14,
        color: CustomColors.colorFontDarkGrey,
        height: 1.5,
        fontWeight: FontWeight.normal);
  }

  static TextStyle red14TextStyle() {
    return TextStyle(
        fontSize: 14,
        color: CustomColors.colorRed,
        fontWeight: FontWeight.normal);
  }

  static TextStyle red16TextStyle() {
    return TextStyle(
        fontSize: 16,
        color: CustomColors.colorRed,
        fontWeight: FontWeight.normal);
  }

  static TextStyle normal16TextStyle() {
    return TextStyle(
        fontSize: 16,
        color: CustomColors.colorFontGrey,
        fontWeight: FontWeight.normal);
  }

  static TextStyle bold16TextStyle() {
    return TextStyle(
        fontSize: 16,
        color: CustomColors.colorFontGrey,
        fontWeight: FontWeight.bold);
  }

  static TextStyle underline16TextStyle() {
    return TextStyle(
        decoration: TextDecoration.underline,
        fontSize: 16,
        color: CustomColors.colorFontGrey,
        fontWeight: FontWeight.normal);
  }

  static TextStyle dark16TextStyle() {
    return TextStyle(
        fontSize: 16,
        color: CustomColors.colorFontDarkGrey,
        fontWeight: FontWeight.normal);
  }

  static TextStyle blue16TextStyle() {
    return TextStyle(
        fontSize: 16,
        color: CustomColors.colorPrimary,
        fontWeight: FontWeight.normal);
  }

  static TextStyle purple16TextStyle() {
    return TextStyle(
        fontSize: 16,
        color: CustomColors.colorAccent,
        fontWeight: FontWeight.normal);
  }

  static TextStyle whiteBold16TextStyle() {
    return TextStyle(
        fontSize: 16,
        color: CustomColors.colorWhite,
        fontWeight: FontWeight.bold);
  }

  static TextStyle darkBold16TextStyle() {
    return TextStyle(
        fontSize: 16,
        color: CustomColors.colorFontDarkGrey,
        fontWeight: FontWeight.bold);
  }

  static TextStyle bold17TextStyle() {
    return TextStyle(
        fontSize: 17,
        color: CustomColors.colorFontGrey,
        fontWeight: FontWeight.bold);
  }

  static TextStyle dark20TextStyle() {
    return TextStyle(
        fontSize: 20,
        color: CustomColors.colorFontDarkGrey,
        fontWeight: FontWeight.normal);
  }

  static TextStyle darkBold20TextStyle() {
    return TextStyle(
        fontSize: 20,
        color: CustomColors.colorFontDarkGrey,
        fontWeight: FontWeight.bold);
  }

  static TextStyle normal24TextStyle() {
    return TextStyle(
        fontSize: 24,
        color: CustomColors.colorFontTitle,
        fontWeight: FontWeight.normal);
  }

  static TextStyle dark24TextStyle() {
    return TextStyle(
        fontSize: 24,
        color: CustomColors.colorFontDarkGrey,
        fontWeight: FontWeight.normal);
  }

  static TextStyle darkBold24TextStyle() {
    return TextStyle(
        fontSize: 24,
        color: CustomColors.colorFontDarkGrey,
        fontWeight: FontWeight.bold);
  }

  static TextStyle normal32TextStyle() {
    return TextStyle(
        fontSize: 32,
        color: CustomColors.colorFontGrey,
        fontWeight: FontWeight.normal);
  }
}
