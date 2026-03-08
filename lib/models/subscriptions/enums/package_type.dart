import 'package:json_annotation/json_annotation.dart';

/// Represents the type/period of a subscription package.
///
/// This enum maps to RevenueCat PackageType values and provides
/// a type-safe way to handle package types throughout the backend.
@JsonEnum()
enum PackageType {
  /// Monthly subscription package.
  monthly,

  /// Annual (yearly) subscription package.
  annual,

  /// Weekly subscription package.
  weekly,

  /// Six-month subscription package.
  sixMonth,

  /// Three-month subscription package.
  threeMonth,

  /// Two-month subscription package.
  twoMonth,

  /// Lifetime (one-time) purchase package.
  lifetime,

  /// Custom package type.
  custom,

  /// Unknown or unrecognized package type.
  unknown,
}
