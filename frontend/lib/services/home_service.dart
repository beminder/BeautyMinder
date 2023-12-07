import 'package:beautyminder/dto/user_model.dart';
import 'package:beautyminder/services/shared_service.dart';
import 'package:beautyminder/services/api_service.dart';

import '../../config.dart';
import 'dio_client.dart';

class HomeService {

  static Future<Result<User>> getUserInfo(String userId) async {

    final accessToken = await SharedService.getAccessToken();
    final refreshToken = await SharedService.getRefreshToken();

    final url = Uri.http(Config.apiURL, Config.getUserInfo + userId).toString();

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
        final user = User.fromJson(response.data as Map<String, dynamic>);
        return Result.success(user);
      }
      return Result.failure("Failed to get user profile");
    } catch (e) {
      return Result.failure("An error occurred: $e");
    }
  }
}
