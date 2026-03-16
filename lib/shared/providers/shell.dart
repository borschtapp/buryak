import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'shell.g.dart';

/// FAB widget published by the active screen, consumed by the shell's [RootLayout].
///
/// Screens with tab-specific FABs (e.g. [SavedScreen]) write to this notifier
/// via [useEffect]; the shell's [Consumer] renders whatever is current.
/// Set to `null` to let the shell fall back to its route-level default.
@Riverpod(keepAlive: true)
class ShellFab extends _$ShellFab {
  @override
  Widget? build() => null;

  void update(Widget? fab) => state = fab;
}
