import 'package:casting_call/res/CustomColors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class BaseWidget {}

mixin BaseUtilMixin {
  /*
  * 스낵바
  * */
  void showSnackBar(BuildContext context, String msg) {
    Future<Null>.delayed(Duration.zero, () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  /*
  * Navigator.pushReplacement
  * */
  void replaceView(BuildContext _context, Widget _widget) {
    Navigator.pushReplacement(
      _context,
      MaterialPageRoute(builder: (context) => _widget),
    );
  }

  /*
  * Navigator.push
  * */
  void addView(BuildContext _context, Widget _widget) {
    Navigator.push(
      _context,
      MaterialPageRoute(builder: (context) => _widget),
    );
  }

  /*
  * Date Picker
  * */
  void showDatePickerForBirthDay(BuildContext _context, Function(DateTime) onClickEvent) {
    DatePicker.showDatePicker(_context,
        showTitleActions: true,
        minTime: DateTime(1900, 1, 1),
        maxTime: DateTime.now(),
        theme: DatePickerTheme(
            headerColor: CustomColors.colorWhite,
            backgroundColor: CustomColors.colorWhite,
            itemStyle: TextStyle(
                color: CustomColors.colorFontGrey,
                fontWeight: FontWeight.bold,
                fontSize: 15),
            doneStyle:
                TextStyle(color: CustomColors.colorFontGrey, fontSize: 13),
            cancelStyle:
                TextStyle(color: CustomColors.colorFontGrey, fontSize: 13)),
        onChanged: (date) {}, onConfirm: (date) {
      onClickEvent(date);
    }, currentTime: DateTime.now(), locale: LocaleType.ko);
  }

  void showDatePickerForDday(BuildContext _context, Function(DateTime) onClickEvent) {
    DateTime today = DateTime.now();

    DatePicker.showDatePicker(_context,
        showTitleActions: true,
        minTime: today,
        maxTime: DateTime(today.year + 10, 1, 1),
        theme: DatePickerTheme(
            headerColor: CustomColors.colorWhite,
            backgroundColor: CustomColors.colorWhite,
            itemStyle: TextStyle(
                color: CustomColors.colorFontGrey,
                fontWeight: FontWeight.bold,
                fontSize: 15),
            doneStyle:
            TextStyle(color: CustomColors.colorFontGrey, fontSize: 13),
            cancelStyle:
            TextStyle(color: CustomColors.colorFontGrey, fontSize: 13)),
        onChanged: (date) {}, onConfirm: (date) {
          onClickEvent(date);
        }, currentTime: DateTime.now(), locale: LocaleType.ko);
  }

  /*
  * 웹뷰 호출
  * */
  Future<void> launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        enableDomStorage: true,
        forceSafariVC: false,
        forceWebView: true,
        enableJavaScript: true
      );
    } else {
      throw '$url을 열 수 없습니다.';
    }
  }
}
