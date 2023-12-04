import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:bicrypto/services/api_service.dart';

class TwoStepVerificationScreen extends StatefulWidget {
  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<TwoStepVerificationScreen>
    with AutomaticKeepAliveClientMixin {
  final apiService = ApiService();
  InAppWebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    apiService.loadTokens(); // Load the tokens initially.
  }

  Future<void> _setCookies(InAppWebViewController controller) async {
    await apiService.loadTokens(); // Ensure the latest tokens are loaded.

    CookieManager cookieManager = CookieManager.instance();

    for (var entry in apiService.tokens.entries) {
      var key = entry.key;
      var value = entry.value;

      if (value != null && value.isNotEmpty) {
        await cookieManager.setCookie(
          url: Uri.parse('https://v3.mash3div.com'),
          name: key,
          value: value,
          domain: 'v3.mash3div.com',
          path: '/',
          isHttpOnly: false,
          isSecure: true,
          sameSite: HTTPCookieSameSitePolicy.LAX,
        );
      }
    }

    controller.loadUrl(
      urlRequest: URLRequest(
        url: Uri.parse('https://v3.mash3div.com/user/flutter/two-factor'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: InAppWebView(
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            javaScriptEnabled: true,
          ),
        ),
        onWebViewCreated: (InAppWebViewController controller) {
          _webViewController = controller;
          _setCookies(controller);
        },
        // Other callback handlers can be removed if they are not used for anything else
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
