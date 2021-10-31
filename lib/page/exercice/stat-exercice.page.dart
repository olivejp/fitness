import 'package:charts_flutter/flutter.dart' as charts;
import 'package:charts_flutter/flutter.dart';
import 'package:fitnc_user/service/user-set.service.dart';
import 'package:fitnc_user/service/workout-instance.service.dart';
import 'package:fitnc_user/widget/time-series-chart.widget.dart';
import 'package:fitness_domain/domain/exercice.domain.dart';
import 'package:fitness_domain/domain/user.line.domain.dart';
import 'package:fitness_domain/domain/user.set.domain.dart';
import 'package:fitness_domain/domain/workout-instance.domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/painting/text_style.dart' as text_style;
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:tuple/tuple.dart';

enum TypeChart {
  volume,
  reps,
  weight,
}

/// Controller
class StatExercicePageController extends GetxController {
  final UserSetService userSetService = Get.find();
  final WorkoutInstanceService workoutInstanceService = Get.find();
  final Rx<Tuple2<String, DateTime>> dateSelected = Tuple2('', DateTime.now()).obs;
  final Rx<TypeChart> typeChart = TypeChart.volume.obs;
  final Rx<UserSet> selectedUserSet = UserSet().obs;

  Future<List<UserSet>> getAllUserSetByExercice(String exerciceUid) {
    return userSetService.getForExercice(exerciceUid);
  }

  Future<WorkoutInstance?> getWorkoutInstance(String uidWorkout) {
    return workoutInstanceService.read(uidWorkout);
  }

  List<charts.Series<TimeSeries, DateTime>> toChartSeries(String exerciceUid, List<TimeSeries> data) {
    data.sort((a, b) => a.time.compareTo(b.time));
    return [
      charts.Series<TimeSeries, DateTime>(
        id: exerciceUid,
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TimeSeries sales, _) => sales.time,
        measureFn: (TimeSeries sales, _) => sales.total,
        data: data,
      )
    ];
  }

  int getVolume(UserSet userSet) {
    int volume = 0;
    if (userSet.lines.isNotEmpty) {
      for (UserLine userLine in userSet.lines) {
        if (userLine.weight != null && userLine.reps != null) {
          volume += int.parse(userLine.weight!) * int.parse(userLine.reps!);
        }
      }
    }
    return volume;
  }

  int getMaxReps(UserSet userSet) {
    int maxReps = 0;
    if (userSet.lines.isNotEmpty) {
      for (UserLine userLine in userSet.lines) {
        if (userLine.reps != null) {
          int userLineReps = int.parse(userLine.reps!);
          maxReps = (userLineReps > maxReps) ? userLineReps : maxReps;
        }
      }
    }
    return maxReps;
  }

  int getMaxWeight(UserSet userSet) {
    int maxWeight = 0;
    if (userSet.lines.isNotEmpty) {
      for (UserLine userLine in userSet.lines) {
        if (userLine.weight != null) {
          int userLineReps = int.parse(userLine.weight!);
          maxWeight = (userLineReps > maxWeight) ? userLineReps : maxWeight;
        }
      }
    }
    return maxWeight;
  }

  List<charts.Series<TimeSeries, DateTime>> getWorkoutVolume(List<UserSet> listUserSet, Exercice exercice) {
    if (listUserSet.isEmpty) {
      return [];
    }

    final String exerciceUid = exercice.uid!;
    final data = <TimeSeries>[];
    for (UserSet userSet in listUserSet) {
      data.add(TimeSeries<UserSet>(userSet.date!, getVolume(userSet), userSet));
    }

    return toChartSeries(exerciceUid, data);
  }

  List<charts.Series<TimeSeries, DateTime>> getWorkoutMaxReps(List<UserSet> listUserSet, Exercice exercice) {
    if (listUserSet.isEmpty) {
      return [];
    }

    final String exerciceUid = exercice.uid!;
    final data = <TimeSeries>[];
    for (UserSet userSet in listUserSet) {
      data.add(TimeSeries<UserSet>(userSet.date!, getMaxReps(userSet), userSet));
    }

    return toChartSeries(exerciceUid, data);
  }

  List<charts.Series<TimeSeries, DateTime>> getWorkoutMaxWeight(List<UserSet> listUserSet, Exercice exercice) {
    if (listUserSet.isEmpty) {
      return [];
    }

    final String exerciceUid = exercice.uid!;
    final data = <TimeSeries>[];
    for (UserSet userSet in listUserSet) {
      data.add(TimeSeries<UserSet>(userSet.date!, getMaxWeight(userSet), userSet));
    }

    return toChartSeries(exerciceUid, data);
  }
}

