import 'package:beautyminder/dto/baumann_model.dart';
import 'package:beautyminder/dto/baumann_result_model.dart';
import 'package:beautyminder/services/shared_service.dart';
import 'package:dio/dio.dart';
import 'package:beautyminder/services/api_service.dart';

import '../../config.dart';
import 'dio_client.dart';

class BaumannService {

  //바우만 테스트 설문 결과 전송하기
  static Future<Response> postSurveyResult(Map<String, dynamic> body) async {

    final accessToken = await SharedService.getAccessToken();
    final refreshToken = await SharedService.getRefreshToken();

    final url = Uri.http(Config.apiURL, Config.baumannTestAPI).toString();

    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Cookie': 'XRT=$refreshToken',
    };

    return DioClient.sendRequest(
      'POST',
      url,
      body: body,
      headers: headers
    );
  }

  //바우만 설문지 불러오기
  static Future<Result<SurveyWrapper>> getBaumannSurveys() async {

    final accessToken = await SharedService.getAccessToken();
    final refreshToken = await SharedService.getRefreshToken();

    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Cookie': 'XRT=$refreshToken',
    };

    final url = Uri.http(Config.apiURL, Config.baumannSurveyAPI).toString();

    try {
      final response = await DioClient.sendRequest(
          'GET',
          url,
          headers: headers
      );

      if (response.statusCode == 200) {
        // 사용자 정보 파싱
        final user =
            SurveyWrapper.fromJson(response.data as Map<String, dynamic>);
        return Result.success(user);
      }
      return Result.failure("Failed to get user profile");
    } catch (e) {
      return Result.failure("An error occurred: $e");
    }
  }


  //바우만 결과 히스토리 불러오기
  static Future<Result<List<BaumannResult>>> getBaumannHistory() async {

    final accessToken = await SharedService.getAccessToken();
    final refreshToken = await SharedService.getRefreshToken();

    final url = Uri.http(Config.apiURL, Config.baumannHistoryAPI).toString();

    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Cookie': 'XRT=$refreshToken',
    };

    try {
      final response = await DioClient.sendRequest(
          'GET',
          url,
          headers: headers
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = response.data as List<dynamic>;
        final List<BaumannResult> result = jsonData
            .map((dynamic item) =>
            BaumannResult.fromJson(item as Map<String, dynamic>))
            .toList();

        return Result<List<BaumannResult>>.success(result);
      }
      return Result<List<BaumannResult>>.failure(
          "Failed to get baumann history");
    } catch (e) {
      return Result<List<BaumannResult>>.failure("An error occurred: $e");
    }
  }


  //바우만 히스토리 삭제하기
  static Future<String> deleteBaumannHistory(String testId) async {

    final accessToken = await SharedService.getAccessToken();
    final refreshToken = await SharedService.getRefreshToken();

    final url = Uri.http(Config.apiURL, Config.baumannDeleteAPI+testId).toString();

    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Cookie': 'XRT=$refreshToken',
    };

    try {
      final response = await DioClient.sendRequest(
          'DELETE',
          url,
          headers: headers
      );

      if (response.statusCode == 200) {
        print("Success Delete - baumann result");
        return "Success to Delete";
      }
      return "Failed to delete";
    } catch (e) {
      print("An error occurred: $e");
      return "An error occurred: $e";
    }
  }
}
