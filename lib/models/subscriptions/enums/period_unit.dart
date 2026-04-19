/// Represents the unit of a subscription period.
///
/// This enum maps to RevenueCat PeriodUnit values for handling
/// introductory offer periods.
enum PeriodUnit {
  /// Day period unit.
  day,

  /// Week period unit.
  week,

  /// Month period unit.
  month,

  /// Year period unit.
  year,

  /// Unknown or unrecognized period unit.
  unknown,
}
