class APIConstants {

  //================================================================================
  // 서버 URL 변수
  //================================================================================
  static const String BASE_URL = "https://k-casting.com/t1/index.php/Api/";
  //static const String BASE_URL = "https://k-casting.com/v1/index.php/Api/";
  static const String URL_MAIN_CONTROL = "mainControl";

  static String getURL(String path) {
    return BASE_URL + path;
  }

  static const String URL_PRIVACY_POLICY = "https://enterrobang.tistory.com/pages/privacy";

  //================================================================================
  // 서버 데이터 키값 변수
  //================================================================================

  // 키값
  static const String key = "key";

  static const String SEL_CCD_LIST  = "SEL_CCD_LIST";  // 공통 코드 조회

  static const String INS_PRD_JOIN = "INS_PRD_JOIN";  // 제작사 회원가입
  static const String LGI_TOT_LOGIN = "LGI_TOT_LOGIN";  // 로그인
  static const String UPD_PRD_INFO = "UPD_PRD_INFO";  // 제작사 개인정보 수정
  static const String UDF_PRD_LOGO = "UDF_PRD_LOGO";  // 제작사 로고 이미지 수정
  static const String SEL_PRD_INFO = "SEL_PRD_INFO";  // 제작사 단일 조회
  static const String INS_PFM_INFO = "INS_PFM_INFO";  // 제작사 필모그래피 추가
  static const String DEA_PFM_LIST = "DEA_PFM_LIST";  // 제작사 필모그래피 삭제
  static const String SEL_PFM_LIST = "SEL_PFM_LIST";  // 제작사 필모그래피 목록 조회
  static const String INS_PPJ_INFO = "INS_PPJ_INFO";  // 제작사 작품 등록
  static const String SEL_PPJ_LIST = "SEL_PPJ_LIST";  // 제작사 작품 목록 조회
  static const String IPC_PCT_INFO  = "IPC_PCT_INFO";  // 캐스팅 등록(배역 추가) - 특정 배역 추가, 다수 배역 추가
  static const String SAR_PCT_INFO  = "SAR_PCT_INFO";  // 캐스팅 단일 조회
  static const String SEL_PCT_LIST  = "SEL_PCT_LIST";  // 캐스팅 목록 조회
  static const String INS_PAP_INFO  = "INS_PAP_INFO";  // 오디션 제안 등록
  static const String SEL_PCT_PAPOKLIST  = "SEL_PCT_PAPOKLIST";  // 오디션 제안 가능 목록 조회
  static const String SEL_PAP_LIST  = "SEL_PAP_LIST";  // 오디션 제안 목록 조회
  static const String SEL_PCT_INGLIST  = "SEL_PCT_INGLIST";  // 캐스팅 진행 현황 조회 : 진행중
  static const String SEL_PCT_CMPLIST  = "SEL_PCT_CMPLIST";  // 캐스팅 진행 현황 조회 : 계약완료
  static const String SEL_PCT_FINLIST  = "SEL_PCT_FINLIST";  // 캐스팅 진행 현황 조회 : 마감
  static const String SAR_FAD_STATE  = "SAR_FAD_STATE";  // 1차 오디션 진행 현황 조회
  static const String SAR_SAD_STATE  = "SAR_SAD_STATE";  // 2차 오디션 진행 현황 조회
  static const String SAR_TAD_STATE  = "SAR_TAD_STATE";  // 3차 오디션 진행 현황 조회
  static const String SAR_TAD_FINSTATE  = "SAR_TAD_FINSTATE";  // 최종 오디션 진행 현황 조회
  static const String INS_SAD_INFO  = "INS_SAD_INFO";  // 2차 오디션 오픈
  static const String INS_TAD_INFO  = "INS_TAD_INFO";  // 3차 오디션 오픈
  static const String UPD_FAT_INFO  = "UPD_FAT_INFO";  // 오디션 대상자 단일 수정(합격, 불합격) - 1차
  static const String UPD_SAT_INFO  = "UPD_SAT_INFO";  // 오디션 대상자 단일 수정(합격, 불합격) - 2차
  static const String UPD_TAT_INFO  = "UPD_TAT_INFO";  // 오디션 대상자 단일 수정(합격, 불합격) - 3차

