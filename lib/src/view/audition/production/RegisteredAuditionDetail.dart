import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/dialog/DialogAuditionQuit.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/util/DateTileUtils.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:casting_call/src/view/audition/actor/AuditionApplyProfile.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
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

  bool _isUpload = false;

  final _txtFieldPay = TextEditingController();

  int _castingSeq;
  String _apiKey = APIConstants.SAR_FAD_STATE;

  Map<String, dynamic> _firstAuditionInfo = new Map();
  List<dynamic> _firstAuditionApplyList = [];

  Map<String, dynamic> _secondAuditionInfo = new Map();
  List<dynamic> _secondAuditionApplyList = [];

  Map<String, dynamic> _thirdAuditionInfo = new Map();
  List<dynamic> _thirdAuditionApplyList = [];

  List<dynamic> _auditionResultList = [];

  String _endDate = "";

  TabController _tabController;
  int _tabIndex = 0;

  ScrollController _scrollController;

  int _total = 0;
  int _limit = 20;

  bool _isLoading = true;

  File _scriptFile;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    _castingSeq = widget.castingSeq;

    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection);

    _scrollController = new ScrollController(initialScrollOffset: 5.0)
      ..addListener(_scrollListener);

    requestCastingStateList(context);
  }

  _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _tabIndex = _tabController.index;

        _total = 0;

        switch (_tabIndex) {
          case 0:
            _firstAuditionApplyList = [];
            _apiKey = APIConstants.SAR_FAD_STATE;
            break;
          case 1:
            _secondAuditionApplyList = [];
            _apiKey = APIConstants.SAR_SAD_STATE;
            break;
          case 2:
            _thirdAuditionApplyList = [];
            _apiKey = APIConstants.SAR_TAD_STATE;
            break;
          case 3:
            _auditionResultList = [];
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
      case 3:
        cnt = _auditionResultList.length;
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
          _scriptFile = file;
        });
      }
    } else {
      showSnackBar(context, "선택된 이미지가 없습니다.");
    }
  }

  _pickDocument() async {
    String result;
    try {
      FlutterDocumentPickerParams params = FlutterDocumentPickerParams(
        allowedFileExtensions: ['doc', 'pdf', 'docx'],
        allowedUtiTypes: [
          'com.adobe.pdf',
          'com.microsoft.word.doc',
          'org.openxmlformats.wordprocessingml.document'
        ],
        allowedMimeTypes: [
          'application/pdf',
          'application/msword',
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
        ],
        invalidFileNameSymbols: ['/'],
      );

      result = await FlutterDocumentPicker.openDocument(params: params);

      if (result != null) {
        File file = File(result);

        final size = file.readAsBytesSync().lengthInBytes;
        final kb = size / 1024;
        final mb = kb / 1024;

        if (mb > 100) {
          showSnackBar(context, "100MB 미만의 파일만 업로드 가능합니다.");
        } else {
          setState(() {
            _scriptFile = file;
          });
        }
      } else {
        showSnackBar(context, "선택된 파일이 없습니다.");
      }

      print('result: $result');
    } catch (e) {
      print(e);
      result = 'Error: $e';
      showSnackBar(context, APIConstants.error_msg_try_again);
    } finally {}
  }

  /*
  오디션 진행 현황 조회
  * */
  void requestCastingStateList(BuildContext context) {
    setState(() {
      _isUpload = true;
    });

    // 1차 오디션 진행 현황 조회 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetData = new Map();
    targetData[APIConstants.casting_seq] = _castingSeq;

    Map<String, dynamic> paging = new Map();
    switch (_apiKey) {
      case APIConstants.SAR_FAD_STATE:
        paging[APIConstants.offset] = _firstAuditionApplyList.length;
        break;
      case APIConstants.SAR_SAD_STATE:
        paging[APIConstants.offset] = _secondAuditionApplyList.length;
        break;
      case APIConstants.SAR_TAD_STATE:
        paging[APIConstants.offset] = _thirdAuditionApplyList.length;
        break;
      case APIConstants.SAR_TAD_FINSTATE:
        paging[APIConstants.offset] = _auditionResultList.length;
        break;
    }

    paging[APIConstants.limit] = _limit;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = _apiKey;
    params[APIConstants.target] = targetData;
    params[APIConstants.paging] = paging;

    // 오디션 진행 현황 조회 api 호출
    RestClient(Dio()).postRequestMainControl(params).then((value) async {
      try {
        if (value == null) {
          // 에러 - 데이터 널
          showSnackBar(context, '다시 시도해 주세요.');
        } else {
          if (value[APIConstants.resultVal]) {
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
                          print("1111111111111");
                          var _listData = _data[APIConstants.data];
                          if (_listData != null) {
                            print("22222222222");
                            List<dynamic> _auditionInfoList =
                                _listData[APIConstants.list] as List;
                            if (_auditionInfoList != null &&
                                _auditionInfoList.length > 0) {
                              print("3333333333333");
                              _thirdAuditionInfo = _auditionInfoList[0];
                            }
                          } else {
                            _thirdAuditionInfo = null;
                          }
                          break;
                        }

                      case APIConstants.ThirdAuditionTarget:
                        {
                          print("4444444444");
                          var _listData = _data[APIConstants.data];
                          if (_listData != null) {
                            print("55555555555");
                            var paging = _listData[APIConstants.paging];
                            _total = paging[APIConstants.total];

                            List<dynamic> _auditionInfoList =
                                _listData[APIConstants.list] as List;
                            if (_auditionInfoList != null) {
                              print("666666666666");
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
          } else {
            // 오디션 진행 현황 조회 실패
            showSnackBar(context, value[APIConstants.resultMsg]);
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
  * 탭 아이템 위젯
  * */
  Widget tabAuditionApplyList() {
    switch (_tabIndex) {
      case 0:
        return firstAuditionApplyList();
        break;
      case 1:
        if (_secondAuditionInfo != null) {
          return secondAuditionApplyList();
        } else {
          return openSecondAudition();
        }
        break;
      case 2:
        if (_thirdAuditionInfo != null) {
          return thirdAuditionApplyList();
        } else {
          return openThirdAudition();
        }
        break;
      case 3:
        return auditionResultList();
        break;
    }
  }

  Widget profileImgWidget(List<String> _imgUrlArr, int idx) {
    return Container(
        height: MediaQuery.of(context).size.width / 5,
        width: MediaQuery.of(context).size.width / 5,
        child: (_imgUrlArr.length > idx)
            ? ClipRRect(
                borderRadius: CustomStyles.circle7BorderRadius(),
                child: CachedNetworkImage(
                    placeholder: (context, url) => Container(
                        alignment: Alignment.center,
                        child: CircularProgressIndicator()),
                    imageUrl: _imgUrlArr[idx],
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) =>
                        CustomStyles.defalutImg()))
            : CustomStyles.defalutImg());
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
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
              margin: EdgeInsets.only(right: 15),
              child: Column(children: [
                Text('지원자', style: CustomStyles.dark14TextStyle()),
                Container(
                    margin: EdgeInsets.only(top: 5),
                    child: Text(
                        StringUtils.checkedString(_firstAuditionInfo[
                            APIConstants.firstAuditionTarget_cnt]),
                        style: CustomStyles.dark14TextStyle()))
              ])),
          Container(
              margin: EdgeInsets.only(right: 15),
              child: Column(children: [
                Text('합격', style: CustomStyles.dark14TextStyle()),
                Container(
                    margin: EdgeInsets.only(top: 5),
                    child: Text(
                        StringUtils.checkedString(_firstAuditionInfo[
                            APIConstants.firstAuditionTarget_pass_cnt]),
                        style: CustomStyles.dark14TextStyle()))
              ])),
          Container(
              child: Column(children: [
            Text('불합격', style: CustomStyles.dark14TextStyle()),
            Container(
                margin: EdgeInsets.only(top: 5),
                child: Text(
                    StringUtils.checkedString(_firstAuditionInfo[
                        APIConstants.firstAuditionTarget_fail_cnt]),
                    style: CustomStyles.dark14TextStyle()))
          ]))
        ]));
  }

  /*
  * 1차 오디션 지원자 리스트
  * */
  Widget firstAuditionApplyList() {
    return Container(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      firstAuditionStatus(),
      Container(
          margin: EdgeInsets.only(top: 15),
          child: Divider(
              color: CustomColors.colorFontGrey, height: 1, thickness: 0.5)),
      Wrap(children: [
        ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            controller: _scrollController,
            itemCount: _firstAuditionApplyList.length,
            itemBuilder: (BuildContext context, int index) {
              Map<String, dynamic> _data = _firstAuditionApplyList[index];
              ;

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
                        addView(
                            context,
                            AuditionApplyProfile(
                              applySeq: _data[APIConstants.auditionApply_seq],
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
                                        profileImgWidget(_imgUrlArr, 0),
                                        profileImgWidget(_imgUrlArr, 1),
                                        profileImgWidget(_imgUrlArr, 2),
                                        Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                5,
                                            alignment: Alignment.center,
                                            child: PopupMenuButton<String>(
                                                itemBuilder: (context) {
                                                  return <String>[
                                                    '대기',
                                                    '합격',
                                                    '불합격'
                                                  ].map((value) {
                                                    return PopupMenuItem(
                                                        value: value,
                                                        child: Text(value,
                                                            style: CustomStyles
                                                                .dark12TextStyle()));
                                                  }).toList();
                                                },
                                                child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: <Widget>[
                                                      Text(
                                                          _data[APIConstants
                                                              .result_type],
                                                          style: CustomStyles
                                                              .dark12TextStyle()),
                                                      Icon(
                                                          Icons.arrow_drop_down)
                                                    ]),
                                                onSelected: (v) {
                                                  setState(() {
                                                    if (_firstAuditionInfo[
                                                            APIConstants
                                                                .isOpenSecondAudition] ==
                                                        0) {
                                                      requestUpdateAuditionResult(
                                                          context,
                                                          index,
                                                          APIConstants
                                                              .UPD_FAT_INFO,
                                                          _data[APIConstants
                                                              .firstAuditionTarget_seq],
                                                          v);
                                                    } else {
                                                      showSnackBar(context,
                                                          '2차 오디션이 오픈된 상태에서는 1차 오디션 상태 수정이 불가능합니다.');
                                                    }
                                                  });
                                                }))
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
      ]),
      Visibility(
          child: Divider(),
          visible: _firstAuditionApplyList.length > 0 ? true : false),
      Visibility(
          child: Container(
              margin: EdgeInsets.only(top: 50),
              alignment: Alignment.center,
              child:
                  Text("지원자가 없습니다.", style: CustomStyles.normal14TextStyle())),
          visible: _firstAuditionApplyList.length > 0 ? false : true)
    ]));
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
              padding:
                  EdgeInsets.only(left: 15, right: 15, top: 12, bottom: 12),
              decoration: BoxDecoration(
                borderRadius: CustomStyles.circle7BorderRadius(),
                color: CustomColors.colorBgGrey,
              ),
              child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('첨부파일 또는 이미지', style: CustomStyles.dark16TextStyle()),
                    GestureDetector(
                        onTap: () async {
                          showModalBottomSheet(
                              elevation: 5,
                              context: context,
                              builder: (context) {
                                return Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      ListTile(
                                          title: Text(
                                            '대본이미지 선택',
                                            textAlign: TextAlign.center,
                                          ),
                                          onTap: () async {
                                            var status = Platform.isAndroid
                                                ? await Permission.storage
                                                    .request()
                                                : await Permission.photos
                                                    .request();
                                            if (status.isGranted) {
                                              getImageFromGallery();
                                              Navigator.pop(context);
                                            } else {
                                              showDialog(
                                                  context: context,
                                                  builder: (BuildContext
                                                          context) =>
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
                                                                child:
                                                                    Text('허용'),
                                                                onPressed: () =>
                                                                    openAppSettings())
                                                          ]));
                                            }
                                          }),
                                      Divider(),
                                      ListTile(
                                          title: Text(
                                            '대본파일 선택',
                                            textAlign: TextAlign.center,
                                          ),
                                          onTap: () async {
                                            var status = Platform.isAndroid
                                                ? await Permission.storage
                                                    .request()
                                                : await Permission.photos
                                                    .request();
                                            if (status.isGranted) {
                                              _pickDocument();
                                              Navigator.pop(context);
                                            } else {
                                              showDialog(
                                                  context: context,
                                                  builder: (BuildContext
                                                          context) =>
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
                                          }),
                                      Divider(),
                                      ListTile(
                                          title: Text(
                                            '취소',
                                            textAlign: TextAlign.center,
                                          ),
                                          onTap: () {
                                            Navigator.pop(context);
                                          })
                                    ]);
                              });
                        },
                        child:
                            Text('업로드', style: CustomStyles.blue16TextStyle()))
                  ])),
          Visibility(
              child: Container(
                  margin: EdgeInsets.only(top: 15),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(color: CustomColors.colorWhite),
                  child: (_scriptFile == null ? null : Text(_scriptFile.path))),
              visible: _scriptFile == null ? false : true),
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
                      Text(_endDate, style: CustomStyles.bold14TextStyle())
                    ])),
          )
        ]));
  }

  /*
  * 2차 오디션 지원자 현황
  * */
  Widget secondAuditionStatus() {
    return Container(
        margin: EdgeInsets.only(top: 20, left: 15, right: 15),
        padding: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
        decoration: BoxDecoration(
            color: CustomColors.colorBgGrey,
            borderRadius: CustomStyles.circle7BorderRadius(),
            border:
                Border.all(width: 1, color: CustomColors.colorFontLightGrey)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
              margin: EdgeInsets.only(right: 15),
              child: Column(children: [
                Text('1차 합격자', style: CustomStyles.dark14TextStyle()),
                Container(
                    margin: EdgeInsets.only(top: 5),
                    child: Text(
                        StringUtils.checkedString(_secondAuditionInfo[
                            APIConstants.secondAuditionTarget_cnt]),
                        style: CustomStyles.dark14TextStyle()))
              ])),
          Container(
              margin: EdgeInsets.only(right: 15),
              child: Column(children: [
                Text('제출', style: CustomStyles.dark14TextStyle()),
                Container(
                    margin: EdgeInsets.only(top: 5),
                    child: Text(
                        StringUtils.checkedString(_secondAuditionInfo[
                            APIConstants.secondAuditionTarget_isSubmit_cnt]),
                        style: CustomStyles.dark14TextStyle()))
              ])),
          Container(
              margin: EdgeInsets.only(right: 15),
              child: Column(children: [
                Text('미제출', style: CustomStyles.dark14TextStyle()),
                Container(
                    margin: EdgeInsets.only(top: 5),
                    child: Text(
                        StringUtils.checkedString(_secondAuditionInfo[
                            APIConstants.secondAuditionTarget_isNotSubmit_cnt]),
                        style: CustomStyles.dark14TextStyle()))
              ])),
          Container(
              child: Column(children: [
            Text('합격', style: CustomStyles.dark14TextStyle()),
            Container(
                margin: EdgeInsets.only(top: 5),
                child: Text(
                    StringUtils.checkedString(_secondAuditionInfo[
                        APIConstants.secondAuditionTarget_pass_cnt]),
                    style: CustomStyles.dark14TextStyle()))
          ]))
        ]));
  }

  /*
  * 2차 오디션 지원자 리스트
  * */
  Widget secondAuditionApplyList() {
    int _dataCnt = _secondAuditionApplyList.length;

    return Container(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      secondAuditionStatus(),
      Container(
          margin: EdgeInsets.only(top: 15),
          child: Divider(
              color: CustomColors.colorFontGrey, height: 1, thickness: 0.5)),
      Wrap(children: [
        ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            controller: _scrollController,
            itemCount: _dataCnt,
            itemBuilder: (BuildContext context, int index) {
              Map<String, dynamic> _data = _secondAuditionApplyList[index];

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
                        addView(
                            context,
                            AuditionApplyProfile(
                              applySeq: _data[APIConstants.auditionApply_seq],
                              isProduction: true,
                            ));
                      },
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                flex: 1,
                                child: Column(children: [
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        profileImgWidget(_imgUrlArr, 0),
                                        profileImgWidget(_imgUrlArr, 1),
                                        profileImgWidget(_imgUrlArr, 2)
                                      ]),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                          margin:
                                              EdgeInsets.only(top: 10, left: 5),
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            StringUtils.checkedString(
                                                _data[APIConstants.actor_name]),
                                            style: CustomStyles
                                                .normal16TextStyle(),
                                          )),
                                      Container(
                                          margin:
                                              EdgeInsets.only(top: 10, left: 5),
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            StringUtils.checkedString(
                                                _data[APIConstants.isSubmit]),
                                            style:
                                                CustomStyles.blue16TextStyle(),
                                          ))
                                    ],
                                  )
                                ])),
                            Container(
                                margin: EdgeInsets.only(left: 16),
                                width: MediaQuery.of(context).size.width / 5,
                                alignment: Alignment.center,
                                child: PopupMenuButton<String>(
                                    itemBuilder: (context) {
                                      return <String>['대기', '합격', '불합격']
                                          .map((value) {
                                        return PopupMenuItem(
                                          value: value,
                                          child: Text(value,
                                              style: CustomStyles
                                                  .dark12TextStyle()),
                                        );
                                      }).toList();
                                    },
                                    child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text(_data[APIConstants.result_type],
                                              style: CustomStyles
                                                  .dark12TextStyle()),
                                          Icon(Icons.arrow_drop_down)
                                        ]),
                                    onSelected: (v) {
                                      setState(() {
                                        if (_firstAuditionInfo[APIConstants
                                                .isOpenThirdAudition] ==
                                            0) {
                                          requestUpdateAuditionResult(
                                              context,
                                              index,
                                              APIConstants.UPD_SAT_INFO,
                                              _data[APIConstants
                                                  .secondAuditionTarget_seq],
                                              v);
                                        } else {
                                          showSnackBar(context,
                                              '3차 오디션이 오픈된 상태에서는 2차 오디션 상태 수정이 불가능합니다.');
                                        }
                                      });
                                    }))
                          ])));
            },
            separatorBuilder: (context, index) {
              return Divider(
                height: 0.1,
                color: CustomColors.colorFontLightGrey,
              );
            })
      ]),
      Visibility(child: Divider(), visible: _dataCnt > 0 ? true : false),
      Visibility(
          child: Container(
              margin: EdgeInsets.only(top: 50),
              alignment: Alignment.center,
              child:
                  Text("지원자가 없습니다.", style: CustomStyles.normal14TextStyle())),
          visible: _dataCnt > 0 ? false : true)
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
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
              margin: EdgeInsets.only(right: 15),
              child: Column(children: [
                Text('2차 합격자', style: CustomStyles.dark14TextStyle()),
                Container(
                    margin: EdgeInsets.only(top: 5),
                    child: Text(
                        StringUtils.checkedString(_thirdAuditionInfo[
                            APIConstants.thirdAuditionTarget_cnt]),
                        style: CustomStyles.dark14TextStyle()))
              ])),
          Container(
              margin: EdgeInsets.only(right: 15),
              child: Column(children: [
                Text('면접완료', style: CustomStyles.dark14TextStyle()),
                Container(
                    margin: EdgeInsets.only(top: 5),
                    child: Text(
                        StringUtils.checkedString(_thirdAuditionInfo[
                            APIConstants
                                .thirdAuditionTarget_interviewComplete]),
                        style: CustomStyles.dark14TextStyle()))
              ])),
          Container(
              margin: EdgeInsets.only(right: 15),
              child: Column(children: [
                Text('면접대기', style: CustomStyles.dark14TextStyle()),
                Container(
                    margin: EdgeInsets.only(top: 5),
                    child: Text(
                        StringUtils.checkedString(_thirdAuditionInfo[
                            APIConstants.thirdAuditionTarget_standby]),
                        style: CustomStyles.dark14TextStyle()))
              ])),
          Container(
              child: Column(children: [
            Text('합격', style: CustomStyles.dark14TextStyle()),
            Container(
                margin: EdgeInsets.only(top: 5),
                child: Text(
                    StringUtils.checkedString(_thirdAuditionInfo[
                        APIConstants.thirdAuditionTarget_finalComplete]),
                    style: CustomStyles.dark14TextStyle()))
          ]))
        ]));
  }

  /*
  * 3차 오디션 지원자 리스트
  * */
  Widget thirdAuditionApplyList() {
    int _dataCnt = _thirdAuditionApplyList.length;

    return Container(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      thirdAuditionStatus(),
      Container(
          margin: EdgeInsets.only(top: 15),
          child: Divider(
              color: CustomColors.colorFontGrey, height: 1, thickness: 0.5)),
      Wrap(children: [
        ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            controller: _scrollController,
            itemCount: _dataCnt,
            itemBuilder: (BuildContext context, int index) {
              Map<String, dynamic> _data = _thirdAuditionApplyList[index];

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
                        addView(
                            context,
                            AuditionApplyProfile(
                              applySeq: _data[APIConstants.auditionApply_seq],
                              isProduction: true,
                            ));
                      },
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                flex: 1,
                                child: Column(children: [
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        profileImgWidget(_imgUrlArr, 0),
                                        profileImgWidget(_imgUrlArr, 1),
                                        profileImgWidget(_imgUrlArr, 2)
                                      ]),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                          margin:
                                              EdgeInsets.only(top: 10, left: 5),
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            StringUtils.checkedString(
                                                _data[APIConstants.actor_name]),
                                            style: CustomStyles
                                                .normal16TextStyle(),
                                          )),
                                      Container(
                                          margin:
                                              EdgeInsets.only(top: 10, left: 5),
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            StringUtils.checkedString(_data[
                                                APIConstants.actor_phone]),
                                            style: CustomStyles
                                                .normal16TextStyle(),
                                          ))
                                    ],
                                  )
                                ])),
                            Container(
                                margin: EdgeInsets.only(left: 16),
                                width: MediaQuery.of(context).size.width / 5,
                                alignment: Alignment.center,
                                child: PopupMenuButton<String>(
                                    itemBuilder: (context) {
                                      return <String>['대기', '면접완료', '합격', '불합격']
                                          .map((value) {
                                        return PopupMenuItem(
                                          value: value,
                                          child: Text(value,
                                              style: CustomStyles
                                                  .dark12TextStyle()),
                                        );
                                      }).toList();
                                    },
                                    child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text(_data[APIConstants.result_type],
                                              style: CustomStyles
                                                  .dark12TextStyle()),
                                          Icon(Icons.arrow_drop_down)
                                        ]),
                                    onSelected: (v) {
                                      setState(() {
                                        if (_firstAuditionInfo[
                                                APIConstants.isAuditionQuit] ==
                                            0) {
                                          requestUpdateAuditionResult(
                                              context,
                                              index,
                                              APIConstants.UPD_TAT_INFO,
                                              _data[APIConstants
                                                  .thirdAuditionTarget_seq],
                                              v);
                                        } else {
                                          showSnackBar(
                                              context, '마감된 오디션은 수정할 수 없습니다.');
                                        }
                                      });
                                    }))
                          ])));
            },
            separatorBuilder: (context, index) {
              return Divider(
                height: 0.1,
                color: CustomColors.colorFontLightGrey,
              );
            })
      ]),
      Visibility(child: Divider(), visible: _dataCnt > 0 ? true : false),
      Visibility(
          child: Container(
              margin: EdgeInsets.only(top: 50),
              alignment: Alignment.center,
              child:
                  Text("지원자가 없습니다.", style: CustomStyles.normal14TextStyle())),
          visible: _dataCnt > 0 ? false : true)
    ]));
  }

  /*
  * 최종 합격자 리스트
  * */
  Widget auditionResultList() {
    int _dataCnt = _auditionResultList.length;

    return Container(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(children: [
        ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            controller: _scrollController,
            itemCount: _dataCnt,
            itemBuilder: (BuildContext context, int index) {
              Map<String, dynamic> _data = _auditionResultList[index];

              List<String> _imgUrlArr;
              if (_data[APIConstants.actor_imgs] != null) {
                _imgUrlArr =
                    _data[APIConstants.actor_imgs].toString().split(',');
              } else {
                _imgUrlArr = [];
              }

              if (_data[APIConstants.result_type] != "계약요청전") {
                _txtFieldPay.text = _data[APIConstants.final_pay].toString();
              }

              return Container(
                  alignment: Alignment.center,
                  padding:
                      EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
                  child: GestureDetector(
                      onTap: () {
                        addView(
                            context,
                            AuditionApplyProfile(
                              applySeq: _data[APIConstants.auditionApply_seq],
                              isProduction: true,
                            ));
                      },
                      child: Column(children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: Column(children: [
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          profileImgWidget(_imgUrlArr, 0),
                                          profileImgWidget(_imgUrlArr, 1),
                                          profileImgWidget(_imgUrlArr, 2)
                                        ]),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                              margin: EdgeInsets.only(
                                                  top: 10, left: 5),
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                StringUtils.checkedString(_data[
                                                    APIConstants.actor_name]),
                                                style: CustomStyles
                                                    .normal16TextStyle(),
                                              )),
                                          Container(
                                              margin: EdgeInsets.only(
                                                  top: 10, left: 5),
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                StringUtils.checkedString(_data[
                                                    APIConstants.actor_phone]),
                                                style: CustomStyles
                                                    .normal16TextStyle(),
                                              ))
                                        ])
                                  ])),
                              Container(
                                  margin: EdgeInsets.only(left: 16),
                                  width: MediaQuery.of(context).size.width / 5,
                                  alignment: Alignment.center,
                                  child: Text(
                                    StringUtils.checkedString(
                                        _data[APIConstants.result_type]),
                                    style: CustomStyles.normal14TextStyle(),
                                  ))
                            ]),
                        Container(
                            margin: EdgeInsets.only(top: 20),
                            alignment: Alignment.centerLeft,
                            child: Text('1회당 출연료',
                                style: CustomStyles.normal14TextStyle())),
                        Container(
                            padding: EdgeInsets.only(top: 10, bottom: 10),
                            child: Container(
                                child: CustomStyles
                                    .greyBorderRound7TextFieldWithDisableOpt(
                                        _txtFieldPay,
                                        '',
                                        (StringUtils.checkedString(_data[
                                                    APIConstants
                                                        .result_type]) ==
                                                "계약요청전")
                                            ? true
                                            : false))),
                        Visibility(
                            child: Container(
                                padding: EdgeInsets.only(top: 5, bottom: 10),
                                child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 48,
                                    child: CustomStyles.greyBGRound7ButtonStyle(
                                        '출연료 확정 및 계약요청하기', () {
                                      if (StringUtils.isEmpty(
                                          _txtFieldPay.text)) {
                                        showSnackBar(context, '출연료를 입력해 주세요.');
                                        return false;
                                      }

                                      if (StringUtils.trimmedString(
                                              _txtFieldPay.text) ==
                                          '0') {
                                        showSnackBar(
                                            context, '출연료는 0원 이상이어야 합니다.');
                                        return false;
                                      }

                                      requestSavePay(
                                          context,
                                          _data[APIConstants
                                              .thirdAuditionTarget_seq]);
                                    }))),
                            visible: (StringUtils.checkedString(
                                        _data[APIConstants.result_type]) ==
                                    "계약요청전")
                                ? true
                                : false),
                        Visibility(
                            child: Container(
                                margin: EdgeInsets.only(top: 10),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                    '* 1회당 출연료를 입력한 후 \'출연료 확정 및 계약요청하기\'버튼을 누르는 즉시, 해당 배우가 계약서를 작성할 수 있습니다.',
                                    style: CustomStyles.normal14TextStyle())),
                            visible: (StringUtils.checkedString(
                                        _data[APIConstants.result_type]) ==
                                    "계약요청전")
                                ? true
                                : false),
                        Visibility(
                            child: Container(
                                padding: EdgeInsets.only(top: 5, bottom: 10),
                                child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 48,
                                    child: CustomStyles.greyBGRound7ButtonStyle(
                                        '출연료 지급하기', () {
                                      requestPayToActor(
                                          context,
                                          _data[APIConstants
                                              .thirdAuditionTarget_seq]);
                                    }))),
                            visible: (StringUtils.checkedString(
                                            _data[APIConstants.result_type]) ==
                                        "계약완료" &&
                                    _data[APIConstants.isPayment] == 0)
                                ? true
                                : false),
                        Visibility(
                            child: Container(
                                alignment: Alignment.centerLeft,
                                child: Text('* 배우에게 출연료를 지급해 주세요.',
                                    style: CustomStyles.normal14TextStyle())),
                            visible: (StringUtils.checkedString(
                                            _data[APIConstants.result_type]) ==
                                        "계약완료" &&
                                    _data[APIConstants.isPayment] == 0)
                                ? true
                                : false),
                        Visibility(
                            child: Container(
                                padding: EdgeInsets.only(top: 5, bottom: 10),
                                child: Container(
                                    alignment: Alignment.center,
                                    width: MediaQuery.of(context).size.width,
                                    height: 48,
                                    decoration: new BoxDecoration(
                                        color: CustomColors.colorBgGrey,
                                        borderRadius:
                                            CustomStyles.circle7BorderRadius()),
                                    child: Text("출연료 지급완료",
                                        style:
                                            CustomStyles.normal16TextStyle()))),
                            visible: (StringUtils.checkedString(
                                            _data[APIConstants.result_type]) ==
                                        "계약완료" &&
                                    _data[APIConstants.isPayment] == 1)
                                ? true
                                : false),
                      ])));
            },
            separatorBuilder: (context, index) {
              return Divider(
                height: 0.1,
                color: CustomColors.colorFontLightGrey,
              );
            })
      ]),
      Visibility(child: Divider(), visible: _dataCnt > 0 ? true : false),
      Visibility(
          child: Container(
              margin: EdgeInsets.only(top: 50),
              alignment: Alignment.center,
              child: Text("최종합격자가 없습니다.",
                  style: CustomStyles.normal14TextStyle())),
          visible: _dataCnt > 0 ? false : true)
    ]));
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
              return Stack(children: [
                Container(
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                                        margin: EdgeInsets.only(
                                                            top: 5),
                                                        child: Text(
                                                            StringUtils.checkedString(
                                                                _firstAuditionInfo[
                                                                    APIConstants
                                                                        .casting_name]),
                                                            style: CustomStyles
                                                                .dark20TextStyle()))
                                                  ])),
                                          Visibility(
                                              child: Expanded(
                                                  flex: 0,
                                                  child: Container(
                                                      child: CustomStyles
                                                          .darkBold14TextButtonStyle(
                                                              '오디션 마감하기', () {
                                                    showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                                _context) =>
                                                            DialogAuditionQuit(
                                                                onClickedAgree:
                                                                    () {
                                                              requestQuitAudition(
                                                                  context);
                                                            }));
                                                  }))),
                                              visible: _firstAuditionInfo[
                                                          APIConstants
                                                              .isAuditionQuit] ==
                                                      0
                                                  ? true
                                                  : false),
                                          Visibility(
                                              child: Expanded(
                                                  flex: 0,
                                                  child: Container(
                                                      child: Text('마감된 오디션입니다.',
                                                          style: CustomStyles
                                                              .dark14TextStyle()))),
                                              visible: _firstAuditionInfo[
                                                          APIConstants
                                                              .isAuditionQuit] ==
                                                      0
                                                  ? false
                                                  : true)
                                        ])),
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
                        visible: (_tabIndex == 1 &&
                                _firstAuditionInfo[
                                        APIConstants.isOpenSecondAudition] ==
                                    0)
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
                          visible: (_tabIndex == 2 &&
                                  _firstAuditionInfo[
                                          APIConstants.isOpenThirdAudition] ==
                                      0)
                              ? true
                              : false)
                    ])),
                Visibility(
                    child: Container(
                        color: Colors.black38,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator()),
                    visible: _isUpload)
              ]);
            })));
  }

  /*
  * 입력 데이터 유효성 검사
  * */
  bool checkValidate(BuildContext context) {
    if (_scriptFile == null) {
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
  Future<void> requestOpenSecondAudition(BuildContext context) async {
    setState(() {
      _isUpload = true;
    });

    // 2차 오디션 오픈 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetData = new Map();
    targetData[APIConstants.casting_seq] = _castingSeq;
    targetData[APIConstants.secondAudition_startDate] =
        DateTileUtils.getToday();
    targetData[APIConstants.secondAudition_endDate] =
        DateTileUtils.stringToDateTime2(_endDate);

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.INS_SAD_INFO_FormData;
    params[APIConstants.target] = targetData;

    var temp = _scriptFile.path.split('/');
    String fileName = temp[temp.length - 1];
    params[APIConstants.target_files] =
        await MultipartFile.fromFile(_scriptFile.path, filename: fileName);

    // 2차 오디션 오픈 api 호출
    RestClient(Dio())
        .postRequestMainControlFormData(params)
        .then((value) async {
      try {
        if (value == null) {
          // 에러 - 데이터 널
          showSnackBar(context, '다시 시도해 주세요.');
        } else {
          if (value[APIConstants.resultVal]) {
            showSnackBar(context, "2차 오디션을 오픈하였습니다.");

            _tabIndex = 1;
            _total = 0;
            _secondAuditionApplyList = [];
            _apiKey = APIConstants.SAR_SAD_STATE;

            requestCastingStateList(context);
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
  * 3차 오디션 오픈
  * */
  void requestOpenThirdAudition(BuildContext context) {
    setState(() {
      _isUpload = true;
    });

    // 3차 오디션 오픈 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetData = new Map();
    targetData[APIConstants.casting_seq] = _castingSeq;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.INS_TAD_INFO;
    params[APIConstants.target] = targetData;

    // 3차 오디션 오픈 api 호출
    RestClient(Dio()).postRequestMainControl(params).then((value) async {
      try {
        if (value == null) {
          // 에러 - 데이터 널
          showSnackBar(context, '다시 시도해 주세요.');
        } else {
          if (value[APIConstants.resultVal]) {
            showSnackBar(context, "3차 오디션을 오픈하였습니다.");

            setState(() {
              _firstAuditionInfo[APIConstants.isOpenThirdAudition] = 1;
            });

            _tabIndex = 2;

            _total = 0;
            _thirdAuditionApplyList = [];
            _apiKey = APIConstants.SAR_TAD_STATE;

            requestCastingStateList(context);
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
  * 오디션 대상자 단일 수정(합격, 불합격)
  * */
  void requestUpdateAuditionResult(BuildContext context, int applyIdx,
      String key, int targetSeq, String resultType) {
    setState(() {
      _isUpload = true;
    });

    // 오디션 대상자 단일 수정 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetData = new Map();
    targetData[APIConstants.seq] = targetSeq;
    targetData[APIConstants.result_type] = resultType;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = key;
    params[APIConstants.target] = targetData;

    // 오디션 대상자 단일 수정 api 호출
    RestClient(Dio()).postRequestMainControl(params).then((value) async {
      try {
        if (value == null) {
          // 에러 - 데이터 널
          showSnackBar(context, '다시 시도해 주세요.');
        } else {
          if (value[APIConstants.resultVal]) {
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
          } else {
            if(value[APIConstants.resultMsg] == 'target data cannot edit. already Audition quit.') {
              showSnackBar(context, '계약이 완료된 배우의 상태를 수정할 수 없습니다.');
            } else {
              // 오디션 대상자 단일 수정 실패
              showSnackBar(context, APIConstants.error_msg_try_again);
            }


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
  * 오디션 마감하기
  * */
  void requestQuitAudition(BuildContext context) {
    setState(() {
      _isUpload = true;
    });

    // 오디션 마감하기 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetData = new Map();
    targetData[APIConstants.casting_seq] = _castingSeq;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.UPD_PCT_QUIT;
    params[APIConstants.target] = targetData;

    // 오디션 마감하기 api 호출
    RestClient(Dio()).postRequestMainControl(params).then((value) async {
      try {
        if (value == null) {
          // 에러 - 데이터 널
          showSnackBar(context, '다시 시도해 주세요.');
        } else {
          if (value[APIConstants.resultVal]) {
            setState(() {
              showSnackBar(context, "오디션이 마감되었습니다.");
            });
          } else {
            // 오디션 마감하기 실패
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
  * 출연료 확정하기
  * */
  void requestSavePay(BuildContext context, int seq) {
    setState(() {
      _isUpload = true;
    });

    // 출연료 확정하기 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetData = new Map();
    targetData[APIConstants.thirdAuditionTarget_seq] = seq;
    targetData[APIConstants.final_pay] =
        StringUtils.trimmedString(_txtFieldPay.text);

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.UPD_TAT_PAY;
    params[APIConstants.target] = targetData;

    // 출연료 확정하기 api 호출
    RestClient(Dio()).postRequestMainControl(params).then((value) async {
      try {
        if (value == null) {
          // 에러 - 데이터 널
          showSnackBar(context, '다시 시도해 주세요.');
        } else {
          if (value[APIConstants.resultVal]) {
            setState(() {
              showSnackBar(context, "전자계약을 요청하였습니다.");

              _tabIndex = 3;

              _total = 0;
              _auditionResultList = [];
              _apiKey = APIConstants.SAR_TAD_FINSTATE;

              requestCastingStateList(context);
            });
          } else {
            // 출연료 확정하기 실패
            showSnackBar(context, value[APIConstants.resultMsg]);
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
  * 출연료 지급하기
  * */
  void requestPayToActor(BuildContext context, int seq) {
    setState(() {
      _isUpload = true;
    });

    // 출연료 지급하기 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetData = new Map();
    targetData[APIConstants.thirdAuditionTarget_seq] = seq;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.CHK_TAT_PAY;
    params[APIConstants.target] = targetData;

    // 출연료 지급하기 api 호출
    RestClient(Dio()).postRequestMainControl(params).then((value) async {
      try {
        if (value == null) {
          // 에러 - 데이터 널
          showSnackBar(context, '다시 시도해 주세요.');
        } else {
          if (value[APIConstants.resultVal]) {
            setState(() {
              showSnackBar(context, "출연료를 지급하였습니다.");

              _tabIndex = 3;

              _total = 0;
              _auditionResultList = [];
              _apiKey = APIConstants.SAR_TAD_FINSTATE;

              requestCastingStateList(context);
            });
          } else {
            // 출연료 지급하기 실패
            showSnackBar(context, value[APIConstants.resultMsg]);
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
}
