import 'package:admin/Service/dio_client.dart';
import 'package:admin/Service/shared_service.dart';
import 'package:admin/models/review_response_model.dart';

import '../config.dart';

// final accessToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJiZWF1dHltaW5kZXIiLCJpYXQiOjE3MDIxMzg2NDAsImV4cCI6MTcwMjIyNTA0MCwic3ViIjoiYmVtaW5kZXJAYWRtaW4iLCJpZCI6IjY1NzNmZWJjNWJkOWJjMWZkNDRkZGE5YiJ9.Bsav37IwxfjLnFwEmQ41qZvBZS95EWbrgpprKouAb70";
// final refreshToken = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJiZWF1dHltaW5kZXIiLCJpYXQiOjE3MDIxMzg2NDAsImV4cCI6MTcwNDczMDY0MCwic3ViIjoiYmVtaW5kZXJAYWRtaW4iLCJpZCI6IjY1NzNmZWJjNWJkOWJjMWZkNDRkZGE5YiJ9.ZZQdp4vSIoq_OPdT1Jqndf9mksj-kdJjJo_TOCllDFU ';

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

static Future<Result<List<ReviewResponse>>> getAllReviews(int page) async{
    final accessToken = await SharedService.getAccessToken();
    final refreshToken = await SharedService.getRefreshToken();

    Map<String, dynamic> queryparameter =  {
      'page' : page.toString()
    };

    final url = Uri.http(Config.apiURL, Config.getAllReviewAPI, queryparameter ).toString();

    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Cookie': 'XRT=$refreshToken',
    };
  
    try{
      final response = await DioClient.sendRequest('GET', url, headers: headers);

      print("page : ${page}");
      print(response.data.runtimeType);
      print(response.data);
      // response.date는 map형식
      if(response.statusCode == 200){
        print(response.data.runtimeType);

        Map<String, dynamic> decodedResponse = response.data;
        ReviewPageResponse reviewPageResponse = ReviewPageResponse.fromJson(decodedResponse);
        List<ReviewResponse> reviews = reviewPageResponse.reviews;

        return Result.success(reviews);
      }else{
        return Result.failure("Failed to get Reviews");
      }
    }catch(e){
     return Result.failure("An error occured : $e");
    }

}

static  Future<Result<List<ReviewResponse>>> getFilteredReviews() async{
  final accessToken = await SharedService.getAccessToken();
  final refreshToken = await SharedService.getRefreshToken();

  final url = Uri.http(Config.apiURL, Config.getFilteredReviews).toString();

    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Cookie': 'XRT=$refreshToken',
    };

  try{
    final response = await DioClient.sendRequest('GET', url, headers: headers);
    ;
    print(response.data.runtimeType);
    print(response.data);
    // response.date는 map형식
    if(response.statusCode == 200){
      print(response.data.runtimeType);

      Map<String, dynamic> decodedResponse = response.data;
      ReviewPageResponse reviewPageResponse = ReviewPageResponse.fromJson(decodedResponse);
      List<ReviewResponse> reviews = reviewPageResponse.reviews;

      return Result.success(reviews);
    }else{
      return Result.failure("Failed to get Reviews");
    }
  }catch(e){
    return Result.failure("An error occured : $e");
  }
}

static Future<Result<String>> updateReviewStatus(String reviewid, String stat) async {
  final accessToken = await SharedService.getAccessToken();
  final refreshToken = await SharedService.getRefreshToken();

  final url = Uri.http(Config.apiURL, Config.updateReviewStatus + reviewid + "/status").toString();

  print("url : ${url}");
  final headers = {
    'Authorization': 'Bearer $accessToken',
    'Cookie': 'XRT=$refreshToken',
  };

  Map<String,dynamic> body = {
    "status": "${stat}"
  };

  try{
    final response = await DioClient.sendRequest('PATCH', url, headers: headers, body: body);

    if(response.statusCode == 200){
      print("response : ${response.data}");

     return Result.success(response.data);
    }else{
     return Result.failure('Failed to update review status');
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