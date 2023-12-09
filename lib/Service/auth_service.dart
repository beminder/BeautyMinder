import 'package:dio/dio.dart'; // DIO 패키지를 이용해 HTTP 통신

import 'shared_service.dart';

final Dio authClient = Dio();

// 공통 HTTP 옵션 설정 함수
Options _httpOptions(String method, Map<String, String>? headers) {
  return Options(
    method: method,
    headers: headers,
  );
}

//POST 방식으로 JSON 데이터 전송
Future<Response> authPost(String url, Map<String, dynamic> body,
    {Map<String, String>? headers}) {
  return authClient.post(
    url,
    options: _httpOptions('POST', headers),
    data: body,
  );
}

void setupAuthClient() {
  authClient.interceptors.add(TokenInterceptor());
}

class TokenInterceptor extends Interceptor {
  int retryCount = 0;

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final accessToken = await SharedService.getAccessToken();
    options.headers['Authorization'] = 'Bearer $accessToken';
    return handler.next(options);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && retryCount < 3) {
      // Change 3 to the max number of retries you want
      retryCount++; // Increment the count on failure

      RequestOptions options =
          err.response?.requestOptions ?? RequestOptions(path: "");
      options.headers['Authorization'] =
          'Bearer ${await SharedService.getAccessToken()}';
      await SharedService.refreshToken();

      try {
        Response response = await authClient.fetch(options);

        // Update tokens based on the new response headers and cookies
        String? newAccessToken =
            response.headers.value('Authorization')?.split(' ')[1];
        String? newRefreshToken = response.headers['set-cookie']
            ?.firstWhere((str) => str.startsWith('XRT='), orElse: () => '')
            ?.split(';')[0]
            ?.substring(4); // Skip 'XRT='

        if (newAccessToken != null) {
          await SharedService.setAccessToken(newAccessToken);
        }
        if (newRefreshToken != null) {
          await SharedService.setRefreshToken(newRefreshToken);
        }

        retryCount = 0; // Reset the retry count if successful
        return handler.resolve(response);
      } catch (e) {
        return handler.next(err);
      }
    } else if (retryCount >= 3) {
      // Check if the retry count has reached its limit
      retryCount = 0; // Reset the retry count
      // Do something to handle too many failed retries, for example:
      return handler.next(DioError(
          requestOptions: err.requestOptions,
          error: "Maximum retry limit reached."));
    }

    return handler.next(err);
  }
}
