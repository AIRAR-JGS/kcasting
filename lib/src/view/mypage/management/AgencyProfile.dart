import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
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

  bool _isUpload = false;
  bool _kIsWeb;

  File _profileImgFile;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    try {
      if (Platform.isAndroid || Platform.isIOS) {
        _kIsWeb = false;
      } else {
        _kIsWeb = true;
      }
    } catch (e) {
      _kIsWeb = true;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  /*
  * 매니지먼트 로고 이미지 수정
  * */
  void requestUpdateAgencyProfile(
      BuildContext context, File profileFile) async {
    setState(() {
      _isUpload = true;
    });

    Map<String, dynamic> targetDatas = new Map();
    targetDatas[APIConstants.seq] =
        KCastingAppData().myInfo[APIConstants.management_seq];

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.UDF_MGM_LOGO_FORMDATA;
    params[APIConstants.target] = targetDatas;

    var temp = profileFile.path.split('/');
    String fileName = temp[temp.length - 1];
    params[APIConstants.target_files_array] =
        await MultipartFile.fromFile(profileFile.path, filename: fileName);

    // 매니지먼트 로고 이미지 수정 api 호출
    RestClient(Dio())
        .postRequestMainControlFormData(params)
        .then((value) async {
      try {
        if (value == null) {
          // 에러 - 데이터 널
          showSnackBar(context, APIConstants.error_msg_server_not_response);
        } else {
          if (value[APIConstants.resultVal]) {
            // 매니지먼트 로고 이미지 수정 성공
            var _responseData = value[APIConstants.data];
            var _responseList = _responseData[APIConstants.list] as List;

            setState(() {
              // 수정된 회원정보 전역변수에 저장
              if (_responseList.length > 0) {
                var newProfileData = _responseList[0];

                if (newProfileData[APIConstants.management_logo_img_url] !=
                    null) {
                  KCastingAppData()
                          .myInfo[APIConstants.management_logo_img_url] =
                      newProfileData[APIConstants.management_logo_img_url];
                }
              }
            });
          } else {
            // 매니지먼트 로고 이미지 수정 실패
            showSnackBar(context, APIConstants.error_msg_try_again);
          }
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

  // 갤러리에서 이미지 가져오기
  Future getImageFromGallery() async {
    if (_kIsWeb) {
      showSnackBar(context, APIConstants.use_mobile_app);
    } else {
      final pickedFile = await picker.getImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        File file = File(pickedFile.path);

        final size = file.readAsBytesSync().lengthInBytes;
        final kb = size / 1024;
        final mb = kb / 1024;

        if (mb > 100) {
          showSnackBar(context, "100MB 미만의 파일만 업로드 가능합니다.");
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
            body: Stack(
              children: [
                Container(
                    child: SingleChildScrollView(
                        child: Container(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                      Container(
                          margin: EdgeInsets.only(top: 30, bottom: 15),
                          child: GestureDetector(
                            onTap: () async {
                              if (_kIsWeb) {
                                showSnackBar(
                                    context, APIConstants.use_mobile_app);
                              } else {
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
                                                      Navigator.of(context)
                                                          .pop(),
                                                ),
                                                CupertinoDialogAction(
                                                    child: Text('허용'),
                                                    onPressed: () =>
                                                        openAppSettings())
                                              ]));
                                }
                              }
                            },
                            child: KCastingAppData().myInfo[
                                        APIConstants.management_logo_img_url] ==
                                    null
                                ? Icon(
                                    Icons.account_circle,
                                    color: CustomColors.colorFontLightGrey,
                                    size: 100,
                                  )
                                : ClipOval(
                                    child: CachedNetworkImage(
                                        imageUrl: KCastingAppData().myInfo[
                                            APIConstants
                                                .management_logo_img_url],
                                        fit: BoxFit.cover,
                                        width: 100.0,
                                        height: 100.0,
                                        errorWidget: (context, url, error) =>
                                            Icon(
                                              Icons.account_circle,
                                              color: CustomColors
                                                  .colorFontLightGrey,
                                              size: 100,
                                            ))),
                          )),
                      Container(
                          margin: EdgeInsets.only(bottom: 30),
                          child: Text(
                              StringUtils.checkedString(KCastingAppData()
                                  .myInfo[APIConstants.management_name]),
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
                              StringUtils.isEmpty(
                                      KCastingAppData().myInfo[APIConstants.id])
                                  ? '-'
                                  : KCastingAppData().myInfo[APIConstants.id],
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
                                      .myInfo[APIConstants.management_CEO_name])
                                  ? '-'
                                  : KCastingAppData()
                                      .myInfo[APIConstants.management_CEO_name],
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
                                      .myInfo[APIConstants.management_email])
                                  ? '-'
                                  : KCastingAppData()
                                      .myInfo[APIConstants.management_email],
                              style: CustomStyles.dark14TextStyle())),
                      Container(
                          margin: EdgeInsets.only(top: 30),
                          child: Divider(
                            height: 1,
                            color: CustomColors.colorFontLightGrey,
                          ))
                      ////
                    ])))),
                Visibility(
                  child: Container(
                      color: Colors.black38,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator()),
                  visible: _isUpload,
                )
              ],
            )));
  }
}
