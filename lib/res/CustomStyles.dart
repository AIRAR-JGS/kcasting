import 'package:casting_call/res/Constants.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:flutter/material.dart';

class CustomStyles {
  static const int appWidth = 900;
  static const int appHeight = 1000;

  //===========================================================================
  // 앱 테마 스타일
  //===========================================================================
  static ThemeData defaultTheme() {
    return ThemeData(
        primaryColor: CustomColors.colorPrimary,
        canvasColor: CustomColors.colorCanvas,
        secondaryHeaderColor: CustomColors.colorAccent,
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
      title: Image.asset('assets/images/logo_white.png', width: 80),
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
  static ElevatedButton lightGreyBGSquareButtonStyle(
      String txtButton, VoidCallback onClickEvent) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
              //모서리를 둥글게
              borderRadius: BorderRadius.circular(0)),
          primary: CustomColors.colorButtonLightGrey,
          alignment: Alignment.center),
      onPressed: () {
        onClickEvent();
      },
      child: Text(txtButton, style: bold17TextStyle()),
    );
  }

  // 배경 있는 사각형 텍스트 버튼 - 회색
  static ElevatedButton greyBGSquareButtonStyle(
      String txtButton, VoidCallback onClickEvent) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          padding: EdgeInsets.only(top: 15, bottom: 15),
          shape: RoundedRectangleBorder(
              //모서리를 둥글게
              borderRadius: BorderRadius.circular(0)),
          primary: CustomColors.colorButtonDefault,
          alignment: Alignment.center),
      onPressed: () {
        onClickEvent();
      },
      child: Text(txtButton, style: whiteBold16TextStyle()),
    );
  }

  // 배경 있는 사각형 텍스트 버튼 - 진한 회색
  static ElevatedButton darkGreyBGSquareButtonStyle(
      String txtButton, VoidCallback onClickEvent) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          padding: EdgeInsets.only(top: 15, bottom: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
          primary: CustomColors.colorButtonPurple,
          alignment: Alignment.center),
      onPressed: () {
        onClickEvent();
      },
      child: Text(txtButton, style: whiteBold16TextStyle()),
    );
  }

  // 배경 있는 사각형 텍스트 버튼 - 파란색
  static ElevatedButton applyButtonStyle(
      String txtButton, VoidCallback onClickEvent) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          elevation: 0.0,
          padding: EdgeInsets.only(top: 15, bottom: 15),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(30),
                  topRight: Radius.circular(30))),
          primary: CustomColors.colorPrimary,
          alignment: Alignment.center),
      onPressed: () {
        onClickEvent();
      },
      child: Text(txtButton, style: whiteBold16TextStyle()),
    );
  }

  static ElevatedButton blueBGSquareButtonStyle(
      String txtButton, VoidCallback onClickEvent) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          elevation: 0.0,
          padding: EdgeInsets.only(top: 15, bottom: 15),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(0))),
          primary: CustomColors.colorPrimary,
          alignment: Alignment.center),
      onPressed: () {
        onClickEvent();
      },
      child: Text(txtButton, style: whiteBold16TextStyle()),
    );
  }

  // 배경 있는 라운드 텍스트 버튼
  static ElevatedButton greyBGRound7ButtonStyle(
      String txtButton, VoidCallback onClickEvent) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          padding: EdgeInsets.only(top: 15, bottom: 15),
          shape: RoundedRectangleBorder(borderRadius: circle7BorderRadius()),
          primary: CustomColors.colorButtonLightGrey,
          alignment: Alignment.center),
      onPressed: () {
        onClickEvent();
      },
      child: Text(txtButton, style: normal16TextStyle()),
    );
  }

  // 테두리있는 라운드 텍스트 버튼
  static ElevatedButton greyBorderRound7ButtonStyle(
      String txtButton, VoidCallback onClickEvent) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          padding: EdgeInsets.only(top: 15, bottom: 15),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
              side: BorderSide(color: CustomColors.colorButtonDefault)),
          primary: CustomColors.colorCanvas,
          alignment: Alignment.center),
      onPressed: () {
        onClickEvent();
      },
      child: Text(txtButton, style: normal16TextStyle()),
    );
  }

  static ElevatedButton greyBorderRound7ButtonStyleNoPadding(
      String txtButton, VoidCallback onClickEvent) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          padding: EdgeInsets.only(top: 15, bottom: 15),
          shape: RoundedRectangleBorder(
              borderRadius: circle7BorderRadius(),
              side: BorderSide(color: CustomColors.colorFontGrey)),
          primary: CustomColors.colorWhite,
          alignment: Alignment.center),
      onPressed: () {
        onClickEvent();
      },
      child: Text(txtButton, style: normal16TextStyle()),
    );
  }

  // 테두리있는 라운드 텍스트 버튼 - 21
  static ElevatedButton greyBorderRound21ButtonStyle(
      String txtButton, VoidCallback onClickEvent) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          padding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7.0),
              side: BorderSide(color: CustomColors.colorBgGrey)),
          primary: CustomColors.colorCanvas,
          alignment: Alignment.center),
      onPressed: () {
        onClickEvent();
      },
      child: Text(txtButton, style: dark14TextStyle()),
    );
  }

  // 파란색 테두리있는 라운드 텍스트 버튼 - 21
  static ElevatedButton blueBorderRound21ButtonStyle(
      String txtButton, VoidCallback onClickEvent) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          padding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7.0),
              side: BorderSide(color: CustomColors.colorBgGrey)),
          primary: CustomColors.colorCanvas,
          alignment: Alignment.center),
      onPressed: () {
        onClickEvent();
      },
      child: Text(txtButton, style: dark14TextStyle()),
    );
  }

  // 보라색 테두리있는 라운드 텍스트 버튼 - 21
  static ElevatedButton purpleBorderRound21ButtonStyle(
      String txtButton, VoidCallback onClickEvent) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          padding: EdgeInsets.only(top: 15, bottom: 15, left: 30, right: 30),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50.0),
              side: BorderSide(color: CustomColors.colorAccent)),
          primary: CustomColors.colorWhite,
          alignment: Alignment.center),
      onPressed: () {
        onClickEvent();
      },
      child: Text(txtButton, style: purple16TextStyle()),
    );
  }

  //===========================================================================
  // 레디어스 스타일
  //===========================================================================

  static BorderRadius circle3BorderRadius() {
    return BorderRadius.circular(3.0);
  }

  static BorderRadius circle4BorderRadius() {
    return BorderRadius.circular(4.0);
  }

  static BorderRadius circle7BorderRadius() {
    return BorderRadius.circular(7.0);
  }

  static BorderRadius circle6BorderRadius() {
    return BorderRadius.circular(6.0);
  }

  static BorderRadius circle21BorderRadius() {
    return BorderRadius.circular(21.0);
  }

  static ClipRRect defalutImg() {
    return ClipRRect(
        borderRadius: circle3BorderRadius(),
        child: Container(
          color: CustomColors.colorBgGrey,
        ));
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

  static TextStyle greyBold14TextStyle() {
    return TextStyle(
        fontSize: 14,
        color: CustomColors.colorFontGrey,
        fontWeight: FontWeight.bold);
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
        color: CustomColors.colorFontTitle,
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

  static TextStyle bold20TextStyle() {
    return TextStyle(
        fontSize: 20,
        color: CustomColors.colorFontGrey,
        fontWeight: FontWeight.bold);
  }

  static TextStyle bold24TextStyle() {
    return TextStyle(
        fontSize: 24,
        color: CustomColors.colorFontGrey,
        fontWeight: FontWeight.bold);
  }

  static TextStyle normal20TextStyle() {
    return TextStyle(
        fontSize: 20,
        color: CustomColors.colorFontGrey,
        fontWeight: FontWeight.normal);
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
        fontWeight: FontWeight.bold);
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
