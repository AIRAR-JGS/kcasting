import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/KCastingAppData.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/model/ImageListModel.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'AuditionApplyUploadVideo.dart';

/*
* 오디션 지원하기 - 이미지 업로드
* */
class AuditionApplyUploadImage extends StatefulWidget {
  final int castingSeq;
  final String projectName;
  final String castingName;
  final int actorSeq;

  const AuditionApplyUploadImage(
      {Key key,
      this.castingSeq,
      this.projectName,
      this.castingName,
      this.actorSeq})
      : super(key: key);

  @override
  _AuditionApplyUploadImage createState() => _AuditionApplyUploadImage();
}

class _AuditionApplyUploadImage extends State<AuditionApplyUploadImage>
    with BaseUtilMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  bool _kIsWeb;

  int _casting_seq;
  String _projectName;
  String _castingName;
  int _actor_seq;

  File _imageFile;
  List<ImageListModel> _myPhotos = [];
  final picker = ImagePicker();

  var actorImage = []; // 보유 배우 회원 이미지

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

    _casting_seq = widget.castingSeq;
    _projectName = widget.projectName;
    _castingName = widget.castingName;
    _actor_seq = widget.actorSeq;

    if (KCastingAppData().myInfo[APIConstants.member_type] ==
        APIConstants.member_type_actor) {
      actorImage = KCastingAppData().myImage;

      // 배우 이미지
      for (int i = 0; i < actorImage.length; i++) {
        _myPhotos.add(new ImageListModel(false, false, null, actorImage[i]));
      }
    } else if (KCastingAppData().myInfo[APIConstants.member_type] ==
        APIConstants.member_type_management) {
      // 매니지먼트 보유 배우 이미지 목록 api 호출
      requestActorListApi(context);
    }
  }

  /*
  * 매니지먼트 보유 배우 이미지 목록 api 호출
  * */
  void requestActorListApi(BuildContext context) {
    final dio = Dio();

    // 매니지먼트 보유 배우 이미지 목록 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetData = new Map();
    targetData[APIConstants.actor_seq] = _actor_seq;

    /*Map<String, dynamic> paging = new Map();
    paging[APIConstants.offset] = _actorList.length;
    paging[APIConstants.limit] = _limit;*/

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.SEL_AIM_LIST;
    params[APIConstants.target] = targetData;
    //params[APIConstants.paging] = paging;

    // 매니지먼트 보유 배우 이미지 목록 api 호출
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value != null) {
        if (value[APIConstants.resultVal]) {
          try {
            // 매니지먼트 보유 배우 이미지 목록 성공
            setState(() {
              var _responseList = value[APIConstants.data];
              if (_responseList != null && _responseList.length > 0) {
                actorImage.addAll(_responseList[APIConstants.list]);

                for (int i = 0; i < actorImage.length; i++) {
                  _myPhotos.add(
                      new ImageListModel(false, false, null, actorImage[i]));
                }
              }
            });
          } catch (e) {}
        }
      }
    });
  }

  Future getImageFromGallery() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      print(pickedFile.path);
      _imageFile = File(pickedFile.path);

      final size = _imageFile.readAsBytesSync().lengthInBytes;
      final kb = size / 1024;
      final mb = kb / 1024;

      if (mb > 100) {
        showSnackBar(context, "100MB 미만의 파일만 업로드 가능합니다.");
      } else {
        setState(() {
          _myPhotos.add(new ImageListModel(true, false, _imageFile, null));
        });
      }
    } else {
      showSnackBar(context, "선택된 이미지가 없습니다.");
    }
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
            appBar: CustomStyles.defaultAppBar('이미지 업로드', () {
              Navigator.pop(context);
            }),
            body: Builder(
              builder: (BuildContext context) {
                return Container(
                    child: Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: SingleChildScrollView(
                        child: Container(
                          padding: EdgeInsets.only(top: 20, bottom: 30),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  padding: EdgeInsets.only(left: 15, right: 15),
                                  child: Text(
                                      StringUtils.checkedString(_projectName),
                                      style:
                                          CustomStyles.darkBold12TextStyle())),
                              Container(
                                  padding: EdgeInsets.only(left: 15, right: 15),
                                  margin: EdgeInsets.only(top: 5.0),
                                  child: Text(
                                      StringUtils.checkedString(_castingName) +
                                          "역",
                                      style: CustomStyles.dark24TextStyle())),
                              Container(
                                margin: EdgeInsets.only(top: 20, bottom: 10),
                                child: Divider(
                                  height: 0.1,
                                  color: CustomColors.colorFontLightGrey,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(left: 15, right: 15),
                                child: Container(
                                  padding: const EdgeInsets.all(10.0),
                                  decoration: new BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: CustomColors.colorFontTitle,
                                  ),
                                  child: new Text('1',
                                      style: new TextStyle(
                                          color: Colors.white,
                                          fontSize:
                                              20.0)), // You can add a Icon instead of text also, like below.
                                  //child: new Icon(Icons.arrow_forward, size: 50.0, color: Colors.black38)),
                                ),
                              ),
                              Container(
                                  margin: EdgeInsets.only(top: 5.0),
                                  padding: EdgeInsets.only(left: 15, right: 15),
                                  child: Text('이미지 업로드',
                                      style: CustomStyles.bold14TextStyle())),
                              Container(
                                  margin: EdgeInsets.only(top: 5),
                                  padding: EdgeInsets.only(left: 15, right: 15),
                                  child: Text(
                                      '나를 잘 나타내는 이미지 3장을 선택 또는 업로드 해주세요.',
                                      style: CustomStyles.normal14TextStyle())),
                              Container(
                                margin: EdgeInsets.only(top: 15, bottom: 20),
                                padding: EdgeInsets.only(left: 15, right: 15),
                                child: ElevatedButton.icon(
                                    icon: Icon(Icons.camera_alt,
                                        color: CustomColors.colorFontTitle),
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.white,
                                      padding: EdgeInsets.only(
                                          left: 15,
                                          right: 20,
                                          top: 10,
                                          bottom: 10),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: CustomStyles
                                              .circle7BorderRadius(),
                                          side: BorderSide(
                                            color: CustomColors.colorFontGrey,
                                          )),
                                      elevation: 0.0,
                                    ),
                                    onPressed: () async {
                                      if (_kIsWeb) {
                                        showSnackBar(context,
                                            APIConstants.use_mobile_app);
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
                                                            Navigator.of(
                                                                    context)
                                                                .pop(),
                                                      ),
                                                      CupertinoDialogAction(
                                                        child: Text('허용'),
                                                        onPressed: () =>
                                                            openAppSettings(),
                                                      ),
                                                    ],
                                                  ));
                                        }
                                      }
                                    },
                                    label: Text("업로드",
                                        style:
                                            CustomStyles.normal16TextStyle())),
                              ),
                              StaggeredGridView.countBuilder(
                                padding: EdgeInsets.only(left: 15, right: 15),
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                crossAxisCount: 4,
                                itemCount: _myPhotos.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _myPhotos[index].isSelected =
                                            !_myPhotos[index].isSelected;
                                      });
                                    },
                                    child: Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                              borderRadius: CustomStyles
                                                  .circle7BorderRadius(),
                                              border: Border.all(
                                                  width: 3,
                                                  color: (_myPhotos[index]
                                                          .isSelected
                                                      ? CustomColors
                                                          .colorPrimary
                                                      : CustomColors
                                                          .colorFontLightGrey))),
                                          child: (_myPhotos != null &&
                                                  _myPhotos.length > 0)
                                              ? ClipRRect(
                                                  borderRadius: CustomStyles
                                                      .circle4BorderRadius(),
                                                  child: _myPhotos[index].isFile
                                                      ? Image.file(
                                                          _myPhotos[index]
                                                              .photoFile)
                                                      : CachedNetworkImage(
                                                      placeholder: (context, url) => Container(
                                                          alignment: Alignment.center,
                                                          child: CircularProgressIndicator()),
                                                          imageUrl: _myPhotos[index]
                                                                  .photoData[
                                                              APIConstants
                                                                  .actor_img_url],
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              ClipRRect(borderRadius: CustomStyles.circle4BorderRadius())))
                                              : ClipRRect(borderRadius: CustomStyles.circle4BorderRadius()),
                                        ),
                                        Container(
                                            margin: EdgeInsets.all(10),
                                            alignment: Alignment.topRight,
                                            child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  _myPhotos[index].isSelected =
                                                      !_myPhotos[index]
                                                          .isSelected;
                                                });
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: (_myPhotos[index]
                                                            .isSelected
                                                        ? CustomColors
                                                            .colorPrimary
                                                        : CustomColors
                                                            .colorFontLightGrey)),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(5.0),
                                                  child: _myPhotos[index]
                                                          .isSelected
                                                      ? Icon(
                                                          Icons.check,
                                                          size: 15.0,
                                                          color: CustomColors
                                                              .colorWhite,
                                                        )
                                                      : Icon(
                                                          Icons
                                                              .check_box_outline_blank,
                                                          size: 15.0,
                                                          color: CustomColors
                                                              .colorFontLightGrey,
                                                        ),
                                                ),
                                              ),
                                            ))
                                      ],
                                    ),
                                  );
                                },
                                staggeredTileBuilder: (int index) =>
                                    new StaggeredTile.fit(2),
                                mainAxisSpacing: 5.0,
                                crossAxisSpacing: 5.0,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                        width: MediaQuery.of(context).size.width,
                        height: 55,
                        child: CustomStyles.blueBGSquareButtonStyle('다음단계', () {
                          saveImageDataAndGoNextPage(context);
                        }))
                  ],
                ));
              },
            )));
  }

  void saveImageDataAndGoNextPage(BuildContext context) {
    int totalImgCnt = 0;

    for (int i = 0; i < _myPhotos.length; i++) {
      if (_myPhotos[i].isSelected) {
        totalImgCnt++;
      }
    }

    if (totalImgCnt < 1) {
      showSnackBar(context, '이미지를 선택해 주세요.');
      return;
    }

    if (totalImgCnt > 3) {
      showSnackBar(context, '이미지는 최대 3장까지만 업로드할 수 있습니다.');
      return;
    }

    //List<Map<String, dynamic>> imageFiles = [];
    List<Map<String, dynamic>> dbImageFiles = [];
    List<File> newImgageFiles = [];

    for (int i = 0; i < _myPhotos.length; i++) {
      if (_myPhotos[i].isSelected) {
        if (_myPhotos[i].isFile) {
          /*final bytes = _myPhotos[i].photoFile.readAsBytesSync();
          String img64 = base64Encode(bytes);

          Map<String, dynamic> fileData = new Map();
          fileData[APIConstants.base64string] = APIConstants.data_image + img64;

          imageFiles.add(fileData);*/

          newImgageFiles.add(_myPhotos[i].photoFile);
        } else {
          // url 이미지 업로드
          Map<String, dynamic> fileData = new Map();
          fileData[APIConstants.url] =
              _myPhotos[i].photoData[APIConstants.actor_img_url];

          dbImageFiles.add(fileData);
        }
      }
    }

    replaceView(
        context,
        AuditionApplyUploadVideo(
            castingSeq: _casting_seq,
            dbImgages: dbImageFiles,
            newImgages: newImgageFiles,
            projectName: _projectName,
            castingName: _castingName,
            actorSeq: _actor_seq));
  }
}
