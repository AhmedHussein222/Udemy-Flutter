import 'dart:convert';
import 'package:http/http.dart' as http;

class PayPalService {
  final String clientId = 'AT1NmU2_TdPJEU49q5gA5cCObkGtrLOmw5l9Ixg3Pjmse2aC06ysZW4_deINXW1c88xglnwgr9y-jCdM';
  final String secret = 'ECXoKo1jFSV34wnVfTS3LVc8MX5veIn-pNwOdxRq4lVGBXEBytIT9KeldeiPOtTEkyV7Xp1Xdy_PQSLb';
  final String domain = 'https://api-m.sandbox.paypal.com';

  Future<String?> getAccessToken() async {
    try {
      final response = await http.post(
        Uri.parse('$domain/v1/oauth2/token'),
        headers: {
          'Accept': 'application/json',
          'Accept-Language': 'en_US',
          'Authorization':
              'Basic ${base64Encode(utf8.encode('$clientId:$secret'))}',
        },
        body: {'grant_type': 'client_credentials'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['access_token'];
      } else {
        print('Access token error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> createOrder(String accessToken, String totalAmount) async {
    try {
      final response = await http.post(
        Uri.parse('$domain/v2/checkout/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          "intent": "CAPTURE",
          "purchase_units": [
            {
              "amount": {
                "currency_code": "USD",
                "value": totalAmount,
              }
            }
          ],
          "application_context": {
            "return_url": "https://example.com/return",
            "cancel_url": "https://example.com/cancel"
          }
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print('Create order error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Create order exception: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> capturePayment(String accessToken, String orderId) async {
    try {
      final response = await http.post(
        Uri.parse('$domain/v2/checkout/orders/$orderId/capture'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print('Capture error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Capture exception: $e');
      return null;
    }
  }
}
