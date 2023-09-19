import 'package:bicrypto/Routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Style/styles.dart'; // Your global styles

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BiCrypto',
      theme: appTheme,
      initialRoute: '/',
      getPages: AppRoutes.routes, // Use your AppRoutes here
    );
  }
}
