// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'RestClientInterface.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

class _RestClient implements RestClient {
  _RestClient(this._dio, {this.baseUrl}) {
    ArgumentError.checkNotNull(_dio, '_dio');
    baseUrl ??= APIConstants.BASE_URL;
  }

  final Dio _dio;

  String baseUrl;

  // Main Control
  @override
  Future<Map<String, dynamic>> postRequestMainControl(params) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(params);
    _data.removeWhere((k, v) => v == null);

    printWrapped(jsonEncode(_data));

    Map<String, dynamic> _result;

    try {
      final _response = await _dio.request<String>(
          APIConstants.getURL(APIConstants.URL_MAIN_CONTROL),
          queryParameters: queryParameters,
          options: Options(
              method: 'POST',
              headers: <String, dynamic>{
                'Content-Type': 'application/json; charset=utf-8'
              },
              extra: _extra),
          data: _data);

      printWrapped(_response.data.toString());

      if (_response.data != null) {
        // api 호출 리턴값
        _result = jsonDecode(_response.data);

        /*var _responseList = jsonDecode(_response.data) as List;
        _result = _responseList.length > 0 ? _responseList[0] : null;*/
      } else {
        _result = null;
      }
    } catch (e) {
      print(e.toString());
      _result = null;
    }

    return Future.value(_result);
  }
}

void printWrapped(String text) {
  final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern.allMatches(text).forEach((match) => print(match.group(0)));
}
