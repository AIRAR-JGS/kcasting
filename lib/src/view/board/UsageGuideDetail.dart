import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../KCastingAppData.dart';

class UsageGuideDetail extends StatefulWidget {
  final int seq;

  const UsageGuideDetail({Key key, this.seq}) : super(key: key);

  @override
  _UsageGuideDetail createState() => _UsageGuideDetail();
}

class _UsageGuideDetail extends State<UsageGuideDetail> with BaseUtilMixin {
  bool _isUpload = false;

  int _seq;
  Map<String, dynamic> _infoData = new Map();

  @override
  void initState() {
    super.initState();

    _seq = widget.seq;

    requestInfoDetailApi(context);
  }

  /*
  * 이용안내 상세조회
  * */
  void requestInfoDetailApi(BuildContext _context) {
    setState(() {
      _isUpload = true;
    });

    // 이용안내 상세조회 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetData = new Map();
    targetData[APIConstants.useInfo_seq] = _seq;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.SEL_TOT_USEDETAILS;
    params[APIConstants.target] = targetData;

    // 이용안내 상세조회 api 호출
    RestClient(Dio()).postRequestMainControl(params).then((value) async {
      try {
        if (value != null) {
          if (value[APIConstants.resultVal]) {
            // 이용안내 상세조회 조회 성공
            var _responseData = value[APIConstants.data];

            if (_responseData == null) {
              return;
            }

            setState(() {
              List<dynamic> _responseList = _responseData[APIConstants.list];

              if (_responseList != null && _responseList.length > 0) {
                _infoData = _responseList[0];
              }
            });
          } else {
            showSnackBar(context, value[APIConstants.resultMsg]);
          }
        } else {
          showSnackBar(context, '다시 시도해 주세요.');
        }
      } catch (e) {
        showSnackBar(context, APIConstants.error_msg_try_again);
      } finally {
        setState(() {
          _isUpload = false;
        });
      }
    });
  }

  /*
  * 메인위젯
  * */
  @override
  Widget build(BuildContext context) {
    return Theme(
        data: CustomStyles.defaultTheme(),
        child: Align(
            alignment: Alignment.topCenter,
            child: Container(
                width: KCastingAppData().isWeb
                    ? CustomStyles.appWidth
                    : double.infinity,
                child: Scaffold(
                    appBar: CustomStyles.defaultAppBar('', () {
                      Navigator.pop(context);
                    }),
                    body: SingleChildScrollView(
                        child: Container(
                            margin: EdgeInsets.only(top: 30, bottom: 70),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      margin: EdgeInsets.only(
                                          bottom: 15, left: 15, right: 15),
                                      child: Text(
                                          StringUtils.checkedString(_infoData[
                                              APIConstants
                                                  .use_infomation_name]),
                                          style: CustomStyles
                                              .normal24TextStyle())),
                                  Container(
                                      margin: EdgeInsets.only(
                                          bottom: 25, left: 15, right: 15),
                                      child: Text(
                                          "등록일: " +
                                              StringUtils.checkedString(
                                                  _infoData[
                                                      APIConstants.addDate]),
                                          style: CustomStyles
                                              .normal14TextStyle())),
                                  Container(
                                      child: Divider(
                                          height: 2,
                                          color: CustomColors.colorFontTitle)),
                                  Container(
                                      margin: EdgeInsets.only(
                                          left: 15, right: 15, top: 20),
                                      child: Text(
                                          StringUtils.checkedString(_infoData[
                                              APIConstants
                                                  .use_infomation_contents]),
                                          style:
                                              CustomStyles.dark14TextStyle()))
                                ])))))));
  }
}
