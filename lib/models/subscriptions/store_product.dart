import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:trainer_backend/models/subscriptions/introductory_price.dart';

part 'store_product.g.dart';

/// Represents a product from the app store (App Store, Play Store, etc.).
///
/// This model contains product information such as price, title, and description.
/// It abstracts the RevenueCat StoreProduct type to avoid direct dependencies.
@CopyWith()
class StoreProduct {
  /// Creates an instance of [StoreProduct].
  const StoreProduct({
    required this.identifier,
    required this.title,
    required this.description,
    required this.price,
    required this.priceString,
    required this.currencyCode,
    this.introductoryPrice,
  });

  /// The product identifier from the store.
  final String identifier;

  /// The display title of the product.
  final String title;

  /// The description of the product.
  final String description;

  /// The price of the product as a number.
  final double price;

  /// The formatted price string (e.g., "$9.99").
  final String priceString;

  /// The currency code (e.g., "USD", "EUR").
  final String currencyCode;

  /// Information about the introductory offer (free trial or discounted price).
  ///
  /// This field is null if no introductory offer is available for this product.
  /// Note: RevenueCat Test Store does NOT support introductory offers, so this
  /// will always be null when using the Test Store.
  final IntroductoryPrice? introductoryPrice;
}
