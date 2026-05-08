import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/dialog_text_input.dart';
import '../../shared/providers/server_url.dart';

Future<void> showServerUrlDialog(BuildContext context, WidgetRef ref) async {
  return showDialog<void>(
    context: context,
    builder: (context) => TextInputDialog(
      title: 'Server URL',
      hintText: ServerUrl.defaultUrl,
      labelText: 'Leave empty to use demo server',
      submitLabel: 'Save',
      onSubmit: (value, context) async {
        await ref.read(serverUrlProvider.notifier).setUrl(value);
        if (context.mounted) Navigator.pop(context);
      },
    ),
  );
}