  static const String INS_ACT_JOIN  = "INS_ACT_JOIN";  // 배우 회원가입
  static const String SEL_ACT_INFO  = "SEL_ACT_INFO";  // 배우 단일 조회
  static const String SEL_ACT_LIST  = "SEL_ACT_LIST";  // 배우 목록 조회
  static const String UPD_ACT_INFO  = "UPD_ACT_INFO";  // 배우 개인정보 수정
  static const String INS_AFM_INFO  = "INS_AFM_INFO";  // 배우 필모그래피 등록
  static const String DEA_AFM_LIST  = "DEA_AFM_LIST";  // 배우 필모그래피 일괄 삭제
  static const String IPC_APR_INFO  = "IPC_APR_INFO";  // 배우 프로필 등록
  static const String UPD_APR_MAINIMG  = "UPD_APR_MAINIMG";  // 배우 프로필 이미지 수정
  static const String SAR_APR_INFO  = "SAR_APR_INFO";  // 배우 이미지 등록
  static const String INS_AIM_LIST  = "INS_AIM_LIST";  // 배우 이미지 등록
  static const String DEA_AIM_LIST  = "DEA_AIM_LIST";  // 배우 이미지 일괄 삭제
  static const String INS_AVD_LIST  = "INS_AVD_LIST";  // 배우 비디오 등록
  static const String DEA_AVD_LIST  = "DEA_AVD_LIST";  // 배우 비디오 일괄 삭제
  static const String INS_AAA_INFO  = "INS_AAA_INFO";  // 배우 오디션 지원
  static const String SEL_AAA_LIST  = "SEL_AAA_LIST";  // 배우 오디션 지원 현황 조회
  static const String DEL_AAA_INFO  = "DEL_AAA_INFO";  // 배우 오디션 지원 취소
  static const String SAR_AAP_INFO  = "SAR_AAP_INFO";  // 배우 오디션 제출 프로필 조회
  static const String SEL_AAA_STATE  = "SEL_AAA_STATE";  // 배우 오디션 지원 상태 조회
  static const String UPD_SAT_SUBMIT  = "UPD_SAT_SUBMIT";  // 배우 비디오 등록 및 연락처 공개 동의
  static const String SEL_APP_LIST  = "SEL_APP_LIST";  // 배우 제안 받은 목록 조회
  static const String UPD_APP_ANSWER  = "UPD_APP_ANSWER";  // 배우 제안 거절 or 수락
  static const String SEL_MKM_LIST  = "SEL_MKM_LIST";  // 메인 : 남배우 외모 특징 목록 조회
  static const String SEL_MKW_LIST  = "SEL_MKW_LIST";  // 메인 : 여배우 외모 특징 목록 조회
  static const String SEL_ACT_STATE  = "SEL_ACT_STATE";  // 배우 상태 조회

  static const String server_error_already_exist = "already exists data";
  static const String server_error_not_joined = "This id not joind";
  static const String server_error_not_valid_pwd = "It not a valid password";
  static const String server_error_not_FirstAuditionTarget = "check table FirstAuditionTarget result_type.";
  static const String server_error_not_SecondAuditionTarget = "check table SecondAuditionTarget result_type.";

  static const String error_msg_try_again = " 다시 시도해 주세요.";
  static const String error_msg_server_not_response = "서버가 응답하지 않습니다. 다시 시도해 주세요.";
  static const String error_msg_join_fail = "회원가입에 실패하였습니다. 다시 시도해 주세요.";
  static const String error_msg_join_already_exist = "이미 존재하는 아이디입니다.";
  static const String error_msg_login_not_valid_id = "존재하지 않는 아이디입니다.";
  static const String error_msg_login_not_valid_pwd = "비밀번호가 올바르지 않습니다.";

