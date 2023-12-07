import 'package:beautyminder/services/shared_service.dart';
import 'package:dio/dio.dart';
import 'package:beautyminder/services/api_service.dart';

import '../../config.dart';
import '../dto/keywordRank_model.dart';
import 'dio_client.dart';

class KeywordRankService {

  //검색 랭킹 불러오기
  static Future<Result<KeyWordRank>> getKeywordRank() async {

    final accessToken = await SharedService.getAccessToken();
    final refreshToken = await SharedService.getRefreshToken();

    final url = Uri.http(Config.apiURL, Config.keywordRankAPI).toString();

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
        final user = KeyWordRank.fromJson(response.data);
        return Result.success(user);
      }

      return Result.failure("Failed to get user profile");
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.connectionTimeout) {
        return Result.failure("Connection timed out");
      }
      return Result.failure("An error occurred: $e");
    }
  }

  //제품 랭킹 불러오기
  static Future<Result<ProductRank>> getProductRank() async {

    final accessToken = await SharedService.getAccessToken();
    final refreshToken = await SharedService.getRefreshToken();

    final url = Uri.http(Config.apiURL, Config.productRankAPI).toString();

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
        final user = ProductRank.fromJson(response.data);
        return Result.success(user);
      }

      return Result.failure("Failed to get user profile");
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.connectionTimeout) {
        return Result.failure("Connection timed out");
      }
      return Result.failure("An error occurred: $e");
    }
  }


  //검색 히스토리 가져오기
  static Future<List> getSearchHistory() async {

    final accessToken = await SharedService.getAccessToken();
    final refreshToken = await SharedService.getRefreshToken();

    final url =
    Uri.http(Config.apiURL, Config.getSearchHistoryAPI).toString();

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
        return response.data;
      } else {
        throw Exception("Failed to search cosmetics by keyword");
      }
    } catch (e) {
      return [];
    }
  }
}
