import 'package:json_schema/json_schema.dart';

/// The result of validating data against a schema
class ValidationResults {
  ValidationResults(List<ValidationError> errors, List<ValidationError> warnings)
      : errors = List.of(errors),
        warnings = List.of(warnings);

  /// Correctness issues discovered by validation.
  final List<ValidationError> errors;

  /// Possible issues discovered by validation.
  final List<ValidationError> warnings;

  @override
  String toString() {
    return '${errors.isEmpty ? 'VALID' : 'INVALID'}${errors.isNotEmpty ? ', Errors: $errors' : ''}${warnings.isNotEmpty ? ', Warnings: $warnings' : ''}';
  }

  /// Whether the [Instance] was valid against its [JsonSchema]
  bool get isValid => errors.isEmpty;
}
