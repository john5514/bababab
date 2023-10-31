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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Wallet Info',
          style: TextStyle(color: appTheme.secondaryHeaderColor),
        ),
        backgroundColor: appTheme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Obx(
        () => Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Display wallet balance with enhanced UI
                Text(
                  '${walletInfoController.walletName.value} Balance: ${walletInfoController.walletBalance.value}',
                  style: appTheme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 20),
                // Display income and expense with icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.arrow_upward,
                        color: Colors.green), // Income Icon
                    Obx(() {
                      Map<String, double> balance =
                          walletController.calculateBalanceForCurrency(
                              walletInfoController.walletName.value);
                      String currencySymbol =
                          walletController.getCurrencySymbol(
                              walletInfoController.walletName.value);
                      return Text(
                        '+$currencySymbol${balance['income']?.toStringAsFixed(2)}',
                        style: appTheme.textTheme.bodyLarge?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                          fontSize: 20, // Adjust the font size as needed
                        ),
                      );
                    }),
                    const SizedBox(width: 20),
                    const Icon(Icons.arrow_downward,
                        color: Colors.red), // Expense Icon
                    Obx(() {
                      Map<String, double> balance =
                          walletController.calculateBalanceForCurrency(
                              walletInfoController.walletName.value);
                      String currencySymbol =
                          walletController.getCurrencySymbol(
                              walletInfoController.walletName.value);
                      return Text(
                        '-$currencySymbol${balance['expense']?.toStringAsFixed(2)}',
                        style: appTheme.textTheme.bodyLarge?.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                          fontSize: 20, // Adjust the font size as needed
                        ),
                      );
                    }),
                  ],
                ),

                const SizedBox(height: 80),
                Text(
                  'Weekly Summary (Last 7 Days)',
                  style: appTheme.textTheme.bodyLarge?.copyWith(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                    fontSize: 20, // Adjust the font size as needed
                  ),
                ),

                AspectRatio(
                  aspectRatio: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      height: 300,
                      color: const Color.fromARGB(
                          255, 17, 1, 39), // Twilight background
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
                                getTitlesWidget:
                                    (double value, TitleMeta meta) {
                                  switch (value.toInt()) {
                                    case 0:
                                      return const Text('0k',
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14));
                                    case 5:
                                      return const Text('5k',
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14));
                                    case 10:
                                      return const Text('10k',
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14));
                                    case 15:
                                      return const Text('15k',
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14));
                                    case 20:
                                      return const Text('20k',
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14));
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
                                getTitlesWidget:
                                    (double value, TitleMeta meta) {
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
                                        top:
                                            20), // Adjust this value to your liking
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

                          barGroups:
                              walletController.weeklySummaries.map((summary) {
                            int index = walletController.weeklySummaries
                                .indexOf(summary);

                            // Set a minimum height for the bars
                            double minBarHeight =
                                0.2; // Adjust this value as needed

                            double incomeHeight = summary.income > 0
                                ? (summary.income > 20000
                                        ? 20000
                                        : summary.income) /
                                    1000
                                : minBarHeight;
                            double expenseHeight = summary.expense > 0
                                ? (summary.expense > 20000
                                        ? 20000
                                        : summary.expense) /
                                    1000
                                : minBarHeight;

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

                          borderData:
                              FlBorderData(show: false), // Remove border
                          gridData: const FlGridData(show: false),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.toNamed('/deposit', arguments: {
                          'walletName': walletInfoController.walletName.value,
                          'walletBalance':
                              walletInfoController.walletBalance.value,
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.green),
                        padding: const EdgeInsets.all(15),
                      ),
                      child: const Text(
                        'Deposit',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.toNamed('/withdraw');
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.all(15),
                      ),
                      child: const Text(
                        'Withdraw',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: appTheme.scaffoldBackgroundColor,
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
