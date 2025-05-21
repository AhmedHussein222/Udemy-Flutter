import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WishlistService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> toggleWishlist(String courseId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // جلب بيانات الكورس من collection الـ Courses
      final courseDoc = await _firestore
          .collection('Courses')
          .doc(courseId)
          .get();
      if (!courseDoc.exists || courseDoc.data() == null) {
        print('Course $courseId does not exist');
        return false;
      }

      final courseData = courseDoc.data()!;
      // جلب بيانات المدرب من Users collection بناءً على instructor_id
      final instructorId = courseData['instructor_id']?.toString();
      String instructorName = 'Unknown Instructor';
      if (instructorId != null && instructorId.isNotEmpty) {
        final instructorDoc = await _firestore
            .collection('Users')
            .doc(instructorId)
            .get();
        if (instructorDoc.exists && instructorDoc.data() != null) {
          final instructorData = instructorDoc.data()!;
          instructorName = '${instructorData['first_name'] ?? 'Unknown'} ${instructorData['last_name'] ?? ''}'.trim();
        }
      }

      final wishlistDocRef = _firestore.collection('Wishlists').doc(user.uid);
      final wishlistDoc = await wishlistDocRef.get();
      final items = wishlistDoc.exists && wishlistDoc.data() != null
          ? List<Map<String, dynamic>>.from(wishlistDoc.data()!['items'] ?? [])
          : [];

      // Check if course is already in wishlist
      final isInWishlist = items.any((item) => item['id'] == courseId);

      if (isInWishlist) {
        // Remove course from wishlist
        await wishlistDocRef.update({
          'items': FieldValue.arrayRemove([
            items.firstWhere((item) => item['id'] == courseId)
          ])
        });
      } else {
        // Add course to wishlist
        await wishlistDocRef.set({
          'items': FieldValue.arrayUnion([
            {
              'id': courseId,
              'title': courseData['title'] ?? 'Untitled Course',
              'thumbnail': courseData['thumbnail'] ?? '',
              'instructor_name': instructorName, // استخدمنا instructorName اللي جبناه
              'price': courseData['price'] ?? 0,
              'addedAt': FieldValue.serverTimestamp(),
            }
          ])
        }, SetOptions(merge: true));
      }

      return true;
    } catch (e) {
      print('Error toggling wishlist: $e');
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
          .get();

      if (!doc.exists || doc.data() == null) return false;

      final items = List<Map<String, dynamic>>.from(doc.data()!['items'] ?? []);
      return items.any((item) => item['id'] == courseId);
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

      final wishlistDoc = await _firestore
          .collection('Wishlists')
          .doc(user.uid)
          .get();

      if (wishlistDoc.exists && wishlistDoc.data() != null) {
        final items = List<Map<String, dynamic>>.from(wishlistDoc.data()!['items'] ?? []);
        if (items.any((item) => item['id'] == courseId)) {
          await _firestore
              .collection('Wishlists')
              .doc(user.uid)
              .update({
            'items': FieldValue.arrayRemove([
              items.firstWhere((item) => item['id'] == courseId)
            ])
          });
        }
      }
    } catch (e) {
      print('Error removing from wishlist: $e');
    }
  }

  Stream<DocumentSnapshot> getWishlistStream() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('Wishlists')
        .doc(user.uid)
        .snapshots();
  }

  Future<void> migrateWishlistData(String uid) async {
    try {
      final wishlistDoc = await _firestore.collection('Wishlists').doc(uid).get();
      if (wishlistDoc.exists && wishlistDoc.data() != null) {
        final data = wishlistDoc.data()!;
        final items = data.entries
            .where((entry) => entry.key != 'items')
            .map((entry) => {...entry.value as Map<String, dynamic>, 'id': entry.key})
            .toList();
        await _firestore.collection('Wishlists').doc(uid).set({'items': items}, SetOptions(merge: true));
      }
    } catch (e) {
      print('Error migrating wishlist data: $e');
    }
  }
}