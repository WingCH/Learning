import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidable_bookmarks/slidable_bookmark_store.dart';
import 'package:slidable_bookmarks/slidable_tutorial_player.dart';
import 'package:slidable_bookmarks/slidable_blocker.dart';

// Widget for a slidable item with bookmark action
class SlidableBookmarkItem extends ConsumerWidget {
  final int index;
  final double minWidth;
  final Function(BuildContext context) onTap;
  final Function(BuildContext context) onTapTextButton;
  final bool showTutorial;

  const SlidableBookmarkItem({
    super.key,
    required this.index,
    required this.minWidth,
    required this.onTap,
    required this.onTapTextButton,
    this.showTutorial = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarks = ref.watch(bookmarkProvider);
    final isBookmarked = bookmarks.contains(index);

    // Main content of the slidable item
    final child = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        onTap(context);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Item $index'),
            SlidableBlocker(
              enabled: false,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  onTapTextButton(context);
                },
                child: const Text('Tap me'),
              ),
            ),
          ],
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return Slidable(
          closeOnScroll: false,
          key: ValueKey(index),
          // End action pane containing bookmark button
          endActionPane: ActionPane(
            extentRatio: minWidth / constraints.maxWidth,
            motion: const DrawerMotion(),
            dismissible: DismissiblePane(
              // TODO: dismissThreshold, dismissalDuration
              closeOnCancel: true,
              confirmDismiss: () async {
                ref.read(bookmarkProvider.notifier).toggleBookmark(index);
                return false;
              },
              onDismissed: () {},
              dismissThreshold: 0.5,
            ),
            children: [
              BookmarkActionButtonV2(
                index: index,
                isBookmarked: isBookmarked,
              ),

              // BookmarkActionButton(
              //   index: index,
              //   isBookmarked: isBookmarked,
              //   minWidth: minWidth,
              // ),
            ],
          ),
          // Apply tutorial controller if needed
          child: showTutorial
              ? SlidableControllerSender(
                  child: child,
                )
              : child,
        );
      },
    );
  }
}

// Button that appears when sliding to bookmark/unbookmark items
class BookmarkActionButton extends ConsumerStatefulWidget {
  final int index;
  final bool isBookmarked;
  final double minWidth;

  const BookmarkActionButton({
    super.key,
    required this.index,
    required this.isBookmarked,
    required this.minWidth,
  });

  @override
  ConsumerState<BookmarkActionButton> createState() =>
      _BookmarkActionButtonState();
}

class _BookmarkActionButtonState extends ConsumerState<BookmarkActionButton> {
  late final slidable = Slidable.of(context)!;
  Animation<double> get animation => slidable.animation;
  double get maxValue => slidable.endActionPaneExtentRatio;
  double progress = 0;
  final Color backgroundColor = const Color(0xFFF3F5F7);

  @override
  void initState() {
    super.initState();
    // Listen to animation changes to update the progress
    animation.addListener(handleValueChanged);
  }

  @override
  void dispose() {
    super.dispose();
    // Clean up the animation listener
    animation.removeListener(handleValueChanged);
  }

  // Update progress based on animation value
  void handleValueChanged() {
    if (mounted) {
      setState(() {
        progress = animation.value / maxValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate opacity:
    // First 10%: Completely transparent (opacity = 0.0)
    // 10-30%: Gradually becomes visible (opacity changes from 0.0 to 1.0)
    // Above 30%: Remains fully visible (opacity = 1.0)
    double opacity;
    if (progress < 0.1) {
      // Keep completely transparent for the first 10%
      opacity = 0.0;
    } else if (progress <= 0.3) {
      // Gradually become visible from 10-30%
      opacity = (progress - 0.1) / 0.2; // Map the range 0.1-0.3 to 0.0-1.0
    } else {
      // Keep fully visible above 30%
      opacity = 1.0;
    }

    // Choose the appropriate bookmark icon based on current state
    final String assetName = widget.isBookmarked
        ? 'assets/bookmark_non_filled.svg' // Show non-filled if currently bookmarked (to remove)
        : 'assets/bookmark_filled.svg'; // Show filled if not bookmarked (to add)

    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: ColoredBox(
              color: Colors.red,
              child: Text(opacity.toString()),
            ),
          ),
          Container(
            width: widget.minWidth,
            decoration: const BoxDecoration(
              color: Color(0xFFF3F5F7),
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                // Toggle bookmark status when tapped
                ref
                    .read(bookmarkProvider.notifier)
                    .toggleBookmark(widget.index);
              },
              child: Center(
                child: Opacity(
                  opacity: opacity,
                  child: SvgPicture.asset(
                    assetName,
                    width: 14,
                    height: 14,
                    fit: BoxFit.none,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BookmarkActionButtonV2 extends ConsumerWidget {
  const BookmarkActionButtonV2({
    super.key,
    required this.index,
    required this.isBookmarked,
  });

  final int index;
  final bool isBookmarked;

  String get assetName => isBookmarked
      ? 'assets/bookmark_non_filled.svg' // Show non-filled if currently bookmarked (to remove)
      : 'assets/bookmark_filled.svg'; // Show filled if not bookmarked (to add)

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: ColoredBox(
        color: Colors.red,
        child: Row(
          children: [
            const Spacer(),
            Container(
              width: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFF3F5F7),
              ),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                     ref
                    .read(bookmarkProvider.notifier)
                    .toggleBookmark(index);
                },
                child: Center(
                  child: SvgPicture.asset(
                    assetName,
                    width: 14,
                    height: 14,
                    fit: BoxFit.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
