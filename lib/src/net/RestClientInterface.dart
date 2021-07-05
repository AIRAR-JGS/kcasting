import 'dart:convert';

import 'package:casting_call/src/net/APIConstants.dart';
import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';

part 'RestClient.dart';

@RestApi(baseUrl: APIConstants.BASE_URL)
abstract class RestClient {
  factory RestClient(Dio dio, {String baseUrl}) = _RestClient;

  // 데이터 추가
  @POST(APIConstants.URL_MAIN_CONTROL)
  Future<Map<String, dynamic>> postRequestMainControl(
      @Body() Map<String, dynamic> params);

  // 데이터 추가(폼데이터)
  @MultiPart()
  @POST(APIConstants.URL_MAIN_CONTROL)
  Future<Map<String, dynamic>> postRequestMainControlFormData(
      @Part() Map<String, dynamic> params);
}
