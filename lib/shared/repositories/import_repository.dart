import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/import_result.dart';
import 'repository.dart';

part 'import_repository.g.dart';

@Riverpod(keepAlive: true)
ImportRepository importRepository(Ref ref) => ImportRepository(ref: ref, client: ref.watch(httpClientProvider));

class ImportRepository extends Repository {
  const ImportRepository({required super.ref, super.client}) : super(module: '/api/v1/import');

  Future<ImportResult> import(String url, {bool update = false, String? type}) async {
    final response = await sendRequest(
      method: .post,
      body: {
        'url': url,
        'update': update,
        'type': ?type,
      },
    );
    return ImportResult.fromJson(ensureMap(response));
  }
}
