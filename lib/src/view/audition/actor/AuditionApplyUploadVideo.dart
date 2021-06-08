import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/model/VideoListModel.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../../KCastingAppData.dart';
import 'AuditionApplyUploadImage.dart';
import 'AuditionApplyUploadProfile.dart';

class AuditionApplyUploadVideo extends StatefulWidget {
  final int castingSeq;
  final String projectName;
  final String castingName;
  final List<dynamic> applyImageData;

  const AuditionApplyUploadVideo(
      {Key key,
      this.castingSeq,
      this.projectName,
      this.castingName,
      this.applyImageData})
      : super(key: key);

  @override
  _AuditionApplyUploadVideo createState() => _AuditionApplyUploadVideo();
}

class _AuditionApplyUploadVideo extends State<AuditionApplyUploadVideo> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  final picker = ImagePicker();

  int _castingSeq;
  String _projectName;
  String _castingName;
  List<dynamic> _applyImageData;

  List<VideoListModel> _myVideos = [];

  bool _isUpload = false;

  @override
  void initState() {
    super.initState();

    _castingSeq = widget.castingSeq;
    _projectName = widget.projectName;
    _castingName = widget.castingName;
    _applyImageData = widget.applyImageData;

    // 배우 비디오
    for (int i = 0; i < KCastingAppData().myVideo.length; i++) {
      _myVideos.add(new VideoListModel(
          false, false, null, null, KCastingAppData().myVideo[i]));
    }
  }

  void showSnackBar(context, String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  /*
  * url to file
  * */
  /*Future<File> urlToFile(String imageUrl, String fileType) async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;

    File file = new File('$tempPath' +
        DateTime.now().millisecondsSinceEpoch.toString() +
        fileType);

    http.Response response = await http.get(imageUrl);
    await file.writeAsBytes(response.bodyBytes);

    return file;
  }*/

  // 갤러리에서 비디오 가져오기
  Future getVideoFromGallery() async {
    final pickedFile = await picker.getVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      print(pickedFile.path);

      getVideoThumbnail(pickedFile.path);
    } else {
      showSnackBar(context, "선택된 이미지가 없습니다.");
    }
  }

  getVideoThumbnail(String filePath) async {
    var _videoFile = File(filePath);

    Uint8List _thumbnailBytes = await VideoThumbnail.thumbnailData(
        video: filePath, imageFormat: ImageFormat.JPEG);

    setState(() {
      final size = _videoFile.readAsBytesSync().lengthInBytes;
      final kb = size / 1024;
      final mb = kb / 1024;

      if (mb > 25) {
        showSnackBar(context, "25MB 미만의 파일만 업로드 가능합니다.");
      } else {
        _myVideos.add(
            new VideoListModel(true, false, _videoFile, _thumbnailBytes, null));
      }
    });
  }

  //========================================================================================================================
  // 메인 위젯
  //========================================================================================================================
  @override
  Widget build(BuildContext context) {
    return Theme(
        data: CustomStyles.defaultTheme(),
        child: Scaffold(
            key: _scaffoldKey,
            appBar: CustomStyles.defaultAppBar('비디오 업로드', () {
              Navigator.pop(context);
            }),
            body: Builder(
              builder: (BuildContext context) {
                return Stack(
                  children: [
                    Container(
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
                                      padding:
                                          EdgeInsets.only(left: 15, right: 15),
                                      child: Text(
                                          StringUtils.checkedString(
                                              _projectName),
                                          style: CustomStyles
                                              .darkBold12TextStyle())),
                                  Container(
                                      padding:
                                          EdgeInsets.only(left: 15, right: 15),
                                      margin: EdgeInsets.only(top: 5.0),
                                      child: Text(
                                          StringUtils.checkedString(
                                                  _castingName) +
                                              "역",
                                          style:
                                              CustomStyles.dark24TextStyle())),
                                  Container(
                                    margin:
                                        EdgeInsets.only(top: 20, bottom: 10),
                                    child: Divider(
                                      height: 0.1,
                                      color: CustomColors.colorFontLightGrey,
                                    ),
                                  ),
                                  Container(
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    child: Container(
                                      padding: const EdgeInsets.all(10.0),
                                      decoration: new BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: CustomColors.colorFontTitle,
                                      ),
                                      child: new Text('2',
                                          style: new TextStyle(
                                              color: Colors.white,
                                              fontSize:
                                                  20.0)), // You can add a Icon instead of text also, like below.
                                      //child: new Icon(Icons.arrow_forward, size: 50.0, color: Colors.black38)),
                                    ),
                                  ),
                                  Container(
                                      margin: EdgeInsets.only(top: 5.0),
                                      padding:
                                          EdgeInsets.only(left: 15, right: 15),
                                      child: Text('비디오 업로드',
                                          style:
                                              CustomStyles.bold14TextStyle())),
                                  Container(
                                      margin: EdgeInsets.only(top: 5),
                                      padding:
                                          EdgeInsets.only(left: 15, right: 15),
                                      child: Text(
                                          '나를 잘 나타내는 비디오 2개을 선택 또는 업로드 해주세요.',
                                          style: CustomStyles
                                              .normal14TextStyle())),
                                  Container(
                                    margin:
                                        EdgeInsets.only(top: 15, bottom: 20),
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    child: RaisedButton.icon(
                                        icon: Icon(Icons.camera_alt,
                                            color: CustomColors.colorFontTitle),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: CustomStyles
                                                .circle7BorderRadius(),
                                            side: BorderSide(
                                              color: CustomColors.colorFontGrey,
                                            )),
                                        elevation: 0.0,
                                        onPressed: () async {
                                          //
                                          var status = Platform.isAndroid
                                              ? await Permission.storage
                                                  .request()
                                              : await Permission.photos
                                                  .request();
                                          if (status.isGranted) {
                                            getVideoFromGallery();
                                          } else {
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) =>
                                                        CupertinoAlertDialog(
                                                          title:
                                                              Text('저장공간 접근권한'),
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
                                          //
                                        },
                                        padding: EdgeInsets.only(
                                            left: 15,
                                            right: 20,
                                            top: 10,
                                            bottom: 10),
                                        color: Colors.white,
                                        textColor: Colors.white,
                                        label: Text("업로드",
                                            style: CustomStyles
                                                .normal16TextStyle())),
                                  ),
                                  ListView.separated(
                                    shrinkWrap: true,
                                    padding: EdgeInsets.only(
                                        left: 15, right: 15, bottom: 10),
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: _myVideos.length,
                                    itemBuilder: (context, index) {
                                      return Stack(
                                        alignment: Alignment.center,
                                        children: <Widget>[
                                          Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              margin:
                                                  EdgeInsets.only(bottom: 10),
                                              height: 200,
                                              decoration: BoxDecoration(
                                                  borderRadius: CustomStyles
                                                      .circle7BorderRadius(),
                                                  border: Border.all(
                                                      width: 5,
                                                      color: (_myVideos[index]
                                                              .isSelected
                                                          ? CustomColors
                                                              .colorAccent
                                                          : CustomColors
                                                              .colorFontLightGrey))),
                                              child: _myVideos[index].isFile
                                                  ? Image.memory(
                                                      _myVideos[index]
                                                          .thumbnailFile,
                                                      fit: BoxFit.cover,
                                                    )
                                                  : Image.network(
                                                      _myVideos[index]
                                                              .videoData[
                                                          APIConstants
                                                              .actor_video_url_thumb],
                                                      fit: BoxFit.cover,
                                                    )),
                                          Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height: 200,
                                              margin: EdgeInsets.all(10),
                                              alignment: Alignment.topRight,
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    _myVideos[index]
                                                            .isSelected =
                                                        !_myVideos[index]
                                                            .isSelected;
                                                  });
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: (_myVideos[index]
                                                              .isSelected
                                                          ? CustomColors
                                                              .colorAccent
                                                          : CustomColors
                                                              .colorFontLightGrey)),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            5.0),
                                                    child: _myVideos[index]
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
                                              )),
                                          GestureDetector(
                                              onTap: () {
                                                /*Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              VideoView(
                                                                  videoURL:
                                                                  _myVideos[index]
                                                                      .video)),
                                                    );*/
                                              },
                                              child: Container(
                                                  alignment: Alignment.center,
                                                  width: 50,
                                                  height: 50,
                                                  child: Image.asset(
                                                      'assets/images/btn_play.png',
                                                      width: 50))),
                                        ],
                                      );
                                      //return VideosListItem(videoId: _myVideos[index]);
                                    },
                                    separatorBuilder: (context, index) {
                                      return VerticalDivider();
                                    },
                                  )
                                  /*StaggeredGridView.countBuilder(
                            padding: EdgeInsets.only(left: 15, right: 15),
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            crossAxisCount: 4,
                            itemCount: _myVideos.length,
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
                                            border: Border.all(
                                                width: 5,
                                                color: (_myPhotos[index]
                                                        .isSelected
                                                    ? CustomColors.colorAccent
                                                    : CustomColors
                                                        .colorFontLightGrey))),
                                        child: new Text('no images...')),
                                    Container(
                                        margin: EdgeInsets.all(10),
                                        alignment: Alignment.topRight,
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              _myPhotos[index].isSelected =
                                                  !_myPhotos[index].isSelected;
                                            });
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: (_myPhotos[index]
                                                        .isSelected
                                                    ? CustomColors.colorAccent
                                                    : CustomColors
                                                        .colorFontLightGrey)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: _myPhotos[index].isSelected
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
                          ),*/
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                            width: double.infinity,
                            height: 50,
                            color: Colors.grey,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                    child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 55,
                                        child: CustomStyles
                                            .greyBGSquareButtonStyle('이전단계',
                                                () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    AuditionApplyUploadImage(
                                                        castingSeq: _castingSeq,
                                                        projectName:
                                                            _projectName,
                                                        castingName:
                                                            _castingName)),
                                          );
                                        }))),
                                Expanded(
                                    child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 55,
                                        child: CustomStyles
                                            .blueBGSquareButtonStyle('다음단계',
                                                () {
                                          saveImageDataAndGoNextPage(context);
                                        })))
                              ],
                            ))
                      ],
                    )),
                    Visibility(
                      child: Container(
                        color: Colors.black38,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(),
                      ),
                      visible: _isUpload,
                    )
                  ],
                );
              },
            )));
  }

  void saveImageDataAndGoNextPage(BuildContext context) {
    int totalVideoCnt = 0;

    for (int i = 0; i < _myVideos.length; i++) {
      if (_myVideos[i].isSelected) {
        totalVideoCnt++;
      }
    }

    if (totalVideoCnt < 1) {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('비디오를 선택해 주세요.')));
      return;
    }

    if (totalVideoCnt > 2) {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('비디오는 최대 2개까지만 업로드할 수 있습니다.')));
      return;
    }

    List<Map<String, dynamic>> videoFile = [];

    for (int i = 0; i < _myVideos.length; i++) {
      if (_myVideos[i].isSelected) {
        if (_myVideos[i].isFile) {
          final bytes = _myVideos[i].videoFile.readAsBytesSync();
          String videoFile64 = base64Encode(bytes);

          String thumbnailFile64 = base64Encode(_myVideos[i].thumbnailFile);

          Map<String, dynamic> fileData = new Map();
          fileData[APIConstants.base64string] =
              APIConstants.data_file + videoFile64;
          fileData[APIConstants.base64string_thumb] =
              APIConstants.data_image + thumbnailFile64;

          videoFile.add(fileData);
        } else {}
      }
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => AuditionApplyUploadProfile(
              castingSeq: _castingSeq,
              projectName: _projectName,
              castingName: _castingName,
              applyImageData: _applyImageData,
              applyVideoData: videoFile)),
    );
  }
}
