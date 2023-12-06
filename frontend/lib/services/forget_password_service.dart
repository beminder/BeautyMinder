import '../../config.dart';
import 'dio_client.dart';

class ForgetPasswordService {

  //비밀번호 찾기 이메일로
  static Future<bool> requestByEmailWhenForgetPwd(String email) async {

    final body = {
      'email': '$email',
    };

    final url = Uri.http(Config.apiURL, Config.uploadFavoritesAPI).toString();

    try {
      final response = await DioClient.sendRequest('POST', url, body:body);

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print("An error occurred: $e");
      return false;
    }
  }

  //비밀번호 찾기 전화번호로
  static Future<bool> requestByPhoneNumWhenForgetPwd(String phoneNumber) async {

    final url = Uri.http(Config.apiURL, Config.uploadFavoritesAPI + phoneNumber).toString();

    try {
      final response = await DioClient.sendRequest('POST', url);

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print("An error occurred: $e");
      return false;
    }
  }
}

