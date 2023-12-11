import 'package:beautyminder/services/shared_service.dart';

import '../config.dart';
import '../dto/cosmetic_expiry_model.dart';
import 'dio_client.dart';

class ExpiryService {
  // Create Expiry Item
  static Future<CosmeticExpiry> createCosmeticExpiry(
      CosmeticExpiry expiry) async {
    final url =
        Uri.http(Config.apiURL, Config.createCosmeticExpiryAPI).toString();
    final accessToken = await SharedService.getAccessToken();

    try {
      final response = await DioClient.sendRequest('POST', url,
          body: expiry.toJson(),
          headers: {'Authorization': 'Bearer $accessToken'});
      if (response.statusCode == 200) {
        return CosmeticExpiry.fromJson(response.data);
      } else {
        throw Exception(
            "Failed to create cosmetic expiry: Status Code ${response.statusCode}, Data: ${response.data}");
      }
    } catch (e) {
      throw Exception("An error occurred: $e");
    }
  }

  // Get all Expiry Items
  static Future<List<CosmeticExpiry>> getAllExpiries() async {
    final url = Uri.http(Config.apiURL, Config.getAllExpiriesAPI).toString();
    final accessToken = await SharedService.getAccessToken();

    try {
      final response = await DioClient.sendRequest('GET', url,
          headers: {'Authorization': 'Bearer $accessToken'});
      if (response.statusCode == 200) {
        List<dynamic> jsonData = response.data;
        return jsonData.map((data) => CosmeticExpiry.fromJson(data)).toList();
      } else {
        throw Exception(
            "Failed to get expiries: Status Code ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("An error occurred: $e");
    }
  }

  // Get an expiry item by and ExpiryId
  static Future<CosmeticExpiry> getExpiry(String expiryId) async {
    final url = Uri.http(
            Config.apiURL, Config.getExpiryByUserIdandExpiryIdAPI + expiryId)
        .toString();
    final accessToken = await SharedService.getAccessToken();

    try {
      final response = await DioClient.sendRequest('GET', url,
          headers: {'Authorization': 'Bearer $accessToken'});
      if (response.statusCode == 200) {
        return CosmeticExpiry.fromJson(response.data);
      } else {
        throw Exception(
            "Failed to get expiry by ID: Status Code ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("An error occurred: $e");
    }
  }

  // Update an expiry item
  static Future<CosmeticExpiry> updateExpiry(
      String expiryId, CosmeticExpiry updatedExpiry) async {
    final url = Uri.http(
            Config.apiURL, Config.getExpiryByUserIdandExpiryIdAPI + expiryId)
        .toString();
    final accessToken = await SharedService.getAccessToken();

    try {
      final response = await DioClient.sendRequest('PUT', url,
          body: updatedExpiry.toJson(),
          headers: {'Authorization': 'Bearer $accessToken'});
      if (response.statusCode == 200) {
        return CosmeticExpiry.fromJson(response.data);
      } else {
        throw Exception(
            "Failed to update expiry: Status Code ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("An error occurred: $e");
    }
  }

  // Delete an expiry item by ExpiryId
  static Future<void> deleteExpiry(String expiryId) async {
    final url = Uri.http(
            Config.apiURL, Config.getExpiryByUserIdandExpiryIdAPI + expiryId)
        .toString();
    final accessToken = await SharedService.getAccessToken();

    try {
      final response = await DioClient.sendRequest('DELETE', url,
          headers: {'Authorization': 'Bearer $accessToken'});
      if (response.statusCode != 200) {
        throw Exception(
            "Failed to delete expiry: Status Code ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("An error occurred: $e");
    }
  }
}