/// Main Widget
class StatExercicePage extends StatelessWidget {
  const StatExercicePage({Key? key, required this.exercice}) : super(key: key);
  final Exercice exercice;

  @override
  Widget build(BuildContext context) {
    final StatExercicePageController controller = Get.put(StatExercicePageController());
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
  }
}

class BarButtons extends StatelessWidget {
  const BarButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final StatExercicePageController controller = Get.find();
    return Obx(
      () {
        TypeChart typeChartSelected = controller.typeChart.value;
        return ButtonBar(
          alignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              onPressed: () => controller.typeChart.value = TypeChart.volume,
              child: Text(
                'Volume',
                style: text_style.TextStyle(
                    color: typeChartSelected == TypeChart.volume ? Colors.white : Theme.of(context).primaryColor),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  if (typeChartSelected == TypeChart.volume) {
                    return Theme.of(context).primaryColor;
                  }
                }),
              ),
            ),
            OutlinedButton(
              onPressed: () => controller.typeChart.value = TypeChart.reps,
              child: Text(
                'Max reps.',
                style: text_style.TextStyle(
                    color: typeChartSelected == TypeChart.reps ? Colors.white : Theme.of(context).primaryColor),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  if (typeChartSelected == TypeChart.reps) {
                    return Theme.of(context).primaryColor;
                  }
                }),
              ),
            ),
            OutlinedButton(
              onPressed: () => controller.typeChart.value = TypeChart.weight,
              child: Text(
                'Max weight',
                style: text_style.TextStyle(
                    color: typeChartSelected == TypeChart.weight ? Colors.white : Theme.of(context).primaryColor),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  if (typeChartSelected == TypeChart.weight) {
                    return Theme.of(context).primaryColor;
                  }
                }),
              ),
            ),
          ],
        );
      },
    );
  }
}

class ListSeance extends StatelessWidget {
  const ListSeance({Key? key, required this.exercice, required this.listUserSet}) : super(key: key);
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
  const Chart({Key? key, required this.exercice, required this.listUserSet}) : super(key: key);
  final Exercice exercice;
  final List<UserSet> listUserSet;

  @override
  Widget build(BuildContext context) {
    final StatExercicePageController controller = Get.find();

    return SizedBox(
      height: 200,
      child: Obx(
        () {
          List<charts.Series<TimeSeries, DateTime>> list = [];
          switch (controller.typeChart.value) {
            case TypeChart.volume:
              list = controller.getWorkoutVolume(listUserSet, exercice);
              break;
            case TypeChart.reps:
              list = controller.getWorkoutMaxReps(listUserSet, exercice);
              break;
            case TypeChart.weight:
              list = controller.getWorkoutMaxWeight(listUserSet, exercice);
              break;
          }

          if (list.isEmpty) {
            return const Text('Aucun élément à afficher');
          } else {
            return Obx(
              () => SimpleTimeSeriesChart(
                list,
                animate: true,
                initialDateSelection: controller.dateSelected.value,
                onChange: (SelectionModel<DateTime> model) {
                  if (model.selectedDatum.elementAt(0).datum.object is UserSet) {
                    controller.selectedUserSet.value = model.selectedDatum.elementAt(0).datum.object;
                  }
                },
              ),
            );
          }
        },
      ),
    );
  }
}

class UserSetCard extends StatelessWidget {
  const UserSetCard({Key? key, required this.userSet}) : super(key: key);
  final UserSet userSet;

  @override
  Widget build(BuildContext context) {
    final StatExercicePageController controller = Get.find();
    return InkWell(
      child: Obx(
        () => ListTile(
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
      ),
      onTap: () {
        if (userSet.date != null) {
          controller.dateSelected.value = Tuple2(userSet.uidExercice, userSet.date!);
        }
        controller.selectedUserSet.value = userSet;
      },
    );
  }
}
