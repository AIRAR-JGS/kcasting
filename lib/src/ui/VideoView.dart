import 'dart:async';

import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:flick_video_player/flick_video_player.dart';

//import 'package:casting_call/src/ui/VimeoVideoPlayer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class VideoView extends StatefulWidget {
  final String videoURL;

  const VideoView({Key key, this.videoURL}) : super(key: key);

  @override
  _VideoView createState() => _VideoView();
}

class _VideoView extends State<VideoView> {
  String _videoURL;
  FlickManager flickManager;
  VideoPlayerController _controller;

  Future<void> initFuture;
  StreamController<Future<void>> _streamController =
      StreamController<Future<void>>();

  double videoHeight;
  double videoWidth;
  double videoMargin;

  int position;

  //QualityLinks _quality;
  Map _qualityValues;
  String _qualityValue;

  @override
  void initState() {
    super.initState();

    _videoURL = widget.videoURL;

    _controller = VideoPlayerController.network(_videoURL)..initialize().then((_) {
      initFuture = _controller.initialize();

      _controller.setLooping(false);

      flickManager = FlickManager(videoPlayerController: _controller);

      _streamController.add(initFuture);
    });





    /*initFuture =
        _controller.initialize().then((value) => _controller.addListener(() {
              if (!_controller.value.isPlaying &&
                  _controller.value.isInitialized &&
                  (_controller.value.duration == _controller.value.position)) {
                setState(() {

                  flickManager = FlickManager(
                      videoPlayerController: _controller
                  );
                });

              }
            }));*/

    /*_myVideos.add('525373676');
    _myVideos.add('525381181');
    _myVideos.add('525448076');
    _myVideos.add('525405003');*/

    /* _quality = QualityLinks('525405003');

    _quality.getQualitiesSync().then((value) {
      setState(() {
        _qualityValues = value;
        _qualityValue = value[value.lastKey()];
        _controller = VideoPlayerController.network(_qualityValue);
        _controller.setLooping(false);
        initFuture = _controller
            .initialize()
            .then((value) => _controller.addListener(() {
                  setState(() {
                    if (!_controller.value.isPlaying &&
                        _controller.value.initialized &&
                        (_controller.value.duration ==
                            _controller.value.position)) {
                      //checking the duration and position every time
                      //Video Completed//
                      setState(() {
                        _isPlaying = false;
                        _controller.pause();
                        _controller.seekTo(Duration.zero);
                      });
                    }
                  });
                }));
      });
    });*/
  }

  @override
  void dispose() {
    flickManager.dispose();
    _controller.dispose();

    super.dispose();
  }

  //========================================================================================================================
  // 메인 위젯
  //========================================================================================================================
  @override
  Widget build(BuildContext context) {
    return Theme(
        data: CustomStyles.defaultTheme(),
        child: Scaffold(
            appBar: CustomStyles.defaultAppBar('내 비디오', () {
              Navigator.pop(context);
            }),
            body: Container(
              alignment: Alignment.center,
              color: CustomColors.colorBlack,
              child: StreamBuilder(
                  stream: _streamController.stream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return Center(child: CircularProgressIndicator());

                    return FutureBuilder(
                        future: initFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            //플레이어 요소 렌더링
                            return AspectRatio(
                                aspectRatio: _controller.value.aspectRatio,
                                child: FlickVideoPlayer(
                                    flickManager: flickManager,
                                    preferredDeviceOrientationFullscreen: [
                                      DeviceOrientation.portraitUp,
                                      DeviceOrientation.landscapeLeft,
                                      DeviceOrientation.landscapeRight,
                                    ],
                                    flickVideoWithControls:
                                        FlickVideoWithControls(
                                      controls: FlickPortraitControls(),
                                    ),
                                    flickVideoWithControlsFullscreen:
                                        FlickVideoWithControls(
                                      videoFit: BoxFit.fitWidth,
                                      controls: FlickPortraitControls(),
                                    ),
                                    systemUIOverlayFullscreen: [
                                      SystemUiOverlay.bottom
                                    ],
                                    wakelockEnabledFullscreen: true,
                                    wakelockEnabled: true));
                          } else {
                            return Center(
                                heightFactor: 6,
                                child: CircularProgressIndicator());
                          }
                        });
                  }),
            )));
  }
}
