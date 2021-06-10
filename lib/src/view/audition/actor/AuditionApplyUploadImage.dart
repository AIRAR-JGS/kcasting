import 'dart:convert';
import 'dart:io';

import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/KCastingAppData.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/model/ImageListModel.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/util/StringUtils.dart';
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

  const AuditionApplyUploadImage(
      {Key key, this.castingSeq, this.projectName, this.castingName})
      : super(key: key);

  @override
  _AuditionApplyUploadImage createState() => _AuditionApplyUploadImage();
}

class _AuditionApplyUploadImage extends State<AuditionApplyUploadImage>
    with BaseUtilMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  int _casting_seq;
  String _projectName;
  String _castingName;

  File _imageFile;
  List<ImageListModel> _myPhotos = [];
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    _casting_seq = widget.castingSeq;
    _projectName = widget.projectName;
    _castingName = widget.castingName;

    // 배우 이미지
    for (int i = 0; i < KCastingAppData().myImage.length; i++) {
      _myPhotos.add(
          new ImageListModel(false, false, null, KCastingAppData().myImage[i]));
    }
  }

  Future getImageFromGallery() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      print(pickedFile.path);
      _imageFile = File(pickedFile.path);

      final size = _imageFile.readAsBytesSync().lengthInBytes;
      final kb = size / 1024;
      final mb = kb / 1024;

      if (mb > 25) {
        showSnackBar(context, "25MB 미만의 파일만 업로드 가능합니다.");
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
                                      '나를 잘 나타내는 이미지 4장을 선택 또는 업로드 해주세요.',
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
                                                          openAppSettings(),
                                                    ),
                                                  ],
                                                ));
                                      }
                                      //
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
                                                      ? Image.file(_myPhotos[index]
                                                          .photoFile)
                                                      : Image.network(
                                                          _myPhotos[index].photoData[
                                                              APIConstants
                                                                  .actor_img_url]))
                                              : ClipRRect(
                                                  borderRadius: CustomStyles
                                                      .circle4BorderRadius()),
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

    if (totalImgCnt > 4) {
      showSnackBar(context, '이미지는 최대 4장까지만 업로드할 수 있습니다.');
      return;
    }

    List<Map<String, dynamic>> imageFiles = [];

    for (int i = 0; i < _myPhotos.length; i++) {
      if (_myPhotos[i].isSelected) {
        if (_myPhotos[i].isFile) {
          print("ddd");

          final bytes = _myPhotos[i].photoFile.readAsBytesSync();
          String img64 = base64Encode(bytes);

          Map<String, dynamic> fileData = new Map();
          fileData[APIConstants.base64string] = APIConstants.data_image + img64;

          imageFiles.add(fileData);
        } else {
          // url 이미지 업로드
        }
      }
    }

    replaceView(
        context,
        AuditionApplyUploadVideo(
            castingSeq: _casting_seq,
            applyImageData: imageFiles,
            projectName: _projectName,
            castingName: _castingName));
  }
}
