import 'package:bicrypto/Controllers/walletinfo_controller.dart';
import 'package:bicrypto/Controllers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bicrypto/Style/styles.dart';
import 'package:fl_chart/fl_chart.dart';

class WalletInfoView extends StatelessWidget {
  final WalletInfoController walletInfoController =
      Get.put(WalletInfoController());
  final WalletController walletController = Get.find();

  final Color leftBarColor = Colors.green;
  final Color rightBarColor = Colors.red;
  final double barWidth = 14;

  WalletInfoView({super.key}) {
    walletController.fetchWeeklySummary(
        currency: walletInfoController.walletName.value);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = appTheme; // Assuming appTheme is a ThemeData object.

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${walletInfoController.walletName.value} Wallet',
          style: theme.textTheme.titleLarge
              ?.copyWith(color: theme.colorScheme.onSurface),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle:
            true, // Center the title if that aligns with your design language
      ),
      body: Obx(
        () => Padding(
          padding: const EdgeInsets.all(
              4.0), // Add padding around the content for better spacing
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ListView(
                  // Use a ListView for better handling of small screen sizes
                  children: [
                    const SizedBox(height: 20),
                    // Display wallet balance with enhanced UI
                    Text(
                      '${walletInfoController.walletName.value} Balance: ${walletInfoController.walletBalance.value.toStringAsFixed(2)}', // Assuming balance is a double, format it
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme
                            .onSurface, // Use the primary color for the balance
                      ),
                      textAlign: TextAlign.center, // Center the text
                    ),
                    const SizedBox(height: 20),
                    // Display income and expense with icons
                    incomeOutcome(),
                    const SizedBox(
                        height: 40), // Adjust the space between elements
                    Text(
                      'Weekly Summary (Last 7 Days)',
                      style: theme.textTheme.headline6?.copyWith(
                        color: theme.colorScheme
                            .onSurface, // Use the secondary color for subtitles
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center, // Center the text
                    ),
                    const SizedBox(height: 20),
                    weeklytranssummarychart(),
                  ],
                ),
              ),
              actionBtns(), // This will stick to the bottom due to the MainAxisAlignment.spaceBetween in the column
            ],
          ),
        ),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
    );
  }

  Row incomeOutcome() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.trending_up,
            color: appTheme.colorScheme.secondary), // Updated icon
        const SizedBox(width: 8), // Slightly reduce the spacing
        Obx(() {
          Map<String, double> balance =
              walletController.calculateBalanceForCurrency(
                  walletInfoController.walletName.value);
          String currencySymbol = walletController
              .getCurrencySymbol(walletInfoController.walletName.value);
          return Text(
            '+$currencySymbol${balance['income']?.toStringAsFixed(2)}',
            style: appTheme.textTheme.bodyLarge?.copyWith(
              color: appTheme.colorScheme.primary, // Use theme's primary color
              fontWeight: FontWeight.bold,
            ),
          );
        }),
        const SizedBox(width: 20), // Keep the spacing for visual separation
        Icon(Icons.trending_down,
            color: appTheme.colorScheme.error), // Updated icon
        const SizedBox(width: 8), // Slightly reduce the spacing
        Obx(() {
          Map<String, double> balance =
              walletController.calculateBalanceForCurrency(
                  walletInfoController.walletName.value);
          String currencySymbol = walletController
              .getCurrencySymbol(walletInfoController.walletName.value);
          return Text(
            '-$currencySymbol${balance['expense']?.toStringAsFixed(2)}',
            style: appTheme.textTheme.bodyLarge?.copyWith(
              color: appTheme.colorScheme.error, // Use theme's error color
              fontWeight: FontWeight.bold,
            ),
          );
        }),
      ],
    );
  }

  Padding actionBtns() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: ElevatedButton.icon(
              icon: Icon(Icons.account_balance_wallet,
                  color: appTheme.colorScheme.onPrimary),
              label: Text('Deposit'),
              onPressed: () {
                Get.toNamed('/deposit', arguments: {
                  'walletName': walletInfoController.walletName.value,
                  'walletBalance': walletInfoController.walletBalance.value,
                  'walletInfo': walletInfoController
                      .walletInfo.value, // Include walletInfo
                });
              },
              style: ElevatedButton.styleFrom(
                primary:
                    appTheme.colorScheme.primary, // Button background color
                onPrimary:
                    appTheme.colorScheme.onPrimary, // Text and icon color
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: ElevatedButton.icon(
              icon: Icon(Icons.money_off, color: appTheme.colorScheme.onError),
              label: Text('Withdraw'),
              onPressed: () {
                Get.toNamed('/withdraw', arguments: {
                  'walletName': walletInfoController.walletName.value,
                  'walletBalance': walletInfoController.walletBalance.value,
                  'walletInfo': walletInfoController
                      .walletInfo.value, // Include walletInfo
                });
              },
              style: ElevatedButton.styleFrom(
                primary: appTheme.colorScheme.error, // Button background color
                onPrimary: appTheme.colorScheme.onError, // Text and icon color
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  AspectRatio weeklytranssummarychart() {
    return AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: const EdgeInsets.all(8), // Reduced padding
        child: SizedBox(
          // Use SizedBox to set minimum height
          height: 350, // Set a minimum height for the card
          child: Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: appTheme.cardColor,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: BarChart(
                BarChartData(
                  maxY: getMaxY(), // <-- Use the dynamic maxY
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.grey,
                      getTooltipItem: (a, b, c, d) => null,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 38,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          switch (value.toInt()) {
                            case 0:
                              return const Text('0k',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 14));
                            case 5:
                              return const Text('5k',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 14));
                            case 10:
                              return const Text('10k',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 14));
                            case 15:
                              return const Text('15k',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 14));
                            case 20:
                              return const Text('20k',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 14));
                            default:
                              return const Text(
                                  ''); // Return empty string for other values
                          }
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 80,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final titles = [
                            'Mn',
                            'Te',
                            'Wd',
                            'Tu',
                            'Fr',
                            'St',
                            'Su'
                          ];
                          return Padding(
                            padding: const EdgeInsets.only(
                                top: 20), // Adjust this value to your liking
                            child: Text(
                              titles[value.toInt()],
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 14),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  barGroups: walletController.weeklySummaries.map((summary) {
                    int index =
                        walletController.weeklySummaries.indexOf(summary);

                    double incomeHeight =
                        (summary.income > 20000 ? 20000 : summary.income) /
                            1000; // Normalize and cap at 20,000
                    double expenseHeight =
                        (summary.expense > 20000 ? 20000 : summary.expense) /
                            1000; // Normalize and cap at 20,000

                    Color incomeColor = summary.income > 20000
                        ? Colors.yellow
                        : leftBarColor; // Set to yellow if exceeds limit
                    Color expenseColor = summary.expense > 20000
                        ? Colors.yellow
                        : rightBarColor; // Set to yellow if exceeds limit

                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: incomeHeight,
                          color: incomeColor,
                          width: barWidth,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        BarChartRodData(
                          toY: expenseHeight,
                          color: expenseColor,
                          width: barWidth,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    );
                  }).toList(),

                  borderData: FlBorderData(show: false), // Remove border
                  gridData: const FlGridData(show: false),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  double getMaxY() {
    double maxIncome = walletController.weeklySummaries.fold(
        0,
        (prevMax, summary) =>
            summary.income > prevMax ? summary.income : prevMax);
    double maxExpense = walletController.weeklySummaries.fold(
        0,
        (prevMax, summary) =>
            summary.expense > prevMax ? summary.expense : prevMax);

    double overallMax = maxIncome > maxExpense ? maxIncome : maxExpense;
    return (overallMax / 1000)
        .ceil()
        .toDouble(); // Convert to 'k' representation and round up
  }
}
