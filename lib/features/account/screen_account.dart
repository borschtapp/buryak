import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/dialog_confirm.dart';
import '../../shared/components/profile_details.dart';
import '../../shared/components/settings_list.dart';
import '../../shared/layouts/content_frame.dart';
import '../../shared/providers/user.dart';
import '../../shared/route_names.dart';
import '../../shared/sections/app_version.dart';
import '../../shared/util/error_extensions.dart';
import '../../shared/util/extensions.dart';
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
      return const Center(child: Text('User not found. Please log in again.'));
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
            const SizedBox(height: 16),
            const HouseholdDetails(),
            const SizedBox(height: 8),
            SettingsSection(
              children: [
                SettingsTile(
                  leading: const Icon(Icons.edit_document),
                  title: 'Terms of Use',
                  onTap: () => context.pushNamed(RouteNames.terms),
                ),
                SettingsTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: 'Privacy Policy',
                  onTap: () => context.pushNamed(RouteNames.privacy),
                ),
              ],
            ),
            SettingsSection(
              children: [
                SettingsTile(
                  leading: const Icon(Icons.logout),
                  title: 'Logout',
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
                  title: isDeleting.value ? 'Deleting Account...' : 'Delete Account',
                  trailing: null,
                  isLoading: isDeleting.value,
                  onTap: () async {
                    final confirmed = await showConfirmDialog(
                      context,
                      title: 'Delete Account',
                      content:
                          'This will permanently delete your account and all associated data. '
                          'This action cannot be undone.',
                      confirmLabel: 'Delete',
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
