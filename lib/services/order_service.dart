import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> createOrder({
    required List<Map<String, dynamic>> cartItems,
    required double total,
    required Map<String, dynamic> paymentDetails,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await _firestore.collection('orders').add({
        'user_id': user.uid,
        'items':
            cartItems
                .map(
                  (item) => ({
                    'course_id': item['id'],
                    'title': item['title'],
                    'price': item['price'],
                  }),
                )
                .toList(),
        'totalAmount': total,
        'paymentDetails': paymentDetails,
        'paymentId': paymentDetails['id'],
        'method': 'PayPal',
        'timestamp': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error creating order: $e');
      return false;
    }
  }

  Stream<QuerySnapshot> getUserOrders() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('orders')
        .where('user_id', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
