import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WishlistService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Adds a course to the user's wishlist with course details.
  Future<bool> addToWishlist(String courseId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        // No user logged in
        return false;
      }

      // Fetch course data
      final courseDoc =
          await _firestore.collection('Courses').doc(courseId).get();

      if (!courseDoc.exists) {
        // Course does not exist
        return false;
      }

      // Extract course details
      final courseData = courseDoc.data()!;
      final wishlistData = {
        'course_id': courseId,
        'title': courseData['title'] ?? 'Unknown Course',
        'image_url': courseData['thumbnail'] ?? '',
        'price': courseData['price'] ?? 0.0,
        'added_at': FieldValue.serverTimestamp(),
      };

      // Add to wishlist
      await _firestore
          .collection('Users')
          .doc(user.uid)
          .collection('wishlist')
          .doc(courseId)
          .set(wishlistData);

      return true;
    } catch (e) {
      // Log error for debugging
      print('Error adding to wishlist: $e');
      // Optionally, you can throw the error or notify the user via UI
      return false;
    }
  }

  /// Removes a course from the user's wishlist.
  Future<bool> removeFromWishlist(String courseId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return false;
      }

      await _firestore
          .collection('Users')
          .doc(user.uid)
          .collection('wishlist')
          .doc(courseId)
          .delete();

      return true;
    } catch (e) {
      print('Error removing from wishlist: $e');
      return false;
    }
  }

  /// Checks if a course is in the user's wishlist.
  Future<bool> isInWishlist(String courseId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return false;
      }

      final doc =
          await _firestore
              .collection('Users')
              .doc(user.uid)
              .collection('wishlist')
              .doc(courseId)
              .get();

      return doc.exists;
    } catch (e) {
      print('Error checking wishlist: $e');
      return false;
    }
  }

  /// Returns a stream of the user's wishlist.
  Stream<QuerySnapshot> getWishlistStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.empty();
    }

    return _firestore
        .collection('Users')
        .doc(user.uid)
        .collection('wishlist')
        .orderBy('added_at', descending: true)
        .snapshots();
  }
}
