import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
//import 'package:casting_call/src/ui/VimeoVideoPlayer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoView extends StatefulWidget {
  final String videoURL;

  const VideoView({Key key, this.videoURL}) : super(key: key);

  @override
  _VideoView createState() => _VideoView();
}

class _VideoView extends State<VideoView> {
  String _videoURL;

  VideoPlayerController _controller;
  Future<void> initFuture;

  double videoHeight;
  double videoWidth;
  double videoMargin;

  int position;

  //QualityLinks _quality;
  Map _qualityValues;
  String _qualityValue;

  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();

    _videoURL = widget.videoURL;

    _controller = VideoPlayerController.network(_videoURL);
    _controller.setLooping(false);
    initFuture =
        _controller.initialize().then((value) => _controller.addListener(() {
              if (!_controller.value.isPlaying &&
                  _controller.value.initialized &&
                  (_controller.value.duration == _controller.value.position)) {
                //checking the duration and position every time
                //Video Completed//
                setState(() {
                  _isPlaying = false;
                  /*_controller.pause();
              _controller.seekTo(Duration.zero);*/
                });
              }
            }));

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
    super.dispose();
    _controller.dispose();
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
              child: FutureBuilder(
                  future: initFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      //비디오 너비 및 높이 제어
                      videoHeight = MediaQuery.of(context).size.width /
                          _controller.value.aspectRatio;
                      videoWidth = MediaQuery.of(context).size.width;
                      videoMargin = 0;

                      //플레이어 요소 렌더링
                      return Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          Container(
                            height: videoHeight,
                            width: videoWidth,
                            child: VideoPlayer(_controller),
                          ),
                          Visibility(
                            child: GestureDetector(
                              onTap: () async {
                                await _controller.seekTo(Duration.zero);
                                setState(() {
                                  _isPlaying = true;
                                  _controller.play();
                                });
                              },
                              child: Image.asset('assets/images/btn_play.png',
                                  width: 50),
                            ),
                            visible: !_isPlaying,
                          )
                        ],
                      );
                    } else {
                      return Center(
                          heightFactor: 6, child: CircularProgressIndicator());
                    }
                  }),
            )));
  }
}