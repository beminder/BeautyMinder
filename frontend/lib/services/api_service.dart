import 'package:beautyminder/dto/delete_request_model.dart';
import 'package:beautyminder/dto/login_request_model.dart';
import 'package:beautyminder/dto/login_response_model.dart';
import 'package:beautyminder/dto/register_request_model.dart';
import 'package:beautyminder/dto/register_response_model.dart';
import 'package:beautyminder/dto/update_request_model.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/src/media_type.dart';
import 'package:mime/src/mime_type.dart';

import '../../config.dart';
import '../dto/user_model.dart';
import 'dio_client.dart';
import 'shared_service.dart';

class APIService {

  //로그인
  static Future<Result<bool>> login(LoginRequestModel model) async {
    final url = Uri.http(Config.apiURL, Config.loginAPI).toString();
    final formData = FormData.fromMap({
      'email': model.email ?? '',
      'password': model.password ?? '',
    });

    try {
      final response = await DioClient.sendRequest('POST', url, body: formData);
      if (response.statusCode == 200) {
        await SharedService.setLoginDetails(loginResponseJson(response.data));
        return Result.success(true);
      }
      return Result.failure("Login failed");
    } catch (e) {
      return Result.failure("An error occurred: $e");
    }
  }

  //회원가입
  static Future<Result<RegisterResponseModel>> register(
      RegisterRequestModel model) async {

    final url = Uri.http(Config.apiURL, Config.registerAPI).toString();

    try {
      final response = await DioClient.sendRequest('POST', url, body: model.toJson());
      return Result.success(
          registerResponseJson(response.data as Map<String, dynamic>));
    } catch (e) {
      return Result.failure("An error occurred: $e");
    }
  }

  //회원 탈퇴
  // static Future<Result<bool>> delete(DeleteRequestModel model) async {
  //
  //   final accessToken = await SharedService.getAccessToken();
  //   final refreshToken = await SharedService.getRefreshToken();
  //
  //   final url = Uri.http(Config.apiURL, Config.deleteAPI).toString();
  //
  //   final headers = {
  //     'Authorization': 'Bearer $accessToken',
  //     'Cookie': 'XRT=$refreshToken',
  //   };
  //
  //   try {
  //     await DioClient.sendRequest('DELETE', url, headers: headers);
  //     return Result.success(true);
  //   } catch (e) {
  //     return Result.failure("An error occurred: $e");
  //   }
  // }
  static Future<Result<bool>> delete(DeleteRequestModel model) async {
    final accessToken = await SharedService.getAccessToken();
    final refreshToken = await SharedService.getRefreshToken();

    final url = Uri.http(Config.apiURL, Config.deleteAPI).toString();

    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Cookie': 'XRT=$refreshToken',
    };

