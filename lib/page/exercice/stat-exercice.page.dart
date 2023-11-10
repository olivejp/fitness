import 'package:fitnc_user/page/exercice/stat-exercice.notifier.dart';
import 'package:fitnc_user/widget/bar_chart.dart';
import 'package:fitness_domain/domain/exercice.domain.dart';
import 'package:fitness_domain/domain/user.set.domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/painting/text_style.dart' as text_style;
import 'package:intl/intl.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

/// TODO Finir les stats
class StatExercicePage extends StatelessWidget {
  const StatExercicePage({super.key, required this.exercice});

  final Exercice exercice;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: StatExercicePageNotifier(),
        builder: (context, child) {
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
              future:
                  Provider.of<StatExercicePageNotifier>(context, listen: false).getAllUserSetByExercice(exercice.uid!),
              builder: (_, snapshot) {
                if (snapshot.hasError) {
                  return SelectableText(snapshot.error.toString());
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return LoadingBouncingGrid.square();
                }
                if (snapshot.connectionState == ConnectionState.done) {
                  final List<UserSet> listUserSet = snapshot.data!;
                  if (listUserSet.isNotEmpty) {
                    Provider.of<StatExercicePageNotifier>(context, listen: false).selectedUserSet =
                        listUserSet.elementAt(0);
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
                              child: FitnessBarChart(
                                exercice: exercice,
                                listUserSet: listUserSet,
                              ),
                            ),
                            const BarButtons(),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListSeance(
                          exercice: exercice,
                          listUserSet: listUserSet,
                        ),
                      ),
                    ],
                  );
                }
                return LoadingRotating.square();
              },
            ),
          );
        });
  }
}

class BarButtons extends StatelessWidget {
  const BarButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StatExercicePageNotifier>(
      builder: (context, controller, child) {
        TypeChart typeChartSelected = controller.typeChart;
        return ButtonBar(
          alignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              onPressed: () => controller.typeChart = TypeChart.volume,
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
              onPressed: () => controller.typeChart = TypeChart.reps,
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
              onPressed: () => controller.typeChart = TypeChart.weight,
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

class UserSetCard extends StatelessWidget {
  const UserSetCard({super.key, required this.userSet});

  final UserSet userSet;

  @override
  Widget build(BuildContext context) {
    return Consumer<StatExercicePageNotifier>(builder: (context, controller, child) {
      return InkWell(
        child: ListTile(
          selected: controller.selectedUserSet.uid == userSet.uid,
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
            controller.dateSelected = Tuple2(userSet.uidExercice, userSet.date!);
          }
          controller.selectedUserSet = userSet;
        },
      );
    });
  }
}
