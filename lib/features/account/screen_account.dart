import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/dialog_confirm.dart';
import '../../shared/components/profile_details.dart';
import '../../shared/components/settings_list.dart';
import '../../shared/layouts/content_frame.dart';
import '../../shared/providers/locale.dart';
import '../../shared/providers/user.dart';
import '../../shared/route_names.dart';
import '../../shared/sections/app_version.dart';
import '../../shared/util/error_extensions.dart';
import '../../shared/util/extensions.dart';
import '../../shared/util/ui_constants.dart';
import 'dialog_join_household.dart';
import 'section_household_details.dart';

class AccountScreen extends HookConsumerWidget {
  final String? joinCode;

  const AccountScreen({super.key, this.joinCode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      if (joinCode != null && joinCode!.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showJoinHouseholdDialog(context, ref, initialCode: joinCode);
        });
      }
      return null;
    }, [joinCode]);

    final userState = ref.watch(authProvider);
    final isDeleting = useState(false);
    if (userState == null) {
      return Center(child: Text(context.l10n.accountUserNotFound));
    }

    final profile = userState;
    final name = profile.name;
    final email = profile.email;
    final image = profile.imageUrl;
    final errorColor = context.colors.error;

    return ContentFrame(
      maxWidth: 720,
      child: SingleChildScrollView(
        child: Column(
          children: [
            ProfileDetails(name: name, email: email, image: image),
            const SizedBox(height: UIConstants.paddingMedium),
            const HouseholdDetails(),
            const SizedBox(height: UIConstants.paddingSmall),
            SettingsSection(
              children: [
                SettingsTile(
                  leading: const Icon(Icons.language),
                  title: context.l10n.settingsLanguage,
                  trailing: DropdownButton<Locale?>(
                    value: ref.watch(localeProvider),
                    underline: const SizedBox.shrink(),
                    items: [
                      DropdownMenuItem(value: null, child: Text(context.l10n.settingsLanguageSystem)),
                      const DropdownMenuItem(value: Locale('en'), child: Text('English')),
                      const DropdownMenuItem(value: Locale('de'), child: Text('Deutsch')),
                      const DropdownMenuItem(value: Locale('uk'), child: Text('Українська')),
                    ],
                    onChanged: (locale) {
                      if (locale == null) {
                        ref.read(localeProvider.notifier).clearLocale();
                      } else {
                        ref.read(localeProvider.notifier).setLocale(locale);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: UIConstants.paddingSmall),
            SettingsSection(
              children: [
                SettingsTile(
                  leading: const Icon(Icons.edit_document),
                  title: context.l10n.accountTermsOfUse,
                  onTap: () => context.pushNamed(RouteNames.terms),
                ),
                SettingsTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: context.l10n.accountPrivacyPolicy,
                  onTap: () => context.pushNamed(RouteNames.privacy),
                ),
              ],
            ),
            SettingsSection(
              children: [
                SettingsTile(
                  leading: const Icon(Icons.logout),
                  title: context.l10n.accountLogout,
                  trailing: null,
                  isLoading: isDeleting.value,
                  onTap: () async {
                    try {
                      await ref.read(authProvider.notifier).logout();
                      if (context.mounted) {
                        context.goNamed(RouteNames.login);
                      }
                    } catch (e) {
                      ref.handleException(e);
                    }
                  },
                ),
                SettingsTile(
                  leading: Icon(Icons.delete_forever, color: errorColor),
                  foregroundColor: errorColor,
                  title: isDeleting.value ? context.l10n.accountDeletingAccount : context.l10n.accountDeleteAccount,
                  trailing: null,
                  isLoading: isDeleting.value,
                  onTap: () async {
                    final confirmed = await showConfirmDialog(
                      context,
                      title: context.l10n.accountDeleteTitle,
                      content: context.l10n.accountDeleteContent,
                      confirmLabel: context.l10n.delete,
                      destructive: true,
                    );
                    if (confirmed && context.mounted) {
                      isDeleting.value = true;
                      try {
                        await ref.read(authProvider.notifier).deleteAccount();
                        if (context.mounted) {
                          context.goNamed(RouteNames.login);
                        }
                      } catch (e) {
                        ref.handleException(e);
                      } finally {
                        isDeleting.value = false;
                      }
                    }
                  },
                ),
              ],
            ),
            const AppVersionSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
