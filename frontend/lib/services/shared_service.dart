import 'dart:convert';

import 'package:beautyminder/dto/login_response_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../dto/user_model.dart';

class SharedService {

  // 안전한 저장소 설정
  static const storage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock)
  );

  // 로그인 여부 확인
  static Future<bool> isLoggedIn() async {
    return await storage.containsKey(key: 'login_details');
  }

  // 로그인 상세 정보 가져오기
  static Future<LoginResponseModel?> loginDetails() async {
    final result = await storage.read(key: 'login_details');
    return result != null
        ? LoginResponseModel.fromJson(jsonDecode(result))
        : null;
  }

  static Future<void> updateLoginDetails(
      String accessToken, String refreshToken) async {
    final loginDetails = await SharedService.loginDetails();
    if (loginDetails != null) {
      loginDetails.accessToken = accessToken;
      loginDetails.refreshToken = refreshToken;
      await storage.write(
        key: 'login_details',
        value: jsonEncode(loginDetails.toJson()),
      );
    }
  }

  static Future<void> updateUser(User user) async {
    final loginDetails = await SharedService.loginDetails();
    if (loginDetails != null) {
      final updatedDetails = LoginResponseModel(
        accessToken: loginDetails.accessToken,
        refreshToken: loginDetails.refreshToken,
        user: user,
      );

      await storage.write(
        key: 'login_details',
        value: jsonEncode(updatedDetails.toJson()),
      );
    }
  }

  // 로그인 상세 정보 저장하기
  static Future<void> setLoginDetails(LoginResponseModel loginResponse) async {
    await storage.write(
      key: 'login_details',
      value: jsonEncode(loginResponse.toJson()),
    );

    await storage.write(key: 'accessToken', value: loginResponse.accessToken);
    await storage.write(key: 'refreshToken', value: loginResponse.refreshToken);
  }

  // 로그아웃
  static Future<void> logout() async {
    await storage.delete(key: 'login_details');
  }

  // refreshToken 가져오기. 값이 없을 경우 null 반환
  static Future<String?> getRefreshToken() async {
    final details = await loginDetails();
    return details?.refreshToken;
  }

  // refreshToken 설정하기
  static Future<void> setRefreshToken(String refreshToken) async {
    await storage.write(key: 'refreshToken', value: refreshToken);
  }

  // accessToken 가져오기. 값이 없을 경우 null 반환
  static Future<String?> getAccessToken() async {
    final details = await loginDetails();
    return details?.accessToken;
  }

  // accessToken 설정하기
  static Future<void> setAccessToken(String accessToken) async {
    await storage.write(key: 'accessToken', value: accessToken);
  }

  // User 가져오기. 값이 없을 경우 null 반환
  static Future<User?> getUser() async {
    final details = await loginDetails();
    return details?.user;
  }

  static Future<void> refreshToken() async {
    final refreshedTokens = await SharedService.getRefreshToken();
    await SharedService.setRefreshToken(refreshedTokens ?? '');
  }

  static Future<bool> getBool(String key) async {
    final result = await storage.read(key: key);
    return result == 'true' ? true : false;
  }

  static Future<String?> getString(String key) async {
    final result = await storage.read(key: key);
    return result;
  }
}
