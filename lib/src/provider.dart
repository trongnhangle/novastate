import 'package:flutter/widgets.dart';
import 'store.dart';

class StateProvider<T> extends InheritedWidget {
  final Store<T> store;

  const StateProvider({
    super.key,
    required this.store,
    required super.child,
  });

  static StateProvider<T> of<T>(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<StateProvider<T>>();
    assert(provider != null, 'Không tìm thấy StateProvider<$T> trong cây widget');
    return provider!;
  }

  static StateProvider<T>? maybeOf<T>(BuildContext context) {
    return context.getInheritedWidgetOfExactType<StateProvider<T>>();
  }

  static Store<T> storeOf<T>(BuildContext context) {
    return of<T>(context).store;
  }

  static T stateOf<T>(BuildContext context) {
    return of<T>(context).store.state;
  }

  static T readState<T>(BuildContext context) {
    final provider = context.getInheritedWidgetOfExactType<StateProvider<T>>();
    assert(provider != null, 'Không tìm thấy StateProvider<$T> trong cây widget');
    return provider!.store.state;
  }

  static void updateState<T>(BuildContext context, T Function(T currentState) callback) {
    final store = storeOf<T>(context);
    store.update(callback);
  }

  static Future<void> updateStateAsync<T>(
      BuildContext context, Future<T> Function(T currentState) callback) {
    final store = storeOf<T>(context);
    return store.updateAsync(callback);
  }

  static Stream<T> streamOf<T>(BuildContext context) {
    return of<T>(context).store.stream;
  }

  @override
  bool updateShouldNotify(StateProvider<T> oldWidget) {
    return store != oldWidget.store;
  }
}
