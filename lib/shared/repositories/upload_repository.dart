import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/uploaded_image.dart';
import 'repository.dart';

part 'upload_repository.g.dart';

@Riverpod(keepAlive: true)
UploadRepository uploadRepository(Ref ref) => UploadRepository(ref: ref, client: ref.watch(httpClientProvider));

class UploadRepository extends Repository {
  const UploadRepository({required super.ref, super.client}) : super(module: '/api/v1/uploads');

  Future<UploadedImage> uploadImage(File file) async {
    final token = await ensureAuthenticated();
    final request = http.MultipartRequest('POST', Uri.parse(getUrlString()));
    if (token != null) {
      request.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
    }
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final effectiveClient = client ?? (throw ArgumentError('A shared http.Client must be provided via httpClientProvider'));
    final streamedResponse = await effectiveClient.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return UploadedImage.fromJson(json.decode(response.body) as Map<String, dynamic>);
    }

    throw GeneralApiException(message: 'Upload failed: ${response.statusCode}');
  }
}
