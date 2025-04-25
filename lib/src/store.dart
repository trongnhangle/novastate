import 'dart:async';
import 'package:flutter/foundation.dart';

typedef StateInitializer<T> = T Function();

typedef StateChangedCallback<T> = void Function(
    T previousState, T currentState);

extension MapExtension<K, V> on Map<K, V> {
  Map<K, V> copyWith(Map<K, V> updates) {
    return {...this, ...updates};
  }
}

class Store<T> {
  T _state;

  final _streamController = StreamController<T>.broadcast();

  final List<StateChangedCallback<T>> _onStateChangedCallbacks = [];

  T get state => _state;

  Stream<T> get stream => _streamController.stream;

  Store(T initialState) : _state = initialState {
    _streamController.add(_state);
  }

  Store.builder(StateInitializer<T> builder) : _state = builder() {
    _streamController.add(_state);
  }

  void update(T Function(T currentState) callback) {
    final oldState = _state;
    final newState = callback(_state);

    if (!_equals(oldState, newState)) {
      _state = newState;
      _notifyListeners();
    }
  }

  set state(T newState) {
    if (!_equals(_state, newState)) {
      final oldState = _state;
      _state = newState;
      _notifyListeners();

      for (var callback in _onStateChangedCallbacks) {
        callback(oldState, _state);
      }
    }
  }

  Future<void> updateAsync(Future<T> Function(T currentState) callback) async {
    try {
      final newState = await callback(_state);
      if (!_equals(_state, newState)) {
        final oldState = _state;
        _state = newState;
        _notifyListeners();

        for (var callback in _onStateChangedCallbacks) {
          callback(oldState, _state);
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  void addStateChangedCallback(StateChangedCallback<T> callback) {
    _onStateChangedCallbacks.add(callback);
  }

  void removeStateChangedCallback(StateChangedCallback<T> callback) {
    _onStateChangedCallbacks.remove(callback);
  }

  void _notifyListeners() {
    if (!_streamController.isClosed) {
      _streamController.add(_state);
    }
  }

  bool _equals(T a, T b) {
    if (a is List && b is List) {
      return listEquals(a as List?, b as List?);
    } else if (a is Map && b is Map) {
      return mapEquals(a as Map?, b as Map?);
    } else if (a is Set && b is Set) {
      return setEquals(a as Set?, b as Set?);
    }
    return a == b;
  }

  void dispose() {
    _streamController.close();
    _onStateChangedCallbacks.clear();
  }
}
