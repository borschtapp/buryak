import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/loading_button.dart';
import '../../shared/providers/household.dart';
import '../../shared/util/error_extensions.dart';
import '../../shared/util/extensions.dart';
import '../../shared/util/ui_constants.dart';

const _currencies = [
  'AUD',
  'BRL',
  'CAD',
  'CHF',
  'CNY',
  'CZK',
  'DKK',
  'EUR',
  'GBP',
  'HKD',
  'HUF',
  'INR',
  'JPY',
  'KRW',
  'MXN',
  'NOK',
  'NZD',
  'PLN',
  'SEK',
  'SGD',
  'TRY',
  'UAH',
  'USD',
  'ZAR',
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
    final isLoading = ref.watch(updateHouseholdMutation).isPending;

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
              expandedInsets: EdgeInsets.zero,
              enableFilter: true,
              requestFocusOnTap: true,
              label: Text(context.l10n.householdCurrency),
              initialSelection: initialCurrency,
              dropdownMenuEntries: _currencies
                  .map((code) => DropdownMenuEntry(value: code, label: '$code — ${context.l10n.currencyName(code)}'))
                  .toList(),
              onSelected: (value) => selected.value = value,
            ),
            const SizedBox(height: UIConstants.paddingLarge),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: isLoading ? null : () => context.pop(),
                    child: Text(context.l10n.cancel),
                  ),
                ),
                const SizedBox(width: UIConstants.paddingSmall),
                Expanded(
                  child: LoadingButton(
                    isLoading: isLoading,
                    onPressed: selected.value == null
                        ? null
                        : () async {
                            final saved = await updateHouseholdMutation.tryRun(
                              ref,
                              (tsx) => tsx.get(householdProvider.notifier).updateHousehold(currency: selected.value!),
                            );
                            if (saved && context.mounted) context.pop();
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
