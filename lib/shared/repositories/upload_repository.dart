import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/uploaded_image.dart';
import '../providers/user.dart';
import 'repository.dart';

part 'upload_repository.g.dart';

@Riverpod(keepAlive: true)
UploadRepository uploadRepository(Ref ref) => UploadRepository(ref: ref, client: ref.watch(httpClientProvider));

class UploadRepository extends Repository {
  const UploadRepository({required super.ref, super.client}) : super(module: '/api/v1/uploads');

  Future<UploadedImage> uploadImage(File file) async {
    // Mirror the auth-refresh logic from sendRequest so uploads respect token expiry.
    final currentUser = ref.read(authProvider);
    if (currentUser == null || !currentUser.isValidAccessToken()) {
      final success = await ref.read(authProvider.notifier).refreshLogin();
      if (!success) {
        await ref.read(authProvider.notifier).logout();
        throw GeneralApiException(message: 'Authentication session expired');
      }
    }

    final token = ref.read(authProvider)?.accessToken;
    final request = http.MultipartRequest('POST', Uri.parse(getUrlString()));
    if (token != null) {
      request.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
    }
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final effectiveClient = client ?? http.Client();
    final streamedResponse = await effectiveClient.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return UploadedImage.fromJson(json.decode(response.body) as Map<String, dynamic>);
    }

    throw GeneralApiException(message: 'Upload failed: ${response.statusCode}');
  }
}
