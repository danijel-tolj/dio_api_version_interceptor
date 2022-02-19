import 'package:equatable/equatable.dart';

class Results {
  static const compatible = 'compatible';
  static const warning = 'warning';
  static const incompatible = 'incompatible';
}

abstract class CompatibilityApiResult extends Equatable {
  final String status;

  CompatibilityApiResult(this.status);

  @override
  List<Object?> get props => [status];
}

class WarningAPIResult extends CompatibleAPIResult {
  final String reason;

  WarningAPIResult(String status, this.reason) : super(status);

  factory WarningAPIResult.fromJson(Map<String, dynamic> map) {
    return WarningAPIResult(
      map['status'],
      map['reason'],
    );
  }

  @override
  List<Object?> get props => [status];

  @override
  String toString() => 'WarningApiResult(status: $status), reason: $reason';
}

class CompatibleAPIResult extends CompatibilityApiResult {
  CompatibleAPIResult(String status) : super(status);

  factory CompatibleAPIResult.fromJson(Map<String, dynamic> map) {
    return CompatibleAPIResult(
      map['status'],
    );
  }

  @override
  List<Object?> get props => [status];

  @override
  String toString() => 'CompatibleAPIResult(status: $status)';
}

class IncompatibleAPIResult extends CompatibilityApiResult
    implements Equatable {
  final String reason;

  IncompatibleAPIResult(String status, this.reason) : super(status);

  factory IncompatibleAPIResult.fromJson(Map<String, dynamic> map) {
    return IncompatibleAPIResult(
      map['status'],
      map['reason'],
    );
  }

  @override
  List<Object?> get props => [status, reason];

  @override
  String toString() =>
      'IncompatibleAPIResult(status: $status, reason: $reason)';
}
