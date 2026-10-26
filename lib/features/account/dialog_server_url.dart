import 'package:flutter/material.dart';

import '../../shared/components/dialog_text_input.dart';
import '../../shared/providers/server_url.dart';
import '../../shared/util/extensions.dart';

Future<void> showServerUrlDialog(BuildContext context) async {
  final l10n = context.l10n;
  return TextInputDialog(
    title: l10n.serverUrlTitle,
    hintText: ServerUrl.defaultUrl,
    labelText: l10n.serverUrlLabel,
    submitLabel: l10n.save,
    mutation: setServerUrlMutation,
    onSubmit: (tsx, value) => tsx.get(serverUrlProvider.notifier).setUrl(value),
  ).show(context);
}
