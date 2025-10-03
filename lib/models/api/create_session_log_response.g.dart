// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_session_log_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateSessionLogResponse _$CreateSessionLogResponseFromJson(
        Map<String, dynamic> json) =>
    CreateSessionLogResponse(
      sessionLog:
          SessionLog.fromJson(json['session_log'] as Map<String, dynamic>),
      updatedSessionPreview: Session.fromJson(
          json['updated_session_preview'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CreateSessionLogResponseToJson(
        CreateSessionLogResponse instance) =>
    <String, dynamic>{
      'session_log': instance.sessionLog.toJson(),
      'updated_session_preview': instance.updatedSessionPreview.toJson(),
    };
