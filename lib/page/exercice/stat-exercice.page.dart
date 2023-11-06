import 'package:fitnc_user/constants.dart';
import 'package:fitnc_user/page/exercice/stat-exercice.notifier.dart';
import 'package:fitness_domain/domain/exercice.domain.dart';
import 'package:fitness_domain/domain/user.set.domain.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/painting/text_style.dart' as text_style;
import 'package:intl/intl.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

/// Main Widget
class StatExercicePage extends StatelessWidget {
  const StatExercicePage({super.key, required this.exercice});

  final Exercice exercice;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: StatExercicePageNotifier(),
        builder: (context, child) {
          return Consumer<StatExercicePageNotifier>(builder: (context, controller, child) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                title: Text(
                  'Stats : ${exercice.name}',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Theme.of(context).primaryColor),
                ),
                leading: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.amber,
                  ),
                ),
              ),
              body: FutureBuilder<List<UserSet>>(
                initialData: const <UserSet>[],
                future: controller.getAllUserSetByExercice(exercice.uid!),
                builder: (_, snapshot) {
                  if (snapshot.hasError) {
                    return SelectableText(snapshot.error.toString());
                  }
                  if (snapshot.hasData) {
                    final List<UserSet> listUserSet = snapshot.data!;
                    if (listUserSet.isNotEmpty) {
                      controller.selectedUserSet.value = listUserSet.elementAt(0);
                    }
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Material(
                          elevation: 2,
                          borderOnForeground: false,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: Chart(exercice: exercice, listUserSet: listUserSet),
                              ),
                              const BarButtons(),
                            ],
                          ),
                        ),
                        Expanded(child: ListSeance(exercice: exercice, listUserSet: listUserSet)),
                      ],
                    );
                  }
                  return LoadingRotating.square();
                },
              ),
            );
          });
        });
  }
}

class BarButtons extends StatelessWidget {
  const BarButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StatExercicePageNotifier>(
      builder: (context, controller, child) {
        TypeChart typeChartSelected = controller.typeChart.value;
        return ButtonBar(
          alignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              onPressed: () => controller.typeChart.value = TypeChart.volume,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  if (typeChartSelected == TypeChart.volume) {
                    return Theme.of(context).primaryColor;
                  }
                  return null;
                }),
              ),
              child: Text(
                'Volume',
                style: text_style.TextStyle(
                    color: typeChartSelected == TypeChart.volume ? Colors.white : Theme.of(context).primaryColor),
              ),
            ),
            OutlinedButton(
              onPressed: () => controller.typeChart.value = TypeChart.reps,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  if (typeChartSelected == TypeChart.reps) {
                    return Theme.of(context).primaryColor;
                  }
                  return null;
                }),
              ),
              child: Text(
                'Max reps.',
                style: text_style.TextStyle(
                    color: typeChartSelected == TypeChart.reps ? Colors.white : Theme.of(context).primaryColor),
              ),
            ),
            OutlinedButton(
              onPressed: () => controller.typeChart.value = TypeChart.weight,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  if (typeChartSelected == TypeChart.weight) {
                    return Theme.of(context).primaryColor;
                  }
                  return null;
                }),
              ),
              child: Text(
                'Max weight',
                style: text_style.TextStyle(
                    color: typeChartSelected == TypeChart.weight ? Colors.white : Theme.of(context).primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }
}

class ListSeance extends StatelessWidget {
  const ListSeance({super.key, required this.exercice, required this.listUserSet});

  final Exercice exercice;
  final List<UserSet> listUserSet;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: listUserSet.length,
              separatorBuilder: (_, __) => const Divider(
                color: Colors.grey,
                thickness: 1,
                height: 1,
              ),
              itemBuilder: (_, int index) => UserSetCard(
                userSet: listUserSet.elementAt(index),
              ),
            ),
          ),
        )
      ],
    );
  }
}

class Chart extends StatelessWidget {
  Chart({
    super.key,
    required this.exercice,
    required this.listUserSet,
    final Color? gradientColor1,
    final Color? gradientColor2,
    final Color? gradientColor3,
    final Color? indicatorStrokeColor,
  })  : gradientColor1 = gradientColor1 ?? Colors.blue,
        gradientColor2 = gradientColor2 ?? Colors.pink,
        gradientColor3 = gradientColor3 ?? Colors.red,
        indicatorStrokeColor = indicatorStrokeColor ?? Colors.blueGrey;

  final Exercice exercice;
  final List<UserSet> listUserSet;

  final Color gradientColor1;
  final Color gradientColor2;
  final Color gradientColor3;
  final Color indicatorStrokeColor;

  final List<int> showingTooltipOnSpots = [1, 3, 5];

  List<FlSpot> get allSpots => const [
        FlSpot(0, 10),
        FlSpot(1, 2),
        FlSpot(2, 1.5),
        FlSpot(3, 3),
        FlSpot(4, 3.5),
        FlSpot(5, 5),
        FlSpot(6, 8),
      ];

