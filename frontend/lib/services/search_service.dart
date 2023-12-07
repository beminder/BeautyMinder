import 'package:beautyminder/services/shared_service.dart';

import '../config.dart';
import '../dto/cosmetic_model.dart';
import 'dio_client.dart';

class SearchService {

  //이름으로 화장품 검색하기
  static Future<List<Cosmetic>> searchCosmeticsByName(String name) async {
    final accessToken = await SharedService.getAccessToken();
    final refreshToken = await SharedService.getRefreshToken();

    final parameters = {
      'name': '$name',
    };

    final url =
        Uri.http(Config.apiURL, Config.searchCosmeticsbyName, parameters)
            .toString();

    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Cookie': 'XRT=$refreshToken',
    };

    final response = await DioClient.sendRequest(
        'GET',
        url,
        headers: headers
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = response.data;
      return jsonData.map((data) => Cosmetic.fromJson(data)).toList();
    } else {
      throw Exception("Failed to search cosmetics by name");
    }
  }

  //카테고리로 화장품 검색하기
  static Future<List<Cosmetic>> searchCosmeticsByCategory(
      String category) async {

    final accessToken = await SharedService.getAccessToken();
    final refreshToken = await SharedService.getRefreshToken();

    final parameters = {
      'category': '$category',
    };

    final url =
        Uri.http(Config.apiURL, Config.searchCosmeticsbyCategory, parameters)
            .toString();

    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Cookie': 'XRT=$refreshToken',
    };

    final response = await DioClient.sendRequest(
        'GET',
        url,
        headers: headers
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = response.data;
      return jsonData.map((data) => Cosmetic.fromJson(data)).toList();
    } else {
      throw Exception("Failed to search cosmetics by category");
    }
  }

  //키워드로 화장품 검색하기
  static Future<List<Cosmetic>> searchCosmeticsByKeyword(String keyword) async {

    final accessToken = await SharedService.getAccessToken();
    final refreshToken = await SharedService.getRefreshToken();

    final parameters = {
      'keyword': '$keyword',
    };

    final url =
        Uri.http(Config.apiURL, Config.searchCosmeticsbyKeyword, parameters)
            .toString();

    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Cookie': 'XRT=$refreshToken',
    };

    final response = await DioClient.sendRequest(
        'GET',
        url,
        headers: headers
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = response.data;
      return jsonData.map((data) => Cosmetic.fromJson(data)).toList();
    } else {
      throw Exception("Failed to search cosmetics by keyword");
    }
  }

  //일반 검색하기
  static Future<List<Cosmetic>> searchAnything(String anything) async {

    final accessToken = await SharedService.getAccessToken();
    final refreshToken = await SharedService.getRefreshToken();

    final parameters = {
      'anything': '$anything',
    };

    final url = Uri.http(Config.apiURL, Config.homeSearchKeywordAPI, parameters)
        .toString();

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
        List<dynamic> jsonData = response.data;
        return jsonData.map((data) => Cosmetic.fromJson(data)).toList();
      } else {
        throw Exception("Failed to search cosmetics by keyword");
      }
    } catch (e) {
      return [];
    }
  }
}
