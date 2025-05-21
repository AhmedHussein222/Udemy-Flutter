import 'package:flutter/material.dart';

import '../../services/enrollment_service.dart';
import '../../services/paypal_checkout_webview.dart';
import '../../services/paypal_services.dart';

class CheckoutPage extends StatelessWidget {
  final PayPalService paypalService = PayPalService();
  final EnrollmentService enrollmentService = EnrollmentService();

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
            title: Text(
              title,
              style: TextStyle(color: success ? Colors.green : Colors.red),
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
      appBar: AppBar(title: Text("Checkout")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary
              Text(
                "Order summary",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 12),
              Text("Original Price: \$0"),
              Text("Discounts (0% Off): -\$0.00"),
              SizedBox(height: 12),
              Text(
                "Total (0 courses):",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "\$0",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                "By completing your purchase, you agree to these Terms of Use.",
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              SizedBox(height: 32),

              // Billing
              Text(
                "Billing address",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 12),
              Text("Country"),
              SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: 'United States',
                items:
                    ['United States', 'Egypt', 'UK']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                onChanged: (value) {},
                decoration: InputDecoration(border: OutlineInputBorder()),
              ),
              SizedBox(height: 16),
              Text("ZIP code"),
              SizedBox(height: 6),
              TextField(
                decoration: InputDecoration(border: OutlineInputBorder()),
              ),
              SizedBox(height: 12),
              Text(
                "Udemy is required by law to collect applicable transaction taxes for purchases made in certain tax jurisdictions.",
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              SizedBox(height: 24),

              // Payment Method
              Row(
                children: [
                  Text(
                    "Payment method",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(width: 6),
                  Text(
                    "Secure and encrypted",
                    style: TextStyle(color: Colors.green),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // PayPal Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final token = await paypalService.getAccessToken();
                    if (token == null) return;

                    final order = await paypalService.createOrder(
                      token,
                      "20.00",
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

                                  // تحديث التسجيلات
                                  final success = await enrollmentService
                                      .updateEnrollments([
                                        // هنا يجب إضافة عناصر السلة
                                        // مثال: {'id': 'course1', 'title': 'Course 1', ...}
                                      ]);

                                  if (success) {
                                    showPaymentDialog(
                                      context,
                                      "نجاح",
                                      "تم الدفع: $amount دولار من $email\nتم تحديث التسجيلات بنجاح",
                                    );
                                  } else {
                                    showPaymentDialog(
                                      context,
                                      "فشل",
                                      "تم الدفع ولكن حدث خطأ في تحديث التسجيلات",
                                    );
                                  }
                                } else {
                                  showPaymentDialog(
                                    context,
                                    "فشل",
                                    "لم يتم إتمام عملية الدفع.",
                                  );
                                }
                              },
                              onCancel: () {
                                Navigator.pop(context);
                                showPaymentDialog(
                                  context,
                                  "إلغاء",
                                  "تم إلغاء عملية الدفع من المستخدم.",
                                  success: false,
                                );
                              },
                            ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0070BA),
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text("PayPal", style: TextStyle(fontSize: 18)),
                ),
              ),

              SizedBox(height: 12),

              // Card Button (نفسه زي PayPal)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final token = await paypalService.getAccessToken();
                    if (token == null) return;

                    final order = await paypalService.createOrder(
                      token,
                      "20.00",
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
                                  showPaymentDialog(
                                    context,
                                    "نجاح",
                                    "تم الدفع: $amount دولار من $email",
                                  );
                                } else {
                                  showPaymentDialog(
                                    context,
                                    "فشل",
                                    "لم يتم إتمام عملية الدفع.",
                                  );
                                }
                              },
                              onCancel: () {
                                Navigator.pop(context);
                                showPaymentDialog(
                                  context,
                                  "إلغاء",
                                  "تم إلغاء عملية الدفع من المستخدم.",
                                  success: false,
                                );
                              },
                            ),
                      ),
                    );
                  },
                  icon: Icon(Icons.credit_card, color: Colors.white),
                  label: Text(
                    "Debit or Credit Card",
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Powered by ", style: TextStyle(fontSize: 12)),
                  Text(
                    "PayPal",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              SizedBox(height: 24),
              Text(
                "Order details (0 course)",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
