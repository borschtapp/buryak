import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/release_info.dart';
import '../repositories/update_repository.dart';
import '../util/logger.dart';

part 'update.g.dart';

@Riverpod(keepAlive: true)
Future<ReleaseInfo?> availableUpdate(Ref ref) async {
  if (!kReleaseMode || defaultTargetPlatform != TargetPlatform.android) return null;

  try {
    final current = await PackageInfo.fromPlatform();
    final latest = await ref.read(updateRepositoryProvider).fetchLatestRelease();
    logger.d('Current: ${current.version}, Latest: ${latest?.version}');

    if (latest == null || latest.version == current.version) return null;
    return latest;
  } catch (e) {
    logger.w('Update check failed: $e');
    return null;
  }
}