  // 공통 - request, response
  static const String table = "table";
  static const String target = "target";
  static const String file = "file";
  static const String resultVal = "resultVal";
  static const String resultMsg = "resultMsg";
  static const String data = "data";
  static const String seq = "seq";
  static const String paging = "paging";
  static const String offset = "offset";
  static const String limit = "limit";
  static const String list = "list";
  static const String total = "total";

  static const String callback = "callback";
  static const String order_type = "order_type";
  static const String order_type_new = "NEW";
  static const String order_type_fin = "FIN";
  static const String look_kwd_seq  = "look_kwd_seq";
  static const String isSubmitVideo  = "isSubmitVideo";
  static const String applyIngCnt  = "applyIngCnt";
  static const String proposalCnt  = "proposalCnt";

  // 공통코드 관련
  static const String parentCode = "parent_code";
  static const String parentType = "parent_type";
  static const String k01 = "K01";                                          // 배역 특징 유형
  static const String k02 = "K02";                                          // 외모 특징 유형
  static const String project_type_movie = "영화";
  static const String project_type_drama = "드라마";
  static const String casting_type_1 = "주연";
  static const String casting_type_2 = "조연";
  static const String casting_type_3 = "조단역";
  static const String casting_type_4 = "보조출연";
  static const String actor_level_1 = "1등급";
  static const String actor_level_2 = "2등급";
  static const String actor_level_3 = "3등급";
  static const String actor_level_4 = "4등급";
  static const String actor_level_5 = "5등급";
  static const String actor_level_6 = "6등급";
  static const String actor_level_7 = "7등급";
  static const String actor_level_8 = "8등급";
  static const String actor_level_9 = "9등급";

  // 로그인 관련
  static const String autoLogin = "autoLogin";
  static const String id = "id";
  static const String pwd = "pwd";

  // 제작사 회원 관련
  static const String table_production_casting = "ProductionCasting";
  static const String table_casting_language = "CastingLanguge";
  static const String table_casting_dialect = "CastingDialect";
  static const String table_casting_ability = "CastingAbility";

  static const String member_type_product = "P";
  static const String member_type = "member_type";
  static const String project_seq = "project_seq";
  static const String production_name = "production_name";
  static const String businessRegistration_number = "businessRegistration_number";
  static const String production_CEO_name = "production_CEO_name";
  static const String production_bank_code = "production_bank_code";
  static const String production_account_number = "production_account_number";
  static const String production_homepage = "production_homepage";
  static const String production_email = "production_email";
  static const String production_logo_img_url = "production_logo_img_url";
  static const String production_logo = "production_logo";
  static const String production_project = "production_project";
  static const String production_project_seq = "production_project_seq";
  static const String TOS_isAgree = "TOS_isAgree";
  static const String PPA_isAgree = "PPA_isAgree";
  static const String addDate = "addDate";
  static const String editDate = "editDate";
  static const String production_seq = "production_seq";
  static const String project_name = "project_name";
  static const String project_releaseYear = "project_releaseYear";
  static const String project_type = "project_type";
  static const String isMainRole = "isMainRole";
  static const String productionFilmography_seq = "productionFilmography_seq";
  static const String actorFilmography_seq = "actorFilmography_seq";
  static const String file_image = "file_image";
  static const String file_video = "file_video";
  static const String isNotPayment  = "isNotPayment";

