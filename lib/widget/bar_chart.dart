import 'package:fitnc_user/page/exercice/stat-exercice.notifier.dart';
import 'package:fitnc_user/service/debug_printer.dart';
import 'package:fitnc_user/service/user-set.service.dart';
import 'package:fitness_domain/domain/exercice.domain.dart';
import 'package:fitness_domain/domain/user.set.domain.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class FitnessBarChart extends StatefulWidget {
  const FitnessBarChart({super.key, required this.exercice, required this.listUserSet});

  final Exercice exercice;
  final List<UserSet> listUserSet;

  final Color volumeColor = Colors.yellow;
  final Color repsColor = Colors.red;
  final Color avgColor = Colors.orange;

  @override
  State<StatefulWidget> createState() => FitnessBarChartState();
}

class FitnessBarChartState extends State<FitnessBarChart> {
  final double width = 14;

  late List<BarChartGroupData> rawBarGroups;
  late List<BarChartGroupData> showingBarGroups;
  late List<DateTime?> orderedListDate;
  late List<String> orderedListStringDate;
  late List<UserSet> orderedListUserSet;

  TypeChart typeChart = TypeChart.volume;
  double maxY = 0;
  int touchedGroupIndex = -1;
  double interval = 1;

  @override
  void initState() {
    super.initState();

    orderedListUserSet = [...widget.listUserSet];
    orderedListUserSet.removeWhere((element) => element.date == null);
    orderedListUserSet.sort((a, b) => a.date!.compareTo(b.date!));

    orderedListStringDate = orderedListUserSet.map((e) => DateFormat('dd/MM/yy').format(e.date!)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                makeTransactionsIcon(),
                const SizedBox(
                  width: 38,
                ),
                const Text(
                  'Transactions',
                  style: TextStyle(
                    fontSize: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 38,
            ),
            Expanded(
              child: Consumer<StatExercicePageNotifier>(builder: (context, notifier, child) {
                var increment = 0;
                final List<BarChartGroupData> listBarChartGroupData = [];

                if (notifier.typeChart != typeChart) {
                  maxY = 0;
                  typeChart = notifier.typeChart;
                }

                for (var userSet in orderedListUserSet) {
                  double data = 0;
                  switch (notifier.typeChart) {
                    case TypeChart.volume:
                      data = UserSetService.getVolume(userSet);
                      break;
                    case TypeChart.reps:
                      data = UserSetService.getMaxReps(userSet);
                      break;
                    case TypeChart.weight:
                      data = UserSetService.getMaxWeight(userSet);
                      break;
                  }
                  maxY = data > maxY ? data : maxY;
                  listBarChartGroupData.add(makeGroupData(increment, data));
                  increment++;
                }

                interval = maxY / 10;
                interval = interval.roundToDouble();
                DebugPrinter.printLn('interval : $interval');

                rawBarGroups = listBarChartGroupData;
                showingBarGroups = rawBarGroups;

                return BarChart(
                  BarChartData(
                    maxY: maxY,
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: bottomTitles,
                          reservedSize: 42,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          interval: interval,
                          getTitlesWidget: leftTitles,
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: false,
                    ),
                    barGroups: showingBarGroups,
                    gridData: const FlGridData(show: false),
                  ),
                );
              }),
            ),
            const SizedBox(
              height: 12,
            ),
          ],
        ),
      ),
    );
  }

  Widget leftTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff7589a2),
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 0,
      child: Text(
        value.toString(),
        style: style,
      ),
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    final Widget text = RotationTransition(
      turns: const AlwaysStoppedAnimation(-45 / 360),
      child: Text(
        orderedListStringDate[value.toInt()],
        style: const TextStyle(
          color: Color(0xff7589a2),
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16, //margin top
      child: text,
    );
  }

  BarChartGroupData makeGroupData(int x, double data) {
    return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: [
        BarChartRodData(
          toY: data,
          color: widget.volumeColor,
          width: width,
        ),
      ],
    );
  }

  Widget makeTransactionsIcon() {
    const width = 4.5;
    const space = 3.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: width,
          height: 10,
          color: Colors.amber.withOpacity(0.4),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 28,
          color: Colors.amber.withOpacity(0.8),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 42,
          color: Colors.amber.withOpacity(1),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 28,
          color: Colors.amber.withOpacity(0.8),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 10,
          color: Colors.amber.withOpacity(0.4),
        ),
      ],
    );
  }
}
