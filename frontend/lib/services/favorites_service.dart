import 'package:beautyminder/services/shared_service.dart';

import '../../config.dart';
import 'api_service.dart';
import 'dio_client.dart';

class FavoritesService {

  //좋아요 등록하기
  static Future<String> uploadFavorites(String cosmeticId) async {

    final accessToken = await SharedService.getAccessToken();
    final refreshToken = await SharedService.getRefreshToken();

    final url = Uri.http(Config.apiURL, Config.uploadFavoritesAPI + cosmeticId).toString();

    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Cookie': 'XRT=$refreshToken',
    };

    try {
      final response = await DioClient.sendRequest(
          'POST',
          url,
          headers: headers
      );

      if (response.statusCode == 200) {
        return "success upload user favorites";
      }
      return "Failed to upload user favorites";
    } catch (e) {
      return "An error occurred: $e";
    }
  }

  //좋아요 삭제하기
  static Future<String> deleteFavorites(String cosmeticId) async {

    final accessToken = await SharedService.getAccessToken();
    final refreshToken = await SharedService.getRefreshToken();

    final url = Uri.http(Config.apiURL, Config.uploadFavoritesAPI + cosmeticId).toString();

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
        return "success deleted user favorites";
      }
      return "Failed to deleted user favorites";
    } catch (e) {
      return "An error occurred: $e";
    }
  }


  // 즐겨찾기 제품 조회
  static Future<Result<List<dynamic>>> getFavorites() async {

    final accessToken = await SharedService.getAccessToken();
    final refreshToken = await SharedService.getRefreshToken();

    final url = Uri.http(Config.apiURL, '/user/favorites').toString();

    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Cookie': 'XRT=$refreshToken',
    };

    try {
      final response = await DioClient.sendRequest(
        'GET',
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Result.success(response.data);
      }

      return Result.failure("Failed to get user favorites");
    } catch (e) {
      return Result.failure("An error occurred: $e");
    }
  }
}
