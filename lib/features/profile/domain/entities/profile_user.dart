import 'package:recipe_app/features/auth/domain/entities/app_user.dart';

class ProfileUser extends AppUser {
  final String profileImageUrl;
  final String bio;

  ProfileUser({
    required super.uid,
    required super.email,
    required super.name,
    required this.profileImageUrl,
    required this.bio,
  });

  ProfileUser copyWith({String? newProfileImageUrl, String? newBio}) {
    return ProfileUser(
      uid: uid,
      email: email,
      name: name,
      profileImageUrl: newProfileImageUrl ?? profileImageUrl,
      bio: newBio ?? bio,
    );
  }

  Map<String, dynamic> tojson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
    };
  }

  factory ProfileUser.fromJson(Map<String, dynamic> json) {
    return ProfileUser(
      uid: json['uid'],
      email: json['email'],
      name: json['name'],
      profileImageUrl: json['profileImageUrl'] ?? '',
      bio: json['bio'] ?? '',
    );
  }
}
