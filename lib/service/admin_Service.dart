import 'package:admin/Service/dio_client.dart';
import 'package:admin/Service/shared_service.dart';
import 'package:admin/models/review_response_model.dart';

import '../config.dart';

class adminService {
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
      return Result.failure("An error occured : $e");
    }
  }

  static Future<Result<List<ReviewResponse>>> getAllReviews(int page) async {

    final accessToken = await SharedService.getAccessToken();
    final refreshToken = await SharedService.getRefreshToken();

    Map<String, dynamic> queryparameter = {'page': page.toString()};

    final url = Uri.http(Config.apiURL, Config.getAllReviewAPI, queryparameter)
        .toString();

    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Cookie': 'XRT=$refreshToken',
    };

    try {
      final response =
          await DioClient.sendRequest('GET', url, headers: headers);

      print("page : ${page}");
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
      String reviewid, String stat) async {

    final accessToken = await SharedService.getAccessToken();
    final refreshToken = await SharedService.getRefreshToken();

    final url = Uri.http(
            Config.apiURL, Config.updateReviewStatus + reviewid + "/status")
        .toString();

    print("url : ${url}");

    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Cookie': 'XRT=$refreshToken',
    };

    Map<String, dynamic> body = {"status": "${stat}"};

    print("url1 : ${url}");

    try {
      final response = await DioClient.sendRequest('PATCH', url,
          headers: headers, body: body);
      print("url2 : ${url}");

      if (response.statusCode == 200) {
        print("response : ${response.data}");
        print("url3 : ${url}");

        return Result.success(response.data);
      } else {
        print("url4 : ${url}");
        return Result.failure('Failed to update review status');
      }
    } catch (e) {
      print("url5 : ${url}, $e");
      return Result.failure("An error occured : $e");
    }
  }

  static Future<Result<double>> getUsageCPU() async {
    final accessToken = await SharedService.getAccessToken();
    final refreshToken = await SharedService.getRefreshToken();

    final url = Uri.http(Config.apiURL, Config.getUsageCpuAPI).toString();

    print("url : ${url}");
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
        final cpuUsage = response.data['measurements'][0]['value'];
        print("CPU Usage: $cpuUsage");

        // 퍼센트로 나누기위해 *100
        return Result.success(cpuUsage * 100);
      } else {
        return Result.failure("error occured in get cpu usage");
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

    print("url : ${url}");
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
        print("UP time: $upTime");

        // 시간 단위로 변경
        return Result.success(upTime / 3600);
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

    print("url : ${url}");
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
