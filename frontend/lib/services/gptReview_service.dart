import 'package:beautyminder/dto/gptReview_model.dart';
import 'package:beautyminder/services/shared_service.dart';
import 'package:beautyminder/services/api_service.dart';

import '../../config.dart';
import 'dio_client.dart';

class GPTReviewService {

  //GPT 리뷰 불러오기
  static Future<Result<GPTReviewInfo>> getGPTReviews(String id) async {

    final accessToken = await SharedService.getAccessToken();
    final refreshToken = await SharedService.getRefreshToken();

    final url = Uri.http(Config.apiURL, '${Config.getGPTReviewAPI}/$id').toString();

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
        final gptReviewInfo = GPTReviewInfo.fromJson(response.data as Map<String, dynamic>);

        return Result.success(gptReviewInfo);
      }
      return Result.failure("Failed to get GPT review information");
    } catch (e) {
      return Result.failure("An error occurred: $e");
    }
  }
}
