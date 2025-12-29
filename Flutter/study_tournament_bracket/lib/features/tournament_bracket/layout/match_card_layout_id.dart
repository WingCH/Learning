/// 比賽卡片的 LayoutId 識別類
library;

/// 用於 CustomMultiChildLayout 的 LayoutId
///
/// 唯一標識每個比賽卡片的位置
class MatchCardLayoutId {
  /// 輪次索引 (0 = 第一輪)
  final int roundIndex;

  /// 該輪次內的比賽索引
  final int matchIndex;

  const MatchCardLayoutId({required this.roundIndex, required this.matchIndex});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MatchCardLayoutId &&
        other.roundIndex == roundIndex &&
        other.matchIndex == matchIndex;
  }

  @override
  int get hashCode => roundIndex.hashCode ^ matchIndex.hashCode;

  @override
  String toString() =>
      'MatchCardLayoutId(round: $roundIndex, match: $matchIndex)';
}
