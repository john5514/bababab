import 'package:bicrypto/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  final apiService = ApiService();
  late CookieManager cookieManager;
  bool isWebViewReady = false;

  @override
  void initState() {
    super.initState();
    cookieManager = CookieManager();
    _setCookies();
  }

  Future<void> _setCookies() async {
    await apiService.loadTokens();

    for (var key in apiService.tokens.keys) {
      String? value = apiService.tokens[key];
      if (value != null) {
        // Remove 'Bearer ' prefix if present
        if (value.startsWith('Bearer ')) {
          value = value.substring('Bearer '.length);
        }
        print("Setting cookie: $key=$value");
        await cookieManager.setCookie(
          WebViewCookie(
            name: key,
            value: value,
            domain: 'v3.mash3div.com', // Verify this with your backend
            path: '/', // Verify this with your backend
            // Consider adding other attributes like 'expires', 'secure', etc.
          ),
        );
      }
    }

    // Delay WebView loading to ensure cookies are set
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      isWebViewReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WebView with Cookies'),
      ),
      body: isWebViewReady
          ? WebView(
              initialUrl: 'https://v3.mash3div.com/user/wallets/fiat',
              javascriptMode: JavascriptMode.unrestricted,
              onPageStarted: (String url) {
                print("WebView started loading: $url");
              },
              onPageFinished: (String url) {
                print("WebView finished loading: $url");
              },
              onWebResourceError: (error) {
                print("WebView error: ${error.description}");
              },
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
