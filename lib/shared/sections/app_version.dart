import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants.dart';
import '../providers/update.dart';
import '../util/extensions.dart';
import 'dialog_update.dart';

class AppVersionText extends HookWidget {
  final EdgeInsetsGeometry padding;
  final TextAlign textAlign;

  const AppVersionText({
    super.key,
    this.padding = EdgeInsets.zero,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    final info = useFuture(useMemoized(PackageInfo.fromPlatform));
    final version = info.data?.version;
    if (version == null) return const SizedBox.shrink();
    return GestureDetector(
      onTap: () => launchUrl(
        Uri.parse('https://github.com/${AppConstants.releasesGithubRepo}/releases/latest'),
        mode: LaunchMode.externalApplication,
      ),
      child: Padding(
        padding: padding,
        child: Text(
          'Version $version',
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.outline,
          ),
          textAlign: textAlign,
        ),
      ),
    );
  }
}

class AppVersionSection extends HookConsumerWidget {
  const AppVersionSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateState = ref.watch(availableUpdateProvider);
    final release = updateState.asData?.value;

    final dialogShown = useRef(false);

    useEffect(() {
      if (release == null || dialogShown.value) return null;
      dialogShown.value = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => UpdateDialog(release: release),
        );
      });
      return null;
    }, [release]);

    return const AppVersionText(
      padding: EdgeInsets.symmetric(vertical: 16),
    );
  }
}
