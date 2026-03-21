import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'notifier_household.dart';

Future<void> showRenameHouseholdDialog(BuildContext context) async {
  return showDialog(
    context: context,
    builder: (context) => const DialogRenameHousehold(),
  );
}

class DialogRenameHousehold extends HookConsumerWidget {
  const DialogRenameHousehold({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final householdAsync = ref.watch(householdProvider);
    final household = householdAsync.value;

    final controller = useTextEditingController(text: household?.name ?? '');
    final isLoading = useState(false);
    final formKey = useMemoized(GlobalKey<FormState>.new);

    return AlertDialog(
      title: const Text('Rename Household'),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Household Name'),
          validator: (value) => value == null || value.trim().isEmpty ? 'Name is required' : null,
          enabled: !isLoading.value,
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
                    await ref.read(householdProvider.notifier).rename(controller.text.trim());
                    if (context.mounted) Navigator.of(context).pop();
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  } finally {
                    if (context.mounted) isLoading.value = false;
                  }
                },
          child: isLoading.value
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Save'),
        ),
      ],
    );
  }
}
