import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_web/services/users/user_service.dart';

class UserStatsPage extends StatefulWidget {
  const UserStatsPage({super.key});

  @override
  _UserStatsPageState createState() => _UserStatsPageState();
}

class _UserStatsPageState extends State<UserStatsPage> {
  bool isLoading = true;
  int userCount = 0;
  int messageCount = 0;

  @override
  void initState() {
    super.initState();
    fetchUserStats();
  }

  void fetchUserStats() async {
    setState(() {
      isLoading = true;
    });
    try {
      final stats = await UserService.fetchUserStats();
      setState(() {
        userCount = stats['user_count'];
        messageCount = stats['message_count'];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Statistiques des Utilisateurs',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true, // Centrer le titre dans la AppBar
        backgroundColor:
            Colors.lightBlue[100], // Couleur uniforme avec les autres pages
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(10),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  // const Text(
                  //   'Statistiques des Utilisateurs',
                  //   style: TextStyle(fontSize: 20),
                  // ),
                  const SizedBox(height: 20),
                  Container(
                    height: 300,
                    padding: const EdgeInsets.all(16.0),
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: (userCount > messageCount
                                ? userCount
                                : messageCount) +
                            1.0,
                        barGroups: [
                          BarChartGroupData(
                            x: 0,
                            barRods: [
                              BarChartRodData(
                                toY: userCount.toDouble(),
                                color: Colors.blue,
                                width: 16,
                              ),
                            ],
                          ),
                          BarChartGroupData(
                            x: 1,
                            barRods: [
                              BarChartRodData(
                                toY: messageCount.toDouble(),
                                color: Colors.red,
                                width: 16,
                              ),
                            ],
                          ),
                        ],
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                return Text(value.toInt().toString());
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                switch (value.toInt()) {
                                  case 0:
                                    return const Text('Utilisateurs');
                                  case 1:
                                    return const Text('Messages');
                                  default:
                                    return const Text('');
                                }
                              },
                            ),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(
                          show: true,
                          border: const Border(
                            bottom: BorderSide(color: Colors.black, width: 1),
                            left: BorderSide(color: Colors.black, width: 1),
                            right: BorderSide(color: Colors.transparent),
                            top: BorderSide(color: Colors.transparent),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Nombre total d\'utilisateurs : $userCount',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Nombre total de messages : $messageCount',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
    );
  }
}
