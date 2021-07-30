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
import 'package:casting_call/src/view/mypage/production/ProductionFilmoAdd.dart';
import 'package:casting_call/src/view/mypage/production/ProductionFilmoListItem.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ProductionProfile extends StatefulWidget {
  @override
  _ProductionProfile createState() => _ProductionProfile();
}

class _ProductionProfile extends State<ProductionProfile>
    with SingleTickerProviderStateMixin, BaseUtilMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  bool _isUpload = false;
  bool _kIsWeb;

  File _profileImgFile;
  final picker = ImagePicker();

  // 필모그래피 리스트 관련 변수
  List<dynamic> _filmorgraphyList = [];
  List<dynamic> _originalFilmorgraphyList = [];
  bool _isFlimorgraphyListEditMode = false;

  List<int> _deletedFilmorgraphyList = [];

  @override
  void initState() {
    super.initState();

    requestProductionFilmorgraphyListApi(context);

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

  /*
  * 제작사 로고 이미지 수정
  * */
  Future<void> requestUpdateProductionProfile(
      BuildContext context, File profileFile) async {
    setState(() {
      _isUpload = true;
    });

    // 제작사 로고 이미지 수정 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetDatas = new Map();
    targetDatas[APIConstants.seq] = KCastingAppData().myInfo[APIConstants.seq];

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.UDF_PRD_LOGO_FORMDATA;
    params[APIConstants.target] = targetDatas;

    var temp = profileFile.path.split('/');
    String fileName = temp[temp.length - 1];
    params[APIConstants.target_files_array] =
        await MultipartFile.fromFile(profileFile.path, filename: fileName);

    // 제작사 로고 이미지 수정 api 호출
    RestClient(Dio())
        .postRequestMainControlFormData(params)
        .then((value) async {
      try {
        if (value == null) {
          // 에러 - 데이터 널
          showSnackBar(context, APIConstants.error_msg_server_not_response);
        } else {
          if (value[APIConstants.resultVal]) {
            // 제작사 로고 이미지 수정 성공
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
          } else {
            // 제작사 로고 이미지 수정 실패
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

  /*
  *제작사 필모그래피 조회
  * */
  void requestProductionFilmorgraphyListApi(BuildContext context) {
    setState(() {
      _isUpload = true;
    });

    // 제작사 필모그래피 조회 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetDatas = new Map();
    targetDatas[APIConstants.production_seq] =
        KCastingAppData().myInfo[APIConstants.seq];

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.SEL_PFM_LIST;
    params[APIConstants.target] = targetDatas;

    // 제작사 필모그래피 조회 api 호출
    RestClient(Dio()).postRequestMainControl(params).then((value) async {
      try {
        if (value != null) {
          if (value[APIConstants.resultVal]) {
            // 제작사 필모그래피 조회 성공
            setState(() {
              var _responseData = value[APIConstants.data];
              var _responseList = _responseData[APIConstants.list] as List;

              if (_responseList != null && _responseList.length > 0) {
                _filmorgraphyList.addAll(_responseList);
                _originalFilmorgraphyList.addAll(_responseList);
              }
            });
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

  /*
  *제작사 필모그래피 삭제
  * */
  void requestProductionFilmorgraphyDeleteApi(BuildContext context) {
    setState(() {
      _isUpload = true;
    });

    // 제작사 필모그래피 삭제 api 호출 시 보낼 파라미터
    Map<String, dynamic> callbackDatas = new Map();
    callbackDatas[APIConstants.production_seq] =
        KCastingAppData().myInfo[APIConstants.seq];

    Map<String, dynamic> targetDatas = new Map();
    targetDatas[APIConstants.seq] = _deletedFilmorgraphyList;
    targetDatas[APIConstants.callback] = callbackDatas;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.DEA_PFM_LIST;
    params[APIConstants.target] = targetDatas;

    // 제작사 필모그래피 삭제 api 호출
    RestClient(Dio()).postRequestMainControl(params).then((value) async {
      try {
        if (value != null) {
          if (value[APIConstants.resultVal]) {
            // 제작사 필모그래피 삭제 성공
            setState(() {
              var _responseData = value[APIConstants.data];
              var _responseList = _responseData[APIConstants.list] as List;

              if (_responseList != null && _responseList.length > 0) {
                _filmorgraphyList = _responseList;
                _originalFilmorgraphyList = _responseList;
              }
            });
          } else {
            showSnackBar(context, APIConstants.error_msg_try_again);
          }
        } else {
          // 에러 - 데이터 널 - 서버가 응답하지 않습니다. 다시 시도해 주세요
          showSnackBar(context, APIConstants.error_msg_server_not_response);
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
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

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
            requestUpdateProductionProfile(context, _profileImgFile);
          });
        }
      } else {
        showSnackBar(context, "선택된 이미지가 없습니다.");
      }
    }
  }

  /*
  * 필모그래피 추가
  * */
  Widget tabFilmography() {
    return Container(
        margin: EdgeInsets.only(bottom: 30),
        child: Column(
          children: [
            Visibility(
              child: Container(
                padding:
                    EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 15),
                child: Row(children: [
                  Expanded(
                      flex: 1,
                      child: Text(
                          '출연 작품: ' + _filmorgraphyList.length.toString(),
                          style: CustomStyles.normal14TextStyle())),
                  Expanded(
                      flex: 0,
                      child: CustomStyles.darkBold14TextButtonStyle('추가', () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProductionFilmoAdd()));
                      })),
                  Container(width: 20),
                  Expanded(
                      flex: 0,
                      child: CustomStyles.darkBold14TextButtonStyle('편집', () {
                        setState(() {
                          _isFlimorgraphyListEditMode = true;
                        });
                      }))
                ]),
              ),
              visible: !_isFlimorgraphyListEditMode,
            ),
            Visibility(
              child: Container(
                padding:
                    EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 15),
                child: Row(children: [
                  Expanded(
                      flex: 1,
                      child: Text(
                          '출연 작품: ' + _filmorgraphyList.length.toString(),
                          style: CustomStyles.normal14TextStyle())),
                  Expanded(
                      flex: 0,
                      child: CustomStyles.darkBold14TextButtonStyle('취소', () {
                        setState(() {
                          _filmorgraphyList.clear();
                          _filmorgraphyList.addAll(_originalFilmorgraphyList);

                          _deletedFilmorgraphyList = [];

                          _isFlimorgraphyListEditMode = false;
                        });
                      })),
                  Container(width: 20),
                  Expanded(
                      flex: 0,
                      child: CustomStyles.darkBold14TextButtonStyle('저장', () {
                        setState(() {
                          _originalFilmorgraphyList.clear();
                          _originalFilmorgraphyList.addAll(_filmorgraphyList);

                          _isFlimorgraphyListEditMode = false;

                          if (_deletedFilmorgraphyList.length > 0)
                            requestProductionFilmorgraphyDeleteApi(context);
                        });
                      }))
                ]),
              ),
              visible: _isFlimorgraphyListEditMode,
            ),
            Wrap(
              children: [
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.only(left: 10, right: 10),
                  itemCount: _filmorgraphyList.length,
                  itemBuilder: (context, index) {
                    final item = _filmorgraphyList[index];
                    return _isFlimorgraphyListEditMode
                        ? Dismissible(
                            direction: DismissDirection.endToStart,
                            key: Key(item[APIConstants.project_name]),
                            onDismissed: (direction) {
                              // 아이템 삭제
                              setState(() {
                                _deletedFilmorgraphyList.add(_filmorgraphyList[
                                        index]
                                    [APIConstants.productionFilmography_seq]);
                                _filmorgraphyList.removeAt(index);
                              });
                            },
                            background: Container(
                              width: MediaQuery.of(context).size.width,
                              alignment: Alignment.centerRight,
                              color: CustomColors.colorWhite,
                              child: Container(
                                width: 60,
                                padding: EdgeInsets.all(10),
                                alignment: Alignment.center,
                                height: double.infinity,
                                color: CustomColors.colorRed,
                                child: Icon(
                                  Icons.delete,
                                  color: CustomColors.colorWhite,
                                ),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(bottom: 10),
                                  child: Divider(
                                    height: 0.1,
                                    color: CustomColors.colorFontLightGrey,
                                  ),
                                ),
                                ProductionFilmoListItem(
                                    idx: index,
                                    data: _filmorgraphyList[index],
                                    isEditMode: _isFlimorgraphyListEditMode,
                                    onClickEvent: () {
                                      // 아이템 삭제
                                      setState(() {
                                        _deletedFilmorgraphyList.add(
                                            _filmorgraphyList[index][APIConstants
                                                .productionFilmography_seq]);
                                        _filmorgraphyList.removeAt(index);
                                      });
                                    })
                              ],
                            ))
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                margin: EdgeInsets.only(bottom: 10),
                                child: Divider(
                                  height: 0.1,
                                  color: CustomColors.colorFontLightGrey,
                                ),
                              ),
                              ProductionFilmoListItem(
                                  idx: index,
                                  data: _filmorgraphyList[index],
                                  isEditMode: _isFlimorgraphyListEditMode,
                                  onClickEvent: () {})
                            ],
                          );
                  },
                )
              ],
            ),
          ],
        ));
  }

  /*
  * 메인 위젯
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
                              }
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
                                    child: CachedNetworkImage(
                                        placeholder: (context, url) => Container(
                                            alignment: Alignment.center,
                                            child: CircularProgressIndicator()),
                                        imageUrl: KCastingAppData().myInfo[
                                            APIConstants.production_img_url],
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
                              KCastingAppData()
                                  .myInfo[APIConstants.production_name],
                              style: CustomStyles.normal32TextStyle())),
                      Container(
                          width: MediaQuery.of(context).size.width,
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(left: 15, right: 15),
                          margin: EdgeInsets.only(top: 20.0),
                          child: Text('홈페이지',
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
                      Container(
                          width: MediaQuery.of(context).size.width,
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(left: 15, right: 15),
                          margin: EdgeInsets.only(top: 20.0),
                          child: Text('필모그래피',
                              style: CustomStyles.bold14TextStyle())),
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        child: Divider(
                          height: 1,
                          color: CustomColors.colorFontLightGrey,
                        ),
                      ),
                      Expanded(flex: 0, child: tabFilmography()),
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
