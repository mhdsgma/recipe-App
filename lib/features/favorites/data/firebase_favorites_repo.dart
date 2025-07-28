import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:recipe_app/features/favorites/domain/repos/favorites_repo.dart';


class FirebaseFavoritesRepo implements FavoritesRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId {
    final user = _auth.currentUser;
    print("--- FirebaseFavoritesRepo: Getting user ID. Current user: ${user?.uid ?? 'null'} ---");
    return user?.uid;
  }

  DocumentReference? get _userDocRef {
    final userId = _userId;
    if (userId == null) {
      if (kDebugMode) {
        print("--- FirebaseFavoritesRepo: User ID is null, cannot get user doc ref. ---");
      }
      return null;
    }
    if (kDebugMode) {
      print("--- FirebaseFavoritesRepo: Getting user doc ref for user ID: $userId ---");
    }
    return _firestore.collection('users').doc(userId);
  }

  @override
  Future<void> addFavorite(String recipeId) async {
    final userDocRef = _userDocRef;
    if (userDocRef == null) {
      print("--- FirebaseFavoritesRepo: addFavorite failed - User not logged in.");
      throw Exception("User not logged in");
    }
    if (kDebugMode) {
      print("--- FirebaseFavoritesRepo: Attempting to add favorite $recipeId for user ${userDocRef.id} ---");
    }
    try {
      await userDocRef.update({
        'favorites': FieldValue.arrayUnion([recipeId])
      });
      if (kDebugMode) {
        print("--- FirebaseFavoritesRepo: Successfully added favorite $recipeId ---");
      }
    } catch (e) {
      if (kDebugMode) {
        print("!!! FirebaseFavoritesRepo: ERROR adding favorite $recipeId: $e !!!");
      }
      rethrow; // Rethrow the error
    }
  }

  @override
  Future<void> removeFavorite(String recipeId) async {
    final userDocRef = _userDocRef;
    if (userDocRef == null) {
      if (kDebugMode) {
        print("--- FirebaseFavoritesRepo: removeFavorite failed - User not logged in.");
      }
      throw Exception("User not logged in");
    }
    if (kDebugMode) {
      print("--- FirebaseFavoritesRepo: Attempting to remove favorite $recipeId for user ${userDocRef.id} ---");
    }
    try {
      await userDocRef.update({
        'favorites': FieldValue.arrayRemove([recipeId])
      });
      if (kDebugMode) {
        print("--- FirebaseFavoritesRepo: Successfully removed favorite $recipeId ---");
      }
    } catch (e) {
      if (kDebugMode) {
        print("!!! FirebaseFavoritesRepo: ERROR removing favorite $recipeId: $e !!!");
      }
      rethrow;
    }
  }

  @override
  Future<List<String>> getFavoriteRecipeIds() async {
    final userDocRef = _userDocRef;
    if (userDocRef == null) return [];

    if (kDebugMode) {
      print("--- FirebaseFavoritesRepo: Fetching favorite IDs for user ${userDocRef.id} ---");
    }
    try {
      final docSnapshot = await userDocRef.get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        if (data.containsKey('favorites') && data['favorites'] is List) {
          final ids = List<String>.from(data['favorites']);
          if (kDebugMode) {
            print("--- FirebaseFavoritesRepo: Fetched favorite IDs: $ids ---");
          }
          return ids;
        }
      }
      if (kDebugMode) {
        print("--- FirebaseFavoritesRepo: User document exists but no 'favorites' field found or invalid.");
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print("!!! FirebaseFavoritesRepo: ERROR fetching favorite IDs: $e !!!");
      }
      return [];
    }
  }

  @override
  Future<bool> isFavorite(String recipeId) async {
    final favoriteIds = await getFavoriteRecipeIds();
    return favoriteIds.contains(recipeId);
  }

  @override
  Stream<List<String>> getFavoritesStream() {
    final userDocRef = _userDocRef;
    if (userDocRef == null) {
      return Stream.value([]);
    }

    if (kDebugMode) {
      print("--- FirebaseFavoritesRepo: Creating favorites stream for user ${userDocRef.id} ---");
    }
    return userDocRef.snapshots().map((snapshot) {
      if (kDebugMode) {
        print("--- FirebaseFavoritesRepo: Stream received snapshot. Exists: ${snapshot.exists} ---");
      }
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data() as Map<String, dynamic>;
        if (data.containsKey('favorites') && data['favorites'] is List) {
          final ids = List<String>.from(data['favorites']);
          if (kDebugMode) {
            print("--- FirebaseFavoritesRepo: Stream emitting favorite IDs: $ids ---");
          }
          return ids;
        }
      }
      if (kDebugMode) {
        print("--- FirebaseFavoritesRepo: Stream emitting empty list (doc doesn't exist or no favorites field).");
      }
      return <String>[];
    }).handleError((error) {
      if (kDebugMode) {
        print("!!! FirebaseFavoritesRepo: ERROR in favorites stream: $error !!!");
      }
      return <String>[];
    });
  }
}

