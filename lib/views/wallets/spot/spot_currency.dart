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
  PullToRefreshController? _pullToRefreshController;

  @override
  void initState() {
    super.initState();
    apiService.loadTokens();

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
    await apiService.loadTokens();

    CookieManager cookieManager = CookieManager.instance();
    for (var entry in apiService.tokens.entries) {
      var key = entry.key;
      var value = entry.value;
      if (value != null && value.isNotEmpty) {
        await cookieManager.setCookie(
          url: Uri.parse(
              apiService.baseDomainUrl), // Use base domain from ApiService
          name: key,
          value: value,
          domain: Uri.parse(apiService.baseDomainUrl)
              .host, // Use host from ApiService
          path: '/',
          isHttpOnly: false,
          isSecure: true,
          sameSite: HTTPCookieSameSitePolicy.LAX,
        );
      }
    }

    String url =
        '${apiService.baseDomainUrl}user/flutter/wallets/spot/${widget.currencyCode.toLowerCase()}';
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
        padding: const EdgeInsets.all(5.0),
        child: InAppWebView(
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
            // Bypass SSL certificate errors, only for development use
            return ServerTrustAuthResponse(
                action: ServerTrustAuthResponseAction.PROCEED);
          },
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
