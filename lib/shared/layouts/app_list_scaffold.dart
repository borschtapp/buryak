import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../components/standard_async_builder.dart';
import '../util/ui_constants.dart';
import 'content_frame.dart';

/// A standard layout for feature screens that display an asynchronous list.
class AppListScaffold<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data)? data;
  final RefreshCallback onRefresh;
  final VoidCallback? onRetry;
  final double maxWidth;
  final String? errorTitle;
  final Widget? emptyState;
  final bool Function(T data)? isEmpty;

  // Pagination support
  final VoidCallback? onLoadMore;
  final bool isLoadingMore;
  final bool hasMore;

  // Sliver support
  final List<Widget> Function(T data)? slivers;

  const AppListScaffold({
    super.key,
    required this.value,
    required this.data,
    required this.onRefresh,
    this.onRetry,
    this.maxWidth = 960,
    this.errorTitle,
    this.emptyState,
    this.isEmpty,
    this.onLoadMore,
    this.isLoadingMore = false,
    this.hasMore = false,
  }) : slivers = null;

  const AppListScaffold.sliver({
    super.key,
    required this.value,
    required this.slivers,
    required this.onRefresh,
    this.onRetry,
    this.maxWidth = 960,
    this.errorTitle,
    this.emptyState,
    this.isEmpty,
    this.onLoadMore,
    this.isLoadingMore = false,
    this.hasMore = false,
  }) : data = null;

  @override
  Widget build(BuildContext context) {
    return StandardAsyncBuilder<T>(
      value: value,
      onRetry: onRetry ?? onRefresh,
      errorTitle: errorTitle,
      data: (results) {
        if (emptyState != null && (isEmpty?.call(results) ?? false)) {
          return emptyState!;
        }

        Widget content;
        if (slivers != null) {
          content = CustomScrollView(
            slivers: slivers!(results),
          );
        } else {
          content = data!(results);
        }

        return ContentFrame(
          maxWidth: maxWidth,
          child: Column(
            children: [
              Expanded(
                child: NotificationListener<ScrollEndNotification>(
                  onNotification: (notification) {
                    if (hasMore && !isLoadingMore && notification.metrics.extentAfter < UIConstants.scrollThreshold) {
                      onLoadMore?.call();
                    }
                    return false;
                  },
                  child: RefreshIndicator(
                    onRefresh: onRefresh,
                    child: content,
                  ),
                ),
              ),
              if (isLoadingMore)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        );
      },
    );
  }
}
