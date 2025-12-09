import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:trainer_backend/models/subscriptions/enums/period_unit.dart';

part 'introductory_price.g.dart';

/// Represents an introductory offer (free trial or discounted price).
///
/// This model contains details about introductory pricing for a subscription,
/// such as free trial periods or discounted introductory rates.
/// It abstracts the RevenueCat IntroductoryPrice type to avoid direct dependencies.
@CopyWith()
class IntroductoryPrice {
  /// Creates an instance of [IntroductoryPrice].
  const IntroductoryPrice({
    required this.price,
    required this.priceString,
    required this.period,
    required this.cycles,
    required this.periodUnit,
    required this.periodNumberOfUnits,
  });

  /// The price of the introductory offer (0.0 for free trials).
  final double price;

  /// The formatted price string (e.g., "Free", "0,00 €").
  final String priceString;

  /// The period of the introductory offer in ISO 8601 format (e.g., "P14D").
  final String period;

  /// The number of cycles for this introductory offer (usually 1).
  final int cycles;

  /// The unit of the billing period (day, week, month, year).
  final PeriodUnit periodUnit;

  /// The number of period units (e.g., 14 for 14 days).
  final int periodNumberOfUnits;

  /// Returns true if this is a free trial (price is 0).
  bool get isFreeTrial => price == 0;
}
