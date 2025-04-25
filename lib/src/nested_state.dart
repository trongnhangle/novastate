import 'dart:convert';

extension NestedStateExtension<T> on T {
  dynamic updateNestedField(String path, dynamic value) {
    if (path.isEmpty) return this;
    
    final parts = path.split('.');
    
    if (this is Map) {
      final Map<dynamic, dynamic> originalMap = this as Map<dynamic, dynamic>;
      final Map<dynamic, dynamic> map = Map<dynamic, dynamic>.from(originalMap);
      _updateMapNestedField(map, parts, value);
      return map;
    } else {
      try {
        final map = _convertToMap(this);
        _updateMapNestedField(map, parts, value);
        return _convertFromMap<T>(map);
      } catch (e) {
        throw ArgumentError(
          'Không thể cập nhật trường lồng nhau cho đối tượng kiểu ${this.runtimeType}. '
          'Chỉ hỗ trợ Map hoặc các đối tượng có thể chuyển đổi qua JSON.'
        );
      }
    }
  }
  
  dynamic getNestedField(String path) {
    if (path.isEmpty) return this;
    
    final parts = path.split('.');
    
    if (this is Map) {
      return _getValueFromMap(this as Map, parts);
    } else {
      try {
        final map = _convertToMap(this);
        return _getValueFromMap(map, parts);
      } catch (e) {
        throw ArgumentError(
          'Không thể truy cập trường lồng nhau cho đối tượng kiểu ${this.runtimeType}. '
          'Chỉ hỗ trợ Map hoặc các đối tượng có thể chuyển đổi qua JSON.'
        );
      }
    }
  }
  
  T updateNestedFields(Map<String, dynamic> updates) {
    dynamic result = this;
    
    for (final entry in updates.entries) {
      result = result.updateNestedField(entry.key, entry.value);
    }
    
    return result as T;
  }
  
  bool hasNestedField(String path) {
    try {
      getNestedField(path);
      return true;
    } catch (e) {
      return false;
    }
  }
}

void _updateMapNestedField(Map map, List<String> parts, dynamic value) {
  if (parts.length == 1) {
    map[parts[0]] = value;
    return;
  }
  
  final key = parts[0];
  final restParts = parts.sublist(1);
  
  if (!map.containsKey(key) || map[key] is! Map) {
    map[key] = <dynamic, dynamic>{};
  }
  
  if (map[key] is Map) {
    final childMap = Map<dynamic, dynamic>.from(map[key] as Map);
    map[key] = childMap;
    _updateMapNestedField(childMap, restParts, value);
  }
}

dynamic _getValueFromMap(Map map, List<String> parts) {
  if (parts.isEmpty) return map;
  
  final key = parts[0];
  
  if (!map.containsKey(key)) {
    throw ArgumentError('Không tìm thấy key "$key" trong đối tượng');
  }
  
  if (parts.length == 1) {
    return map[key];
  }
  
  if (map[key] is! Map) {
    throw ArgumentError('Giá trị tại "$key" không phải là Map');
  }
  
  return _getValueFromMap(map[key] as Map, parts.sublist(1));
}

Map<String, dynamic> _convertToMap(dynamic object) {
  final jsonString = jsonEncode(object);
  final decodedMap = jsonDecode(jsonString);
  
  if (decodedMap is Map) {
    return Map<String, dynamic>.from(decodedMap);
  }
  
  throw ArgumentError('Đối tượng không thể chuyển đổi thành Map<String, dynamic>');
}

T _convertFromMap<T>(Map<String, dynamic> map) {
  final jsonString = jsonEncode(map);
  return jsonDecode(jsonString) as T;
}
