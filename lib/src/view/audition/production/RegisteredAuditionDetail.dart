import 'dart:convert';
import 'dart:io';

import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/util/DateTileUtils.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:casting_call/src/view/audition/actor/AuditionApplyProfile.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

/*
* 오디션 상세
* */
class RegisteredAuditionDetail extends StatefulWidget {
  final int castingSeq;

  const RegisteredAuditionDetail({Key key, this.castingSeq}) : super(key: key);

  @override
  _RegisteredAuditionDetail createState() => _RegisteredAuditionDetail();
}

class _RegisteredAuditionDetail extends State<RegisteredAuditionDetail>
    with SingleTickerProviderStateMixin, BaseUtilMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  int _castingSeq;
  String _apiKey = APIConstants.SAR_FAD_STATE;

  Map<String, dynamic> _firstAuditionInfo = new Map();
  List<dynamic> _firstAuditionApplyList = [];

  Map<String, dynamic> _secondAuditionInfo = new Map();
  List<dynamic> _secondAuditionApplyList = [];

  Map<String, dynamic> _thirdAuditionInfo = new Map();
  List<dynamic> _thirdAuditionApplyList = [];

  Map<String, dynamic> _auditionResultInfo = new Map();
  List<dynamic> _auditionResultList = [];

  String _endDate = "";

  TabController _tabController;
  int _tabIndex = 0;

  ScrollController _scrollController;

  int _total = 0;
  int _limit = 20;

  bool _isLoading = true;

  File _profileImgFile;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    _castingSeq = widget.castingSeq;

    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection);

    requestCastingStateList(context);

    _scrollController = new ScrollController(initialScrollOffset: 5.0)
      ..addListener(_scrollListener);
  }

  _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _tabIndex = _tabController.index;

        _total = 0;
        _firstAuditionApplyList = [];
        _secondAuditionApplyList = [];
        _thirdAuditionApplyList = [];
        _auditionResultList = [];

        switch (_tabIndex) {
          case 0:
            _apiKey = APIConstants.SAR_FAD_STATE;
            break;
          case 1:
            _apiKey = APIConstants.SAR_SAD_STATE;
            break;
          case 2:
            _apiKey = APIConstants.SAR_TAD_STATE;
            break;
          case 3:
            _apiKey = APIConstants.SAR_TAD_FINSTATE;
            break;
        }

        requestCastingStateList(context);
      });
    }
  }

  _scrollListener() {
    int cnt = 0;

    switch (_tabIndex) {
      case 0:
        cnt = _firstAuditionApplyList.length;
        break;
      case 1:
        cnt = _secondAuditionApplyList.length;
        break;
      case 2:
        cnt = _thirdAuditionApplyList.length;
        break;
    }

    if (_total == 0 || cnt >= _total) return;

    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      setState(() {
        print("comes to bottom $_isLoading");
        _isLoading = true;

        if (_isLoading) {
          print("RUNNING LOAD MORE");

          requestCastingStateList(context);
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // 갤러리에서 이미지 가져오기
  Future getImageFromGallery() async {
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
        });
      }
    } else {
      showSnackBar(context, "선택된 이미지가 없습니다.");
    }
  }

  /*
  오디션 진행 현황 조회
  * */
  void requestCastingStateList(BuildContext context) {
    final dio = Dio();

    // 1차 오디션 진행 현황 조회 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetData = new Map();
    targetData[APIConstants.casting_seq] = _castingSeq;

    Map<String, dynamic> paging = new Map();
    paging[APIConstants.offset] = _firstAuditionApplyList.length;
    paging[APIConstants.limit] = _limit;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = _apiKey;
    params[APIConstants.target] = targetData;
    params[APIConstants.paging] = paging;

    // 오디션 진행 현황 조회 api 호출
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value == null) {
        // 에러 - 데이터 널
        showSnackBar(context, '다시 시도해 주세요.');
      } else {
        if (value[APIConstants.resultVal]) {
          try {
            setState(() {
              // 오디션 진행 현황 조회 성공
              if (_apiKey != APIConstants.SAR_TAD_FINSTATE) {
                var _responseList = value[APIConstants.data] as List;

                if (_responseList != null && _responseList.length > 0) {
                  for (int i = 0; i < _responseList.length; i++) {
                    var _data = _responseList[i];

                    switch (_data[APIConstants.table]) {
                      case APIConstants.FirstAudition:
                        {
                          var _listData = _data[APIConstants.data];
                          if (_listData != null) {
                            List<dynamic> _auditionInfoList =
                                _listData[APIConstants.list] as List;
                            if (_auditionInfoList != null &&
                                _auditionInfoList.length > 0) {
                              _firstAuditionInfo = _auditionInfoList[0];
                            }
                          }
                          break;
                        }

                      case APIConstants.FirstAuditionTarget:
                        {
                          var _listData = _data[APIConstants.data];
                          if (_listData != null) {
                            var paging = _listData[APIConstants.paging];
                            _total = paging[APIConstants.total];

                            List<dynamic> _auditionInfoList =
                                _listData[APIConstants.list] as List;
                            if (_auditionInfoList != null) {
                              _firstAuditionApplyList.addAll(_auditionInfoList);
                              _isLoading = false;
                            }
                          }
                          break;
                        }

                      case APIConstants.SecondAudition:
                        {
                          var _listData = _data[APIConstants.data];
                          if (_listData != null) {
                            List<dynamic> _auditionInfoList =
                                _listData[APIConstants.list] as List;
                            if (_auditionInfoList != null &&
                                _auditionInfoList.length > 0) {
                              _secondAuditionInfo = _auditionInfoList[0];
                            }
                          } else {
                            _secondAuditionInfo = null;
                          }
                          break;
                        }

                      case APIConstants.SecondAuditionTarget:
                        {
                          var _listData = _data[APIConstants.data];
                          if (_listData != null) {
                            var paging = _listData[APIConstants.paging];
                            _total = paging[APIConstants.total];

                            List<dynamic> _auditionInfoList =
                                _listData[APIConstants.list] as List;
                            if (_auditionInfoList != null) {
                              _secondAuditionApplyList
                                  .addAll(_auditionInfoList);
                              _isLoading = false;
                            }
                          }
                          break;
                        }

                      case APIConstants.ThirdAudition:
                        {
                          var _listData = _data[APIConstants.data];
                          if (_listData != null) {
                            List<dynamic> _auditionInfoList =
                                _listData[APIConstants.list] as List;
                            if (_auditionInfoList != null &&
                                _auditionInfoList.length > 0) {
                              _thirdAuditionInfo = _auditionInfoList[0];
                            }
                          } else {
                            _thirdAuditionInfo = null;
                          }
                          break;
                        }

                      case APIConstants.ThirdAuditionTarget:
                        {
                          var _listData = _data[APIConstants.data];
                          if (_listData != null) {
                            var paging = _listData[APIConstants.paging];
                            _total = paging[APIConstants.total];

                            List<dynamic> _auditionInfoList =
                                _listData[APIConstants.list] as List;
                            if (_auditionInfoList != null) {
                              _thirdAuditionApplyList.addAll(_auditionInfoList);
                              _isLoading = false;
                            }
                          }
                          break;
                        }
                    }
                  }
                }
              } else {
                var _responseData = value[APIConstants.data];
                var paging = _responseData[APIConstants.paging];
                _total = paging[APIConstants.total];

                var _responseList = _responseData[APIConstants.list];
                if (_responseList != null) {
                  _auditionResultList.addAll(_responseList);
                  _isLoading = false;
                }
              }
            });
          } catch (e) {
            showSnackBar(context, value[APIConstants.resultMsg]);
          }
        } else {
          // 오디션 진행 현황 조회 실패
          showSnackBar(context, value[APIConstants.resultMsg]);
        }
      }
    });
  }

  /*
  * 1차 오디션 지원자 현황
  * */
  Widget firstAuditionStatus() {
    return Container(
      margin: EdgeInsets.only(top: 20, left: 15, right: 15),
      padding: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
      decoration: BoxDecoration(
        color: CustomColors.colorBgGrey,
        borderRadius: CustomStyles.circle7BorderRadius(),
        border: Border.all(width: 1, color: CustomColors.colorFontLightGrey),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              margin: EdgeInsets.only(right: 15),
              child: Column(
                children: [
                  Text('지원자', style: CustomStyles.dark14TextStyle()),
                  Container(
                    margin: EdgeInsets.only(top: 5),
                    child: Text(
                        StringUtils.checkedString(_firstAuditionInfo[
                            APIConstants.firstAuditionTarget_cnt]),
                        style: CustomStyles.dark14TextStyle()),
                  )
                ],
              )),
          Container(
              margin: EdgeInsets.only(right: 15),
              child: Column(
                children: [
                  Text('합격', style: CustomStyles.dark14TextStyle()),
                  Container(
                    margin: EdgeInsets.only(top: 5),
                    child: Text(
                        StringUtils.checkedString(_firstAuditionInfo[
                            APIConstants.firstAuditionTarget_pass_cnt]),
                        style: CustomStyles.dark14TextStyle()),
                  )
                ],
              )),
          Container(
              child: Column(
            children: [
              Text('불합격', style: CustomStyles.dark14TextStyle()),
              Container(
                margin: EdgeInsets.only(top: 5),
                child: Text(
                    StringUtils.checkedString(_firstAuditionInfo[
                        APIConstants.firstAuditionTarget_fail_cnt]),
                    style: CustomStyles.dark14TextStyle()),
              )
            ],
          ))
        ],
      ),
    );
  }

  /*
  * 1차 오디션 지원자 현황
  * */
  Widget secondAuditionStatus() {
    return Container(
      margin: EdgeInsets.only(top: 20, left: 15, right: 15),
      padding: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
      decoration: BoxDecoration(
        color: CustomColors.colorBgGrey,
        borderRadius: CustomStyles.circle7BorderRadius(),
        border: Border.all(width: 1, color: CustomColors.colorFontLightGrey),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              margin: EdgeInsets.only(right: 15),
              child: Column(
                children: [
                  Text('1차 합격자', style: CustomStyles.dark14TextStyle()),
                  Container(
                    margin: EdgeInsets.only(top: 5),
                    child: Text(
                        StringUtils.checkedString(_secondAuditionInfo[
                            APIConstants.secondAuditionTarget_cnt]),
                        style: CustomStyles.dark14TextStyle()),
                  )
                ],
              )),
          Container(
              margin: EdgeInsets.only(right: 15),
              child: Column(
                children: [
                  Text('제출', style: CustomStyles.dark14TextStyle()),
                  Container(
                    margin: EdgeInsets.only(top: 5),
                    child: Text(
                        StringUtils.checkedString(_secondAuditionInfo[
                            APIConstants.secondAuditionTarget_isSubmit_cnt]),
                        style: CustomStyles.dark14TextStyle()),
                  )
                ],
              )),
          Container(
              margin: EdgeInsets.only(right: 15),
              child: Column(
                children: [
                  Text('미제출', style: CustomStyles.dark14TextStyle()),
                  Container(
                    margin: EdgeInsets.only(top: 5),
                    child: Text(
                        StringUtils.checkedString(_secondAuditionInfo[
                            APIConstants.secondAuditionTarget_isNotSubmit_cnt]),
                        style: CustomStyles.dark14TextStyle()),
                  )
                ],
              )),
          Container(
              child: Column(
            children: [
              Text('합격', style: CustomStyles.dark14TextStyle()),
              Container(
                margin: EdgeInsets.only(top: 5),
                child: Text(
                    StringUtils.checkedString(_secondAuditionInfo[
                        APIConstants.secondAuditionTarget_pass_cnt]),
                    style: CustomStyles.dark14TextStyle()),
              )
            ],
          ))
        ],
      ),
    );
  }

  /*
  * 3차 오디션 지원자 현황
  * */
  Widget thirdAuditionStatus() {
    return Container(
      margin: EdgeInsets.only(top: 20, left: 15, right: 15),
      padding: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
      decoration: BoxDecoration(
        color: CustomColors.colorBgGrey,
        borderRadius: CustomStyles.circle7BorderRadius(),
        border: Border.all(width: 1, color: CustomColors.colorFontLightGrey),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              margin: EdgeInsets.only(right: 15),
              child: Column(
                children: [
                  Text('2차 합격자', style: CustomStyles.dark14TextStyle()),
                  Container(
                    margin: EdgeInsets.only(top: 5),
                    child: Text(
                        StringUtils.checkedString(_thirdAuditionInfo[
                            APIConstants.thirdAuditionTarget_cnt]),
                        style: CustomStyles.dark14TextStyle()),
                  )
                ],
              )),
          Container(
              margin: EdgeInsets.only(right: 15),
              child: Column(
                children: [
                  Text('면접완료', style: CustomStyles.dark14TextStyle()),
                  Container(
                    margin: EdgeInsets.only(top: 5),
                    child: Text(
                        StringUtils.checkedString(_thirdAuditionInfo[
                            APIConstants
                                .thirdAuditionTarget_interviewComplete]),
                        style: CustomStyles.dark14TextStyle()),
                  )
                ],
              )),
          Container(
              margin: EdgeInsets.only(right: 15),
              child: Column(
                children: [
                  Text('면접대기', style: CustomStyles.dark14TextStyle()),
                  Container(
                    margin: EdgeInsets.only(top: 5),
                    child: Text(
                        StringUtils.checkedString(_thirdAuditionInfo[
                            APIConstants.thirdAuditionTarget_standby]),
                        style: CustomStyles.dark14TextStyle()),
                  )
                ],
              )),
          Container(
              child: Column(
            children: [
              Text('합격', style: CustomStyles.dark14TextStyle()),
              Container(
                margin: EdgeInsets.only(top: 5),
                child: Text(
                    StringUtils.checkedString(_thirdAuditionInfo[
                        APIConstants.thirdAuditionTarget_finalComplete]),
                    style: CustomStyles.dark14TextStyle()),
              )
            ],
          ))
        ],
      ),
    );
  }

  /*
  * 2차 오디션 오픈하기
  * */
  Widget openSecondAudition() {
    return Container(
        padding: EdgeInsets.all(15),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              margin: EdgeInsets.only(bottom: 15, top: 15),
              child: Text('2차 오디션 오픈', style: CustomStyles.dark20TextStyle())),
          Container(
              child: Text(
                  '2차 오디션은 대본리딩으로 진행되는 오디션입니다.\n1차 합격자에게 전달할 대본을 등록해 주세요.\n\n합격 시, 3차 오디션을 위한 배우들의 연락처가 공개됩니다.\n오디션 내용 외 부적절한 연락 시 회원탈퇴 처리와 법적인 책임을 질 수 있습니다.',
                  style: CustomStyles.dark16TextStyle())),
          Container(
              margin: EdgeInsets.only(top: 30),
              alignment: Alignment.centerLeft,
              child: Text('대본등록', style: CustomStyles.darkBold14TextStyle())),
          Container(
            margin: EdgeInsets.only(top: 10),
            padding: EdgeInsets.only(left: 15, right: 15, top: 12, bottom: 12),
            decoration: BoxDecoration(
              borderRadius: CustomStyles.circle7BorderRadius(),
              color: CustomColors.colorBgGrey,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('이미지', style: CustomStyles.dark16TextStyle()),
                GestureDetector(
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
                                    onPressed: () => openAppSettings(),
                                  ),
                                ],
                              ));
                    }
                    //
                  },
                  child: Text('업로드', style: CustomStyles.blue16TextStyle()),
                )
              ],
            ),
          ),
          Visibility(
              child: Container(
                  margin: EdgeInsets.only(top: 15),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width * 0.625,
                  decoration: BoxDecoration(color: CustomColors.colorBgGrey),
                  child: (_profileImgFile == null
                      ? null
                      : Image.file(_profileImgFile, fit: BoxFit.cover))),
              visible: _profileImgFile == null ? false : true),
          Container(
              margin: EdgeInsets.only(top: 30),
              alignment: Alignment.centerLeft,
              child: Text('마감날짜', style: CustomStyles.darkBold14TextStyle())),
          GestureDetector(
            onTap: () {
              showDatePickerForDday(context, (date) {
                setState(() {
                  var _birthY = date.year.toString();
                  var _birthM = date.month.toString().padLeft(2, '0');
                  var _birthD = date.day.toString().padLeft(2, '0');

                  _endDate = _birthY + '-' + _birthM + '-' + _birthD;
                });
              });
            },
            child: Container(
                height: 48,
                margin: EdgeInsets.only(top: 10),
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                    borderRadius: CustomStyles.circle7BorderRadius(),
                    border: Border.all(
                        width: 1, color: CustomColors.colorFontGrey)),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(right: 10),
                      child: Icon(Icons.date_range,
                          color: CustomColors.colorFontTitle),
                    ),
                    Text(_endDate, style: CustomStyles.bold14TextStyle()),
                  ],
                )),
          )
        ]));
  }

  /*
  * 3차 오디션 오픈하기
  * */
  Widget openThirdAudition() {
    return Container(
        padding: EdgeInsets.all(15),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              margin: EdgeInsets.only(bottom: 15, top: 15),
              child: Text('3차 오디션 오픈', style: CustomStyles.dark20TextStyle())),
          Container(
              child: Text('3차 오디션은 대면 오디션입니다.',
                  style: CustomStyles.dark16TextStyle()))
        ]));
  }

  /*
  * 1차 오디션 지원자 상태 변경
  * */
  Widget updateFirstAuditionApplyState(Map<String, dynamic> _data, int index) {
    return Container(
        width: MediaQuery.of(context).size.width / 5,
        alignment: Alignment.center,
        child: PopupMenuButton<String>(
          itemBuilder: (context) {
            return <String>['대기', '합격', '불합격'].map((value) {
              return PopupMenuItem(
                value: value,
                child: Text(value, style: CustomStyles.dark12TextStyle()),
              );
            }).toList();
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(_data[APIConstants.result_type],
                  style: CustomStyles.dark12TextStyle()),
              Icon(Icons.arrow_drop_down),
            ],
          ),
          onSelected: (v) {
            setState(() {
              print(v);
              requestUpdateAuditionResult(
                  context,
                  index,
                  APIConstants.UPD_FAT_INFO,
                  _data[APIConstants.firstAuditionTarget_seq],
                  v);
            });
          },
        ));
  }

  /*
  * 2차 오디션 지원자 상태 변경
  * */
  Widget updateSecondAuditionApplyState(Map<String, dynamic> _data, int index) {
    return Container(
        width: MediaQuery.of(context).size.width / 5,
        alignment: Alignment.center,
        child: PopupMenuButton<String>(
          itemBuilder: (context) {
            return <String>['대기', '합격', '불합격'].map((value) {
              return PopupMenuItem(
                value: value,
                child: Text(value, style: CustomStyles.dark12TextStyle()),
              );
            }).toList();
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(_data[APIConstants.result_type],
                  style: CustomStyles.dark12TextStyle()),
              Icon(Icons.arrow_drop_down),
            ],
          ),
          onSelected: (v) {
            setState(() {
              print(v);
              requestUpdateAuditionResult(
                  context,
                  index,
                  APIConstants.UPD_SAT_INFO,
                  _data[APIConstants.secondAuditionTarget_seq],
                  v);
            });
          },
        ));
  }

  /*
  * 3차 오디션 지원자 상태 변경
  * */
  Widget updateThirdAuditionApplyState(Map<String, dynamic> _data, int index) {
    return Container(
        width: MediaQuery.of(context).size.width / 5,
        alignment: Alignment.center,
        child: PopupMenuButton<String>(
          itemBuilder: (context) {
            return <String>['대기', '면접완료', '합격', '불합격'].map((value) {
              return PopupMenuItem(
                value: value,
                child: Text(value, style: CustomStyles.dark12TextStyle()),
              );
            }).toList();
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(_data[APIConstants.result_type],
                  style: CustomStyles.dark12TextStyle()),
              Icon(Icons.arrow_drop_down),
            ],
          ),
          onSelected: (v) {
            setState(() {
              print(v);
              requestUpdateAuditionResult(
                  context,
                  index,
                  APIConstants.UPD_TAT_INFO,
                  _data[APIConstants.thirdAuditionTarget_seq],
                  v);
            });
          },
        ));
  }

  /*
  * 오디션 지원자 리스트
  * */
  Widget auditionApplyList() {
    int _dataCnt = 0;

    switch (_tabIndex) {
      case 0:
        _dataCnt = _firstAuditionApplyList.length;
        break;
      case 1:
        _dataCnt = _secondAuditionApplyList.length;
        break;
      case 2:
        _dataCnt = _thirdAuditionApplyList.length;
        break;
      case 3:
        _dataCnt = _auditionResultList.length;
        break;
    }

    return Container(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      (_tabIndex == 0)
          ? firstAuditionStatus()
          : (_tabIndex == 1
              ? secondAuditionStatus()
              : (_tabIndex == 2 ? thirdAuditionStatus() : Container())),
      Container(
        margin: EdgeInsets.only(top: 15),
        child: Divider(
          color: CustomColors.colorFontGrey,
          height: 1,
          thickness: 0.5,
        ),
      ),
      Wrap(children: [
        ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            controller: _scrollController,
            itemCount: _dataCnt,
            itemBuilder: (BuildContext context, int index) {
              Map<String, dynamic> _data = new Map();

              switch (_tabIndex) {
                case 0:
                  _data = _firstAuditionApplyList[index];
                  break;
                case 1:
                  _data = _secondAuditionApplyList[index];
                  break;
                case 2:
                  _data = _thirdAuditionApplyList[index];
                  break;
                case 3:
                  _data = _auditionResultList[index];
                  break;
              }

              List<String> _imgUrlArr;
              if (_data[APIConstants.actor_imgs] != null) {
                _imgUrlArr =
                    _data[APIConstants.actor_imgs].toString().split(',');
              } else {
                _imgUrlArr = [];
              }

              return Container(
                  alignment: Alignment.center,
                  padding:
                      EdgeInsets.only(left: 16, right: 0, top: 10, bottom: 10),
                  child: GestureDetector(
                      onTap: () {
                        addView(context, AuditionApplyProfile(
                          applySeq:
                          _data[APIConstants.auditionApply_seq],
                          isProduction: true,
                        ));
                      },
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                flex: 1,
                                child: Column(children: [
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              5,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              5,
                                          child: (_imgUrlArr.length > 0)
                                              ? ClipRRect(
                                                  borderRadius: CustomStyles
                                                      .circle7BorderRadius(),
                                                  child: Image.network(
                                                    _imgUrlArr[0],
                                                    fit: BoxFit.cover,
                                                  ))
                                              : ClipRRect(
                                                  borderRadius: CustomStyles
                                                      .circle7BorderRadius()),
                                        ),
                                        Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              5,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              5,
                                          child: (_imgUrlArr.length > 1)
                                              ? ClipRRect(
                                                  borderRadius: CustomStyles
                                                      .circle7BorderRadius(),
                                                  child: Image.network(
                                                      _imgUrlArr[1],
                                                      fit: BoxFit.cover))
                                              : ClipRRect(
                                                  borderRadius: CustomStyles
                                                      .circle7BorderRadius()),
                                        ),
                                        Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              5,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              5,
                                          child: (_imgUrlArr.length > 2)
                                              ? ClipRRect(
                                                  borderRadius: CustomStyles
                                                      .circle7BorderRadius(),
                                                  child: Image.network(
                                                      _imgUrlArr[2],
                                                      fit: BoxFit.cover))
                                              : ClipRRect(
                                                  borderRadius: CustomStyles
                                                      .circle7BorderRadius()),
                                        ),
                                        _tabIndex == 0
                                            ? updateFirstAuditionApplyState(
                                                _data, index)
                                            : (_tabIndex == 1
                                                ? updateSecondAuditionApplyState(
                                                    _data, index)
                                                : (_tabIndex == 2
                                                    ? updateThirdAuditionApplyState(
                                                        _data, index)
                                                    : Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            5,
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                          "최종합격",
                                                          style: CustomStyles
                                                              .normal16TextStyle(),
                                                        ))))
                                      ]),
                                  Container(
                                      margin: EdgeInsets.only(top: 10, left: 5),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        StringUtils.checkedString(
                                            _data[APIConstants.actor_name]),
                                        style: CustomStyles.normal16TextStyle(),
                                      ))
                                ]))
                          ])));
            },
            separatorBuilder: (context, index) {
              return Divider(
                height: 0.1,
                color: CustomColors.colorFontLightGrey,
              );
            })
      ])
    ]));
  }

  Widget tabAuditionApplyList() {
    switch (_tabIndex) {
      case 0:
        return auditionApplyList();
        break;
      case 1:
        if (_secondAuditionInfo != null) {
          return auditionApplyList();
        } else {
          return openSecondAudition();
        }
        break;
      case 2:
        if (_thirdAuditionInfo != null) {
          return auditionApplyList();
        } else {
          return openThirdAudition();
        }
        break;
      case 3:
        return auditionApplyList();
        break;
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
            appBar: CustomStyles.defaultAppBar('지원현황', () {
              Navigator.pop(context);
            }),
            body: Builder(builder: (context) {
              return Container(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Expanded(
                        flex: 1,
                        child: SingleChildScrollView(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Container(
                                  margin:
                                      EdgeInsets.only(top: 30.0, bottom: 10),
                                  padding: EdgeInsets.only(
                                      left: 16, right: 16, bottom: 15),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Container(
                                                child: Text(
                                                    StringUtils.checkedString(
                                                        _firstAuditionInfo[
                                                            APIConstants
                                                                .project_name]),
                                                    style: CustomStyles
                                                        .darkBold10TextStyle())),
                                            Container(
                                                margin: EdgeInsets.only(top: 5),
                                                child: Text(
                                                    StringUtils.checkedString(
                                                        _firstAuditionInfo[
                                                            APIConstants
                                                                .casting_name]),
                                                    style: CustomStyles
                                                        .dark20TextStyle()))
                                          ],
                                        ),
                                      ),
                                      /*Expanded(
                                      flex: 0,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                              child: Text('1차 오디션 진행중',
                                                  style: CustomStyles
                                                      .dark12TextStyle())),
                                          Container(
                                              margin: EdgeInsets.only(top: 5),
                                              child: Text('D-32',
                                                  style: CustomStyles
                                                      .darkBold16TextStyle()))
                                        ],
                                      ),
                                    )*/
                                    ],
                                  )),
                              Container(
                                  color: CustomColors.colorWhite,
                                  child: TabBar(
                                      controller: _tabController,
                                      indicatorPadding: EdgeInsets.zero,
                                      labelStyle:
                                          CustomStyles.bold14TextStyle(),
                                      unselectedLabelStyle:
                                          CustomStyles.normal14TextStyle(),
                                      tabs: [
                                        Tab(text: '1차 오디션'),
                                        Tab(text: '2차 오디션'),
                                        Tab(text: '3차 오디션'),
                                        Tab(text: '최종합격')
                                      ])),
                              Expanded(
                                flex: 0,
                                child: [
                                  tabAuditionApplyList(),
                                  tabAuditionApplyList(),
                                  tabAuditionApplyList(),
                                  tabAuditionApplyList()
                                ][_tabIndex],
                              )
                            ]))),
                    Visibility(
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 55,
                          child: CustomStyles.blueBGSquareButtonStyle(
                              '2차 오디션 오픈하기', () {
                            setState(() {
                              if (checkValidate(context)) {
                                requestOpenSecondAudition(context);
                              }
                            });
                          })),
                      visible: (_tabIndex == 1 && _secondAuditionInfo == null)
                          ? true
                          : false,
                    ),
                    Visibility(
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 55,
                          child: CustomStyles.blueBGSquareButtonStyle(
                              '3차 오디션 오픈하기', () {
                            setState(() {
                              requestOpenThirdAudition(context);
                            });
                          })),
                      visible: (_tabIndex == 2 && _thirdAuditionInfo == null)
                          ? true
                          : false,
                    )
                  ]));
            })));
  }

  /*
  * 입력 데이터 유효성 검사
  * */
  bool checkValidate(BuildContext context) {
    if (_profileImgFile == null) {
      showSnackBar(context, "대본이미지를 업로드해주세요.");
      return false;
    }

    if (StringUtils.isEmpty(_endDate)) {
      showSnackBar(context, "마감날짜를 입력해 주세요.");
      return false;
    }

    return true;
  }

  /*
  * 2차 오디션 오픈
  * */
  void requestOpenSecondAudition(BuildContext context) {
    final dio = Dio();

    // 2차 오디션 오픈 api 호출 시 보낼 파라미터
    final bytes = File(_profileImgFile.path).readAsBytesSync();
    String img64 = base64Encode(bytes);

    Map<String, dynamic> fileData = new Map();
    fileData[APIConstants.base64string] = APIConstants.data_image + img64;

    Map<String, dynamic> targetData = new Map();
    targetData[APIConstants.casting_seq] = _castingSeq;
    targetData[APIConstants.secondAudition_startDate] =
        DateTileUtils.getToday();
    targetData[APIConstants.secondAudition_endDate] =
        DateTileUtils.stringToDateTime2(_endDate);
    targetData[APIConstants.file] = fileData;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.INS_SAD_INFO;
    params[APIConstants.target] = targetData;

    // 2차 오디션 오픈 api 호출
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value == null) {
        // 에러 - 데이터 널
        showSnackBar(context, '다시 시도해 주세요.');
      } else {
        if (value[APIConstants.resultVal]) {
          try {
            setState(() {
              var _responseList = value[APIConstants.data] as List;
              if (_responseList != null && _responseList.length > 0) {
                for (int i = 0; i < _responseList.length; i++) {
                  var _data = _responseList[i];

                  switch (_data[APIConstants.table]) {
                    case APIConstants.SecondAudition:
                      {
                        var _listData = _data[APIConstants.data];
                        if (_listData != null) {
                          List<dynamic> _auditionInfoList =
                              _listData[APIConstants.list] as List;
                          if (_auditionInfoList != null &&
                              _auditionInfoList.length > 0) {
                            _secondAuditionInfo = _auditionInfoList[0];
                          }
                        } else {
                          _secondAuditionInfo = null;
                        }
                        break;
                      }

                    case APIConstants.SecondAuditionTarget:
                      {
                        var _listData = _data[APIConstants.data];
                        if (_listData != null) {
                          var paging = _listData[APIConstants.paging];
                          _total = paging[APIConstants.total];

                          List<dynamic> _auditionInfoList =
                              _listData[APIConstants.list] as List;
                          if (_auditionInfoList != null) {
                            _secondAuditionApplyList.addAll(_auditionInfoList);
                            _isLoading = false;
                          }
                        }
                        break;
                      }
                  }
                }
              }
            });
          } catch (e) {
            showSnackBar(context, value[APIConstants.resultMsg]);
          }
        } else {
          // 2차 오디션 오픈 실패
          switch (value[APIConstants.resultMsg]) {
            case APIConstants.server_error_not_FirstAuditionTarget:
              showSnackBar(context, "1차 오디션 합격자를 선택해 주세요.");
              break;
            default:
              showSnackBar(context, APIConstants.error_msg_try_again);
              break;
          }
        }
      }
    });
  }

  /*
  * 3차 오디션 오픈
  * */
  void requestOpenThirdAudition(BuildContext context) {
    final dio = Dio();

    // 3차 오디션 오픈 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetData = new Map();
    targetData[APIConstants.casting_seq] = _castingSeq;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.INS_TAD_INFO;
    params[APIConstants.target] = targetData;

    // 3차 오디션 오픈 api 호출
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value == null) {
        // 에러 - 데이터 널
        showSnackBar(context, '다시 시도해 주세요.');
      } else {
        if (value[APIConstants.resultVal]) {
          try {
            setState(() {
              var _responseList = value[APIConstants.data] as List;

              if (_responseList != null && _responseList.length > 0) {
                for (int i = 0; i < _responseList.length; i++) {
                  var _data = _responseList[i];

                  switch (_data[APIConstants.table]) {
                    case APIConstants.ThirdAudition:
                      {
                        var _listData = _data[APIConstants.data];
                        if (_listData != null) {
                          List<dynamic> _auditionInfoList =
                              _listData[APIConstants.list] as List;
                          if (_auditionInfoList != null &&
                              _auditionInfoList.length > 0) {
                            _thirdAuditionInfo = _auditionInfoList[0];
                          }
                        } else {
                          _thirdAuditionInfo = null;
                        }
                        break;
                      }

                    case APIConstants.ThirdAuditionTarget:
                      {
                        var _listData = _data[APIConstants.data];
                        if (_listData != null) {
                          var paging = _listData[APIConstants.paging];
                          _total = paging[APIConstants.total];

                          List<dynamic> _auditionInfoList =
                              _listData[APIConstants.list] as List;
                          if (_auditionInfoList != null) {
                            _thirdAuditionApplyList.addAll(_auditionInfoList);
                            _isLoading = false;
                          }
                        }
                        break;
                      }
                  }
                }
              }
            });
          } catch (e) {
            showSnackBar(context, value[APIConstants.resultMsg]);
          }
        } else {
          // 3차 오디션 오픈 실패
          switch (value[APIConstants.resultMsg]) {
            case APIConstants.server_error_not_SecondAuditionTarget:
              showSnackBar(context, "2차 오디션 합격자를 선택해 주세요.");
              break;
            default:
              showSnackBar(context, APIConstants.error_msg_try_again);
              break;
          }
        }
      }
    });
  }

  /*
  * 오디션 대상자 단일 수정(합격, 불합격)
  * */
  void requestUpdateAuditionResult(BuildContext context, int applyIdx,
      String key, int targetSeq, String resultType) {
    final dio = Dio();

    // 오디션 대상자 단일 수정 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetData = new Map();
    targetData[APIConstants.seq] = targetSeq;
    targetData[APIConstants.result_type] = resultType;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = key;
    params[APIConstants.target] = targetData;

    // 오디션 대상자 단일 수정 api 호출
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value == null) {
        // 에러 - 데이터 널
        showSnackBar(context, '다시 시도해 주세요.');
      } else {
        if (value[APIConstants.resultVal]) {
          try {
            setState(() {
              //var _responseData = value[APIConstants.data];

              switch (key) {
                case APIConstants.UPD_FAT_INFO:
                  _firstAuditionApplyList[applyIdx][APIConstants.result_type] =
                      resultType;
                  break;
                case APIConstants.UPD_SAT_INFO:
                  _secondAuditionApplyList[applyIdx][APIConstants.result_type] =
                      resultType;
                  break;
                case APIConstants.UPD_TAT_INFO:
                  _thirdAuditionApplyList[applyIdx][APIConstants.result_type] =
                      resultType;
                  break;
              }

              showSnackBar(context, "수정 완료");
            });
          } catch (e) {
            showSnackBar(context, value[APIConstants.resultMsg]);
          }
        } else {
          // 오디션 대상자 단일 수정 실패
          showSnackBar(context, APIConstants.error_msg_try_again);
        }
      }
    });
  }
}
