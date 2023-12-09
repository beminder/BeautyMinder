import 'package:admin/Service/dio_client.dart';
import 'package:admin/Service/shared_service.dart';

import '../config.dart';

class adminService {

  static Future<Result<String>> kickUser(String id) async{
    final accessToken = await SharedService.getAccessToken();
    final refreshToken = await SharedService.getRefreshToken();
    final url = Uri.http(Config.apiURL,Config.kickUserAPI).toString();

    final Map<String, dynamic> body = {
      "username" : "$id"
    };

    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Cookie': 'XRT=$refreshToken',
    };
    
    try{
      final response = await DioClient.sendRequest('POST', url, body: body, headers: headers);

      print("response : ${response.data}");

      if(response.statusCode == 200){
       return Result.success(response.data);
      }else{
       return Result.failure("Failed to kick user");
      }
    }catch(e){
     return Result.failure("An error occured : $e");
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