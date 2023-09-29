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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Wallet Info',
          style: TextStyle(color: appTheme.secondaryHeaderColor),
        ),
        backgroundColor: appTheme.primaryColor,
      ),
      body: Obx(
        () => Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Text(
                  'Wallet Name: ${walletInfoController.walletName.value}',
                  style: appTheme.textTheme.bodyLarge,
                ),
                SizedBox(height: 20),
                Text(
                  'Wallet Balance: ${walletInfoController.walletBalance.value}',
                  style: appTheme.textTheme.bodyLarge,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_upward,
                        color: Colors.green), // Income Icon
                    Text(
                      '+${walletController.calculateIncome()}', // Display calculated income
                      style: appTheme.textTheme.bodyLarge
                          ?.copyWith(color: Colors.green),
                    ),
                    SizedBox(width: 20),
                    Icon(Icons.arrow_downward,
                        color: Colors.red), // Expense Icon
                    Text(
                      '-${walletController.calculateExpense()}', // Display calculated expense
                      style: appTheme.textTheme.bodyLarge
                          ?.copyWith(color: Colors.red),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  'Weekly Summary (Last 7 Days)',
                  style: appTheme.textTheme.bodyLarge,
                ),
                AspectRatio(
                  aspectRatio: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: BarChart(
                      BarChartData(
                        maxY: 20,
                        barGroups:
                            walletController.weeklySummaries.map((summary) {
                          int index =
                              walletController.weeklySummaries.indexOf(summary);
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                fromY: 0,
                                toY: summary.income,
                                color: leftBarColor,
                                width: barWidth,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              BarChartRodData(
                                fromY: 0,
                                toY: summary.expense,
                                color: rightBarColor,
                                width: barWidth,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ],
                          );
                        }).toList(),
                        titlesData: FlTitlesData(
                          show: true,
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                return Text('$value');
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 42,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                int index = value.toInt();
                                if (index >= 0 &&
                                    index <
                                        walletController
                                            .weeklySummaries.length) {
                                  return Text(
                                    walletController
                                        .weeklySummaries[index].week,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 22),
                                  );
                                }
                                return Text('');
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: Colors.grey, width: 1),
                        ),
                        groupsSpace: 10,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40),
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
                        side: BorderSide(color: Colors.green),
                        padding: EdgeInsets.all(15),
                      ),
                      child: Text(
                        'Deposit',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.toNamed('/withdraw');
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red),
                        padding: EdgeInsets.all(15),
                      ),
                      child: Text(
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
}
