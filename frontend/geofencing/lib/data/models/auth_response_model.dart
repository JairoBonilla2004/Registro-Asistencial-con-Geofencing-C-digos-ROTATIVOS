import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/auth_response.dart';
import '../../domain/entities/user.dart';
import 'user_model.dart';

part 'auth_response_model.g.dart';

@JsonSerializable()
class AuthResponseModel extends AuthResponse {
  @JsonKey(name: 'user')
  final UserModel userModel;

  const AuthResponseModel({
    required super.token,
    required super.type,
    required this.userModel,
  }) : super(user: userModel);

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseModelToJson(this);

  AuthResponse toEntity() => AuthResponse(
        token: token,
        type: type,
        user: userModel.toEntity(),
      );
}
