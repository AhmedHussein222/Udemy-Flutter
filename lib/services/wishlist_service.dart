import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WishlistService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> toggleWishlist(String courseId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Check if course is in Carts (Still under Users/{uid}/Carts)
      final cartDoc = await _firestore
          .collection('Users')
          .doc(user.uid)
          .collection('Carts')
          .doc(courseId)
          .get();

      // New wishlist path
      final wishlistDoc = await _firestore
          .collection('Wishlists')
          .doc(user.uid)
          .collection('items')
          .doc(courseId)
          .get();

      // If in Carts, remove from wishlist if exists
      if (cartDoc.exists) {
        if (wishlistDoc.exists) {
          await _firestore
              .collection('Wishlists')
              .doc(user.uid)
              .collection('items')
              .doc(courseId)
              .delete();
          return true;
        }
        return false;
      }

      if (wishlistDoc.exists) {
        await _firestore
            .collection('Wishlists')
            .doc(user.uid)
            .collection('items')
            .doc(courseId)
            .delete();
        return true;
      } else {
        final courseDoc =
            await _firestore.collection('Courses').doc(courseId).get();

        if (!courseDoc.exists) return false;

        final course = courseDoc.data()!;
        final instructorId = course['instructor_id'];

        String instructorName = 'Unknown Instructor';
        if (instructorId != null) {
          final instructorDoc = await _firestore
              .collection('Users')
              .doc(instructorId)
              .get();

          if (instructorDoc.exists &&
              instructorDoc.data()?['role'] == 'instructor') {
            instructorName = instructorDoc.data()?['name'] ?? 'Unknown Instructor';
          }
        }

        final wishlistData = {
          'id': courseId,
          'title': course['title'] ?? 'Untitled Course',
          'price': course['price'] ?? 0.0,
          'thumbnail': course['thumbnail'] ?? '',
          'description': course['description'] ?? '',
          'instructor_name': instructorName,
          'rating': course['rating'] ?? {'count': 0, 'rate': 0.0},
          'addedAt': FieldValue.serverTimestamp(),
        };

        await _firestore
            .collection('Wishlists')
            .doc(user.uid)
            .collection('items')
            .doc(courseId)
            .set(wishlistData);

        return true;
      }
    } catch (e) {
      print('Error toggling Wishlists: $e');
      return false;
    }
  }

  Future<bool> isInWishlist(String courseId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final doc = await _firestore
          .collection('Wishlists')
          .doc(user.uid)
          .collection('items')
          .doc(courseId)
          .get();

      return doc.exists;
    } catch (e) {
      print('Error checking wishlist: $e');
      return false;
    }
  }

  Future<bool> isInCarts(String courseId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final doc = await _firestore
          .collection('Users')
          .doc(user.uid)
          .collection('Carts')
          .doc(courseId)
          .get();

      return doc.exists;
    } catch (e) {
      print('Error checking cart: $e');
      return false;
    }
  }
  Future<void> removeFromWishlist(String courseId) async {
  try {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('Wishlists')
        .doc(user.uid)
        .collection('items')
        .doc(courseId)
        .delete();
  } catch (e) {
    print('Error removing from wishlist: $e');
  }
}


  Stream<QuerySnapshot> getWishlistStream() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('Wishlists')
        .doc(user.uid)
        .collection('items')
        .orderBy('addedAt', descending: true)
        .snapshots();
  }
}
