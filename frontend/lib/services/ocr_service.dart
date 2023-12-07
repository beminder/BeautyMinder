import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import '../config.dart';
import 'dio_client.dart';

class OCRService {

  // 이미지 선택 및 업로드 함수
  static Future<dynamic> selectAndUploadImage(PlatformFile file) async {
    final url = Uri.http(Config.apiURL, Config.ocrAPI).toString();

    final MediaType contentType = MediaType.parse(
        lookupMimeType(file.name) ?? 'application/octet-stream');

    // PlatformFile에서 MultipartFile 생성
    MultipartFile multipartFile = MultipartFile.fromBytes(
        file.bytes!,
        filename: file.name,
        contentType: contentType
    );

    FormData formData = FormData.fromMap({
      'image': multipartFile,
    });

    try {
      var response = await DioClient.sendRequest('POST', url, body: formData);

      if (response.statusCode == 200) {
        // OCR 결과 반환
        return response.data;
      } else if (response.statusCode == 404) {
        throw Exception('사진을 인식하지 못했습니다. 다시 시도해 주세요.');
      } else {
        throw Exception('Failed to upload image for OCR: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Error uploading image for OCR: $e');
    }
  }
}
