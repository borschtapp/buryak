import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'date.g.dart';

/// Provides the current date, yielding a new value every midnight.
///
/// DST Behavior:
/// The [tomorrow.difference(now)] calculates duration in wall clock time.
/// On DST change days (spring forward), the wait will be 23h but yield at local midnight.
/// On fall back, the wait will be 25h but yield at local midnight.
/// This is generally acceptable for UI date tracking.
@Riverpod(keepAlive: true)
Stream<DateTime> currentDate(Ref ref) async* {
  yield DateTime.now();

  // Yield a new date at every midnight
  while (true) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final sleepDuration = tomorrow.difference(now);

    // Future.delayed uses monotonic time.
    await Future<void>.delayed(sleepDuration);
    yield DateTime.now();
  }
}
