import 'dart:async';
import 'package:flutter/widgets.dart';
import 'provider.dart';
import 'store.dart';

class StateBuilder<T> extends StatefulWidget {
  final Widget Function(BuildContext context, T state) builder;
  final Store<T>? store;
  final StateChangedCallback<T>? onStateChanged;

  const StateBuilder({
    super.key,
    required this.builder,
    this.store,
    this.onStateChanged,
  });

  @override
  State<StateBuilder<T>> createState() => _StateBuilderState<T>();
}

class _StateBuilderState<T> extends State<StateBuilder<T>> {
  Store<T>? _store;
  late T _state;
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
  void didUpdateWidget(StateBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.store != oldWidget.store) {
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
    
    _state = _store!.state;
    
    if (widget.onStateChanged != null) {
      _store!.addStateChangedCallback(widget.onStateChanged!);
    }
    
    _subscription = _store!.stream.listen((newState) {
      if (mounted && !identical(_state, newState)) {
        setState(() => _state = newState);
      }
    });
  }

  void _disposeListener() {
    _subscription?.cancel();
    _subscription = null;
    
    if (widget.onStateChanged != null && _store != null) {
      _store!.removeStateChangedCallback(widget.onStateChanged!);
    }
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
      _state = store.state;
      _initStateListener();
      _isInitialized = true;
    }
    
    return widget.builder(context, _state);
  }
}

extension StreamSubscriptionExtension<T> on StreamSubscription<T>? {
  void cancel() {
    this?.cancel();
  }
}
