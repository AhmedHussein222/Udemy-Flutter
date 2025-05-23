import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/enrollment_service.dart';
import '../../services/order_service.dart';
import '../../services/paypal_checkout_webview.dart';
import '../../services/paypal_services.dart';

class CheckoutPage extends StatelessWidget {
  final PayPalService paypalService = PayPalService();
  final EnrollmentService enrollmentService = EnrollmentService();
  final OrderService orderService = OrderService();
  final String userId;
  final List<dynamic> cartItems;

  CheckoutPage({super.key, required this.userId, required this.cartItems});

  void showPaymentDialog(
    BuildContext context,
    String title,
    String message, {
    bool success = true,
  }) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(
              title,
              style: TextStyle(
                color: success ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(message),
            actions: [
              TextButton(
                child: Text("OK"),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Checkout"),
        elevation: 0,
        backgroundColor: Theme.of(context).secondaryHeaderColor,
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.1),
                Colors.white,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Summary
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.receipt_long,
                            color: Theme.of(context).primaryColor,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Order Summary",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Original Price:",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          Text(
                            "\$${cartItems.fold<double>(0, (sum, item) => sum + (item['price'] ?? 0)).toStringAsFixed(2)}",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Discounts (0%):",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          Text(
                            "-\$0.00",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total (${cartItems.length} Courses):",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "\$${cartItems.fold<double>(0, (sum, item) => sum + (item['price'] ?? 0)).toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),

                // Payment Method
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.payment,
                            color: Theme.of(context).primaryColor,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Payment Method",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.lock, color: Colors.green, size: 16),
                          Text(
                            "Secure and encrypted",
                            style: TextStyle(color: Colors.green, fontSize: 12),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final total = cartItems.fold<double>(
                              0,
                              (sum, item) => sum + (item['price'] ?? 0),
                            );
                            final token = await paypalService.getAccessToken();
                            if (token == null) return;

                            final order = await paypalService.createOrder(
                              token,
                              total.toStringAsFixed(2),
                            );
                            if (order == null) return;

                            final approvalLink =
                                (order['links'] as List).firstWhere(
                                  (l) => l['rel'] == 'approve',
                                )['href'];

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => PayPalCheckoutWebView(
                                      approvalUrl: approvalLink,
                                      returnUrl: "https://example.com/return",
                                      cancelUrl: "https://example.com/cancel",
                                      onSuccess: (orderId) async {
                                        final result = await paypalService
                                            .capturePayment(token, orderId);
                                        Navigator.pop(context);

                                        if (result != null &&
                                            result['status'] == 'COMPLETED') {
                                          final email =
                                              result['payer']['email_address'];
                                          final amount =
                                              result['purchase_units'][0]['payments']['captures'][0]['amount']['value'];
                                          final success = await enrollmentService
                                              .updateEnrollments(
                                                cartItems
                                                    .map<Map<String, dynamic>>(
                                                      (item) => {
                                                        'course_id':
                                                            item['course_id'],
                                                        'title': item['title'],
                                                        'price': item['price'],
                                                      },
                                                    )
                                                    .toList(),
                                                userId: userId,
                                              );

                                          if (success) {
                                            // إنشاء الطلب
                                            final orderSuccess =
                                                await orderService.createOrder(
                                                  cartItems:
                                                      cartItems
                                                          .map(
                                                            (item) => {
                                                              'id':
                                                                  item['course_id'],
                                                              'title':
                                                                  item['title'],
                                                              'price':
                                                                  item['price'],
                                                            },
                                                          )
                                                          .toList(),
                                                  total: double.parse(amount),
                                                  paymentDetails: result,
                                                );

                                            // حذف عناصر السلة بعد نجاح الدفع
                                            await FirebaseFirestore.instance
                                                .collection('Carts')
                                                .doc(userId)
                                                .set({
                                                  'items': [],
                                                }, SetOptions(merge: true));

                                            showPaymentDialog(
                                              context,
                                              "Success",
                                              "Payment successful: $amount from $email\nEnrollments updated successfully",
                                            );

                                            // التوجيه إلى صفحة My Learning
                                            Navigator.pushNamedAndRemoveUntil(
                                              context,
                                              '/my-learning',
                                              (route) => false,
                                            );
                                          } else {
                                            showPaymentDialog(
                                              context,
                                              "Failed",
                                              "Payment successful but failed to update enrollments",
                                              success: false,
                                            );
                                          }
                                        } else {
                                          showPaymentDialog(
                                            context,
                                            "Failed",
                                            "Payment was not completed.",
                                            success: false,
                                          );
                                        }
                                      },
                                      onCancel: () {
                                        Navigator.pop(context);
                                        showPaymentDialog(
                                          context,
                                          "Cancelled",
                                          "Payment was cancelled by user.",
                                          success: false,
                                        );
                                      },
                                    ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0070BA),
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.payment, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                "PayPal",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),

                // Order Details
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.school,
                            color: Theme.of(context).primaryColor,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Order Details (${cartItems.length} Courses)",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return Container(
                            margin: EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[200]!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      item['thumbnail'] ?? '',
                                      width: 100,
                                      height: 75,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Container(
                                          width: 100,
                                          height: 75,
                                          color: Colors.grey[200],
                                          child: Icon(
                                            Icons.image_not_supported,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['title'] ?? 'Untitled Course',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          '\$${item['price']?.toStringAsFixed(2) ?? '0.00'}',
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                Center(
                  child: Text(
                    "Powered by PayPal",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
