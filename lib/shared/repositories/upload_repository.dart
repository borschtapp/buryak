import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'repository.dart';
import '../models/uploaded_image.dart';
import '../providers/user.dart';

class UploadRepository {
  static const String _uploadUrl = '$baseUrl/api/v1/uploads';

  static Future<UploadedImage> uploadImage(File file) async {
    final request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));
    request.headers[HttpHeaders.authorizationHeader] = 'Bearer ${UserService.getAccessToken()}';
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return UploadedImage.fromJson(json.decode(response.body));
    }

    throw GeneralApiException(message: 'Upload failed: ${response.statusCode}');
  }
}
