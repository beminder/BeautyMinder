import 'package:beautyminder_dashboard/Service/dio_client.dart';
import 'package:beautyminder_dashboard/Service/shared_service.dart';
import 'package:beautyminder_dashboard/models/review_response_model.dart';

import '../config.dart';

class AdminService {
  static Future<Result<String>> kickUser(String id) async {
    final accessToken = await SharedService.getAccessToken();
    final refreshToken = await SharedService.getRefreshToken();

    final url = Uri.http(Config.apiURL, Config.kickUserAPI).toString();

    final Map<String, dynamic> body = {"username": "$id"};

    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Cookie': 'XRT=$refreshToken',
    };

    try {
      final response = await DioClient.sendRequest('POST', url,
          body: body, headers: headers);

      print("response : ${response.data}");

      if (response.statusCode == 200) {
        return Result.success(response.data);
      } else {
        return Result.failure("Failed to kick user");
      }
    } catch (e) {
      return Result.failure("An error occurred : $e");
    }
  }

  static Future<Result<List<ReviewResponse>>> getAllReviews(int page) async {

    final accessToken = await SharedService.getAccessToken();
    final refreshToken = await SharedService.getRefreshToken();

    Map<String, dynamic> queryParameter = {'page': page.toString()};

    final url = Uri.http(Config.apiURL, Config.getAllReviewAPI, queryParameter)
        .toString();

    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Cookie': 'XRT=$refreshToken',
    };

    try {
      final response =
          await DioClient.sendRequest('GET', url, headers: headers);

      // response.date는 map형식
      if (response.statusCode == 200) {
        print(response.data.runtimeType);

        Map<String, dynamic> decodedResponse = response.data;
        ReviewPageResponse reviewPageResponse =
            ReviewPageResponse.fromJson(decodedResponse);
        List<ReviewResponse> reviews = reviewPageResponse.reviews;

        return Result.success(reviews);
      } else {
        return Result.failure("Failed to get Reviews");
      }
    } catch (e) {
      return Result.failure("An error occured : $e");
    }
  }

  static Future<Result<List<ReviewResponse>>> getFilteredReviews() async {
    final accessToken = await SharedService.getAccessToken();
    final refreshToken = await SharedService.getRefreshToken();

    final url = Uri.http(Config.apiURL, Config.getFilteredReviews).toString();

    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Cookie': 'XRT=$refreshToken',
    };

    try {
      final response =
          await DioClient.sendRequest('GET', url, headers: headers);
      ;
      print(response.data.runtimeType);
      print(response.data);
      // response.date는 map형식
      if (response.statusCode == 200) {
        print(response.data.runtimeType);

        Map<String, dynamic> decodedResponse = response.data;
        ReviewPageResponse reviewPageResponse =
            ReviewPageResponse.fromJson(decodedResponse);
        List<ReviewResponse> reviews = reviewPageResponse.reviews;

        return Result.success(reviews);
      } else {
        return Result.failure("Failed to get Reviews");
      }
    } catch (e) {
      return Result.failure("An error occured : $e");
    }
  }

  static Future<Result<String>> updateReviewStatus(
      String reviewId, String stat) async {

    final accessToken = await SharedService.getAccessToken();
    final refreshToken = await SharedService.getRefreshToken();

    final url = Uri.http(
            Config.apiURL, Config.updateReviewStatus + reviewId + "/status")
        .toString();

    print("url : $url");

    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Cookie': 'XRT=$refreshToken',
    };

    Map<String, dynamic> body = {"status": "${stat}"};

    try {
      final response = await DioClient.sendRequest('PATCH', url,
          headers: headers, body: body);
      if (response.statusCode == 200) {
        return Result.success(response.data);
      } else {
        return Result.failure('Failed to update review status');
      }
    } catch (e) {
      return Result.failure("An error occured : $e");
    }
  }

  static Future<Result<double>> getUsageCPU() async {
    final accessToken = await SharedService.getAccessToken();
    final refreshToken = await SharedService.getRefreshToken();

    final url = Uri.http(Config.apiURL, Config.getUsageCpuAPI).toString();

    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Cookie': 'XRT=$refreshToken',
    };

    try {
      final response =
          await DioClient.sendRequest('GET', url, headers: headers);

      if (response.statusCode == 200) {
        // JSON 데이터에서 value 추출
        final cpuUsage = response.data['measurements'][0]['value'];

        // 퍼센트로 나누기위해 *100
        return Result.success(cpuUsage * 100);
      } else {
        return Result.failure("error occurred in get cpu usage");
      }
    } catch (e) {
      print("Error: $e");
      return Result.failure("Error occurred while fetching CPU usage.");
    }
  }

  static Future<Result<double>> getUpTime() async {
    final accessToken = await SharedService.getAccessToken();
    final refreshToken = await SharedService.getRefreshToken();

    final url = Uri.http(Config.apiURL, Config.getUpTimeAPI).toString();

    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Cookie': 'XRT=$refreshToken',
    };

    try {
      final response =
          await DioClient.sendRequest('GET', url, headers: headers);

      if (response.statusCode == 200) {
        print("response : ${response.data}");

        // JSON 데이터에서 value 추출
        final upTime = response.data['measurements'][0]['value'];
        // 시간 단위로 변경
        return Result.success(upTime);
      } else {
        return Result.failure("error occured in get cpu usage");
      }
    } catch (e) {
      print("Error: $e");
      return Result.failure("Error occurred while fetching CPU usage.");
    }
  }

  static Future<Result<double>> getAverage1M() async {
    final accessToken = await SharedService.getAccessToken();
    final refreshToken = await SharedService.getRefreshToken();

    final url = Uri.http(Config.apiURL, Config.getAverage1M).toString();

    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Cookie': 'XRT=$refreshToken',
    };

    try {
      final response =
          await DioClient.sendRequest('GET', url, headers: headers);

      if (response.statusCode == 200) {
        print("response : ${response.data}");

        // JSON 데이터에서 value 추출
        final availability = response.data['measurements'][0]['value'];
        print("availability: $availability");

        // 퍼센트 단위로 변경
        return Result.success(availability * 100);
      } else {
        return Result.failure("error occured in get cpu usage");
      }
    } catch (e) {
      print("Error: $e");
      return Result.failure("Error occurred while fetching CPU usage.");
    }
  }
}

// 결과 클래스
class Result<T> {
  final T? value;
  final String? error;

  Result.success(this.value) : error = null;

  Result.failure(this.error) : value = null;

  bool get isSuccess => error == null;

  bool get isFailure => !isSuccess;
}
