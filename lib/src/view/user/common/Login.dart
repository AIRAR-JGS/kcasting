import 'dart:convert';

import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/KCastingAppData.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:casting_call/src/view/main/Home.dart';
import 'package:casting_call/src/view/user/common/FindID.dart';
import 'package:casting_call/src/view/user/common/FindPW.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asymmetric/api.dart';

import 'JoinSelectType.dart';

/*
* 로그인
* */
class Login extends StatefulWidget {
  @override
  _Login createState() => _Login();
}

class _Login extends State<Login> with BaseUtilMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  DateTime currentBackPressTime;

  final _txtFieldID = TextEditingController();
  final _txtFieldPW = TextEditingController();

  int _isAutoLogin = 1;

  Future<String> loadPublicKey() async {
    return await rootBundle.loadString('assets/files/public_key.pem');
  }

  @override
  void initState() {
    super.initState();
  }

  /*
  * 메인 위젯
  * */
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          DateTime now = DateTime.now();
          if (currentBackPressTime == null ||
              now.difference(currentBackPressTime) > Duration(seconds: 2)) {
            currentBackPressTime = now;

            showSnackBar(context, '뒤로 버튼을 한번 더 누르시면 앱이 종료됩니다.');

            return Future.value(false);
          }

          return Future.value(true);
        },
        child: Theme(
            data: CustomStyles.defaultTheme(),
            child: Scaffold(
                key: _scaffoldKey,
                appBar: CustomStyles.appBarWithoutBtn(),
                body: Builder(builder: (BuildContext context) {
                  return SingleChildScrollView(
                      child: Container(
                          padding: EdgeInsets.only(left: 30, right: 30),
                          alignment: Alignment.centerLeft,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // 앱 로고 영역
                                Container(
                                    margin: EdgeInsets.only(top: 100),
                                    alignment: Alignment.center,
                                    child: Image.asset(
                                        'assets/images/logo_blue_big.png',
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.4)),
                                // 아이디 입력 필드
                                Container(
                                    margin: EdgeInsets.only(top: 50),
                                    child:
                                        CustomStyles.greyBorderRound7TextField(
                                            _txtFieldID, '아이디 입력')),
                                // 비밀번호 입력 필드
                                Container(
                                    margin: EdgeInsets.only(top: 10),
                                    child: CustomStyles
                                        .greyBorderRound7PWDTextField(
                                            _txtFieldPW, '비밀번호 입력')),
                                // 자동로그인 체크박스 영역
                                Container(
                                    margin: EdgeInsets.only(top: 5),
                                    child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Radio<int>(
                                            value: _isAutoLogin,
                                            visualDensity:
                                                VisualDensity.compact,
                                            groupValue: 1,
                                            toggleable: true,
                                            onChanged: (_) {
                                              setState(() {
                                                if (_isAutoLogin == 0) {
                                                  _isAutoLogin = 1;
                                                } else {
                                                  _isAutoLogin = 0;
                                                }
                                              });
                                            },
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                          ),
                                          Text('자동 로그인',
                                              style: CustomStyles
                                                  .normal14TextStyle())
                                        ])),
                                // 로그인 버튼
                                Container(
                                    width: double.infinity,
                                    height: 50,
                                    margin: EdgeInsets.only(top: 15),
                                    child: CustomStyles.greyBGRound7ButtonStyle(
                                        '로그인', () {
                                      // 로그인 버튼 클릭
                                      if (checkValidate(context)) {
                                        requestLoginApi(context);
                                      }
                                    })),
                                // 회원가입 버튼
                                Container(
                                    margin: EdgeInsets.only(top: 30),
                                    child: CustomStyles.normal16TextButtonStyle(
                                        '회원가입', () {
                                      replaceView(context, JoinSelectType());
                                    })),
                                Container(
                                    margin:
                                        EdgeInsets.only(top: 30, bottom: 50),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // 아이디 찾기 버튼
                                          CustomStyles.normal16TextButtonStyle(
                                              '아이디 찾기', () {
                                            replaceView(context, FindID());
                                          }),
                                          Container(
                                              margin: EdgeInsets.only(
                                                  left: 5, right: 5),
                                              height: 10,
                                              child: VerticalDivider(
                                                width: 0.5,
                                                thickness: 1,
                                                color:
                                                    CustomColors.colorFontGrey,
                                              )),
                                          // 비밀번호 찾기 버튼
                                          CustomStyles.normal16TextButtonStyle(
                                              '비밀번호 찾기', () {
                                            replaceView(context, FindPW());
                                          })
                                        ]))
                              ])));
                }))));
  }

  /*
  * 입력 데이터 유효성 검사
  * */
  bool checkValidate(BuildContext context) {
    if (StringUtils.isEmpty(_txtFieldID.text)) {
      showSnackBar(context, '아이디를 입력해 주세요.');
      return false;
    }

    if (StringUtils.isEmpty(_txtFieldPW.text)) {
      showSnackBar(context, '비밀번호를 입력해 주세요.');
      return false;
    }

    return true;
  }

  /*
  * 로그인 api 호출
  * */
  void requestLoginApi(BuildContext context) async {

    // 비밀번호 암호화
    final publicPem = await rootBundle.loadString('assets/files/public_key.pem');
    final publicKey = RSAKeyParser().parse(publicPem) as RSAPublicKey;

    final encryptor = Encrypter(RSA(publicKey: publicKey));
    final encrypted = encryptor.encrypt(StringUtils.trimmedString(_txtFieldPW.text));

    // 로그인 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetDatas = new Map();
    targetDatas[APIConstants.id] = StringUtils.trimmedString(_txtFieldID.text);
    targetDatas[APIConstants.pwd] = encrypted.base64;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.LGI_TOT_LOGINRSA;
    params[APIConstants.target] = targetDatas;

    // 로그인 api 호출
    RestClient(Dio()).postRequestMainControl(params).then((value) async {
      if (value == null) {
        // 에러 - 데이터 널
        showSnackBar(context, APIConstants.error_msg_server_not_response);
      } else {
        if (value[APIConstants.resultVal]) {
          var _responseList = value[APIConstants.data];
          List<dynamic> _listData = _responseList[APIConstants.list];

          // 회원데이터 전역변수에 저장
          KCastingAppData().myInfo = _listData.length > 0 ? _listData[0] : null;

          String memberType = KCastingAppData().myInfo[APIConstants.member_type];

          // 로그인 성공
          if (_isAutoLogin == 1) {
            final SharedPreferences prefs =
                await SharedPreferences.getInstance();
            prefs.setBool(APIConstants.autoLogin, true);

            prefs.setString(APIConstants.member_type, memberType);
            prefs.setInt(APIConstants.seq, KCastingAppData().myInfo[APIConstants.seq]);
          }

          if (memberType == APIConstants.member_type_actor) {
            requestActorProfileApi(context);
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Home()),
            );
          }
        } else {
          switch (value[APIConstants.resultMsg]) {
            // 존재하지 않는 아이디입니다.
            case APIConstants.server_error_not_joined:
              showSnackBar(context, APIConstants.error_msg_login_not_valid_id);
              break;
            // 비밀번호가 올바르지 않습니다.
            case APIConstants.server_error_not_valid_pwd:
              showSnackBar(context, APIConstants.error_msg_login_not_valid_pwd);
              break;
            default:
              showSnackBar(context, APIConstants.error_msg_try_again);
              break;
          }
        }
      }
    });
  }

  // 배우프로필조회 api 호출
  void requestActorProfileApi(BuildContext context) {
    final dio = Dio();

    // 배우프로필조회 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetData = new Map();
    targetData[APIConstants.actor_seq] =
        KCastingAppData().myInfo[APIConstants.seq];
    targetData[APIConstants.actor_profile_seq] =
        KCastingAppData().myInfo[APIConstants.actorProfile_seq];

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.SAR_APR_INFO;
    params[APIConstants.target] = targetData;

    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value != null) {
        if (value[APIConstants.resultVal]) {
          // 배우프로필조회 성공
          var _responseList = value[APIConstants.data] as List;

          setState(() {
            for (int i = 0; i < _responseList.length; i++) {
              var _data = _responseList[i];

              switch (_data[APIConstants.table]) {
                // 배우 프로필
                case APIConstants.table_actor_profile:
                  {
                    var _listData = _data[APIConstants.data];
                    if (_listData != null) {
                      List<dynamic> _actorProfileList =
                          _listData[APIConstants.list] as List;
                      if (_actorProfileList != null) {
                        KCastingAppData().myProfile =
                            _actorProfileList.length > 0
                                ? _actorProfileList[0]
                                : null;
                      }
                    }
                    break;
                  }

                // 배우 학력사항
                case APIConstants.table_actor_education:
                  {
                    var _listData = _data[APIConstants.data];
                    if (_listData != null) {
                      KCastingAppData().myEducation =
                          _listData[APIConstants.list] as List;
                    } else {
                      KCastingAppData().myEducation = [];
                    }
                    break;
                  }

                // 배우 언어
                case APIConstants.table_actor_languge:
                  {
                    var _listData = _data[APIConstants.data];
                    if (_listData != null) {
                      KCastingAppData().myLanguage =
                          _listData[APIConstants.list] as List;
                    } else {
                      KCastingAppData().myLanguage = [];
                    }
                    break;
                  }

                // 배우 사투리
                case APIConstants.table_actor_dialect:
                  {
                    var _listData = _data[APIConstants.data];
                    if (_listData != null) {
                      KCastingAppData().myDialect =
                          _listData[APIConstants.list] as List;
                    } else {
                      KCastingAppData().myDialect = [];
                    }
                    break;
                  }

                // 배우 특기
                case APIConstants.table_actor_ability:
                  {
                    var _listData = _data[APIConstants.data];
                    if (_listData != null) {
                      KCastingAppData().myAbility =
                          _listData[APIConstants.list] as List;
                    } else {
                      KCastingAppData().myAbility = [];
                    }
                    break;
                  }

                // 배우 외모 키워드
                case APIConstants.table_actor_lookkwd:
                  {
                    var _listData = _data[APIConstants.data];
                    if (_listData != null) {
                      KCastingAppData().myLookKwd =
                          _listData[APIConstants.list] as List;
                    } else {
                      KCastingAppData().myLookKwd = [];
                    }
                    break;
                  }

                // 배우 캐스팅 키워드
                case APIConstants.table_actor_castingKwd:
                  {
                    var _listData = _data[APIConstants.data];

                    if (_listData != null) {
                      KCastingAppData().myCastingKwd =
                          _listData[APIConstants.list] as List;
                    } else {
                      KCastingAppData().myCastingKwd = [];
                    }

                    break;
                  }

                // 배우 필모그래피
                case APIConstants.table_actor_filmography:
                  {
                    var _listData = _data[APIConstants.data];
                    if (_listData != null) {
                      KCastingAppData()
                        ..myFilmorgraphy = _listData[APIConstants.list] as List;
                    } else {
                      KCastingAppData().myFilmorgraphy = [];
                    }
                    break;
                  }

                // 배우 이미지
                case APIConstants.table_actor_image:
                  {
                    var _listData = _data[APIConstants.data];
                    if (_listData != null) {
                      KCastingAppData().myImage =
                          _listData[APIConstants.list] as List;
                    } else {
                      KCastingAppData().myImage = [];
                    }

                    break;
                  }

                // 배우 비디오
                case APIConstants.table_actor_video:
                  {
                    var _listData = _data[APIConstants.data];
                    if (_listData != null) {
                      KCastingAppData().myVideo =
                          _listData[APIConstants.list] as List;
                    } else {
                      KCastingAppData().myVideo = [];
                    }

                    break;
                  }
              }
            }
          });
        }
      }

      replaceView(context, Home());
    });
  }
}
