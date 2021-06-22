import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/KCastingAppData.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

/*
* 매니지먼트 프로필 관리
* */
class AgencyProfile extends StatefulWidget {
  @override
  _AgencyProfile createState() => _AgencyProfile();
}

class _AgencyProfile extends State<AgencyProfile>
    with SingleTickerProviderStateMixin, BaseUtilMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  File _profileImgFile;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  /*
  * 매니지먼트 로고 이미지 수정
  * */
  void requestUpdateAgencyProfile(BuildContext context, File profileFile) {
    final dio = Dio();

    final bytes = File(profileFile.path).readAsBytesSync();
    String img64 = base64Encode(bytes);

    // 매니지먼트 로고 이미지 수정 api 호출 시 보낼 파라미터
    Map<String, dynamic> fileData = new Map();
    fileData[APIConstants.base64string] = APIConstants.data_image + img64;

    Map<String, dynamic> targetDatas = new Map();
    targetDatas[APIConstants.seq] = KCastingAppData().myInfo[APIConstants.seq];
    targetDatas[APIConstants.file] = fileData;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.UDF_PRD_LOGO;
    params[APIConstants.target] = targetDatas;

    // 매니지먼트 로고 이미지 수정 api 호출
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value == null) {
        // 에러 - 데이터 널
        showSnackBar(context, APIConstants.error_msg_server_not_response);
      } else {
        if (value[APIConstants.resultVal]) {
          try {
            // 매니지먼트 로고 이미지 수정 성공
            var _responseData = value[APIConstants.data];
            var _responseList = _responseData[APIConstants.list] as List;

            setState(() {
              // 수정된 회원정보 전역변수에 저장
              if (_responseList.length > 0) {
                var newProfileData = _responseList[0];

                if (newProfileData[APIConstants.production_img_url] != null) {
                  KCastingAppData().myInfo[APIConstants.production_img_url] =
                      newProfileData[APIConstants.production_img_url];
                }
              }
            });
          } catch (e) {
            showSnackBar(context, APIConstants.error_msg_try_again);
          }
        } else {
          // 매니지먼트 로고 이미지 수정 실패
          showSnackBar(context, APIConstants.error_msg_try_again);
        }
      }
    });
  }

  // 갤러리에서 이미지 가져오기
  Future getImageFromGallery() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File file = File(pickedFile.path);

      final size = file.readAsBytesSync().lengthInBytes;
      final kb = size / 1024;
      final mb = kb / 1024;

      if (mb > 25) {
        showSnackBar(context, "25MB 미만의 파일만 업로드 가능합니다.");
      } else {
        setState(() {
          _profileImgFile = file;
          requestUpdateAgencyProfile(context, _profileImgFile);
        });
      }
    } else {
      showSnackBar(context, "선택된 이미지가 없습니다.");
    }
  }

  /*
  *  메인 위젯
  * */
  @override
  Widget build(BuildContext context) {
    return Theme(
        data: CustomStyles.defaultTheme(),
        child: Scaffold(
            key: _scaffoldKey,
            appBar: CustomStyles.defaultAppBar('프로필 관리', () {
              Navigator.pop(context);
            }),
            body: Container(
              child: SingleChildScrollView(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                          margin: EdgeInsets.only(top: 30, bottom: 15),
                          child: GestureDetector(
                            onTap: () async {
                              //
                              var status = Platform.isAndroid
                                  ? await Permission.storage.request()
                                  : await Permission.photos.request();
                              if (status.isGranted) {
                                getImageFromGallery();
                              } else {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        CupertinoAlertDialog(
                                          title: Text('저장공간 접근권한'),
                                          content: Text(
                                              '사진 또는 비디오를 업로드하려면, 기기 사진, 미디어, 파일 접근 권한이 필요합니다.'),
                                          actions: <Widget>[
                                            CupertinoDialogAction(
                                              child: Text('거부'),
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                            ),
                                            CupertinoDialogAction(
                                              child: Text('허용'),
                                              onPressed: () =>
                                                  openAppSettings(),
                                            ),
                                          ],
                                        ));
                              }
                              //
                            },
                            child: KCastingAppData().myInfo[
                                        APIConstants.production_img_url] ==
                                    null
                                ? Icon(
                                    Icons.account_circle,
                                    color: CustomColors.colorFontLightGrey,
                                    size: 100,
                                  )
                                : ClipOval(
                                    child: Image.network(
                                        KCastingAppData().myInfo[
                                            APIConstants.production_img_url],
                                        fit: BoxFit.cover,
                                        width: 100.0,
                                        height: 100.0),
                                  ),
                          )),
                      Container(
                          margin: EdgeInsets.only(bottom: 30),
                          child: Text(
                              StringUtils.checkedString(KCastingAppData()
                                  .myInfo[APIConstants.production_name]),
                              style: CustomStyles.normal32TextStyle())),
                      Container(
                          width: MediaQuery.of(context).size.width,
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(left: 15, right: 15),
                          margin: EdgeInsets.only(top: 20.0),
                          child: Text('아이디',
                              style: CustomStyles.bold14TextStyle())),
                      Container(
                          width: MediaQuery.of(context).size.width,
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(left: 15, right: 15),
                          margin: EdgeInsets.only(top: 10.0),
                          child: Text(
                              StringUtils.isEmpty(KCastingAppData()
                                      .myInfo[APIConstants.production_homepage])
                                  ? '-'
                                  : KCastingAppData()
                                      .myInfo[APIConstants.production_homepage],
                              style: CustomStyles.dark14TextStyle())),
                      Container(
                          width: MediaQuery.of(context).size.width,
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(left: 15, right: 15),
                          margin: EdgeInsets.only(top: 20.0),
                          child: Text('이름',
                              style: CustomStyles.bold14TextStyle())),
                      Container(
                          width: MediaQuery.of(context).size.width,
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(left: 15, right: 15),
                          margin: EdgeInsets.only(top: 10.0),
                          child: Text(
                              StringUtils.isEmpty(KCastingAppData()
                                      .myInfo[APIConstants.production_email])
                                  ? '-'
                                  : KCastingAppData()
                                      .myInfo[APIConstants.production_email],
                              style: CustomStyles.dark14TextStyle())),
                      Container(
                          width: MediaQuery.of(context).size.width,
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(left: 15, right: 15),
                          margin: EdgeInsets.only(top: 20.0),
                          child: Text('이메일',
                              style: CustomStyles.bold14TextStyle())),
                      Container(
                          width: MediaQuery.of(context).size.width,
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(left: 15, right: 15),
                          margin: EdgeInsets.only(top: 10.0),
                          child: Text(
                              StringUtils.isEmpty(KCastingAppData()
                                      .myInfo[APIConstants.production_email])
                                  ? '-'
                                  : KCastingAppData()
                                      .myInfo[APIConstants.production_email],
                              style: CustomStyles.dark14TextStyle())),
                      Container(
                        margin: EdgeInsets.only(top: 30),
                        child: Divider(
                          height: 1,
                          color: CustomColors.colorFontLightGrey,
                        ),
                      ),
                      ////
                    ],
                  ),
                ),
              ),
            )));
  }
}