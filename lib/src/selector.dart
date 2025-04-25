import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'provider.dart';
import 'store.dart';

class StateSelector<T, S> extends StatefulWidget {
  final Widget Function(BuildContext context, S selectedValue) builder;
  final S Function(T state) selector;
  final bool Function(S previous, S current)? equals;
  final Store<T>? store;

  const StateSelector({
    super.key,
    required this.builder,
    required this.selector,
    this.equals,
    this.store,
  });

  @override
  State<StateSelector<T, S>> createState() => _StateSelectorState<T, S>();
}

class _StateSelectorState<T, S> extends State<StateSelector<T, S>> {
  Store<T>? _store;
  late S _selectedValue;
  StreamSubscription<T>? _subscription;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final store = widget.store ?? StateProvider.storeOf<T>(context);
    if (_store != store || !_isInitialized) {
      _disposeListener();
      _store = store;
      _initStateListener();
      _isInitialized = true;
    }
  }

  @override
  void didUpdateWidget(StateSelector<T, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.store != oldWidget.store || widget.selector != oldWidget.selector) {
      final store = widget.store ?? (_isInitialized ? _store : StateProvider.storeOf<T>(context));
      if (_store != store) {
        _disposeListener();
        _store = store;
        _initStateListener();
      }
    }
  }

  void _initStateListener() {
    if (_store == null) return;
    _selectedValue = widget.selector(_store!.state);
    _subscription = _store!.stream.listen((newState) {
      final newSelectedValue = widget.selector(newState);
      if (!_areEqual(_selectedValue, newSelectedValue)) {
        if (mounted) {
          setState(() => _selectedValue = newSelectedValue);
        }
      }
    });
  }

  bool _areEqual(S a, S b) {
    if (widget.equals != null) {
      return widget.equals!(a, b);
    }
    if (a is List && b is List) {
      return listEquals(a as List?, b as List?);
    } else if (a is Map && b is Map) {
      return mapEquals(a as Map?, b as Map?);
    } else if (a is Set && b is Set) {
      return setEquals(a as Set?, b as Set?);
    }
    return a == b;
  }

  void _disposeListener() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  void dispose() {
    _disposeListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized && widget.store == null) {
      final store = StateProvider.storeOf<T>(context);
      _store = store;
      _selectedValue = widget.selector(store.state);
      _initStateListener();
      _isInitialized = true;
    }
    return widget.builder(context, _selectedValue);
  }
}
