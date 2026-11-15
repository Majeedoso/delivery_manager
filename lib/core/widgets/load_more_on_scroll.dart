import 'package:flutter/widgets.dart';

/// Loads a list's next page as the list nears its end, and at once when a
/// page is too short to scroll, which no scroll would ask for: every list
/// comes 10 at a time and loads the next as it is scrolled, with no "Load
/// more" button (the owner's rule, 2026-11-15).
///
/// [child] is the list, or holds it (a RefreshIndicator around a ListView);
/// only the list's own scroll is listened to, not one nested in it.
class LoadMoreOnScroll extends StatefulWidget {
  const LoadMoreOnScroll({
    super.key,
    required this.hasMore,
    required this.isLoadingMore,
    required this.itemCount,
    required this.onLoadMore,
    required this.child,
  });

  /// Whether a next page exists.
  final bool hasMore;

  /// Whether the next page is on its way: nothing more is asked meanwhile.
  final bool isLoadingMore;

  /// The rows the list shows: a list too short to scroll asks for the next
  /// page once for each count, so that a page that failed is not asked
  /// again in a loop.
  final int itemCount;

  /// Asks for the next page.
  final VoidCallback onLoadMore;

  final Widget child;

  @override
  State<LoadMoreOnScroll> createState() => _LoadMoreOnScrollState();
}

class _LoadMoreOnScrollState extends State<LoadMoreOnScroll> {
  int? _askedAtCount;

  /// Asked, and the list has not answered yet: a scroll asks once, not once
  /// for each of its frames.
  bool _waiting = false;

  /// The list's scroll, read again when the list changes: a list shorter
  /// than the screen keeps the same scroll metrics when a page comes, and
  /// says nothing.
  ScrollPosition? _position;

  @override
  void didUpdateWidget(LoadMoreOnScroll oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLoadingMore != widget.isLoadingMore ||
        oldWidget.itemCount != widget.itemCount ||
        oldWidget.hasMore != widget.hasMore) {
      _waiting = false;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final position = _position;
      if (mounted &&
          position != null &&
          position.hasContentDimensions &&
          position.hasPixels) {
        _askIfNearTheEnd(position, scrolled: false);
      }
    });
  }

  bool _onNotification(Notification notification) {
    if (notification is ScrollUpdateNotification && notification.depth == 0) {
      _position = _positionOf(notification.context) ?? _position;
      _askIfNearTheEnd(notification.metrics, scrolled: true);
    } else if (notification is ScrollMetricsNotification &&
        notification.depth == 0) {
      // The list was laid out: its first page came, or one more
      _position = _positionOf(notification.context) ?? _position;
      _askIfNearTheEnd(notification.metrics, scrolled: false);
    }
    return false;
  }

  ScrollPosition? _positionOf(BuildContext? context) =>
      context == null ? null : Scrollable.maybeOf(context)?.position;

  void _askIfNearTheEnd(ScrollMetrics metrics, {required bool scrolled}) {
    if (metrics.axis != Axis.vertical ||
        // Less than a screen of rows left: the next ones are there in time
        metrics.extentAfter > metrics.viewportDimension ||
        !widget.hasMore ||
        widget.isLoadingMore ||
        _waiting ||
        (!scrolled && _askedAtCount == widget.itemCount)) {
      return;
    }
    _askedAtCount = widget.itemCount;
    _waiting = true;
    widget.onLoadMore();
  }

  @override
  Widget build(BuildContext context) => NotificationListener<Notification>(
    onNotification: _onNotification,
    child: widget.child,
  );
}
