// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_api_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionApiResponse _$SessionApiResponseFromJson(Map<String, dynamic> json) =>
    SessionApiResponse(
      programId: (json['program_id'] as num).toInt(),
      session: Session.fromJson(json['session'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SessionApiResponseToJson(SessionApiResponse instance) =>
    <String, dynamic>{
      'program_id': instance.programId,
      'session': instance.session.toJson(),
    };
