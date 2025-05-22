import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PayPalCheckoutWebView extends StatefulWidget {
  final String approvalUrl;
  final String returnUrl;
  final String cancelUrl;
  final Function(String orderId) onSuccess;
  final VoidCallback onCancel;

  const PayPalCheckoutWebView({
    Key? key,
    required this.approvalUrl,
    required this.returnUrl,
    required this.cancelUrl,
    required this.onSuccess,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<PayPalCheckoutWebView> createState() => _PayPalCheckoutWebViewState();
}

class _PayPalCheckoutWebViewState extends State<PayPalCheckoutWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    // if (Platform.isAndroid) WebViewPlatform.instance = SurfaceAndroidWebView();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final url = request.url;
            if (url.startsWith(widget.returnUrl)) {
              final uri = Uri.parse(url);
              final token = uri.queryParameters['token'];
              if (token != null) {
                widget.onSuccess(token);
              }
              return NavigationDecision.prevent;
            } else if (url.startsWith(widget.cancelUrl)) {
              widget.onCancel();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.approvalUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pay with PayPal")),
      body: WebViewWidget(controller: _controller),
    );
  }
}
