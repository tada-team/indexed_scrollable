import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Расширенный [ScrollController] для управления [IndexedScrollable]
///
/// Добавляет метод [jumpToKey], который позволяет прыгнуть к нужному виджету по ключу
class IndexedScrollController extends ScrollController {
  final bool reversed;

  IndexedScrollController({this.reversed = false});

  @override
  ScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition oldPosition,
  ) {
    return IndexedScrollPosition(
      physics: physics,
      context: context,
      initialPixels: initialScrollOffset,
      keepScrollOffset: keepScrollOffset,
      oldPosition: oldPosition,
      debugLabel: debugLabel,
    );
  }

  /// Проиндексировать контент в [IndexedScrollable]
  Future<void> index() async {
    for (final position in List<IndexedScrollPosition>.from(positions)) {
      await position.index();
    }
  }

  /// Прыгнуть к нужному виджету по его ключу [value]
  void jumpToKey(String indexKey, {double offset = 0}) {
    for (final position in List<IndexedScrollPosition>.from(positions)) {
      position.jumpToKey(indexKey, offset, reversed);
    }
  }
}

/// Расширенный [ScrollPosition]
class IndexedScrollPosition extends ScrollPositionWithSingleContext {
  /// Содержит информацию о каждом объекте в [SliverList], необходимая для поиска позиции
  final List<_ChildSizeData> _data = [];

  /// Коллбек для выполнения индексации, устанавливается в [IndexedScrollable]
  Future<void> Function() indexCallback;

  IndexedScrollPosition({
    context,
    physics,
    initialPixels,
    keepScrollOffset,
    oldPosition,
    debugLabel,
  }) : super(
          context: context,
          physics: physics,
          initialPixels: initialPixels,
          keepScrollOffset: keepScrollOffset,
          oldPosition: oldPosition,
          debugLabel: debugLabel,
        );

  /// Проиндексировать контент в [IndexedScrollable]
  Future<void> index() {
    if (indexCallback != null) {
      return indexCallback();
    }
    return null;
  }

  /// Аналогично [jumpTo], только принимает ключ виджета, к которому хотим прыгнуть
  void jumpToKey(String indexKey, double offset, bool reversed) {
    goIdle();

    double totalOffset = 0;
    for (var item in _data) {
      if (item.key == Key(indexKey)) {
        if (reversed) {
          // totalOffset += item.size.height;
        }
        forcePixels(totalOffset - offset);
        break;
      }

      totalOffset += item.size.height;
    }

    didEndScroll();
  }

  void setChildSize(Key key, int childIndex, Size childSize) {
    _data.add(_ChildSizeData(key, childIndex, childSize));
  }
}

/// Информация о проиндексированных виджетах
class _ChildSizeData {
  final Key key;
  final int index;
  final Size size;

  _ChildSizeData(this.key, this.index, this.size);
}
