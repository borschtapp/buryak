import 'package:buryak/shared/util/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../repositories/update_repository.dart';

part 'update.g.dart';

@Riverpod(keepAlive: true)
Future<String?> availableUpdate(Ref ref) async {
  try {
    final current = await PackageInfo.fromPlatform();
    final latest = await ref.read(updateRepositoryProvider).fetchLatestVersion();
    logger.d('Current: ${current.version}, Latest: $latest');

    if (latest == null || latest == current.version) return null;
    return latest;
  } catch (e) {
    logger.w('Update check failed: $e');
    return null;
  }
}
