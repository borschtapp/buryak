import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'providers/shell.dart';

/// Hook to manage a FloatingActionButton in the shell's RootLayout.
///
/// Sets the FAB on mount and clears it on unmount.
void useFab(WidgetRef ref, Widget? fab) {
  // A generation counter ensures stale post-frame callbacks (e.g. from a
  // previous screen's cleanup that fires after this screen has already
  // registered its own FAB) do not clobber the current value.
  final token = useRef(Object());

  useEffect(() {
    final myToken = Object();
    token.value = myToken;

    if (fab != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (ref.context.mounted && identical(token.value, myToken)) {
          ref.read(shellFabProvider.notifier).update(fab);
        }
      });
    }

    return () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Only clear if no newer registration has taken over.
        if (!identical(token.value, myToken)) return;
        try {
          ref.read(shellFabProvider.notifier).update(null);
        } catch (e) {
          // Only swallow StateError (provider disposed during teardown).
          if (e is! StateError) rethrow;
        }
      });
    };
  }, [fab]);
}
