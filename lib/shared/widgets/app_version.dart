import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants.dart';
import '../providers/update.dart';

class AppVersionText extends StatefulWidget {
  final EdgeInsetsGeometry padding;
  final TextAlign textAlign;

  const AppVersionText({
    super.key,
    this.padding = EdgeInsets.zero,
    this.textAlign = TextAlign.center,
  });

  @override
  State<AppVersionText> createState() => _AppVersionTextState();
}

class _AppVersionTextState extends State<AppVersionText> {
  late final Future<PackageInfo> _info = PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: _info,
      builder: (context, snapshot) {
        final version = snapshot.data?.version;
        if (version == null) return const SizedBox.shrink();
        return GestureDetector(
          onTap: () => launchUrl(
            Uri.parse('https://github.com/${AppConstants.releasesGithubRepo}/releases/latest'),
            mode: LaunchMode.externalApplication,
          ),
          child: Padding(
            padding: widget.padding,
            child: Text(
              'Version $version',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
              textAlign: widget.textAlign,
            ),
          ),
        );
      },
    );
  }
}

class AppVersionSection extends ConsumerWidget {
  const AppVersionSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateState = ref.watch(availableUpdateProvider);
    final latestVersion = updateState.asData?.value;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (latestVersion != null)
          MaterialBanner(
            content: Text('Version $latestVersion is available'),
            leading: const Icon(Icons.system_update),
            actions: [
              TextButton(
                onPressed: () => launchUrl(
                  Uri.parse('https://github.com/${AppConstants.releasesGithubRepo}/releases/latest'),
                  mode: LaunchMode.externalApplication,
                ),
                child: const Text('Update'),
              ),
            ],
          ),
        const AppVersionText(
          padding: EdgeInsets.symmetric(vertical: 16),
        ),
      ],
    );
  }
}
