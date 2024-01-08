import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:bitcuit/services/api_service.dart';

class TwoStepVerificationScreen extends StatefulWidget {
  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<TwoStepVerificationScreen>
    with AutomaticKeepAliveClientMixin {
  final apiService = ApiService();
  InAppWebViewController? _webViewController;
  PullToRefreshController? _pullToRefreshController;

  @override
  void initState() {
    super.initState();
    apiService.loadTokens(); // Load the tokens initially.
    _pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (_webViewController != null) {
          _webViewController!.reload();
        }
      },
    );
  }

  Future<void> _setCookies(InAppWebViewController controller) async {
    await apiService.loadTokens(); // Ensure the latest tokens are loaded.

    CookieManager cookieManager = CookieManager.instance();

    for (var entry in apiService.tokens.entries) {
      var key = entry.key;
      var value = entry.value;

      if (value != null && value.isNotEmpty) {
        await cookieManager.setCookie(
          url: Uri.parse(apiService.baseDomainUrl),
          name: key,
          value: value,
          domain: Uri.parse(apiService.baseDomainUrl).host,
          path: '/',
          isHttpOnly: false,
          isSecure: true,
          sameSite: HTTPCookieSameSitePolicy.LAX,
        );
      }
    }

    controller.loadUrl(
      urlRequest: URLRequest(
        url: Uri.parse(
            '${apiService.baseDomainUrl}user/flutter/two-factor'), // Use variable for URL
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
        pullToRefreshController: _pullToRefreshController,
        onWebViewCreated: (InAppWebViewController controller) {
          _webViewController = controller;
          _setCookies(controller);
        },
        onLoadStop: (controller, url) {
          _pullToRefreshController?.endRefreshing();
        },
        onProgressChanged: (controller, progress) {
          if (progress == 100) {
            _pullToRefreshController?.endRefreshing();
          }
        },
        onReceivedServerTrustAuthRequest: (controller, challenge) async {
          // This bypasses all SSL certificate errors, use with caution in production
          return ServerTrustAuthResponse(
              action: ServerTrustAuthResponseAction.PROCEED);
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
