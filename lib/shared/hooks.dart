import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'providers/shell.dart';

/// Hook to manage a FloatingActionButton in the shell's RootLayout.
///
/// Shows [fab] while this screen's route is on top: a page pushed over it hides
/// the FAB, and popping that page brings it back. Clears it on unmount.
void useFab(WidgetRef ref, Widget? fab) {
  final isCurrent = ModalRoute.isCurrentOf(useContext()) ?? true;

  useEffect(() {
    if (fab == null || !isCurrent) return null;

    // The provider can't change during build, so both writes wait for the frame,
    // and their callbacks may run in either order. Each run owns its FAB under a
    // fresh token, so a stale hide (this screen's previous FAB, or a screen that
    // lost the top of the stack) is a no-op once a newer FAB is shown.
    final owner = Object();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.context.mounted) ref.read(shellFabProvider.notifier).show(owner, fab);
    });
    return () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          ref.read(shellFabProvider.notifier).hide(owner);
        } catch (e) {
          // Only swallow StateError (provider disposed during teardown).
          if (e is! StateError) rethrow;
        }
      });
    };
  }, [fab, isCurrent]);
}
