import 'package:equatable/equatable.dart';

abstract class CompatibilityResult extends Equatable {
  final String apiVersion;
  final String appVersion;

  @override
  List<Object?> get props => [apiVersion, appVersion];

  CompatibilityResult(this.apiVersion, this.appVersion);
}

class IncompatibleVersion extends CompatibilityResult {
  IncompatibleVersion(String apiVersion, String appVersion)
      : super(apiVersion, appVersion);

  @override
  String toString() =>
      'IncompatibleVersion(apiVersion: $apiVersion, appVersion: $appVersion)';
}

class CompatibleVersion extends CompatibilityResult {
  CompatibleVersion(String apiVersion, String appVersion)
      : super(apiVersion, appVersion);

  @override
  String toString() =>
      'CompatibleVersion(apiVersion: $apiVersion, appVersion: $appVersion)';
}
