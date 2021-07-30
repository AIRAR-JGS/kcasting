import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pinch_zoom/pinch_zoom.dart';

class ImageView extends StatefulWidget {
  //final File videoURL;
  final String imgURL;

  const ImageView({Key key, this.imgURL}) : super(key: key);

  @override
  _ImageView createState() => _ImageView();
}

class _ImageView extends State<ImageView> {
  String _imgURL;

  @override
  void initState() {
    super.initState();

    _imgURL = widget.imgURL;
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
                  image: CachedNetworkImage(
                      placeholder: (context, url) => Container(
                          alignment: Alignment.center,
                          child: CircularProgressIndicator()),
                      imageUrl: _imgURL,
                      errorWidget: (context, url, error) => Container()),
                  zoomedBackgroundColor: Colors.black.withOpacity(0.5),
                  resetDuration: const Duration(milliseconds: 100),
                  maxScale: 2.5,
                  onZoomStart: (){},
                  onZoomEnd: (){},
                ))));
  }
}
