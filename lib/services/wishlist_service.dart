import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WishlistService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Map<String, String> _instructorCache = {};

  Future<bool> toggleWishlist(String courseId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Check if course is in Carts (Still under Users/{uid}/Carts)
      final cartDoc =
          await _firestore
              .collection('Users')
              .doc(user.uid)
              .collection('Carts')
              .doc(courseId)
              .get();

      // Access the wishlist document
      final wishlistRef = _firestore.collection('Wishlists').doc(user.uid);
      final wishlistDoc = await wishlistRef.get();

      // If in Carts, remove from wishlist if exists
      if (cartDoc.exists) {
        if (wishlistDoc.exists && wishlistDoc.data() != null) {
          final items = List<Map<String, dynamic>>.from(
            wishlistDoc.data()!['items'] ?? [],
          );
          final itemToRemove = items.firstWhere(
            (item) => item['id'] == courseId,
            orElse: () => {},
          );
          if (itemToRemove.isNotEmpty) {
            await wishlistRef.update({
              'items': FieldValue.arrayRemove([itemToRemove]),
            });
            return true;
          }
        }
        return false;
      }

      if (wishlistDoc.exists && wishlistDoc.data() != null) {
        final items = List<Map<String, dynamic>>.from(
          wishlistDoc.data()!['items'] ?? [],
        );
        final itemExists = items.any((item) => item['id'] == courseId);
        if (itemExists) {
          // Remove from wishlist
          final itemToRemove = items.firstWhere(
            (item) => item['id'] == courseId,
          );
          await wishlistRef.update({
            'items': FieldValue.arrayRemove([itemToRemove]),
          });
          return true;
        }
      }

      // Add to wishlist
      final courseDoc =
          await _firestore.collection('Courses').doc(courseId).get();
      if (!courseDoc.exists) return false;

      final course = courseDoc.data()!;
      final instructorName = await getInstructorName(courseId);

      final wishlistData = {
        'id': courseId,
        'title': course['title'] ?? 'Untitled Course',
        'price': course['price']?.toDouble() ?? 0.0,
        'thumbnail':
            course['thumbnail'] ?? 'https://via.placeholder.com/300x200',
        'description': course['description'] ?? '',
        'instructor_name': instructorName,
        'rating': course['rating'] ?? {'count': 0, 'rate': 0.0},
        'totalHours': course['totalHours']?.toDouble() ?? 0.0,
        'lectures': course['lectures']?.toInt() ?? 0,
        'addedAt':
            DateTime.now().toIso8601String(), // Match JavaScript's ISO string
      };

      // Initialize document if it doesn't exist
      if (!wishlistDoc.exists) {
        await wishlistRef.set({
          'items': [wishlistData],
        });
      } else {
        await wishlistRef.update({
          'items': FieldValue.arrayUnion([wishlistData]),
        });
      }

      return true;
    } catch (e) {
      print('Error toggling Wishlists: $e');
      return false;
    }
  }

  Future<bool> isInWishlist(String courseId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final doc = await _firestore.collection('Wishlists').doc(user.uid).get();
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

      final doc =
          await _firestore
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

      final wishlistDoc =
          await _firestore.collection('Wishlists').doc(user.uid).get();
      if (wishlistDoc.exists && wishlistDoc.data() != null) {
        final items = List<Map<String, dynamic>>.from(
          wishlistDoc.data()!['items'] ?? [],
        );
        final itemToRemove = items.firstWhere(
          (item) => item['id'] == courseId,
          orElse: () => {},
        );
        if (itemToRemove.isNotEmpty) {
          await _firestore.collection('Wishlists').doc(user.uid).update({
            'items': FieldValue.arrayRemove([itemToRemove]),
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

    return _firestore.collection('Wishlists').doc(user.uid).snapshots();
  }

  Future<String> getInstructorName(String courseId) async {
    try {
      final courseDoc =
          await _firestore.collection('Courses').doc(courseId).get();
      if (!courseDoc.exists) return 'Unknown Instructor';

      final course = courseDoc.data()!;
      final instructorId = course['instructor_id'];
      if (instructorId == null) return 'Unknown Instructor';

      if (_instructorCache.containsKey(instructorId)) {
        return _instructorCache[instructorId]!;
      }

      final instructorDoc =
          await _firestore.collection('Users').doc(instructorId).get();

      if (instructorDoc.exists &&
          instructorDoc.data()?['role'] == 'instructor') {
        final firstName = instructorDoc.data()?['first_name'] ?? '';
        final lastName = instructorDoc.data()?['last_name'] ?? '';
        final fullName = '$firstName $lastName'.trim();
        final name = fullName.isEmpty ? 'Unknown Instructor' : fullName;
        _instructorCache[instructorId] = name;
        return name;
      }

      return 'Unknown Instructor';
    } catch (e) {
      print('Error fetching instructor name: $e');
      return 'Unknown Instructor';
    }
  }
}
