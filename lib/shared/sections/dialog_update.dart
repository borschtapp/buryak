import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants.dart';
import '../models/release_info.dart';
import '../util/logger.dart';

enum _UpdateState { idle, downloading, error }

class UpdateDialog extends HookWidget {
  final ReleaseInfo release;

  const UpdateDialog({super.key, required this.release});

  @override
  Widget build(BuildContext context) {
    final state = useState(_UpdateState.idle);
    final progress = useState(0.0);
    final clientRef = useRef<http.Client?>(null);

    useEffect(() {
      return () {
        clientRef.value?.close();
        clientRef.value = null;
      };
    }, const []);

    Future<void> downloadAndInstall(String apkUrl) async {
      state.value = _UpdateState.downloading;
      progress.value = 0.0;

      final navigator = Navigator.of(context);
      final client = http.Client();
      clientRef.value = client;
      try {
        final request = http.Request('GET', Uri.parse(apkUrl));
        final response = await client.send(request);
        final total = response.contentLength ?? -1;
        var received = 0;

        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/updates/update.apk');
        await file.parent.create(recursive: true);
        final sink = file.openWrite();
        try {
          await for (final chunk in response.stream) {
            sink.add(chunk);
            received += chunk.length;
            if (total > 0 && context.mounted) progress.value = received / total;
          }
        } finally {
          await sink.flush();
          await sink.close();
        }

        const channel = MethodChannel(AppConstants.installerChannel);
        await channel.invokeMethod<void>('install', file.path);

        if (!context.mounted) return;
        state.value = _UpdateState.idle;
        navigator.pop();
      } catch (e) {
        logger.e('Self-update failed: $e');
        if (context.mounted) state.value = _UpdateState.error;
      } finally {
        clientRef.value = null;
        client.close();
      }
    }

    void onUpdate() {
      final apkUrl = release.apkUrl;
      if (Platform.isAndroid && apkUrl != null) {
        downloadAndInstall(apkUrl);
      } else {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
        launchUrl(
          Uri.parse('https://github.com/${AppConstants.releasesGithubRepo}/releases/latest'),
          mode: LaunchMode.externalApplication,
        );
      }
    }

    final isDownloading = state.value == _UpdateState.downloading;

    return AlertDialog(
      icon: const Icon(Icons.system_update),
      title: Text('Version ${release.version} available'),
      content: isDownloading
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Downloading update…'),
                const SizedBox(height: 12),
                LinearProgressIndicator(value: progress.value > 0 ? progress.value : null),
              ],
            )
          : Text(
              state.value == _UpdateState.error ? 'Download failed. Please try again.' : 'A new version of Borscht is ready to install.',
            ),
      actions: [
        if (!isDownloading) ...[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Later'),
          ),
          FilledButton(
            onPressed: onUpdate,
            child: const Text('Update'),
          ),
        ],
      ],
    );
  }
}
