// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      provider: json['provider'] as String,
      roles: (json['roles'] as List<dynamic>).map((e) => e as String).toList(),
      enabled: json['enabled'] as bool,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'fullName': instance.fullName,
      'provider': instance.provider,
      'roles': instance.roles,
      'enabled': instance.enabled,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
