import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/uploaded_image.dart';
import '../providers/user.dart';
import 'repository.dart';

part 'upload_repository.g.dart';

@riverpod
UploadRepository uploadRepository(Ref ref) => UploadRepository(ref: ref);

class UploadRepository extends Repository {
  static const String _uploadPath = '/api/v1/uploads';

  const UploadRepository({required super.ref}) : super(module: _uploadPath);

  Future<UploadedImage> uploadImage(File file) async {
    final token = ref.read(authProvider)?.accessToken;
    final request = http.MultipartRequest('POST', Uri.parse('$effectiveBaseUrl$_uploadPath'));
    if (token != null) {
      request.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
    }
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return UploadedImage.fromJson(json.decode(response.body) as Map<String, dynamic>);
    }

    throw GeneralApiException(message: 'Upload failed: ${response.statusCode}');
  }
}
