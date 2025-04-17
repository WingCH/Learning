import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_flutter_slidable/bookmark_manager.dart';
import 'package:study_flutter_slidable/slidable_blocker.dart';

class BookmarkListItem extends ConsumerWidget {
  final int index;
  final double extentRatio;

  const BookmarkListItem({
    super.key,
    required this.index,
    required this.extentRatio,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarks = ref.watch(bookmarkProvider);
    final isBookmarked = bookmarks.contains(index);

    return Slidable(
      closeOnScroll: false,
      key: ValueKey(index),
      endActionPane: ActionPane(
        extentRatio: extentRatio,
        motion: const StretchMotion(),
        children: [
          Expanded(
            child: BookmarkActionButton(
              index: index,
              isBookmarked: isBookmarked,
            ),
          ),
        ],
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          print('Item $index tapped');
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
                    print('TextButton Item $index tapped');
                  },
                  child: const Text('Tap me'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void doNothing(BuildContext context) {
    print('doNothing');
  }
}

class BookmarkActionButton extends ConsumerStatefulWidget {
  final int index;
  final bool isBookmarked;

  const BookmarkActionButton({
    super.key,
    required this.index,
    required this.isBookmarked,
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

  @override
  void initState() {
    super.initState();
    animation.addListener(handleValueChanged);

    print('maxValue $maxValue');
  }

  @override
  void dispose() {
    super.dispose();
    animation.removeListener(handleValueChanged);
  }

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

    final String assetName = widget.isBookmarked
        ? 'assets/bookmark_non_filled.svg' // Show non-filled if currently bookmarked (to remove)
        : 'assets/bookmark_filled.svg'; // Show filled if not bookmarked (to add)

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF3F5F7),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          ref.read(bookmarkProvider.notifier).toggleBookmark(widget.index);
        },
        child: Center(
          child: Opacity(
            opacity: opacity,
            child: SvgPicture.asset(
              assetName,
              width: 14,
              height: 14,
              fit: BoxFit.none,
              clipBehavior: Clip.hardEdge,
            ),
          ),
        ),
      ),
    );
  }
}
