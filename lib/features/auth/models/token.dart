import 'package:equatable/equatable.dart';

class Token extends Equatable {
  const Token({
    required this.tokenType,
    required this.accessToken,
    required this.expiresIn,
    required this.expiresAt,
  });

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      tokenType: json['token_type'] as String,
      accessToken: json['access_token'] as String,
      expiresIn: json['expires_in'] as int,
      expiresAt: json['expires_at'] as String,
    );
  }

  final String tokenType;
  final String accessToken;
  final int expiresIn;
  final String expiresAt;

  Map<String, dynamic> toJson() {
    return {
      'token_type': tokenType,
      'access_token': accessToken,
      'expires_in': expiresIn,
      'expires_at': expiresAt,
    };
  }

  @override
  List<Object?> get props => [tokenType, accessToken, expiresIn, expiresAt];
}
