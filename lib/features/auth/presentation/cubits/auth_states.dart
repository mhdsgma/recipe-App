import 'package:recipe_app/features/auth/domain/entities/app_user.dart';

abstract class AuthSate {}

class AuthInitial extends AuthSate {}

class AuthLoading extends AuthSate {}

class Authenticated extends AuthSate {
  final AppUser user;
  Authenticated(this.user);
}

class Unauthenticated extends AuthSate {}

class AuthError extends AuthSate {
  final String message;
  AuthError(this.message);
}