  static const String casting_seq = "casting_seq";
  static const String casting_type = "casting_type";
  static const String casting_max_age = "casting_max_age";
  static const String casting_min_age = "casting_min_age";
  static const String casting_max_tall = "casting_max_tall";
  static const String casting_min_tall = "casting_min_tall";
  static const String casting_max_weight = "casting_max_weight";
  static const String casting_max_weigh = "casting_max_weigh";
  static const String casting_min_weight = "casting_min_weight";
  static const String casting_min_weigh = "casting_min_weigh";
  static const String production_img_url = "production_img_url";
  static const String casting_uniqueness = "casting_uniqueness";
  static const String casting_introduce = "casting_introduce";
  static const String casting_Introduce = "casting_Introduce";
  static const String casting_pay = "casting_pay";
  static const String major_type = "major_type";
  static const String genre_type = "genre_type";
  static const String project_Introduce = "project_Introduce";
  static const String shooting_startDate = "shooting_startDate";
  static const String shooting_endDate = "shooting_endDate";
  static const String shooting_place = "shooting_place";
  static const String productionCasting_addDate = "productionCasting_addDate";
  static const String firstAuditionTarget_cnt = "firstAuditionTarget_cnt";
  static const String firstAuditionTarget_isView_cnt = "firstAuditionTarget_isView_cnt";
  static const String firstAuditionTarget_isNotView_cnt = "firstAuditionTarget_isNotView_cnt";
  static const String firstAuditionTarget_pass_cnt = "firstAuditionTarget_pass_cnt";
  static const String firstAuditionTarget_fail_cnt = "firstAuditionTarget_fail_cnt";
  static const String secondAuditionTarget_cnt = "secondAuditionTarget_cnt";
  static const String secondAuditionTarget_isSubmit_cnt = "secondAuditionTarget_isSubmit_cnt";
  static const String secondAuditionTarget_isSubmit = "secondAuditionTarget_isSubmit";
  static const String secondAuditionTarget_isNotSubmit = "secondAuditionTarget_isNotSubmit";
  static const String secondAuditionTarget_isNotSubmit_cnt = "secondAuditionTarget_isNotSubmit_cnt";
  static const String secondAuditionTarget_pass_cnt = "secondAuditionTarget_pass_cnt";
  static const String thirdAuditionTarget_cnt = "thirdAuditionTarget_cnt";
  static const String thirdAuditionTarget_interviewFin = "thirdAuditionTarget_interviewFin";
  static const String thirdAuditionTarget_fail = "thirdAuditionTarget_fail";
  static const String thirdAuditionTarget_pass = "thirdAuditionTarget_pass";
  static const String thirdAuditionTarget_standby = "thirdAuditionTarget_standby";
  static const String thirdAuditionTarget_finalPass = "thirdAuditionTarget_finalPass";
  static const String thirdAuditionTarget_interviewComplete = "thirdAuditionTarget_interviewComplete";
  static const String thirdAuditionTarget_finalComplete = "thirdAuditionTarget_finalComplete";
  static const String isAlreadyProposal = "isAlreadyProposal";
  static const String castring_seq = "castring_seq";
  static const String isImg = "isImg";
  static const String casting_state_type = "casting_state_type";
  static const String isApply = "isApply";
  static const String audition_prps_state_type = "audition_prps_state_type";
  static const String firstAudition_endDate = "firstAudition_endDate";
  static const String secondAudition_startDate = "secondAudition_startDate";
  static const String secondAudition_endDate = "secondAudition_endDate";
  static const String firstAudition_state_type = "firstAudition_state_type";
  static const String secondAudition_state_type = "secondAudition_state_type";
  static const String thirdAudition_state_type = "thirdAudition_state_type";
  static const String FirstAudition = "FirstAudition";
  static const String SecondAudition = "SecondAudition";
  static const String ThirdAudition = "ThirdAudition";
  static const String FirstAuditionTarget = "FirstAuditionTarget";
  static const String SecondAuditionTarget = "SecondAuditionTarget";
  static const String ThirdAuditionTarget = "ThirdAuditionTarget";
  static const String AuditionApply = "AuditionApply";
  static const String result_type = "result_type";

  static const String firstAuditionTarget_result_type = "firstAuditionTarget_result_type";
  static const String secondAuditionTarget_result_type = "secondAuditionTarget_result_type";
  static const String thirdAuditionTarget_result_type = "thirdAuditionTarget_result_type";


