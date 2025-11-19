import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// 一個專門用於處理「頂部插入資料」時自動修正滾動位置的 Widget。
///
/// 當子組件的高度因內容變更而增加時，此 Widget 會假設這是因為在頂部插入了新內容，
/// 並自動調整滾動偏移量 (Scroll Offset)，使視覺上的滾動位置保持不變。
///
/// **注意：此 Widget 僅支援頂部插入 (Prepend) 的場景。**
/// 如果在底部插入資料 (Append)，此 Widget 會錯誤地將畫面下移，導致滾動位置跳動。
/// 請確保只在需要處理頂部插入的場景下使用此 Widget。
class TopPrependScrollFixer extends StatefulWidget {
  final Widget child;
  final ScrollController? scrollController;
  final bool enabled;

  const TopPrependScrollFixer({
    super.key,
    required this.child,
    this.scrollController,
    this.enabled = true,
  });

  @override
  State<TopPrependScrollFixer> createState() => _TopPrependScrollFixerState();
}

class _TopPrependScrollFixerState extends State<TopPrependScrollFixer> {
  double? _previousHeight;
  double? _previousOffset;

  ScrollController? get _effectiveController {
    return widget.scrollController ?? PrimaryScrollController.of(context);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _effectiveController;

    if (widget.enabled && controller != null) {
      // 1. 在新佈局發生之前（即 build 階段），記錄當前的高度和滾動偏移量。
      // context.findRenderObject() 在此處獲取的是「上一幀」的 RenderBox。
      final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
      _previousHeight = renderBox?.size.height;

      if (controller.hasClients) {
        _previousOffset = controller.offset;
      }

      // 2. 安排一個回調在佈局完成後執行。
      SchedulerBinding.instance.addPostFrameCallback((_) {
        // 再次獲取 controller，因為在 callback 執行時 context 可能已經變了（雖然機會微）
        // 但更重要的是要檢查 mounted
        if (!mounted) return;

        final activeController = _effectiveController;
        if (activeController == null || !activeController.hasClients) return;

        // 再次獲取新的 RenderBox（這是佈局更新後的狀態）
        final RenderBox? newRenderBox =
            context.findRenderObject() as RenderBox?;
        final double newHeight = newRenderBox?.size.height ?? 0;
        final double oldHeight = _previousHeight ?? 0;

        // 計算高度差（即內容增加了多少）
        final double diff = newHeight - oldHeight;

        // 我們只關心高度是否增加（因為插入了數據）。
        // 同時確保之前有記錄到滾動偏移量。
        //
        // ⚠️ 關鍵限制：
        // 此邏輯假設高度增加完全是因為在「頂部」插入了內容。
        // 如果內容是在底部插入，這裡的修正會導致錯誤的滾動跳轉。
        if (diff > 0 && _previousOffset != null) {
          final double targetOffset = _previousOffset! + diff;

          // 瞬間跳轉至新的偏移量，用於抵銷頂部內容增加造成的位移
          activeController.jumpTo(targetOffset);
        }
      });
    }

    return widget.child;
  }
}
