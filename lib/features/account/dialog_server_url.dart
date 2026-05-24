import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/dialog_text_input.dart';
import '../../shared/providers/server_url.dart';
import '../../shared/util/extensions.dart';

Future<void> showServerUrlDialog(BuildContext context, WidgetRef ref) async {
  final l10n = context.l10n;
  return showDialog<void>(
    context: context,
    builder: (context) => TextInputDialog(
      title: l10n.serverUrlTitle,
      hintText: ServerUrl.defaultUrl,
      labelText: l10n.serverUrlLabel,
      submitLabel: l10n.save,
      onSubmit: (value, context) async {
        await ref.read(serverUrlProvider.notifier).setUrl(value);
        if (context.mounted) Navigator.pop(context);
      },
    ),
  );
}
