import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'shell.g.dart';

/// FAB widget published by the active screen, consumed by the shell's [RootLayout].
///
/// Screens publish through `useFab`, which shows a FAB only while its route is on
/// top; the shell's [Consumer] renders whatever is current.
@Riverpod(keepAlive: true)
class ShellFab extends _$ShellFab {
  Object? _owner;

  @override
  Widget? build() => null;

  /// Shows [fab] on behalf of [owner], replacing any other FAB.
  void show(Object owner, Widget fab) {
    _owner = owner;
    state = fab;
  }

  /// Removes [owner]'s FAB; a no-op once a newer FAB has been shown.
  void hide(Object owner) {
    if (!identical(_owner, owner)) return;
    _owner = null;
    state = null;
  }
}
