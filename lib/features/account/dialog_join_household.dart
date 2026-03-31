import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/loading_indicator.dart';
import '../../shared/providers/household.dart';
import '../../shared/util/error_extensions.dart';

Future<void> showJoinHouseholdDialog(BuildContext context, {String? initialCode}) async {
  return showDialog(
    context: context,
    builder: (context) => DialogJoinHousehold(initialCode: initialCode),
  );
}

class DialogJoinHousehold extends HookConsumerWidget {
  final String? initialCode;

  const DialogJoinHousehold({super.key, this.initialCode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController(text: initialCode ?? '');
    final isLoading = useState(false);
    final formKey = useMemoized(GlobalKey<FormState>.new);

    return AlertDialog(
      title: const Text('Join Household'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the invite code shared with you to join their household.'),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Invite Code'),
              validator: (value) => value == null || value.trim().isEmpty ? 'Code is required' : null,
              enabled: !isLoading.value,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading.value ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: isLoading.value
              ? null
              : () async {
                  if (!formKey.currentState!.validate()) return;

                  isLoading.value = true;
                  try {
                    await ref.read(householdProvider.notifier).joinHousehold(controller.text.trim());
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('Successfully joined household!')));
                    }
                  } catch (e) {
                    ref.handleException(e);
                  } finally {
                    if (context.mounted) isLoading.value = false;
                  }
                },
          child: isLoading.value ? const LoadingIndicator() : const Text('Join'),
        ),
      ],
    );
  }
}
