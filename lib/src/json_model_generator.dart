/// Generates a Dart model class from a JSON object
/// modelType can be 'request' or 'response'
String generateModelFromJson(
  Map<String, dynamic> json,
  String className, {
  String modelType = 'response',
}) {
  // Check if this is a standard API response with status, message, data structure
  if (json.containsKey('status') &&
      json.containsKey('message') &&
      json.containsKey('data')) {
    // If data is an array, use the first item as the model
    if (json['data'] is List &&
        (json['data'] as List).isNotEmpty &&
        (json['data'] as List)[0] is Map<String, dynamic>) {
      return generateModelFromJson(
        (json['data'] as List)[0] as Map<String, dynamic>,
        className,
      );
    }
    // If data is an object, use it as the model
    else if (json['data'] is Map<String, dynamic>) {
      return generateModelFromJson(
        json['data'] as Map<String, dynamic>,
        className,
      );
    }
  }

  final buffer = StringBuffer();

  // Generate class declaration
  String suffix = modelType.toLowerCase() == 'request' ? 'Request' : 'Response';
  buffer.writeln('class ${className}$suffix {');

  // Generate fields
  json.forEach((key, value) {
    final fieldType = _getFieldType(value, modelType: modelType);
    final fieldName = _snakeToCamel(key);
    buffer.writeln('  $fieldType? $fieldName;');
  });

  buffer.writeln();

  // Generate constructor
  buffer.writeln('  ${className}$suffix({');
  json.forEach((key, value) {
    final fieldName = _snakeToCamel(key);
    buffer.writeln('    this.$fieldName,');
  });
  buffer.writeln('  });');

  buffer.writeln();

  // Generate fromJson method
  buffer.writeln(
    '  factory ${className}$suffix.fromJson(Map<String, dynamic> json) {',
  );
  buffer.writeln('    return ${className}$suffix(');
  json.forEach((key, value) {
    final fieldName = _snakeToCamel(key);
    if (value is Map<String, dynamic>) {
      buffer.writeln(
        '      $fieldName: json[\'$key\'] != null ? ${_getNestedClassName(key)}$suffix.fromJson(json[\'$key\']) : null,',
      );
    } else if (value is List && value.isNotEmpty && value[0] is Map) {
      buffer.writeln(
        '      $fieldName: json[\'$key\'] != null ? List<${_getNestedClassName(key)}$suffix>.from(json[\'$key\'].map((x) => ${_getNestedClassName(key)}$suffix.fromJson(x))) : null,',
      );
    } else {
      buffer.writeln('      $fieldName: json[\'$key\'],');
    }
  });
  buffer.writeln('    );');
  buffer.writeln('  }');

  buffer.writeln();

  // Generate toJson method
  buffer.writeln('  Map<String, dynamic> toJson() {');
  buffer.writeln('    final Map<String, dynamic> data = <String, dynamic>{};');
  json.forEach((key, value) {
    final fieldName = _snakeToCamel(key);
    if (value is Map<String, dynamic>) {
      buffer.writeln('    if ($fieldName != null) {');
      buffer.writeln('      data[\'$key\'] = $fieldName!.toJson();');
      buffer.writeln('    }');
    } else if (value is List && value.isNotEmpty && value[0] is Map) {
      buffer.writeln('    if ($fieldName != null) {');
      buffer.writeln(
        '      data[\'$key\'] = $fieldName!.map((x) => x.toJson()).toList();',
      );
      buffer.writeln('    }');
    } else {
      buffer.writeln('    data[\'$key\'] = $fieldName;');
    }
  });
  buffer.writeln('    return data;');
  buffer.writeln('  }');

  buffer.writeln('}');

  // Generate nested classes if needed
  json.forEach((key, value) {
    if (value is Map<String, dynamic>) {
      buffer.writeln();
      buffer.writeln(
        generateModelFromJson(
          value,
          _getNestedClassName(key),
          modelType: modelType,
        ),
      );
    } else if (value is List && value.isNotEmpty && value[0] is Map) {
      buffer.writeln();
      buffer.writeln(
        generateModelFromJson(
          value[0],
          _getNestedClassName(key),
          modelType: modelType,
        ),
      );
    }
  });

  return buffer.toString();
}

