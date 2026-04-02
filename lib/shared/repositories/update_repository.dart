import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../constants.dart';
import '../models/release_info.dart';
import 'repository.dart';

part 'update_repository.g.dart';

@Riverpod(keepAlive: true)
UpdateRepository updateRepository(Ref ref) => UpdateRepository(ref: ref, client: ref.watch(httpClientProvider));

class UpdateRepository extends Repository {
  const UpdateRepository({required super.ref, super.client})
    : super(
        module: '/repos/${AppConstants.releasesGithubRepo}/releases',
        // list endpoint, works with prereleases
        isAuth: false,
        baseUrlOverride: 'https://api.github.com',
      );

  Future<ReleaseInfo?> fetchLatestRelease() async {
    final response = await sendRequest(
      method: .get,
      queryParams: {'per_page': '1'},
      headersCustom: {'User-Agent': 'buryak-app', 'Accept': 'application/json'},
    );
    final releases = ensureList(response);
    if (releases.isEmpty) return null;

    final release = ensureMap(releases.first);
    final tag = release['tag_name'] as String?;
    if (tag == null) return null;

    final version = tag.replaceFirst(RegExp(r'^v'), '');

    final assets = release['assets'] as List?;
    final apkAsset = assets?.map(ensureMap).where((a) => (a['name'] as String?)?.endsWith('.apk') == true).firstOrNull;
    final apkUrl = apkAsset?['browser_download_url'] as String?;

    return ReleaseInfo(version: version, apkUrl: apkUrl);
  }
}
