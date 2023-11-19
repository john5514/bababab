import 'package:bicrypto/Controllers/Auth/profile/kyc_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class KYCScreen extends StatelessWidget {
  final KYCController kycController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // KYC related fields and buttons go here
          Text("KYC Verification"),
          // Example: A button to fetch and display KYC data
          ElevatedButton(
            onPressed: () => kycController.fetchKYCData(),
            child: Text("Fetch KYC Data"),
          ),
          // Use Obx or GetBuilder to display reactive data
        ],
      ),
    );
  }
}
