import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;
import 'dart:developer' as developer;

// 用於追蹤日誌序號的全局變量
int _logCounter = 0;

// 日誌輔助函數
void _log(String message) {
  developer.log('[${_logCounter++}] $message');
}

// 1. 定義 ParentData 類別，繼承 ContainerBoxParentData 以取得 offset 和鏈表功能
class MyStackParentData extends ContainerBoxParentData<RenderBox> {
  double? left;
  double? top;
}

// 2. 定義 ParentDataWidget，用於在 Widget 樹中給子 widget 設定偏移值
class MyPositioned extends ParentDataWidget<MyStackParentData> {
  final double? left;
  final double? top;
  const MyPositioned({this.left, this.top, required super.child, super.key});

  @override
  void applyParentData(RenderObject renderObject) {
    _log('MyPositioned.applyParentData: 開始設置 parent data');
    final MyStackParentData parentData =
        renderObject.parentData as MyStackParentData;
    bool needsLayout = false;
    // 將新值寫入 parentData，檢查是否需要重新布局
    if (parentData.left != left || parentData.top != top) {
      _log('MyPositioned.applyParentData: 更新位置 - left: $left, top: $top');
      parentData.left = left;
      parentData.top = top;
      needsLayout = true;
    }
    if (needsLayout) {
      // 通知父 RenderObject 重新布局
      final RenderObject? parentRenderObject = renderObject.parent;
      if (parentRenderObject is RenderObject) {
        _log('MyPositioned.applyParentData: 標記父物件需要重新布局');
        parentRenderObject.markNeedsLayout();
      }
    }
    _log('MyPositioned.applyParentData: 完成');
  }

  @override
  Type get debugTypicalAncestorWidgetClass => MyStack;
}

// 3. 定義自訂的多子 RenderObject Widget，對應的 RenderObject 為 RenderMyStack
class MyStack extends MultiChildRenderObjectWidget {
  const MyStack({super.key, required super.children});

  @override
  RenderMyStack createRenderObject(BuildContext context) {
    _log('MyStack.createRenderObject: 創建 RenderMyStack');
    return RenderMyStack();
  }

  @override
  void updateRenderObject(BuildContext context, RenderMyStack renderObject) {
    _log('MyStack.updateRenderObject: 更新 RenderMyStack');
    super.updateRenderObject(context, renderObject);
  }
}

// 4. 定義 RenderObject 實作，自訂布局和繪製邏輯
class RenderMyStack extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, MyStackParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, MyStackParentData> {
  @override
  void attach(PipelineOwner owner) {
    _log('RenderMyStack.attach: 附加到渲染管線');
    super.attach(owner);
  }

  @override
  void detach() {
    _log('RenderMyStack.detach: 從渲染管線分離');
    super.detach();
  }

  @override
  void setupParentData(RenderObject child) {
    _log('RenderMyStack.setupParentData: 設置子元素的 ParentData');
    // 確保每個子節點都有 MyStackParentData
    if (child.parentData is! MyStackParentData) {
      child.parentData = MyStackParentData();
      _log('RenderMyStack.setupParentData: 為子元素創建新的 MyStackParentData');
    }
  }

  @override
  void performLayout() {
    _log('RenderMyStack.performLayout: 開始計算佈局');
    // 根據子元素位置計算所需的最大寬高
    double maxWidth = 0;
    double maxHeight = 0;
    RenderBox? child = firstChild;
    int childIndex = 0;

    while (child != null) {
      final MyStackParentData childParentData =
          child.parentData as MyStackParentData;
      // 讓子元素在不約束寬高（loosen）的條件下自我布局
      _log('RenderMyStack.performLayout: 佈局子元素 #$childIndex');
      child.layout(constraints.loosen(), parentUsesSize: true);
      _log('RenderMyStack.performLayout: 子元素 #$childIndex 大小: ${child.size}');

      // 取得偏移參數，默認為 (0,0)（未指定則放在左上角）
      final double dx = childParentData.left ?? 0.0;
      final double dy = childParentData.top ?? 0.0;
      _log('RenderMyStack.performLayout: 子元素 #$childIndex 位置: ($dx, $dy)');

      // 將計算出的偏移存入 parentData.offset，供繪製使用
      childParentData.offset = Offset(dx, dy);

      // 更新容器所需的寬高：確保包含所有子元素範圍
      maxWidth = math.max(maxWidth, dx + child.size.width);
      maxHeight = math.max(maxHeight, dy + child.size.height);

      // 移動到下一個子節點
      child = childParentData.nextSibling;
      childIndex++;
    }

    // 設定自身尺寸，考慮父 constraints 的限制
    size = constraints.constrain(Size(maxWidth, maxHeight));
    _log('RenderMyStack.performLayout: 最終大小: $size，子元素總數: $childIndex');
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _log('RenderMyStack.paint: 開始繪製，偏移: $offset');
    // 繪製每個子節點於對應的偏移位置
    RenderBox? child = firstChild;
    int childIndex = 0;

    while (child != null) {
      final MyStackParentData childParentData =
          child.parentData as MyStackParentData;
      final Offset childOffset = offset + childParentData.offset;
      _log('RenderMyStack.paint: 繪製子元素 #$childIndex，偏移: $childOffset');
      context.paintChild(child, childOffset);

      child = childParentData.nextSibling;
      childIndex++;
    }
    _log('RenderMyStack.paint: 繪製完成，總共繪製了 $childIndex 個子元素');
  }

  @override
  void markNeedsLayout() {
    _log('RenderMyStack.markNeedsLayout: 標記需要重新佈局');
    super.markNeedsLayout();
  }

  @override
  void markNeedsPaint() {
    _log('RenderMyStack.markNeedsPaint: 標記需要重新繪製');
    super.markNeedsPaint();
  }
}

void main() {
  _log('應用啟動');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    _log('MyApp.build: 構建 MyApp');
    return MaterialApp(
      title: 'Custom Stack Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    _log('MyHomePage.build: 構建 MyHomePage');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Stack Example'),
      ),
      body: Center(
        child: Container(
          width: 300,
          height: 300,
          color: Colors.grey,
          child: MyStack(
            children: [
              MyPositioned(
                left: 0,
                top: 0,
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.red,
                  child: const Center(
                    child: Text(
                      'Red Box',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              MyPositioned(
                left: 150,
                top: 50,
                child: Container(
                  width: 80,
                  height: 80,
                  color: Colors.green,
                  child: const Center(
                    child: Text(
                      'Green Box',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              MyPositioned(
                left: 80,
                top: 180,
                child: Container(
                  width: 120,
                  height: 60,
                  color: Colors.blue,
                  child: const Center(
                    child: Text(
                      'Blue Box',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
