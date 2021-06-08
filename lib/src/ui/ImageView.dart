import 'dart:io';

import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pinch_zoom/pinch_zoom.dart';

class ImageView extends StatefulWidget {
  final File videoURL;

  const ImageView({Key key, this.videoURL}) : super(key: key);

  @override
  _ImageView createState() => _ImageView();
}

class _ImageView extends State<ImageView> {
  File _videoFile;

  @override
  void initState() {
    super.initState();

    _videoFile = widget.videoURL;
  }

  //========================================================================================================================
  // 메인 위젯
  //========================================================================================================================
  @override
  Widget build(BuildContext context) {
    return Theme(
        data: CustomStyles.defaultTheme(),
        child: Scaffold(
            appBar: CustomStyles.defaultAppBar('이미지', () {
              Navigator.pop(context);
            }),
            body: Container(
                alignment: Alignment.center,
                color: CustomColors.colorWhite,
                child: PinchZoom(
                  image: Image.file(_videoFile),
                  zoomedBackgroundColor: Colors.black.withOpacity(0.5),
                  resetDuration: const Duration(milliseconds: 100),
                  maxScale: 2.5,
                  onZoomStart: (){print('Start zooming');},
                  onZoomEnd: (){print('Stop zooming');},
                ))));
  }
}