  // 배우 회원 관련
  static const String table_actor = "Actor";
  static const String table_actor_profile = "ActorProfile";
  static const String table_actor_education = "ActorEducation";
  static const String table_actor_languge = "ActorLanguge";
  static const String table_actor_dialect = "ActorDialect";
  static const String table_actor_ability = "ActorAbility";
  static const String table_actor_lookkwd = "ActorLookKwd";
  static const String table_actor_castingKwd = "ActorCastingKwd";
  static const String table_actor_filmography = "ActorFilmography";
  static const String table_actor_image = "ActorImage";
  static const String table_actor_video = "ActorVideo";
  static const String table_keyword_m = "KeywordM";
  static const String table_actor_seq = "Actor.seq";
  static const String table_audition_apply = "AuditionApply";
  static const String table_audition_apply_image = "AuditionApplyImage";
  static const String table_audition_apply_video = "AuditionApplyVidoe";
  static const String table_audition_apply_profile = "AuditionApplyProfile";
  static const String table_audition_apply_filmography = "AuditionApplyFilmography";
  static const String table_audition_proposal = "AuditionProposal";

  static const String KeywordM = "KeywordM";
  static const String KeywordW = "KeywordW";
  static const String ActorLookKwd = "ActorLookKwd";

  // 배우 목록 조회 관련
  static const String actor_seq = "actor_seq";
  static const String actor_profile_seq = "actor_profile_seq";
  static const String actor_filmorgraphy_seq = "ActorFilmography.actor_seq";
  static const String actor_image_seq = "ActorImage.actor_seq";
  static const String actor_imgs = "actor_imgs";
  static const String actor_video_seq = "ActorVideo.actor_seq";
  static const String member_type_actor = "A";
  static const String actor_name = "actor_name";
  static const String actor_isAuth = "actor_isAuth";                                      // 배우 인증여부
  static const String guardian_isAuth = "guardian_isAuth";                          // 보호자 인증여부
  static const String guardian_RR_url = "guardian_RR_url";                          // 보호자 주민등록등본
  static const String guardian_COH_url = "guardian_COH_url";                    // 보호자 건강보험증
  static const String guardian_COFR_url = "guardian_COFR_url";                // 보호자 가족관계증명서
  static const String actor_bank_code = "actor_bank_code";
  static const String actor_account_number = "actor_account_number";
  static const String actor_birth = "actor_birth";
  static const String sex_type = "sex_type";
  static const String actor_phone = "actor_phone";
  static const String actor_email = "actor_email";
  static const String actor_sex_male = "남자";
  static const String actor_sex_female = "여자";
  static const String actor_education = "actor_education";
  static const String actor_languge = "actor_languge";
  static const String actor_dialect = "actor_dialect";
  static const String actor_ability = "actor_ability";
  static const String actor_kwd = "actor_kwd";
  static const String min = "min";
  static const String max = "max";
  static const String casting_age = "casting_age";
  static const String casting_tall  = "casting_tall";
  static const String casting_weight   = "casting_weight";
  static const String auditionApply_seq   = "auditionApply_seq";
  static const String firstAuditionTarget_seq   = "firstAuditionTarget_seq";
  static const String secondAuditionTarget_seq   = "secondAuditionTarget_seq";
  static const String thirdAuditionTarget_seq   = "thirdAuditionTarget_seq";

  static const String profile_target = "profile_target";
  static const String education_target = "education_target";
  static const String languge_target = "languge_target";
  static const String dialect_target = "dialect_target";
  static const String ability_target = "ability_target";
  static const String lookKwd_target = "lookKwd_target";
  static const String castingKwd_target = "castingKwd_target";


  static const String main_img_url = "main_img_url";
  static const String actorProfile_seq = "actorProfile_seq";
  static const String actor_Introduce = "actor_Introduce";
  static const String actor_level = "actor_level";
  static const String actor_levelConfirmation_url = "actor_levelConfirmation_url";
  static const String actor_drama_pay = "actor_drama_pay";
  static const String actor_movie_pay = "actor_movie_pay";
  static const String actor_tall = "actor_tall";
  static const String actor_weigh = "actor_weigh";
  static const String actor_weight = "actor_weight";
  static const String actor_major_isAuth = "actor_major_isAuth";
  static const String viewCnt = "viewCnt";
  static const String save_db_key = "save_db_key";
  static const String save_dir = "save_dir";
  static const String actor_profile = "actor_profile";
  static const String base64string = "base64string";
  static const String base64string_thumb = "base64string_thumb";
  static const String data_image = "data:image/png;base64,";
  static const String data_file = "data:@file/mp4;base64,";
  static const String education_type = "education_type";
  static const String education_name = "education_name";
  static const String major_name = "major_name";
  static const String diploma_url = "diploma_url";
  static const String language_type = "language_type";
  static const String dialect_type = "dialect_type";
  static const String child_type = "child_type";
  static const String child_name = "child_name";
  static const String code_seq = "code_seq";
  static const String casting_target = "casting_target";
  static const String firstAudition_target = "firstAudition_target";

