// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:webview_cookie_manager/webview_cookie_manager.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class WebViewExample extends StatefulWidget {
//   @override
//   WebViewExampleState createState() => WebViewExampleState();
// }

// class WebViewExampleState extends State<WebViewExample> {
//   late WebViewController controller;

//   @override
//   void initState() {
//     super.initState();
//     // Initialize your WebViewController here
//     initWebView();
//   }

//   void initWebView() async {
//     controller = WebViewController();

//     // Retrieve tokens from SharedPreferences
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? accessToken = prefs.getString('access-token');
//     String? csrfToken = prefs.getString('csrf-token');
//     String? sessionId = prefs.getString('session-id');

//     // Print the retrieved tokens for debugging
//     print('-*****-*-*-*--*Access Token: $accessToken');
//     print('CSRF Token: $csrfToken');
//     print('Session ID: $sessionId');

//     // Encode the tokens before setting them as cookies
//     if (accessToken != null && csrfToken != null && sessionId != null) {
//       accessToken = Uri.encodeFull(accessToken);
//       csrfToken = Uri.encodeFull(csrfToken);
//       sessionId = Uri.encodeFull(sessionId);

//       // Set the cookies in the WebView using WebviewCookieManager
//       final cookieManager = WebviewCookieManager();
//       try {
//         await cookieManager.setCookies([
//           Cookie('access-token', accessToken)
//             ..domain = 'v3.mash3div.com'
//             ..path = '/',
//           Cookie('csrf-token', csrfToken)
//             ..domain = 'v3.mash3div.com'
//             ..path = '/',
//           Cookie('session-id', sessionId)
//             ..domain = 'v3.mash3div.com'
//             ..path = '/',
//         ]);
//         print('Cookies set successfully');
//       } catch (e) {
//         print('Error setting cookies: $e');
//       }
//     }

//     controller
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setBackgroundColor(const Color(0x00000000))
//       ..loadRequest(Uri.parse('https://v3.mash3div.com/user/wallets/fiat'));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Flutter WebView Example')),
//       body: WebViewWidget(controller: controller),
//     );
//   }
// }
