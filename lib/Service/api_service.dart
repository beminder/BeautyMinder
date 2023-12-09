
import 'package:dio/dio.dart';
import 'package:http_parser/src/media_type.dart';
import 'package:mime/src/mime_type.dart';

import '../config.dart';
import '../dto/login_request_model.dart';
import '../dto/login_response_model.dart';
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
        print("response: ${response}");
        await SharedService.setLoginDetails(loginResponseJson(response.data));
        return Result.success(true);
      }
      return Result.failure("Login failed");
    } catch (e) {
      return Result.failure("An error occurred: $e");
    }
  }

  // //회원가입
  // static Future<Result<RegisterResponseModel>> register(
  //     RegisterRequestModel model) async {
  //   final url = Uri.http(Config.apiURL, Config.registerAPI).toString();
  //
  //   try {
  //     final response =
  //         await DioClient.sendRequest('POST', url, body: model.toJson());
  //     return Result.success(
  //         registerResponseJson(response.data as Map<String, dynamic>));
  //   } catch (e) {
  //     return Result.failure("An error occurred: $e");
  //   }
  // }

  static Future<Result<String>> certificateAdmin() async{
    final accessToken = await SharedService.getAccessToken();
    final refreshToken = await SharedService.getRefreshToken();
    
    final url = Uri.http(Config.apiURL, Config.certificateAdminAPI).toString();

    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Cookie': 'XRT=$refreshToken',
    };
    
    try{
      final response = await DioClient.sendRequest('GET', url, headers: headers);

      print("response : ${response.data}");

      if(response.statusCode == 200){
        print("관리자 페이지 입장.");
        return Result.success(response.data);
      }else{
        return Result.failure("Failed to certificate adming");
      }
    }catch(e){
      return Result.failure("An erroe occured : $e");
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
