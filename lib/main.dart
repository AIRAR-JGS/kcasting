import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/KCastingAppData.dart';
import 'package:casting_call/res/Constants.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/view/main/Home.dart';
import 'package:casting_call/src/view/user/common/Login.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return MaterialApp(
      // 디버그 배너 숨기기
      debugShowCheckedModeBanner: false,

      // 앱 타이틀(앱 이름)
      title: Constants.appName,

      routes: {
        '/': (context) => MyHomePage(),
      },

      // 앱 테마(컬러 및 폰트 지정)
      theme: ThemeData(
        primaryColor: CustomColors.colorPrimary,
        fontFamily: Constants.appFont,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with BaseUtilMixin {
  bool _isLogin = false;

  @override
  void initState() {
    super.initState();

    requestCommonCodeK01ListApi(context);
  }

  /*
  *공통코드조회 - 배역 특징 유형
  * */
  void requestCommonCodeK01ListApi(BuildContext context) {
    final dio = Dio();

    // 공통코드조회 api 호출 시 보낼 파라미터
    Map<String, dynamic> target = new Map();
    target[APIConstants.parentCode] = APIConstants.k01;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.SEL_CCD_LIST;
    params[APIConstants.target] = target;

    // 공통코드조회 api 호출
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value != null) {
        if (value[APIConstants.resultVal]) {
          // 공통코드조회 성공
          var _responseList = value[APIConstants.data];
          KCastingAppData().commonCodeK01 = _responseList[APIConstants.list];
        }
      }

      // 외모 특징 유형 공통 코드 조회 api 호출
      requestCommonCodeK02ListApi(context);
    });
  }

  /*
  공통코드조회 - 외모 특징 유형
  * */
  void requestCommonCodeK02ListApi(BuildContext context) {
    final dio = Dio();

    // 공통코드조회 api 호출 시 보낼 파라미터
    Map<String, dynamic> target = new Map();
    target[APIConstants.parentCode] = APIConstants.k02;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.SEL_CCD_LIST;
    params[APIConstants.target] = target;

    // 공통코드조회 api 호출
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value != null) {
        if (value[APIConstants.resultVal]) {
          // 공통코드조회 성공
          var _responseList = value[APIConstants.data];
          KCastingAppData().commonCodeK02 = _responseList[APIConstants.list];
        }
      }

      // 은행코드 api 호출
      requestBankCodeListApi(context);
    });
  }

  /*
  공통코드조회 - 은행코드
  * */
  void requestBankCodeListApi(BuildContext context) {
    final dio = Dio();

    // 공통코드조회 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetDatas = new Map();
    targetDatas[APIConstants.parentCode] = APIConstants.b01;
    targetDatas[APIConstants.isUse] = 1;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.SEL_CCD_LIST;
    params[APIConstants.target] = targetDatas;

    // 공통코드조회 api 호출
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value != null) {
        if (value[APIConstants.resultVal]) {
          // 공통코드조회 성공
          var _responseList = value[APIConstants.data];
          KCastingAppData().bankCode = _responseList[APIConstants.list];
        }
      }

      // 로그인 api 호출
      requestLoginApi(context);
    });
  }

  /*
  * 로그인
  * */
  Future<void> requestLoginApi(BuildContext context) async {
    final dio = Dio();

    // 로그인 api 호출 시 보낼 파라미터
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _isLogin = prefs.getBool(APIConstants.autoLogin) ?? false;

    String memberType = prefs.getString(APIConstants.member_type);
    int seq = prefs.getInt(APIConstants.seq);

    Map<String, dynamic> targetDatas = new Map();
    targetDatas[APIConstants.seq] = seq;

    Map<String, dynamic> params = new Map();
    switch (memberType) {
      case APIConstants.member_type_actor:
        params[APIConstants.key] = APIConstants.SEL_ACT_INFO;
        break;

      case APIConstants.member_type_product:
        params[APIConstants.key] = APIConstants.SEL_PRD_INFO;
        break;

      case APIConstants.member_type_management:
        params[APIConstants.key] = APIConstants.SEL_MGM_INFO;
        break;
    }

    params[APIConstants.target] = targetDatas;

    // 회원 단일 조회 api 호출
    return _isLogin
        ? (RestClient(dio).postRequestMainControl(params).then((value) {
            if (value != null) {
              if (value[APIConstants.resultVal]) {
                try {
                  // 로그인 성공
                  var _responseList = value[APIConstants.data];
                  List<dynamic> _listData = _responseList[APIConstants.list];

                  // 회원데이터 전역변수에 저장
                  KCastingAppData().myInfo =
                      _listData.length > 0 ? _listData[0] : null;

                  switch (KCastingAppData().myInfo[APIConstants.member_type]) {
                    case APIConstants.member_type_actor:
                      requestActorProfileApi(context);
                      break;
                    case APIConstants.member_type_product:
                      replaceView(context, Home());
                      break;
                    case APIConstants.member_type_management:
                      replaceView(context, Home());
                      break;
                  }
                } catch (e) {
                  replaceView(context, Login());
                }
              } else {
                replaceView(context, Login());
              }
            } else {
              replaceView(context, Login());
            }
          }))
        : replaceView(context, Login());
  }

  /*
  * 배우프로필조회
  * */
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

    // 배우프로필조회 api 호출
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

  //========================================================================================================================
  // 메인 위젯
  //========================================================================================================================
  @override
  Widget build(BuildContext context) {
    return Theme(
        data: CustomStyles.defaultTheme(),
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent, // transparent status bar
            systemNavigationBarColor: Colors.black, // navigation bar color
            statusBarIconBrightness: Brightness.dark, // status bar icons' color
            systemNavigationBarIconBrightness:
                Brightness.dark, //navigation bar icons' color
          ),
          child: Scaffold(
              body: Container(
                  width: double.infinity,
                  height: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0, 1],
                        tileMode: TileMode.clamp,
                        colors: [
                          CustomColors.colorPrimary,
                          CustomColors.colorAccent
                        ]),
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset('assets/images/logo_white.png',
                            width: MediaQuery.of(context).size.width * 0.7)
                      ]))),
        ));
  }
}
