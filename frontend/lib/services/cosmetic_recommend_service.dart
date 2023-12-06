import 'package:beautyminder/services/dio_client.dart';
import 'package:beautyminder/services/shared_service.dart';
import 'package:dio/dio.dart';
import 'package:beautyminder/services/api_service.dart';

import '../config.dart';
import '../dto/cosmetic_model.dart';

class CosmeticSearchService {

  //추천 제품 전체 불러오기
  static Future<Result<List<Cosmetic>>> getAllCosmetics() async {

    final accessToken = await SharedService.getAccessToken();
    final refreshToken = await SharedService.getRefreshToken();

    final url = Uri.http(Config.apiURL, Config.RecommendAPI).toString();

    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Cookie': 'XRT=$refreshToken',
    };

    try {
      final response =
          await DioClient.sendRequest('GET', url, headers: headers);

      if (response.statusCode == 200) {
        Map<String, dynamic> decodedResponse;

        if (response.data is List) {
          List<dynamic> dataList = response.data;
          List<Cosmetic> cosmetics = dataList.map<Cosmetic>((data) {
            if (data is Map<String, dynamic>) {
              return Cosmetic.fromJson(data);
            } else {
              throw Exception("Invalid data type");
            }
          }).toList();

          return Result.success(cosmetics);
        } else if (response.data is Map) {
          decodedResponse = response.data;
        } else {
          return Result.failure("Unexpected response data type");
        }

        return Result.failure(
            "Failed to serach Cosmetics : No cosmetics key in response");
      }
      return Result.failure("Failed to ge cosmeics");
    } catch (e) {
      return Result.failure("An error Occured : $e");
    }
  }

  //추천 제품 전체 불러오기
  static Future<Result<List<Cosmetic>>> refreshCosmetics() async {

    final accessToken = await SharedService.getAccessToken();
    final refreshToken = await SharedService.getRefreshToken();

    final url = Uri.http(Config.apiURL, Config.RecommendAPI).toString();

    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Cookie': 'XRT=$refreshToken',
    };



    try {
      final response =
      await DioClient.sendRequest('GET', url + "?refresh=true", headers: headers);

      print("response.data : ${response.data}");

      if (response.statusCode == 200) {
        Map<String, dynamic> decodedResponse;

        if (response.data is List) {
          List<dynamic> dataList = response.data;
          List<Cosmetic> cosmetics = dataList.map<Cosmetic>((data) {
            if (data is Map<String, dynamic>) {
              return Cosmetic.fromJson(data);
            } else {
              throw Exception("Invalid data type");
            }
          }).toList();

          return Result.success(cosmetics);
        } else if (response.data is Map) {
          decodedResponse = response.data;
        } else {
          return Result.failure("Unexpected response data type");
        }

        return Result.failure(
            "Failed to serach Cosmetics : No cosmetics key in response");
      }
      return Result.failure("Failed to ge cosmeics");
    } catch (e) {
      return Result.failure("An error Occured : $e");
    }
  }
}