/// Entity content with import path and class definition
class EntityContent {
  final String import;
  final String classDefinition;
  final String modelType;

  EntityContent(
    this.import,
    this.classDefinition, {
    this.modelType = 'response',
  });
}

/// Generates an entity class from a model
EntityContent generateEntityFromModel(
  String featureName,
  String className,
  Map<String, dynamic> json,
  String importPath, {
  String modelType = 'response',
}) {
  // Check if this is a standard API response with status, message, data structure
  if (json.containsKey('status') &&
      json.containsKey('message') &&
      json.containsKey('data')) {
    // If data is an array, use the first item as the model
    if (json['data'] is List &&
        (json['data'] as List).isNotEmpty &&
        (json['data'] as List)[0] is Map<String, dynamic>) {
      return generateEntityFromModel(
        featureName,
        className,
        (json['data'] as List)[0] as Map<String, dynamic>,
        importPath,
        modelType: modelType,
      );
    }
    // If data is an object, use it as the model
    else if (json['data'] is Map<String, dynamic>) {
      return generateEntityFromModel(
        featureName,
        className,
        json['data'] as Map<String, dynamic>,
        importPath,
        modelType: modelType,
      );
    }
  }

  final buffer = StringBuffer();

  // Generate class declaration
  buffer.writeln('class ${featureName}Entity {');

  // Generate fields
  json.forEach((key, value) {
    final fieldType = _getFieldType(value, modelType: modelType);
    final fieldName = _snakeToCamel(key);
    buffer.writeln('  $fieldType? $fieldName;');
  });

  buffer.writeln();

  // Generate constructor
  buffer.writeln('  ${featureName}Entity({');
  json.forEach((key, value) {
    final fieldName = _snakeToCamel(key);
    buffer.writeln('    this.$fieldName,');
  });
  buffer.writeln('  });');

  buffer.writeln();

  // Generate fromResponse factory
  buffer.writeln('  factory ${featureName}Entity.fromResponse(');
  buffer.writeln('      ${className}Response response) {');
  buffer.writeln('    return ${featureName}Entity(');
  json.forEach((key, value) {
    final fieldName = _snakeToCamel(key);
    buffer.writeln('      $fieldName: response.$fieldName,');
  });
  buffer.writeln('    );');
  buffer.writeln('  }');

  buffer.writeln('}');

  return EntityContent(importPath, buffer.toString(), modelType: modelType);
}

/// Gets the Dart type for a JSON value
String _getFieldType(dynamic value, {String modelType = 'response'}) {
  if (value == null) return 'dynamic';
  if (value is String) return 'String';
  if (value is int) return 'int';
  if (value is double) return 'double';
  if (value is bool) return 'bool';
  if (value is Map)
    return '${_getNestedClassName(value.keys.first)}${modelType.toLowerCase() == 'request' ? 'Request' : 'Response'}';
  if (value is List) {
    if (value.isEmpty) return 'List<dynamic>';
    if (value[0] is Map)
      return 'List<${_getNestedClassName(value[0].keys.first)}${modelType.toLowerCase() == 'request' ? 'Request' : 'Response'}>';
    if (value[0] is String) return 'List<String>';
    if (value[0] is int) return 'List<int>';
    if (value[0] is double) return 'List<double>';
    if (value[0] is bool) return 'List<bool>';
    return 'List<dynamic>';
  }
  return 'dynamic';
}

/// Converts a field name to a class name (e.g. "user_data" -> "UserData")
String _getNestedClassName(String fieldName) {
  return fieldName
      .split('_')
      .map(
        (word) =>
            word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '',
      )
      .join('');
}

/// Converts a field name from snake_case to camelCase (e.g. "user_data" -> "userData")
String _snakeToCamel(String fieldName) {
  if (!fieldName.contains('_')) return fieldName;

  final parts = fieldName.split('_');
  final camelCase = StringBuffer(parts[0]);

  for (var i = 1; i < parts.length; i++) {
    if (parts[i].isNotEmpty) {
      camelCase.write(parts[i][0].toUpperCase() + parts[i].substring(1));
    }
  }

  return camelCase.toString();
}
