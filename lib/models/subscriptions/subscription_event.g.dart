// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_event.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SubscriptionEventCWProxy {
  SubscriptionEvent id(String id);

  SubscriptionEvent subscriptionId(String? subscriptionId);

  SubscriptionEvent userId(String userId);

  SubscriptionEvent eventType(String eventType);

  SubscriptionEvent vendorEventId(String? vendorEventId);

  SubscriptionEvent eventTime(DateTime eventTime);

  SubscriptionEvent eventPayload(Map<String, dynamic> eventPayload);

  SubscriptionEvent createdAt(DateTime createdAt);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `SubscriptionEvent(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// SubscriptionEvent(...).copyWith(id: 12, name: "My name")
  /// ```
  SubscriptionEvent call({
    String id,
    String? subscriptionId,
    String userId,
    String eventType,
    String? vendorEventId,
    DateTime eventTime,
    Map<String, dynamic> eventPayload,
    DateTime createdAt,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfSubscriptionEvent.copyWith(...)` or call `instanceOfSubscriptionEvent.copyWith.fieldName(value)` for a single field.
class _$SubscriptionEventCWProxyImpl implements _$SubscriptionEventCWProxy {
  const _$SubscriptionEventCWProxyImpl(this._value);

  final SubscriptionEvent _value;

  @override
  SubscriptionEvent id(String id) => call(id: id);

  @override
  SubscriptionEvent subscriptionId(String? subscriptionId) =>
      call(subscriptionId: subscriptionId);

  @override
  SubscriptionEvent userId(String userId) => call(userId: userId);

  @override
  SubscriptionEvent eventType(String eventType) => call(eventType: eventType);

  @override
  SubscriptionEvent vendorEventId(String? vendorEventId) =>
      call(vendorEventId: vendorEventId);

  @override
  SubscriptionEvent eventTime(DateTime eventTime) => call(eventTime: eventTime);

  @override
  SubscriptionEvent eventPayload(Map<String, dynamic> eventPayload) =>
      call(eventPayload: eventPayload);

  @override
  SubscriptionEvent createdAt(DateTime createdAt) => call(createdAt: createdAt);

  @override

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `SubscriptionEvent(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// SubscriptionEvent(...).copyWith(id: 12, name: "My name")
  /// ```
  SubscriptionEvent call({
    Object? id = const $CopyWithPlaceholder(),
    Object? subscriptionId = const $CopyWithPlaceholder(),
    Object? userId = const $CopyWithPlaceholder(),
    Object? eventType = const $CopyWithPlaceholder(),
    Object? vendorEventId = const $CopyWithPlaceholder(),
    Object? eventTime = const $CopyWithPlaceholder(),
    Object? eventPayload = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
  }) {
    return SubscriptionEvent(
      id: id == const $CopyWithPlaceholder() || id == null
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      subscriptionId: subscriptionId == const $CopyWithPlaceholder()
          ? _value.subscriptionId
          // ignore: cast_nullable_to_non_nullable
          : subscriptionId as String?,
      userId: userId == const $CopyWithPlaceholder() || userId == null
          ? _value.userId
          // ignore: cast_nullable_to_non_nullable
          : userId as String,
      eventType: eventType == const $CopyWithPlaceholder() || eventType == null
          ? _value.eventType
          // ignore: cast_nullable_to_non_nullable
          : eventType as String,
      vendorEventId: vendorEventId == const $CopyWithPlaceholder()
          ? _value.vendorEventId
          // ignore: cast_nullable_to_non_nullable
          : vendorEventId as String?,
      eventTime: eventTime == const $CopyWithPlaceholder() || eventTime == null
          ? _value.eventTime
          // ignore: cast_nullable_to_non_nullable
          : eventTime as DateTime,
      eventPayload:
          eventPayload == const $CopyWithPlaceholder() || eventPayload == null
              ? _value.eventPayload
              // ignore: cast_nullable_to_non_nullable
              : eventPayload as Map<String, dynamic>,
      createdAt: createdAt == const $CopyWithPlaceholder() || createdAt == null
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
    );
  }
}

extension $SubscriptionEventCopyWith on SubscriptionEvent {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfSubscriptionEvent.copyWith(...)` or `instanceOfSubscriptionEvent.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SubscriptionEventCWProxy get copyWith =>
      _$SubscriptionEventCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionEvent _$SubscriptionEventFromJson(Map<String, dynamic> json) =>
    SubscriptionEvent(
      id: json['id'] as String,
      subscriptionId: json['subscription_id'] as String?,
      userId: json['user_id'] as String,
      eventType: json['event_type'] as String,
      vendorEventId: json['vendor_event_id'] as String?,
      eventTime: DateTime.parse(json['event_time'] as String),
      eventPayload: json['event_payload'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$SubscriptionEventToJson(SubscriptionEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'subscription_id': instance.subscriptionId,
      'user_id': instance.userId,
      'event_type': instance.eventType,
      'vendor_event_id': instance.vendorEventId,
      'event_time': instance.eventTime.toIso8601String(),
      'event_payload': instance.eventPayload,
      'created_at': instance.createdAt.toIso8601String(),
    };
