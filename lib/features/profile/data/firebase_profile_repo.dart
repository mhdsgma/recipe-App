import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_app/features/profile/data/OfflineProfileRepo.dart';
import 'package:recipe_app/features/profile/domain/entities/profile_user.dart';
import 'package:recipe_app/features/profile/domain/repos/profile_repo.dart';

class FirebaseProfileRepo implements ProfileRepo {
  @override
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final offlineRepo = OfflineProfileRepo();

  @override
  Future<ProfileUser?> fetchUserProfile(String uid) async {
    try {
      final userDoc =
          await firebaseFirestore.collection('users').doc(uid).get();

      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data()!;
        final user = ProfileUser(
          uid: uid,
          email: data['email'],
          name: data['name'],
          bio: data['bio'] ?? '',
          profileImageUrl: data['profileImageUrl'] ?? '',
        );

        await offlineRepo.saveUser(user);
        return user;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateProfile(ProfileUser updatedProfile) async {
    try {
      await firebaseFirestore
          .collection('users')
          .doc(updatedProfile.uid)
          .update({
            'bio': updatedProfile.bio,
            'profileImageUrl': updatedProfile.profileImageUrl,
          });

      await offlineRepo.saveUser(updatedProfile);
    } catch (e) {
      throw Exception(e);
    }
  }
}