  static const String casting_name = "casting_name";
  static const String casting_count = "casting_count";
  static const String casting_cnt = "casting_cnt";
  static const String apply_cnt = "apply_cnt";
  static const String project_file_url = "project_file_url";
  static const String casting_character_name = "casting_character_name";
  static const String employmentCertificate_url = "employmentCertificate_url";
  static const String actor_img_url = "actor_img_url";
  static const String actor_img = "actor_img";
  static const String actor_video_url = "actor_video_url";
  static const String actor_video = "actor_video";
  static const String actor_video_url_thumb = "actor_video_url_thumb";
  static const String actor_sex_type = "Actor.sex_type";
  static const String actor_lookkwd_code_seq = "ActorLookKwd.code_seq";
  static const String actor_profile_actor_tall_above = "ActorProfile.actor_tall >";
  static const String actor_profile_actor_tall_under = "ActorProfile.actor_tall <";
  static const String actor_profile_actor_weigh_under = "ActorProfile.actor_weigh <";
  static const String actor_age = "return_age(Actor.actor_birth) >";

  // 지원하기
  static const String changeIsView = "changeIsView";
  static const String audition_apply_seq = "audition_apply_seq";
  static const String apply_image = "apply_image";
  static const String apply_video = "apply_video";
  static const String apply_actor_img = "apply_actor_img";
  static const String apply_actor_video = "apply_actor_video";
  static const String apply_date = "apply_date";
  static const String state_type = "state_type";
  static const String isView = "isView";
  static const String aa_state_type = "aa_state_type";
  static const String first_audition_seq = "first_audition_seq";
  static const String first_auditionstate_type = "first_auditionstate_type";
  static const String first_auditionstartDate = "first_auditionstartDate";
  static const String first_audition_target_seq = "first_audition_target_seq";
  static const String first_audition_target_result_type = "first_audition_target_result_type";
  static const String second_audition_seq = "second_audition_seq";
  static const String second_audition_state_type = "second_audition_state_type";
  static const String second_audition_startDate = "second_audition_startDate";
  static const String second_audition_target_seq = "second_audition_target_seq";
  static const String second_audition_target_result_type = "second_audition_target_result_type";
  static const String third_audition_seq = "third_audition_seq";
  static const String third_audition_state_type = "third_audition_state_type";
  static const String third_audition_target_seq = "third_audition_target_seq";
  static const String third_audition_target_result_type = "third_audition_target_result_type";
  static const String third_audition_target_bank_code = "third_audition_target_bank_code";
  static const String thirdAudition_target_account_isAuth = "thirdAudition_target_account_isAuth";
  static const String thirdAudition_target_phone = "thirdAudition_target_phone";
  static const String thirdAudition_phone_use_isAgree = "thirdAudition_phone_use_isAgree";
  static const String firstautidion_startdate = "firstAudition_startDate";
  static const String firstautidion_enddate = "firstAudition_endDate";

  static const String auditionProposal_seq = "auditionProposal_seq";
  static const String audition_prps_seq = "audition_prps_seq";
  static const String audition_prps_contents = "audition_prps_contents";
  static const String audition_prps_reply_contents = "audition_prps_reply_contents";


  static const String secondAudition_seq = "secondAudition_seq";

  // 소속사 회원 관련
  static const String table_management = "Management";
  static const String member_type_management = "M";
}