import 'dart:convert';

import 'package:beautyminder/config.dart';
import 'package:beautyminder/dto/review_request_model.dart';
import 'package:beautyminder/dto/review_response_model.dart';
import 'package:beautyminder/services/shared_service.dart';
import 'package:beautyminder/services/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class ReviewService {

  // 리뷰 추가 함수
  static Future<ReviewResponse> addReview(ReviewRequest reviewRequest, List<PlatformFile> imageFiles) async {
    final accessToken = await SharedService.getAccessToken();
    final url = Uri.http(Config.apiURL, Config.AllReviewAPI).toString();

    // 이미지 파일 처리
    List<MultipartFile> multipartImageList = imageFiles.map((file) {
      final MediaType contentType = MediaType.parse(lookupMimeType(file.name) ?? 'application/octet-stream');
      return MultipartFile.fromBytes(file.bytes!, filename: file.name, contentType: contentType);
    }).toList();

    // 리뷰 데이터 처리
    String reviewJson = jsonEncode({
      'content': reviewRequest.content,
      'rating': reviewRequest.rating,
      'cosmeticId': reviewRequest.cosmeticId,
    });

    MultipartFile reviewMultipart = MultipartFile.fromString(
      reviewJson,
      contentType: MediaType('application', 'json'),
    );

    var formData = FormData.fromMap({
      'review': reviewMultipart,
      'images': multipartImageList,
    });

    var response = await DioClient.sendRequest(
        'POST',
        url,
        body: formData,
        headers: {'Authorization': 'Bearer $accessToken'}
    );

    if (response.statusCode == 201) {
      return ReviewResponse.fromJson(response.data);
    } else {
      throw Exception('Failed to add review: ${response.statusMessage}');
    }
  }

  // 리뷰 조회 함수
  static Future<List<ReviewResponse>> getReviewsForCosmetic(String cosmeticId) async {
    final accessToken = await SharedService.getAccessToken();
    final url = Uri.http(Config.apiURL, Config.getReviewAPI + cosmeticId).toString();

    var response = await DioClient.sendRequest(
        'GET',
        url,
        headers: {'Authorization': 'Bearer $accessToken'}
    );

    if (response.statusCode == 200) {
      return (response.data as List).map((e) => ReviewResponse.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load reviews');
    }
  }

  // 리뷰 삭제 함수
  static Future<void> deleteReview(String reviewId) async {
    final accessToken = await SharedService.getAccessToken();
    final url = Uri.http(Config.apiURL, Config.AllReviewAPI + reviewId).toString();

    var response = await DioClient.sendRequest(
        'DELETE',
        url,
        headers: {'Authorization': 'Bearer $accessToken'}
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete review');
    }
  }

  // 리뷰 수정 함수
  static Future<ReviewResponse> updateReview(String reviewId, ReviewRequest reviewRequest, List<PlatformFile> imageFiles) async {
    final accessToken = await SharedService.getAccessToken();
    final url = Uri.http(Config.apiURL, Config.AllReviewAPI + '/' + reviewId).toString();

    // 이미지 및 리뷰 데이터 처리
    List<MultipartFile> multipartImageList = imageFiles.map((file) {
      final MediaType contentType = MediaType.parse(lookupMimeType(file.name) ?? 'application/octet-stream');
      return MultipartFile.fromFileSync(file.path!, contentType: contentType);
    }).toList();

    String reviewJson = jsonEncode(reviewRequest.toJson());

    var formData = FormData.fromMap({
      'review': MultipartFile.fromString(reviewJson, filename: 'review.json', contentType: MediaType('application', 'json')),
      'images': multipartImageList,
    });

    var response = await DioClient.sendRequest(
        'PUT',
        url,
        body: formData,
        headers: {'Authorization': 'Bearer $accessToken'}
    );

    if (response.statusCode == 200) {
      return ReviewResponse.fromJson(response.data);
    } else {
      throw Exception('Failed to update review: ${response.statusMessage}');
    }
  }

}