    try {
      await DioClient.sendRequest('DELETE', url, headers: headers);
      await SharedService.logout();
      return Result.success(true);
    } catch (e) {
      return Result.failure("An error occurred: $e");
    }
  }

  //사용자 프로필 조회
  static Future<Result<User>> getUserProfile() async {

    final accessToken = await SharedService.getAccessToken();
    final refreshToken = await SharedService.getRefreshToken();

    final url = Uri.http(Config.apiURL, Config.userProfileAPI).toString();

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
        final user = User.fromJson(response.data as Map<String, dynamic>);
        return Result.success(user);
      }

      return Result.failure("Failed to get user profile");
    } catch (e) {
      return Result.failure("An error occurred: $e");
    }
  }

  //리뷰 조회
  static Future<Result<List<dynamic>>> getReviews() async {

    final accessToken = await SharedService.getAccessToken();
    final refreshToken = await SharedService.getRefreshToken();

    final url = Uri.http(Config.apiURL, Config.getUserReview).toString();

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
      return Result.failure("Failed to get user reviews");
    } catch (e) {
      print(e);
      return Result.failure("An error occurred: $e");
    }
  }

  //회원정보 수정
  static Future<Result<bool>> sendEditInfo(UpdateRequestModel model) async {

    final accessToken = await SharedService.getAccessToken();
    final refreshToken = await SharedService.getRefreshToken();

    final url = Uri.http(Config.apiURL, Config.editUserInfo).toString();

    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Cookie': 'XRT=$refreshToken',
    };

    try {
      final response = await DioClient.sendRequest('PATCH', url,
          body: model.toJson(), headers: headers);
      if (response.statusCode == 200) {
        return Result.success(true);
      }
      return Result.failure("Failed to update user profile");
    } catch (e) {
      return Result.failure("An error occurred: $e");
    }
  }

  //프로필 사진 변경
  static Future<String> editProfileImgInfo(String image) async {

    final accessToken = await SharedService.getAccessToken();
    final refreshToken = await SharedService.getRefreshToken();

    final url = Uri.http(Config.apiURL, Config.editProfileImg).toString();

    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Cookie': 'XRT=$refreshToken',
    };

    final MediaType contentType = MediaType.parse(
        lookupMimeType('new_profile.jpg') ?? 'application/octet-stream');

    final formData = FormData.fromMap({
      "image": MultipartFile.fromFileSync(
        image,
        contentType: contentType,
      ),
    });

    final response = await DioClient.sendRequest(
      'POST',
      url,
      body: formData,
      headers: headers,
    );
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to update review: ${response.statusMessage}');
    }
  }

  // 리뷰 수정 함수
  static Future<Result<List<dynamic>>> updateReview(id) async {

    final accessToken = await SharedService.getAccessToken();
    final refreshToken = await SharedService.getRefreshToken();

    final url = Uri.http(Config.apiURL, Config.getReviewAPI + id).toString();

    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Cookie': 'XRT=$refreshToken',
    };

    try {
      final response =
          await DioClient.sendRequest('PUT', url, headers: headers);
      return Result.success(response.data);
    } catch (e) {
      print(e);
      return Result.failure("An error occurred: $e");
    }
  }

  //리뷰 삭제
  static Future<Result<List<dynamic>>> deleteReview(String id) async {

    final accessToken = await SharedService.getAccessToken();
    final refreshToken = await SharedService.getRefreshToken();

    final url = Uri.http(Config.apiURL, Config.getReviewAPI + id).toString();

    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Cookie': 'XRT=$refreshToken',
    };

    try {
      final response =
          await DioClient.sendRequest('DELETE', url, headers: headers);
      return Result.success(response.data);
    } catch (e) {
      print(e);
      return Result.failure("An error occurred: $e");
    }
  }

  // //비밀번호 변경
  // static Future<Result<bool>> changePassword({
  //   required String currentPassword,
  //   required String newPassword,
  // }) async {
  //
  //   final accessToken = await SharedService.getAccessToken();
  //   final refreshToken = await SharedService.getRefreshToken();
  //
  //   final url = Uri.http(Config.apiURL, Config.changePassword).toString();
  //
  //   final headers = {
  //     'Authorization': 'Bearer $accessToken',
  //     'Cookie': 'XRT=$refreshToken',
  //   };
  //
  //   final Map<String, dynamic> passwords = {
  //     'current_password': currentPassword,
  //     'new_password': newPassword,
  //   };
  //
  //   try {
  //     final response = await DioClient.sendRequest(
  //       'POST',
  //       url,
  //       body: passwords,
  //       headers: headers,
  //     );
  //     if (response.statusCode == 200) {
  //       return Result.success(true);
  //     }
  //     return Result.failure("Failed to change password");
  //   } catch (e) {
  //     return Result.failure("An error occurred: $e");
  //   }
  // }

  //비밀번호 변경
  static Future<Result<bool>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final accessToken = await SharedService.getAccessToken();
    final refreshToken = await SharedService.getRefreshToken();

    final url = Uri.http(Config.apiURL, Config.updatePassword).toString();

    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Cookie': 'XRT=$refreshToken',
    };

    final Map<String, dynamic> passwords = {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    };

    try {
      final response = await DioClient.sendRequest(
        'POST',
        url,
        body: passwords,
        headers: headers,
      );
      if (response.statusCode == 200) {
        return Result.success(true);
      }
      return Result.failure("Failed to change password");
    } catch (e) {
      return Result.failure("An error occurred: $e");
    }
  }

  //비밀번호 리셋
  static Future<Result<bool>> requestResetPassword({
    required String email,
  }) async {

    final accessToken = await SharedService.getAccessToken();
    final refreshToken = await SharedService.getRefreshToken();

    final url = Uri.http(Config.apiURL, Config.requestResetPassword).toString();

    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Cookie': 'XRT=$refreshToken',
    };

    try {
      final response = await DioClient.sendRequest(
        'POST',
        url,
        body: {'email': email},
        headers: headers,
      );
      if (response.statusCode == 200) {
        return Result.success(true);
      }
      return Result.failure("Failed to request reset password");
    } catch (e) {
      return Result.failure("An error occurred: $e");
    }
  }

  //유저 정보 변경
  static Future<Result<bool>> updateUserInfo(
      Map<String, dynamic> userData) async {

    final accessToken = await SharedService.getAccessToken();
    final refreshToken = await SharedService.getRefreshToken();

    final url = Uri.http(Config.apiURL, Config.editUserInfo).toString();

    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Cookie': 'XRT=$refreshToken',
    };

    try {
      final response = await DioClient.sendRequest('PATCH', url,
          body: userData, headers: headers);
      if (response.statusCode == 200) {
        return Result.success(true);
      }
      return Result.failure("Failed to update user profile");
    } catch (e) {
      return Result.failure("An error occurred: $e");
    }
  }

  //로그아웃
  static Future<Result<bool>> logout() async {
    final accessToken = await SharedService.getAccessToken();
    final refreshToken = await SharedService.getRefreshToken();

    final url = Uri.http(Config.apiURL, Config.logoutAPI).toString();

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
        await SharedService.logout();
        return Result.success(true);
      }
      return Result.failure("Logout failed");
    } catch (e) {
      return Result.failure("An error occurred: $e");
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
