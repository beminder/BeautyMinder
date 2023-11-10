import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import '../config.dart';
import '../dto/review_request_model.dart';
import '../dto/review_response_model.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';


class ReviewService {
  static final Dio client = Dio(BaseOptions(baseUrl: Config.apiURL));


  static Future<List<PlatformFile>> getImages() async {
    List<PlatformFile> paths = List.empty();
    try {
      paths = (await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        allowedExtensions: ['png', 'jpg', 'jpeg', 'heic'],
      ))
          !.files;
    } on PlatformException catch (e) {
      log('Unsupported operation' + e.toString());
    } catch (e) {
      log(e.toString());
    }
    return paths;
  }


  // 리뷰 추가 함수
  static Future<ReviewResponse> addReview(
      ReviewRequest reviewRequest, List<PlatformFile> imageFiles) async {
    final url = '/review';

    // Convert the PlatformFile objects to MultipartFile objects
    List<MultipartFile> multipartImageList = imageFiles.map((file) {
      final MediaType contentType = MediaType.parse(lookupMimeType(file.name) ?? 'application/octet-stream');
      return MultipartFile.fromBytes(
        file.bytes!,
        filename: file.name,
        contentType: contentType,
      );
    }).toList();

// Convert the review JSON into a string
    String reviewJson = jsonEncode({
      'content': reviewRequest.content,
      'rating': reviewRequest.rating,
      'cosmeticId': reviewRequest.cosmeticId,
      'userId': reviewRequest.userId,
    });

    // Create a MultipartFile from the JSON string
    MultipartFile reviewMultipart = MultipartFile.fromString(
      reviewJson,
      contentType: MediaType('application', 'json'),
    );

// Add the JSON MultipartFile to the FormData
    var formData = FormData.fromMap({
      'review': reviewMultipart,
      // Here we send the review as a MultipartFile
      'images': multipartImageList,
      // The images are sent as usual
    });
    print('FormData: $formData');

    // Dio 클라이언트를 사용하여 서버로 요청을 보내고 응답을 받습니다.
    var response = await client.post(url, data: formData);
    if (response.statusCode == 201) {
      // 성공적으로 리뷰가 생성되었을 때의 처리
      return ReviewResponse.fromJson(response.data);
    } else {
      // 서버에서 오류 응답이 왔을 때의 처리
      throw Exception('Failed to add review: ${response.statusMessage}');
    }
  }

  // 리뷰 조회 함수
  static Future<List<ReviewResponse>> getReviewsForCosmetic(
      String cosmeticId) async {
    final url = '/review/$cosmeticId';
    var response = await client.get(url);
    if (response.statusCode == 200) {
      return (response.data as List)
          .map((e) => ReviewResponse.fromJson(e))
          .toList();
    } else {
      throw Exception('Failed to load reviews');
    }
  }

  // 리뷰 삭제 함수
  static Future<void> deleteReview(String reviewId) async {
    final url = '/review/$reviewId';
    var response = await client.delete(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to delete review');
    }
  }

  // 리뷰 수정 함수
  static Future<ReviewResponse> updateReview(String reviewId,
      ReviewRequest reviewRequest, List<PlatformFile> imageFiles) async {
    final url = '/review/$reviewId';
    var formData = FormData();

    // 리뷰 텍스트 데이터를 JSON 문자열로 변환하고 추가
    String reviewJson = jsonEncode(reviewRequest.toJson());
    formData.fields..add(MapEntry('review', reviewJson));

    // 이미지 파일을 FormData에 추가합니다.
    // List<MultipartFile> multipartImageList =
    //     await Future.wait(imageFiles.map((file) async {
    //   final byteData = await fileHandler.readFileAsBytes(file);
    //   final mimeTypeData = lookupMimeType(fileHandler.getFileName(file),
    //           headerBytes: byteData) ??
    //       'application/octet-stream';
    //   return MultipartFile.fromBytes(
    //     byteData,
    //     filename: fileHandler.getFileName(file),
    //     contentType: MediaType.parse(mimeTypeData),
    //   );
    // }));

    // Dio 클라이언트를 사용하여 서버로 요청을 보내고 응답을 받습니다.
    var response = await client.put(url, data: formData);
    if (response.statusCode == 200) {
      return ReviewResponse.fromJson(response.data);
    } else {
      throw Exception('Failed to update review: ${response.statusMessage}');
    }
  }
}