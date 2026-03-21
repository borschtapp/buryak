import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../constants.dart';
import 'repository.dart';

part 'update_repository.g.dart';

@Riverpod(keepAlive: true)
UpdateRepository updateRepository(Ref ref) => UpdateRepository(ref: ref);

class UpdateRepository extends Repository {
  const UpdateRepository({required super.ref})
    : super(
        module: '/repos/${AppConstants.releasesGithubRepo}/releases',
        // list endpoint, works with prereleases
        isAuth: false,
        baseUrlOverride: 'https://api.github.com',
      );

  Future<String?> fetchLatestVersion() async {
    final response = await sendRequest(
      method: .get,
      queryParams: {'per_page': '1'},
      headersCustom: {'User-Agent': 'buryak-app', 'Accept': 'application/json'},
    );
    final releases = ensureList(response);
    if (releases.isEmpty) return null;
    final tag = ensureMap(releases.first)['tag_name'] as String?;
    // Strip leading 'v' from tag, e.g. 'v1.2.3' -> '1.2.3'
    return tag?.replaceFirst(RegExp(r'^v'), '');
  }
}
