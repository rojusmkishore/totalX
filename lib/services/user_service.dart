import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:total_x/models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> addUser(UserModel user, File? imageFile) async {
    String imageUrl = '';
    
    if (imageFile != null) {
      final ref = _storage.ref().child('users/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(imageFile);
      imageUrl = await ref.getDownloadURL();
    }

    final userData = user.toMap();
    userData['imageUrl'] = imageUrl;

    await _firestore.collection('users').doc(user.id).set(userData);
  }

  Stream<List<UserModel>> getUsers() {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data()))
            .toList());
  }

  // Pagination support
  Future<QuerySnapshot> fetchUsersSnapshot({
    DocumentSnapshot? startAfter,
    int limit = 10,
    String? searchQuery,
    bool? isOlder,
  }) async {
    Query query = _firestore.collection('users').orderBy('name');

    if (isOlder != null) {
      if (isOlder) {
        query = query.where('age', isGreaterThan: 60);
      } else {
        query = query.where('age', isLessThanOrEqualTo: 60);
      }
    }

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return await query.limit(limit).get();
  }
}
