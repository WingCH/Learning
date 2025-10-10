import 'package:flutter/material.dart';
import '../managers/video_player_manager.dart';

/// 全局 PIP 控制器 - 管理跨頁面的 PIP 狀態
class GlobalPipController extends ChangeNotifier {
  VideoPlayerManager? _videoManager;
  bool _isViewA = true;
  bool _isPipVisible = false;
  Offset _pipPosition = const Offset(20, 100);

  VideoPlayerManager? get videoManager => _videoManager;
  bool get isViewA => _isViewA;
  bool get isPipVisible => _isPipVisible;
  Offset get pipPosition => _pipPosition;

  void initialize(VideoPlayerManager manager) {
    _videoManager = manager;
    _isPipVisible = true;
    notifyListeners();
  }

  void switchView() {
    _isViewA = !_isViewA;
    notifyListeners();
  }

  void updatePipPosition(Offset position) {
    _pipPosition = position;
    notifyListeners();
  }

  void showPip() {
    _isPipVisible = true;
    notifyListeners();
  }

  void hidePip() {
    _isPipVisible = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _videoManager?.dispose();
    super.dispose();
  }
}