  Widget bottomTitleWidgets(double value, TitleMeta meta, double chartWidth) {
    final style = TextStyle(
      fontWeight: FontWeight.bold,
      color: FitnessNcColors.amber,
      fontFamily: 'Digital',
      fontSize: 18 * chartWidth / 500,
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = '00:00';
        break;
      case 1:
        text = '04:00';
        break;
      case 2:
        text = '08:00';
        break;
      case 3:
        text = '12:00';
        break;
      case 4:
        text = '16:00';
        break;
      case 5:
        text = '20:00';
        break;
      case 6:
        text = '23:59';
        break;
      default:
        return Container();
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text, style: style),
    );
  }

  /// Lerps between a [LinearGradient] colors, based on [t]
  Color lerpGradient(List<Color> colors, List<double> stops, double t) {
    if (colors.isEmpty) {
      throw ArgumentError('"colors" is empty.');
    } else if (colors.length == 1) {
      return colors[0];
    }

    if (stops.length != colors.length) {
      stops = [];

      /// provided gradientColorStops is invalid and we calculate it here
      colors.asMap().forEach((index, color) {
        final percent = 1.0 / (colors.length - 1);
        stops.add(percent * index);
      });
    }

    for (var s = 0; s < stops.length - 1; s++) {
      final leftStop = stops[s];
      final rightStop = stops[s + 1];
      final leftColor = colors[s];
      final rightColor = colors[s + 1];
      if (t <= leftStop) {
        return leftColor;
      } else if (t < rightStop) {
        final sectionT = (t - leftStop) / (rightStop - leftStop);
        return Color.lerp(leftColor, rightColor, sectionT)!;
      }
    }
    return colors.last;
  }

  @override
  Widget build(BuildContext context) {
    final lineBarsData = [
      LineChartBarData(
        showingIndicators: showingTooltipOnSpots,
        spots: allSpots,
        isCurved: true,
        barWidth: 4,
        shadow: const Shadow(
          blurRadius: 8,
        ),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [
              gradientColor1.withOpacity(0.4),
              gradientColor2.withOpacity(0.4),
              gradientColor3.withOpacity(0.4),
            ],
          ),
        ),
        dotData: const FlDotData(show: false),
        gradient: LinearGradient(
          colors: [
            gradientColor1,
            gradientColor2,
            gradientColor3,
          ],
          stops: const [0.1, 0.4, 0.9],
        ),
      ),
    ];

    final tooltipsOnBar = lineBarsData[0];

    return SizedBox(
      height: 200,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return LineChart(
            LineChartData(
              showingTooltipIndicators: showingTooltipOnSpots.map((index) {
                return ShowingTooltipIndicators([
                  LineBarSpot(
                    tooltipsOnBar,
                    lineBarsData.indexOf(tooltipsOnBar),
                    tooltipsOnBar.spots[index],
                  ),
                ]);
              }).toList(),
              lineTouchData: LineTouchData(
                enabled: true,
                handleBuiltInTouches: false,
                touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
                  if (response == null || response.lineBarSpots == null) {
                    return;
                  }
                  if (event is FlTapUpEvent) {
                    final spotIndex = response.lineBarSpots!.first.spotIndex;
                  }
                },
                mouseCursorResolver: (FlTouchEvent event, LineTouchResponse? response) {
                  if (response == null || response.lineBarSpots == null) {
                    return SystemMouseCursors.basic;
                  }
                  return SystemMouseCursors.click;
                },
                getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
                  return spotIndexes.map((index) {
                    return TouchedSpotIndicatorData(
                      const FlLine(
                        color: Colors.pink,
                      ),
                      FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                          radius: 8,
                          color: lerpGradient(
                            barData.gradient!.colors,
                            barData.gradient!.stops!,
                            percent / 100,
                          ),
                          strokeWidth: 2,
                          strokeColor: indicatorStrokeColor,
                        ),
                      ),
                    );
                  }).toList();
                },
                touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor: Colors.pink,
                  tooltipRoundedRadius: 8,
                  getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
                    return lineBarsSpot.map((lineBarSpot) {
                      return LineTooltipItem(
                        lineBarSpot.y.toString(),
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              lineBarsData: lineBarsData,
              minY: 0,
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  axisNameWidget: Text('count'),
                  axisNameSize: 24,
                  sideTitles: SideTitles(
                    showTitles: false,
                    reservedSize: 0,
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      return bottomTitleWidgets(
                        value,
                        meta,
                        constraints.maxWidth,
                      );
                    },
                    reservedSize: 30,
                  ),
                ),
                rightTitles: const AxisTitles(
                  axisNameWidget: Text('count'),
                  sideTitles: SideTitles(
                    showTitles: false,
                    reservedSize: 0,
                  ),
                ),
                topTitles: const AxisTitles(
                  axisNameWidget: Text(
                    'Wall clock',
                    textAlign: TextAlign.left,
                  ),
                  axisNameSize: 24,
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 0,
                  ),
                ),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(
                show: true,
                border: Border.all(
                  color: Colors.cyan,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class UserSetCard extends StatelessWidget {
  const UserSetCard({super.key, required this.userSet});

  final UserSet userSet;

  @override
  Widget build(BuildContext context) {
    return Consumer<StatExercicePageNotifier>(builder: (context, controller, child) {
      return InkWell(
        child: ListTile(
          selected: controller.selectedUserSet.value.uid == userSet.uid,
          selectedTileColor: Colors.grey.withAlpha(50),
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('dd/MM/yy - kk:mm').format(userSet.date!),
                  style: const text_style.TextStyle(fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          const Text(
                            'volume',
                            style: text_style.TextStyle(fontSize: 12),
                          ),
                          Text('${controller.getVolume(userSet)}'),
                        ],
                      ),
                      Column(
                        children: [
                          const Text(
                            'max reps.',
                            style: text_style.TextStyle(fontSize: 12),
                          ),
                          Text('${controller.getMaxReps(userSet)}'),
                        ],
                      ),
                      Column(
                        children: [
                          const Text(
                            'max weight',
                            style: text_style.TextStyle(fontSize: 12),
                          ),
                          Text('${controller.getMaxWeight(userSet)}'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          if (userSet.date != null) {
            controller.dateSelected.value = Tuple2(userSet.uidExercice, userSet.date!);
          }
          controller.selectedUserSet.value = userSet;
        },
      );
    });
  }
}
