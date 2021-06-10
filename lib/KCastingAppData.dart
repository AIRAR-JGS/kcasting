/*
* 전역 변수 클래스
* */
class KCastingAppData {
  static final KCastingAppData _appData = KCastingAppData._internal();

  factory KCastingAppData() {
    return _appData;
  }

  KCastingAppData._internal();

  var  commonCodeK01 = [];                              //  공통코드 - 배역 특징 유형
  var commonCodeK02 = [];                               //  공통코드 - 외모 특징 유형

  var myInfo = new Map();                                  // 내 회원정보(로그인 정보)

  var myProfile = new Map();                             // 배우 회원 프로필
  var myEducation = [];                                       // 배우 회원 학력사항
  var myLanguage = [];                                       // 배우 회원 언어
  var myDialect = [];                                            // 배우 회원 사투리
  var myAbility = [];                                              // 배우 회원 특기
  var myLookKwd = [];                                         // 배우 회원 외모 키워드
  var myCastingKwd = [];                                    // 배우 회원 캐스팅 키워드
  var myFilmorgraphy = [];                                 // 배우 회원 필모그래피
  var myImage = [];                                              // 배우 회원 이미지
  var myVideo = [];                                               // 배우 회원 비디오

  // 모든 데이터 초기화
  void clearData() {
    myInfo = new Map();
    myProfile = new Map();
    myEducation = [];
    myLanguage = [];
    myDialect = [];
    myAbility = [];
    myCastingKwd = [];
    myLookKwd = [];
    myFilmorgraphy = [];
    myImage = [];
    myVideo = [];
  }
}