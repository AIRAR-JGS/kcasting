import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/KCastingAppData.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/model/CheckboxITemModel.dart';
import 'package:casting_call/src/model/CommonCodeModel.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/view/mypage/actor/ActorProfileModifyMainInfo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';

import 'AgencyActorList.dart';

/*
* 보유 배우 프로필 추가 - 2
* */
class RegisterAgencyActorProfileSubInfo extends StatefulWidget {
  final Map<String, dynamic> targetData;

  const RegisterAgencyActorProfileSubInfo({Key key, this.targetData})
      : super(key: key);

  @override
  _RegisterAgencyActorProfileSubInfo createState() =>
      _RegisterAgencyActorProfileSubInfo();
}

class _RegisterAgencyActorProfileSubInfo
    extends State<RegisterAgencyActorProfileSubInfo>
    with SingleTickerProviderStateMixin, BaseUtilMixin {
  bool _isUpload = false;

  Map<String, dynamic> _targetData;

  TabController _tabController;
  int _tabIndex = 0;

  List<CheckboxItemModel> _languages = [];
  List<CheckboxItemModel> _dialect = [];
  List<CheckboxItemModel> _secialityMusic = [];
  List<CheckboxItemModel> _secialityDance = [];
  List<CheckboxItemModel> _secialitySports = [];
  List<CheckboxItemModel> _secialityEtc = [];

  List<CommonCodeModel> _castingKeyword = [];
  List<CommonCodeModel> _lookKeyword = [];

  final GlobalKey<TagsState> _characterTagStateKey = GlobalKey<TagsState>();
  final GlobalKey<TagsState> _appearanceTagStateKey = GlobalKey<TagsState>();

  @override
  void initState() {
    super.initState();

    _targetData = widget.targetData;

    _languages.add(new CheckboxItemModel('영어', false));
    _languages.add(new CheckboxItemModel('중국어', false));
    _languages.add(new CheckboxItemModel('일본어', false));
    _languages.add(new CheckboxItemModel('아랍어', false));
    _languages.add(new CheckboxItemModel('불어', false));
    _languages.add(new CheckboxItemModel('스페인어', false));

    _dialect.add(new CheckboxItemModel('경상도', false));
    _dialect.add(new CheckboxItemModel('전라도', false));
    _dialect.add(new CheckboxItemModel('충청도', false));
    _dialect.add(new CheckboxItemModel('강원도', false));
    _dialect.add(new CheckboxItemModel('제주도', false));
    _dialect.add(new CheckboxItemModel('연변', false));
    _dialect.add(new CheckboxItemModel('북한', false));

    _secialityMusic.add(new CheckboxItemModel('성악', false));
    _secialityMusic.add(new CheckboxItemModel('알앤비', false));
    _secialityMusic.add(new CheckboxItemModel('락', false));
    _secialityMusic.add(new CheckboxItemModel('랩', false));
    _secialityMusic.add(new CheckboxItemModel('뮤지컬', false));
    _secialityMusic.add(new CheckboxItemModel('피아노', false));
    _secialityMusic.add(new CheckboxItemModel('바이올린', false));
    _secialityMusic.add(new CheckboxItemModel('플루트', false));
    _secialityMusic.add(new CheckboxItemModel('첼로', false));
    _secialityMusic.add(new CheckboxItemModel('우쿨렐레', false));
    _secialityMusic.add(new CheckboxItemModel('일렉기타', false));
    _secialityMusic.add(new CheckboxItemModel('베이스', false));
    _secialityMusic.add(new CheckboxItemModel('통기타', false));
    _secialityMusic.add(new CheckboxItemModel('트럼펫', false));
    _secialityMusic.add(new CheckboxItemModel('트럼본', false));

    _secialityDance.add(new CheckboxItemModel('한국무용', false));
    _secialityDance.add(new CheckboxItemModel('발레', false));
    _secialityDance.add(new CheckboxItemModel('재즈댄스', false));
    _secialityDance.add(new CheckboxItemModel('뮤지컬댄스', false));
    _secialityDance.add(new CheckboxItemModel('스포츠댄스', false));
    _secialityDance.add(new CheckboxItemModel('브레이크', false));
    _secialityDance.add(new CheckboxItemModel('스트릿댄스', false));
    _secialityDance.add(new CheckboxItemModel('팝핀', false));
    _secialityDance.add(new CheckboxItemModel('힙합', false));
    _secialityDance.add(new CheckboxItemModel('하우스', false));
    _secialityDance.add(new CheckboxItemModel('방송댄스', false));
    _secialityDance.add(new CheckboxItemModel('라틴', false));
    _secialityDance.add(new CheckboxItemModel('밸리댄스', false));
    _secialityDance.add(new CheckboxItemModel('탭댄스', false));

    _secialitySports.add(new CheckboxItemModel('요가', false));
    _secialitySports.add(new CheckboxItemModel('골프', false));
    _secialitySports.add(new CheckboxItemModel('축구', false));
    _secialitySports.add(new CheckboxItemModel('야구', false));
    _secialitySports.add(new CheckboxItemModel('농구', false));
    _secialitySports.add(new CheckboxItemModel('수영', false));
    _secialitySports.add(new CheckboxItemModel('헬스', false));
    _secialitySports.add(new CheckboxItemModel('탁구', false));
    _secialitySports.add(new CheckboxItemModel('복싱', false));
    _secialitySports.add(new CheckboxItemModel('스쿼시', false));
    _secialitySports.add(new CheckboxItemModel('조깅', false));
    _secialitySports.add(new CheckboxItemModel('인라인', false));
    _secialitySports.add(new CheckboxItemModel('보드', false));

    _secialityEtc.add(new CheckboxItemModel('자전거', false));
    _secialityEtc.add(new CheckboxItemModel('등산', false));
    _secialityEtc.add(new CheckboxItemModel('레프팅', false));
    _secialityEtc.add(new CheckboxItemModel('수상스키', false));
    _secialityEtc.add(new CheckboxItemModel('암벽등반', false));
    _secialityEtc.add(new CheckboxItemModel('번지점프', false));
    _secialityEtc.add(new CheckboxItemModel('낚시', false));
    _secialityEtc.add(new CheckboxItemModel('작곡', false));
    _secialityEtc.add(new CheckboxItemModel('작사', false));

    for (int i = 0; i < _languages.length; i++) {
      for (int j = 0; j < KCastingAppData().myLanguage.length; j++) {
        var myLanguage = KCastingAppData().myLanguage[j];

        if (_languages[i].itemName == myLanguage[APIConstants.language_type]) {
          _languages[i].isSelected = true;
        }
      }
    }

    for (int i = 0; i < _dialect.length; i++) {
      for (int j = 0; j < KCastingAppData().myDialect.length; j++) {
        var myDialect = KCastingAppData().myDialect[j];

        if (_dialect[i].itemName == myDialect[APIConstants.dialect_type]) {
          _dialect[i].isSelected = true;
        }
      }
    }

    for (int i = 0; i < _secialityMusic.length; i++) {
      for (int j = 0; j < KCastingAppData().myAbility.length; j++) {
        var myAbility = KCastingAppData().myAbility[j];

        if (_secialityMusic[i].itemName == myAbility[APIConstants.child_type]) {
          _secialityMusic[i].isSelected = true;
        }
      }
    }

    for (int i = 0; i < _secialityDance.length; i++) {
      for (int j = 0; j < KCastingAppData().myAbility.length; j++) {
        var myAbility = KCastingAppData().myAbility[j];

        if (_secialityDance[i].itemName == myAbility[APIConstants.child_type]) {
          _secialityDance[i].isSelected = true;
        }
      }
    }

    for (int i = 0; i < _secialitySports.length; i++) {
      for (int j = 0; j < KCastingAppData().myAbility.length; j++) {
        var myAbility = KCastingAppData().myAbility[j];

        if (_secialitySports[i].itemName ==
            myAbility[APIConstants.child_type]) {
          _secialitySports[i].isSelected = true;
        }
      }
    }

    for (int i = 0; i < _secialityEtc.length; i++) {
      for (int j = 0; j < KCastingAppData().myAbility.length; j++) {
        var myAbility = KCastingAppData().myAbility[j];

        if (_secialityEtc[i].itemName == myAbility[APIConstants.child_type]) {
          _secialityEtc[i].isSelected = true;
        }
      }
    }

    for (int i = 0; i < KCastingAppData().commonCodeK01.length; i++) {
      var commonCode = KCastingAppData().commonCodeK01[i];

      _castingKeyword.add(new CommonCodeModel(commonCode[APIConstants.seq],
          commonCode[APIConstants.child_name], false));
    }

    for (int i = 0; i < _castingKeyword.length; i++) {
      for (int j = 0; j < KCastingAppData().myCastingKwd.length; j++) {
        var commonCode = KCastingAppData().myCastingKwd[j];

        if (_castingKeyword[i].seq == commonCode[APIConstants.code_seq]) {
          _castingKeyword[i].isSelected = true;
        }
      }
    }

    for (int i = 0; i < KCastingAppData().commonCodeK02.length; i++) {
      var commonCode = KCastingAppData().commonCodeK02[i];

      _lookKeyword.add(new CommonCodeModel(commonCode[APIConstants.seq],
          commonCode[APIConstants.child_name], false));
    }

    for (int i = 0; i < _lookKeyword.length; i++) {
      for (int j = 0; j < KCastingAppData().myLookKwd.length; j++) {
        var commonCode = KCastingAppData().myLookKwd[j];

        if (_lookKeyword[i].seq == commonCode[APIConstants.code_seq]) {
          _lookKeyword[i].isSelected = true;
        }
      }
    }

    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _tabIndex = _tabController.index;
      });
    }
  }

  Widget tabSpecialityMusic() {
    return Container(
      margin: EdgeInsets.only(left: 15, right: 15, top: 10),
      child: Wrap(
        children: [
          GridView.count(
            childAspectRatio: 3,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 4,
            children: List.generate(_secialityMusic.length, (index) {
              return Container(
                  child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: _secialityMusic[index].isSelected,
                      onChanged: (value) {
                        setState(() {
                          _secialityMusic[index].isSelected = value;
                        });
                      },
                    ),
                  ),
                  Text(_secialityMusic[index].itemName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CustomStyles.normal14TextStyle())
                ],
              ));
            }),
          ),
        ],
      ),
    );
  }

  Widget tabSpecialityDance() {
    return Container(
      margin: EdgeInsets.only(left: 15, right: 15, top: 10),
      child: Wrap(
        children: [
          GridView.count(
            childAspectRatio: 3,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 4,
            children: List.generate(_secialityDance.length, (index) {
              return Container(
                  child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: _secialityDance[index].isSelected,
                      onChanged: (value) {
                        setState(() {
                          _secialityDance[index].isSelected = value;
                        });
                      },
                    ),
                  ),
                  Text(_secialityDance[index].itemName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CustomStyles.normal14TextStyle())
                ],
              ));
            }),
          ),
        ],
      ),
    );
  }

  Widget tabSpecialitySports() {
    return Container(
      margin: EdgeInsets.only(left: 15, right: 15, top: 10),
      child: Wrap(
        children: [
          GridView.count(
            childAspectRatio: 3,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 4,
            children: List.generate(_secialitySports.length, (index) {
              return Container(
                  child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: _secialitySports[index].isSelected,
                      onChanged: (value) {
                        setState(() {
                          _secialitySports[index].isSelected = value;
                        });
                      },
                    ),
                  ),
                  Text(_secialitySports[index].itemName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CustomStyles.normal14TextStyle())
                ],
              ));
            }),
          ),
        ],
      ),
    );
  }

  Widget tabSpecialityEtc() {
    return Container(
      margin: EdgeInsets.only(left: 15, right: 15, top: 10),
      child: Wrap(
        children: [
          GridView.count(
            childAspectRatio: 3,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 4,
            children: List.generate(_secialityEtc.length, (index) {
              return Container(
                  child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: _secialityEtc[index].isSelected,
                      onChanged: (value) {
                        setState(() {
                          _secialityEtc[index].isSelected = value;
                        });
                      },
                    ),
                  ),
                  Text(_secialityEtc[index].itemName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CustomStyles.normal14TextStyle())
                ],
              ));
            }),
          ),
        ],
      ),
    );
  }

  /*
  * 메인 위젯
  * */
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: CustomStyles.defaultTheme(),
      child: Scaffold(
        appBar: CustomStyles.defaultAppBar('프로필 편집', () {
          Navigator.pop(context);
        }),
        body: Stack(
          children: [
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      flex: 1,
                      child: SingleChildScrollView(
                          child: Container(
                              padding: EdgeInsets.only(top: 30, bottom: 30),
                              child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                        margin: EdgeInsets.only(bottom: 5),
                                        padding: EdgeInsets.only(
                                            left: 15, right: 15),
                                        alignment: Alignment.centerLeft,
                                        child: Text('언어',
                                            style: CustomStyles
                                                .bold14TextStyle())),
                                    Wrap(
                                      children: [
                                        GridView.count(
                                          childAspectRatio: 3,
                                          padding: EdgeInsets.only(
                                              left: 15, right: 10),
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          crossAxisCount: 4,
                                          children: List.generate(
                                              _languages.length, (index) {
                                            return Container(
                                                child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                SizedBox(
                                                  width: 24,
                                                  height: 24,
                                                  child: Checkbox(
                                                    materialTapTargetSize:
                                                        MaterialTapTargetSize
                                                            .shrinkWrap,
                                                    value: _languages[index]
                                                        .isSelected,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _languages[index]
                                                            .isSelected = value;
                                                      });
                                                    },
                                                  ),
                                                ),
                                                Text(_languages[index].itemName,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: CustomStyles
                                                        .normal14TextStyle())
                                              ],
                                            ));
                                          }),
                                        ),
                                      ],
                                    ),
                                    Container(
                                        margin:
                                            EdgeInsets.only(bottom: 5, top: 20),
                                        padding: EdgeInsets.only(
                                            left: 15, right: 15),
                                        alignment: Alignment.centerLeft,
                                        child: Text('사투리',
                                            style: CustomStyles
                                                .bold14TextStyle())),
                                    Wrap(
                                      children: [
                                        GridView.count(
                                          childAspectRatio: 3,
                                          padding: EdgeInsets.only(
                                              left: 15, right: 10),
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          crossAxisCount: 4,
                                          children: List.generate(
                                              _dialect.length, (index) {
                                            return Container(
                                                child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                SizedBox(
                                                  width: 24,
                                                  height: 24,
                                                  child: Checkbox(
                                                    materialTapTargetSize:
                                                        MaterialTapTargetSize
                                                            .shrinkWrap,
                                                    value: _dialect[index]
                                                        .isSelected,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _dialect[index]
                                                            .isSelected = value;
                                                      });
                                                    },
                                                  ),
                                                ),
                                                Text(_dialect[index].itemName,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: CustomStyles
                                                        .normal14TextStyle())
                                              ],
                                            ));
                                          }),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: 20),
                                      child: Divider(
                                        height: 1,
                                        color: CustomColors.colorFontLightGrey,
                                      ),
                                    ),
                                    Container(
                                        margin:
                                            EdgeInsets.only(bottom: 5, top: 15),
                                        padding: EdgeInsets.only(
                                            left: 15, right: 15),
                                        alignment: Alignment.centerLeft,
                                        child: Text('특기',
                                            style: CustomStyles
                                                .bold14TextStyle())),
                                    Container(
                                        margin: EdgeInsets.only(top: 5),
                                        width:
                                            MediaQuery.of(context).size.width,
                                        color: CustomColors.colorWhite,
                                        child: TabBar(
                                            controller: _tabController,
                                            indicatorSize:
                                                TabBarIndicatorSize.label,
                                            indicatorPadding: EdgeInsets.zero,
                                            labelStyle:
                                                CustomStyles.bold14TextStyle(),
                                            unselectedLabelStyle: CustomStyles
                                                .normal14TextStyle(),
                                            tabs: [
                                              Tab(text: '음악'),
                                              Tab(text: '춤'),
                                              Tab(text: '스포츠'),
                                              Tab(text: '기타')
                                            ])),
                                    Expanded(
                                      flex: 0,
                                      child: [
                                        tabSpecialityMusic(),
                                        tabSpecialityDance(),
                                        tabSpecialitySports(),
                                        tabSpecialityEtc()
                                      ][_tabIndex],
                                    ),
                                    Container(
                                        margin: EdgeInsets.only(top: 20),
                                        child: Divider(
                                          height: 0.1,
                                          color:
                                              CustomColors.colorFontLightGrey,
                                        )),
                                    Container(
                                        margin: EdgeInsets.only(top: 15),
                                        padding: EdgeInsets.only(
                                            left: 15, right: 15),
                                        alignment: Alignment.centerLeft,
                                        child: Text('키워드',
                                            style: CustomStyles
                                                .bold14TextStyle())),
                                    Container(
                                        margin: EdgeInsets.only(top: 10),
                                        padding: EdgeInsets.only(
                                            left: 15, right: 15),
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                            '회원님에게 맞는 키워드를 설정하여 제작자들에게 회원님을 노출해보세요.(최대 3개)',
                                            style: CustomStyles
                                                .normal14TextStyle())),
                                    Container(
                                        margin: EdgeInsets.only(top: 20),
                                        padding: EdgeInsets.only(
                                            left: 15, right: 15),
                                        alignment: Alignment.centerLeft,
                                        child: Text('배역 특징',
                                            style: CustomStyles
                                                .bold14TextStyle())),
                                    Container(
                                      alignment: Alignment.topLeft,
                                      margin: EdgeInsets.only(top: 10),
                                      padding: EdgeInsets.only(
                                        left: 15,
                                        right: 15,
                                      ),
                                      child: Tags(
                                        runSpacing: 5,
                                        alignment: WrapAlignment.start,
                                        key: _characterTagStateKey,
                                        itemCount: _castingKeyword.length,
                                        itemBuilder: (int index) {
                                          final item = _castingKeyword[index];
                                          return ItemTags(
                                              textStyle: CustomStyles
                                                  .dark14TextStyle(),
                                              textColor: CustomColors
                                                  .colorFontDarkGrey,
                                              activeColor:
                                                  CustomColors.colorPrimary,
                                              textActiveColor:
                                                  CustomColors.colorWhite,
                                              key: Key(index.toString()),
                                              index: index,
                                              title: item.childName,
                                              active: item.isSelected,
                                              combine: ItemTagsCombine
                                                  .withTextBefore,
                                              elevation: 0.0,
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              onPressed: (item) {
                                                _castingKeyword[index]
                                                    .isSelected = item.active;
                                              });
                                        },
                                      ),
                                    ),
                                    Container(
                                        margin: EdgeInsets.only(top: 25),
                                        padding: EdgeInsets.only(
                                            left: 15, right: 15),
                                        alignment: Alignment.centerLeft,
                                        child: Text('외모 특징',
                                            style: CustomStyles
                                                .bold14TextStyle())),
                                    Container(
                                      alignment: Alignment.topLeft,
                                      margin: EdgeInsets.only(top: 10),
                                      padding: EdgeInsets.only(
                                        left: 15,
                                        right: 15,
                                      ),
                                      child: Tags(
                                        runSpacing: 5,
                                        alignment: WrapAlignment.start,
                                        key: _appearanceTagStateKey,
                                        itemCount: _lookKeyword.length,
                                        itemBuilder: (int index) {
                                          final item = _lookKeyword[index];
                                          return ItemTags(
                                            textStyle:
                                                CustomStyles.dark14TextStyle(),
                                            textColor:
                                                CustomColors.colorFontDarkGrey,
                                            activeColor:
                                                CustomColors.colorPrimary,
                                            textActiveColor:
                                                CustomColors.colorWhite,
                                            key: Key(index.toString()),
                                            index: index,
                                            title: item.childName,
                                            active: item.isSelected,
                                            combine:
                                                ItemTagsCombine.withTextBefore,
                                            elevation: 0.0,
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            onPressed: (item) {
                                              _lookKeyword[index].isSelected =
                                                  item.active;
                                              print(item.active);
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ])))),
                  Container(
                      width: double.infinity,
                      height: 50,
                      color: Colors.grey,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                              child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 55,
                                  child: CustomStyles.greyBGSquareButtonStyle(
                                      '이전', () {
                                    replaceView(
                                        context, ActorProfileModifyMainInfo());
                                  }))),
                          Expanded(
                              child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 55,
                                  child: CustomStyles.blueBGSquareButtonStyle(
                                      '저장', () {
                                    requestUpdateApi(context);
                                  })))
                        ],
                      ))
                ],
              ),
            ),
            Visibility(
              child: Container(
                  color: Colors.black38,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator()),
              visible: _isUpload,
            )
          ],
        ),
      ),
    );
  }

  /*
  * 매니지먼트 보유 배우 추가 수정
  * */
  void requestUpdateApi(BuildContext context) {
    setState(() {
      _isUpload = true;
    });

    // 매니지먼트 보유 배우 추가 api 호출 시 보낼 파라미터
    List<Map<String, dynamic>> languageTargetDatas = [];

    for (int i = 0; i < _languages.length; i++) {
      if (_languages[i].isSelected) {
        Map<String, dynamic> actorLanguage = new Map();
        actorLanguage[APIConstants.language_type] = _languages[i].itemName;

        languageTargetDatas.add(actorLanguage);
      }
    }

    if (languageTargetDatas.length > 0) {
      _targetData[APIConstants.languge_target] = languageTargetDatas;
    }

    List<Map<String, dynamic>> dialectTargetDatas = [];

    for (int i = 0; i < _dialect.length; i++) {
      if (_dialect[i].isSelected) {
        Map<String, dynamic> actorDialect = new Map();
        actorDialect[APIConstants.dialect_type] = _dialect[i].itemName;

        dialectTargetDatas.add(actorDialect);
      }
    }

    if (dialectTargetDatas.length > 0) {
      _targetData[APIConstants.dialect_target] = dialectTargetDatas;
    }

    List<Map<String, dynamic>> abilityTargetDatas = [];

    for (int i = 0; i < _secialityMusic.length; i++) {
      if (_secialityMusic[i].isSelected) {
        Map<String, dynamic> data = new Map();
        data[APIConstants.parentType] = "음악";
        data[APIConstants.child_type] = _secialityMusic[i].itemName;

        abilityTargetDatas.add(data);
      }
    }

    for (int i = 0; i < _secialityDance.length; i++) {
      if (_secialityDance[i].isSelected) {
        Map<String, dynamic> data = new Map();
        data[APIConstants.parentType] = "춤";
        data[APIConstants.child_type] = _secialityDance[i].itemName;

        abilityTargetDatas.add(data);
      }
    }

    for (int i = 0; i < _secialitySports.length; i++) {
      if (_secialitySports[i].isSelected) {
        Map<String, dynamic> data = new Map();
        data[APIConstants.parentType] = "스포츠";
        data[APIConstants.child_type] = _secialitySports[i].itemName;

        abilityTargetDatas.add(data);
      }
    }

    for (int i = 0; i < _secialityEtc.length; i++) {
      if (_secialityEtc[i].isSelected) {
        Map<String, dynamic> data = new Map();
        data[APIConstants.parentType] = "기타";
        data[APIConstants.child_type] = _secialityEtc[i].itemName;

        abilityTargetDatas.add(data);
      }
    }

    if (abilityTargetDatas.length > 0) {
      _targetData[APIConstants.ability_target] = abilityTargetDatas;
    }

    List<Map<String, dynamic>> lookKeyword = [];

    for (int i = 0; i < _lookKeyword.length; i++) {
      if (_lookKeyword[i].isSelected) {
        Map<String, dynamic> data = new Map();
        data[APIConstants.code_seq] = _lookKeyword[i].seq;

        lookKeyword.add(data);
      }
    }

    if (lookKeyword.length > 0) {
      _targetData[APIConstants.lookKwd_target] = lookKeyword;
    }

    List<Map<String, dynamic>> castingKeyword = [];

    for (int i = 0; i < _castingKeyword.length; i++) {
      if (_castingKeyword[i].isSelected) {
        Map<String, dynamic> data = new Map();
        data[APIConstants.code_seq] = _castingKeyword[i].seq;

        castingKeyword.add(data);
      }
    }

    if (castingKeyword.length > 0) {
      _targetData[APIConstants.castingKwd_target] = castingKeyword;
    }

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.INS_MGM_JOINACTOR;
    params[APIConstants.target] = _targetData;

    // 매니지먼트 보유 배우 추가 api 호출
    RestClient(Dio()).postRequestMainControl(params).then((value) async {
      try {
        if (value != null) {
          if (value[APIConstants.resultVal]) {
            // 매니지먼트 보유 배우 추가 성공
            replaceView(context, AgencyActorList());
          } else {
            showSnackBar(context, APIConstants.error_msg_try_again);
          }
        } else {
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
}
