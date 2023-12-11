import 'package:bicrypto/Controllers/home_controller.dart'; // <-- Import HomeController
import 'package:bicrypto/views/Auth/profile/tabbar.dart';
import 'package:bicrypto/views/market/markethome.dart';
import 'package:bicrypto/views/news/news_screen.dart';
import 'package:bicrypto/views/wallet_view.dart'; // <-- Import WalletView
import 'package:bicrypto/views/webview/fiat.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bicrypto/Style/styles.dart';

class HomeView extends StatelessWidget {
  final HomeController homeController = Get.find();

  final List<Widget> _children = [
    NewsWidget(),
    MarketScreen(),
    // WebViewPage(),
    WalletView(),
    MainSettingsScreen(),
  ];

  HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Using the appTheme for consistent styling
    ThemeData theme = appTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Obx(
        () => IndexedStack(
          index: homeController.currentTabIndex.value,
          children: _children,
        ),
      ),
      bottomNavigationBar: Obx(
        () => NavigationBarTheme(
          data: NavigationBarThemeData(
            // Customizing label behavior and icons
            labelTextStyle:
                MaterialStateProperty.resolveWith((Set<MaterialState> states) {
              final bool isSelected = states.contains(MaterialState.selected);
              return TextStyle(
                fontSize: isSelected ? 14 : 12,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
              );
            }),
            iconTheme:
                MaterialStateProperty.resolveWith((Set<MaterialState> states) {
              final bool isSelected = states.contains(MaterialState.selected);
              return IconThemeData(
                size: 24,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              );
            }),
            // Set height using padding around NavigationBar destinations
            height: 65, // Adjust to your preference
            backgroundColor: theme.colorScheme.surface, // Match your dark theme
            indicatorColor: theme
                .colorScheme.background, // Indicator is the secondary color
          ),
          child: NavigationBar(
            selectedIndex: homeController.currentTabIndex.value,
            onDestinationSelected: (index) {
              homeController.changeTabIndex(index);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.pie_chart_outline),
                selectedIcon: Icon(Icons.pie_chart),
                label: 'Market',
              ),
              // NavigationDestination(
              //   icon: Icon(Icons.show_chart),
              //   selectedIcon: Icon(Icons.show_chart),
              //   label: 'Charts',
              // ),
              NavigationDestination(
                icon: Icon(Icons.account_balance_wallet_outlined),
                selectedIcon: Icon(Icons.account_balance_wallet),
                label: 'Wallet',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
