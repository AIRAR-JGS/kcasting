import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:casting_call/src/view/user/common/JoinSelectType.dart';
import 'package:casting_call/src/view/user/management/JoinAgency.dart';
import 'package:casting_call/src/view/user/production/JoinProduction.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/*
*  법인 조회
* */
class CompanyAuth extends StatefulWidget {
  final String memberType;

  const CompanyAuth({Key key, this.memberType}) : super(key: key);

  @override
  _CompanyAuth createState() => _CompanyAuth();
}

class _CompanyAuth extends State<CompanyAuth> with BaseUtilMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  bool _isUpload = false;
  String _memberType;

  final _txtFieldCompanyNum = TextEditingController();

  @override
  void initState() {
    super.initState();

    _memberType = widget.memberType;
  }

  /*
  *  메인위젯
  * */
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          // 로그인 페이지 이동
          return Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => JoinSelectType()),
          );
        },
        child: Theme(
            data: CustomStyles.defaultTheme(),
            child: Scaffold(
                key: _scaffoldKey,
                appBar: CustomStyles.defaultAppBar('법인 조회', () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => JoinSelectType()),
                  );
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
                                        padding: EdgeInsets.only(
                                            top: 30, bottom: 50),
                                        child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                  margin: EdgeInsets.only(
                                                      bottom: 30),
                                                  alignment: Alignment.center,
                                                  child: Text('법인 조회',
                                                      style: CustomStyles
                                                          .normal24TextStyle())),
                                              Container(
                                                  padding: EdgeInsets.only(
                                                      left: 30, right: 30),
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: RichText(
                                                      text: TextSpan(
                                                          style: CustomStyles
                                                              .normal14TextStyle(),
                                                          children: <TextSpan>[
                                                        TextSpan(
                                                            text: '사업자등록번호'),
                                                        TextSpan(
                                                            style: TextStyle(
                                                                color: CustomColors
                                                                    .colorRed),
                                                            text: '*'),
                                                      ]))),
                                              Container(
                                                  padding: EdgeInsets.only(
                                                      left: 30, right: 30),
                                                  margin:
                                                      EdgeInsets.only(top: 5),
                                                  child: CustomStyles
                                                      .greyBorderRound7TextFieldWithOption(
                                                          _txtFieldCompanyNum,
                                                          TextInputType.number,
                                                          '사업자등록번호 입력(숫자만)')),
                                            ])))),
                            Container(
                                height: 50,
                                width: double.infinity,
                                child:
                                    CustomStyles.lightGreyBGSquareButtonStyle(
                                        '법인 조회하기', () {
                                  if (checkValidate(context)) {
                                    requestCompanyAuthApi(context);
                                  }
                                }))
                          ],
                        )),
                        Visibility(
                          child: Container(
                              color: Colors.black38,
                              alignment: Alignment.center,
                              child: CircularProgressIndicator()),
                          visible: _isUpload,
                        )
                      ],
                    );
                  },
                ))));
  }

  /*
  * 입력 데이터 유효성 검사
  * */
  bool checkValidate(BuildContext context) {
    if (StringUtils.isEmpty(_txtFieldCompanyNum.text)) {
      showSnackBar(context, '사업자등록번호를 입력해 주세요.');
      return false;
    }

    return true;
  }

  /*
  *  기업 실명확인 api 호출
  * */
  void requestCompanyAuthApi(BuildContext context) async {
    setState(() {
      _isUpload = true;
    });

    // 기업 실명확인 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetDatas = new Map();
    targetDatas[APIConstants.resId] =
        StringUtils.trimmedString(_txtFieldCompanyNum.text);

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.CHK_TOT_REALCORPNAME;
    params[APIConstants.target] = targetDatas;

    // 기업 실명확인 api 호출
    RestClient(Dio()).postRequestMainControl(params).then((value) async {
      try {
        if (value == null) {
          // 에러 - 데이터 널 - 서버가 응답하지 않습니다. 다시 시도해 주세요
          showSnackBar(context, APIConstants.error_msg_server_not_response);
        } else {
          if (value[APIConstants.resultVal]) {
            // 기업 실명확인 성공
            var _responseData = value[APIConstants.data];

            if (_responseData == null) {
              showSnackBar(context, value[APIConstants.error_msg_try_again]);

              return;
            }

            String _resultCorpName = _responseData[APIConstants.resultCorpName];
            String _resultCEOName = _responseData[APIConstants.resultCEOName];
            String _resultCode = _responseData[APIConstants.resultCode];

            if (_resultCode == null) {
              showSnackBar(context, value[APIConstants.error_msg_try_again]);
              return;
            }

            if (_resultCode == "01") {
              if (_resultCorpName != null) {
                if (_memberType == APIConstants.member_type_product) {
                  replaceView(
                      context,
                      JoinProduction(
                          companyName: _resultCorpName,
                          companyCEOName: _resultCEOName,
                          companyNum: StringUtils.trimmedString(
                              _txtFieldCompanyNum.text)));
                } else if (_memberType == APIConstants.member_type_management) {
                  replaceView(
                      context,
                      JoinAgency(
                          companyName: _resultCorpName,
                          companyCEOName: _resultCEOName,
                          companyNum: StringUtils.trimmedString(
                              _txtFieldCompanyNum.text)));
                }
              } else {
                showSnackBar(context, value[APIConstants.error_msg_try_again]);
              }
            } else {
              switch (_resultCode) {
                case "02":
                  showSnackBar(context, "법인 조회 실패, 기업명 불일치");
                  break;
                case "03":
                  showSnackBar(context, "법인 조회 실패, 기업명 미보유");
                  break;
                case "04":
                  showSnackBar(context, "법인 조회 실패, 시스템 오류");
                  break;
                case "05":
                  showSnackBar(context, "법인 조회 실패, 사업자/법인번호 유효성 오류");
                  break;
                case "08":
                  showSnackBar(context, "법인 조회 실패, 서비스 이용 권한 없음");
                  break;
                case "09":
                  showSnackBar(context, "법인 조회 실패, 필수입력값오류");
                  break;
                case "12":
                  showSnackBar(context, "법인 조회 실패, 대표자 불일치");
                  break;
                case "13":
                  showSnackBar(context, "법인 조회 실패, 기업명 대표자 미보유");
                  break;
                case "22":
                  showSnackBar(context, "법인 조회 실패, 사업자/법인명 일치 + 대표자 불일치");
                  break;
                case "23":
                  showSnackBar(context, "법인 조회 실패, 사업자/법인명 일치 + 대표자 미보유");
                  break;
                default:
                  showSnackBar(context, "법인 조회 실패");
                  break;
              }
            }
          } else {
            // 기업 실명확인 실패
            showSnackBar(context, value[APIConstants.error_msg_try_again]);
          }
        }
      } catch (e) {
        showSnackBar(context, value[APIConstants.error_msg_try_again]);
      } finally {
        setState(() {
          _isUpload = false;
        });
      }
    });
  }
}
