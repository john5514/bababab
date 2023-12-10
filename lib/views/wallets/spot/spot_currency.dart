import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:bicrypto/services/api_service.dart';

class CurrencySpotView extends StatefulWidget {
  final String currencyCode;

  CurrencySpotView({Key? key, required this.currencyCode}) : super(key: key);

  @override
  _CurrencySpotViewState createState() => _CurrencySpotViewState();
}

class _CurrencySpotViewState extends State<CurrencySpotView>
    with AutomaticKeepAliveClientMixin {
  final apiService = ApiService();
  InAppWebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    apiService.loadTokens();
  }

  Future<void> _setCookies(InAppWebViewController controller) async {
    await apiService.loadTokens();

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

    String url =
        'https://v3.mash3div.com/user/flutter/wallets/spot/${widget.currencyCode.toLowerCase()}';
    controller.loadUrl(urlRequest: URLRequest(url: Uri.parse(url)));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.currencyCode.toUpperCase()} Spot Wallet'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5.0), // Apply general padding of 5 pixels
        child: InAppWebView(
          initialOptions: InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(
              javaScriptEnabled: true,
            ),
          ),
          onWebViewCreated: (InAppWebViewController controller) {
            _webViewController = controller;
            _setCookies(controller);
          },
          // Additional event handlers can be added if needed
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
