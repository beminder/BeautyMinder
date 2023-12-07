import 'package:dio/dio.dart';

import '../../config.dart';
import 'dio_client.dart';

class EmailVerifyService {

  //이메일 인증 요청
  static Future<Response<dynamic>> emailVerifyRequest(String email) async {

    final parameters = {
      'email': '$email',
    };

    final url = Uri.http(Config.apiURL, Config.emailVerifyRequestAPI, parameters).toString();

    try {
      final response = await DioClient.sendRequest('POST', url);

      if (response.statusCode == 200) {
        return response;
      }
      throw DioException(
        response: response,
        requestOptions: RequestOptions(path: ''),
        error: "Email verification request failed with status code ${response.statusCode}",
      );
    } catch (e) {
      throw DioException(
        response: null,
        requestOptions: RequestOptions(path: ''),
        error: "An error occurred: $e",
      );
    }
  }


  //이메일 인증 토큰 확인 요청
  static Future<Response<dynamic>> emailVerifyTokenRequest(String token) async {

    final parameters = {
      'token': '$token',
    };

    final url = Uri.http(Config.apiURL, Config.emailTokenRequestAPI, parameters).toString();

    try {
      final response = await DioClient.sendRequest('POST', url);

      if (response.statusCode == 200) {
        return response;
      }
      throw DioException(
        response: response,
        requestOptions: RequestOptions(path: ''),
        error: "Email verification request failed with status code ${response.statusCode}",
      );
    } catch (e) {
      throw DioException(
        response: null,
        requestOptions: RequestOptions(path: ''),
        error: "An error occurred: $e",
      );
    }
  }

}

