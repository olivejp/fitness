// import 'package:charts_flutter/flutter.dart' as charts;
// import 'package:charts_flutter/flutter.dart';
import 'package:fitnc_user/page/exercice/stat-exercice.notifier.dart';
import 'package:fitness_domain/domain/exercice.domain.dart';
import 'package:fitness_domain/domain/user.set.domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/painting/text_style.dart' as text_style;
import 'package:google_fonts/google_fonts.dart';
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
                  style: GoogleFonts.comfortaa(fontSize: 18),
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
  const Chart({super.key, required this.exercice, required this.listUserSet});

  final Exercice exercice;
  final List<UserSet> listUserSet;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Consumer<StatExercicePageNotifier>(
        builder: (context, controller, child) {
          // List<charts.Series<TimeSeries, DateTime>> list = [];
          // switch (controller.typeChart.value) {
          //   case TypeChart.volume:
          //     list = controller.getWorkoutVolume(listUserSet, exercice);
          //     break;
          //   case TypeChart.reps:
          //     list = controller.getWorkoutMaxReps(listUserSet, exercice);
          //     break;
          //   case TypeChart.weight:
          //     list = controller.getWorkoutMaxWeight(listUserSet, exercice);
          //     break;
          // }

          // if (list.isEmpty) {
          return const Text('Aucun élément à afficher');
          // } else {
          //   return const Text('Aucun élément à afficher');
          // TODO A REMPLACER
          // return Obx(
          //   () => SimpleTimeSeriesChart(
          //     list,
          //     animate: true,
          //     initialDateSelection: controller.dateSelected.value,
          //     onChange: (SelectionModel<DateTime> model) {
          //       if (model.selectedDatum.elementAt(0).datum.object is UserSet) {
          //         controller.selectedUserSet.value = model.selectedDatum.elementAt(0).datum.object;
          //       }
          //     },
          //   ),
          // );
          // }
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
