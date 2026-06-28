import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/loading_button.dart';
import '../../shared/providers/household.dart';
import '../../shared/util/error_extensions.dart';
import '../../shared/util/extensions.dart';
import '../../shared/util/ui_constants.dart';

const _currencies = [
  ('AUD', 'Australian Dollar'),
  ('BRL', 'Brazilian Real'),
  ('CAD', 'Canadian Dollar'),
  ('CHF', 'Swiss Franc'),
  ('CNY', 'Chinese Yuan'),
  ('CZK', 'Czech Koruna'),
  ('DKK', 'Danish Krone'),
  ('EUR', 'Euro'),
  ('GBP', 'British Pound'),
  ('HKD', 'Hong Kong Dollar'),
  ('HUF', 'Hungarian Forint'),
  ('INR', 'Indian Rupee'),
  ('JPY', 'Japanese Yen'),
  ('KRW', 'South Korean Won'),
  ('MXN', 'Mexican Peso'),
  ('NOK', 'Norwegian Krone'),
  ('NZD', 'New Zealand Dollar'),
  ('PLN', 'Polish Zloty'),
  ('SEK', 'Swedish Krona'),
  ('SGD', 'Singapore Dollar'),
  ('TRY', 'Turkish Lira'),
  ('UAH', 'Ukrainian Hryvnia'),
  ('USD', 'US Dollar'),
  ('ZAR', 'South African Rand'),
];

Future<void> showChangeCurrencyDialog(BuildContext context, String? currentCurrency) {
  return showDialog<void>(
    context: context,
    builder: (_) => _ChangeCurrencyDialog(initialCurrency: currentCurrency),
  );
}

class _ChangeCurrencyDialog extends HookConsumerWidget {
  const _ChangeCurrencyDialog({this.initialCurrency});

  final String? initialCurrency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = useState<String?>(initialCurrency);
    final controller = useTextEditingController();
    final isLoading = useState(false);

    return Dialog(
      constraints: const BoxConstraints(maxWidth: 560),
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.paddingLarge),
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .stretch,
          children: [
            Text(context.l10n.householdChangeCurrency, style: context.textTheme.headlineSmall),
            const SizedBox(height: UIConstants.paddingLarge),
            DropdownMenu<String>(
              controller: controller,
              expandedInsets: EdgeInsets.zero,
              enableFilter: true,
              requestFocusOnTap: true,
              label: Text(context.l10n.householdCurrency),
              initialSelection: initialCurrency,
              dropdownMenuEntries: _currencies.map((c) => DropdownMenuEntry(value: c.$1, label: '${c.$1} — ${c.$2}')).toList(),
              onSelected: (value) => selected.value = value,
            ),
            const SizedBox(height: UIConstants.paddingLarge),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: isLoading.value ? null : () => Navigator.pop(context),
                    child: Text(context.l10n.cancel),
                  ),
                ),
                const SizedBox(width: UIConstants.paddingSmall),
                Expanded(
                  child: LoadingButton(
                    isLoading: isLoading.value,
                    onPressed: selected.value == null
                        ? null
                        : () async {
                            isLoading.value = true;
                            try {
                              await ref.read(householdProvider.notifier).updateHousehold(currency: selected.value!);
                              if (context.mounted) Navigator.pop(context);
                            } catch (e) {
                              ref.handleException(e);
                            } finally {
                              if (context.mounted) isLoading.value = false;
                            }
                          },
                    child: Text(context.l10n.save),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
