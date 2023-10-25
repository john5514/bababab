import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WebWalletView extends StatelessWidget {
  Future<Map<String, String>> getSavedTokens() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String> headers = {
      'access-token': prefs.getString('access-token') ?? '',
      'refresh-token': prefs.getString('refresh-token') ?? '',
      'csrf-token': prefs.getString('csrf-token') ?? '',
      'session-id': prefs.getString('session-id') ?? '',
      // Include other tokens as needed
    };
    return headers;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: getSavedTokens(),
      builder:
          (BuildContext context, AsyncSnapshot<Map<String, String>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Wallet View'),
            ),
            body: WebView(
              initialUrl: 'https://v3.mash3div.com/user/wallets/fiat',
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                webViewController.loadUrl(
                  'https://v3.mash3div.com/user/wallets/fiat',
                  headers: snapshot.data!,
                );
              },
            ),
          );
        }
      },
    );
  }
}
