import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/providers/server_url.dart';

class ServerUrlDialog extends HookConsumerWidget {
  const ServerUrlDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUrl = ref.watch(serverUrlProvider);
    final controller = useTextEditingController(text: currentUrl == ServerUrl.defaultUrl ? '' : currentUrl);

    return AlertDialog(
      title: const Text('Server URL'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          labelText: 'Leave empty to use demo server',
          hintText: ServerUrl.defaultUrl,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            await ref.read(serverUrlProvider.notifier).setUrl(controller.text);
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
