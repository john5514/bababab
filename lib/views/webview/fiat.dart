import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:bicrypto/services/api_service.dart';

class WebViewPage extends StatefulWidget {
  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  final apiService = ApiService();
  InAppWebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    // Load the tokens initially.
    apiService.loadTokens();
  }

  Future<void> _setCookies(InAppWebViewController controller) async {
    await apiService.loadTokens(); // Ensure the latest tokens are loaded.

    CookieManager cookieManager = CookieManager.instance();

    for (var entry in apiService.tokens.entries) {
      var key = entry.key;
      var value = entry.value;

      if (value != null && value.isNotEmpty) {
        // Set each cookie using CookieManager
        await cookieManager
            .setCookie(
          url: Uri.parse('https://v3.mash3div.com'),
          name: key,
          value: value,
          domain: 'v3.mash3div.com',
          path: '/',
          isHttpOnly: false, // Set as needed
          isSecure: true, // Set as needed
          sameSite: HTTPCookieSameSitePolicy.LAX, // Set as needed
          // expiresDate: ... // If you need to set an expiration date
        )
            .then((result) {
          // print('Cookie set: $key=$value');
        }).catchError((error) {
          // print('Error setting cookie $key: $error');
        });
      }
    }

    // After setting cookies, load the initial URL.
    controller.loadUrl(
        urlRequest: URLRequest(
      url: Uri.parse('https://v3.mash3div.com/user/wallets/fiat'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('WebView with Cookies')),
      body: InAppWebView(
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            javaScriptEnabled: true,
          ),
        ),
        onWebViewCreated: (InAppWebViewController controller) {
          _webViewController = controller;
          _setCookies(controller); // Set cookies when web view is created.
        },
        onLoadStart: (controller, url) {
          // print("WebView started loading: $url");
        },
        onLoadStop: (controller, url) {
          // print("WebView finished loading: $url");
        },
        onLoadError: (controller, url, code, message) {
          // print(
          //     "WebView error: URL: $url, Error Code: $code, Error Message: $message");
        },
        onConsoleMessage: (controller, consoleMessage) {
          // print("Console message: ${consoleMessage.message}");
        },
      ),
    );
  }
}
