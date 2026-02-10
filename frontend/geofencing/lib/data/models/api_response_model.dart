import 'package:json_annotation/json_annotation.dart';

part 'api_response_model.g.dart';

/// Modelo genérico para todas las respuestas de la API
@JsonSerializable(genericArgumentFactories: true)
class ApiResponseModel<T> {
  final bool success;
  final String? message;
  final T? data;
  final String? errorCode;
  final DateTime? timestamp;

  const ApiResponseModel({
    required this.success,
    this.message,
    this.data,
    this.errorCode,
    this.timestamp,
  });

  factory ApiResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ApiResponseModelFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$ApiResponseModelToJson(this, toJsonT);
}
