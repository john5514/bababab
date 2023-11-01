import 'package:bicrypto/Controllers/wallets/spot%20wallet/spotWallet_controller.dart';
import 'package:bicrypto/services/CoinGeckoService.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CoinGeckoView extends StatelessWidget {
  final CoinGeckoController controller = Get.put(
      CoinGeckoController(coinGeckoService: Get.find<CoinGeckoService>()));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: controller.currencies.length,
          itemBuilder: (context, index) {
            var currency = controller.currencies[index];
            return ListTile(
              leading: SizedBox(
                height: 35.0,
                width: 35.0,
                child: CachedNetworkImage(
                  imageUrl: currency['image'],
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currency['symbol']
                        .toUpperCase(), // Uppercase for the symbol
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                        fontFamily: 'Inter'),
                  ),
                  Text(
                    currency['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.0,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
              // Price is excluded as per your request
            );
          },
        );
      }),
    );
  }
}
