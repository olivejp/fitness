import 'package:community_charts_flutter/community_charts_flutter.dart' as charts;
import 'package:fitnc_user/widget/time-series-chart.widget.dart';
import 'package:fitnc_user/domain/exercice.domain.dart';
import 'package:fitnc_user/domain/user-set.domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/painting/text_style.dart' as text_style;
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:tuple/tuple.dart';
import 'package:fitnc_user/page/stat-exercice/stat-exercice.notifier.dart';

/// Main Widget
class StatExercicePage extends StatefulWidget {
  const StatExercicePage({Key? key, required this.exercice}) : super(key: key);
  final Exercice exercice;

  @override
  State<StatExercicePage> createState() => _StatExercicePageState();
}

class _StatExercicePageState extends State<StatExercicePage> {
  final StatExerciceNotifier notifier = StatExerciceNotifier();

  Exercice get exercice => widget.exercice;

  @override
  void dispose() {
    notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        future: notifier.getAllUserSetByExercice(exercice.uid!),
        builder: (_, snapshot) {
          if (snapshot.hasError) {
            return SelectableText(snapshot.error.toString());
          }
          if (snapshot.hasData) {
            final List<UserSet> listUserSet = snapshot.data!;
            if (listUserSet.isNotEmpty) {
              notifier.selectedUserSet.value = listUserSet.elementAt(0);
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
                        child: Chart(
                          exercice: exercice,
                          listUserSet: listUserSet,
                          notifier: notifier,
                        ),
                      ),
                      BarButtons(notifier: notifier),
                    ],
                  ),
                ),
                Expanded(
                  child: ListSeance(
                    exercice: exercice,
                    listUserSet: listUserSet,
                    notifier: notifier,
                  ),
                ),
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
  const BarButtons({Key? key, required this.notifier}) : super(key: key);

  final StatExerciceNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TypeChart>(
      valueListenable: notifier.typeChart,
      builder: (_, TypeChart typeChartSelected, __) {
        return ButtonBar(
          alignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              onPressed: () => notifier.typeChart.value = TypeChart.volume,
              child: Text(
                'Volume',
                style: text_style.TextStyle(
                    color: typeChartSelected == TypeChart.volume ? Colors.white : Theme.of(context).colorScheme.primary),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  if (typeChartSelected == TypeChart.volume) {
                    return Theme.of(context).colorScheme.primary;
                  }
                }),
              ),
            ),
            OutlinedButton(
              onPressed: () => notifier.typeChart.value = TypeChart.reps,
              child: Text(
                'Max reps.',
                style: text_style.TextStyle(
                    color: typeChartSelected == TypeChart.reps ? Colors.white : Theme.of(context).colorScheme.primary),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  if (typeChartSelected == TypeChart.reps) {
                    return Theme.of(context).colorScheme.primary;
                  }
                }),
              ),
            ),
            OutlinedButton(
              onPressed: () => notifier.typeChart.value = TypeChart.weight,
              child: Text(
                'Max weight',
                style: text_style.TextStyle(
                    color: typeChartSelected == TypeChart.weight ? Colors.white : Theme.of(context).colorScheme.primary),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  if (typeChartSelected == TypeChart.weight) {
                    return Theme.of(context).colorScheme.primary;
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
  const ListSeance(
      {Key? key,
      required this.exercice,
      required this.listUserSet,
      required this.notifier})
      : super(key: key);
  final Exercice exercice;
  final List<UserSet> listUserSet;
  final StatExerciceNotifier notifier;

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
                notifier: notifier,
              ),
            ),
          ),
        )
      ],
    );
  }
}

class Chart extends StatelessWidget {
  const Chart(
      {Key? key,
      required this.exercice,
      required this.listUserSet,
      required this.notifier})
      : super(key: key);
  final Exercice exercice;
  final List<UserSet> listUserSet;
  final StatExerciceNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ValueListenableBuilder<TypeChart>(
        valueListenable: notifier.typeChart,
        builder: (_, TypeChart typeChart, __) {
          List<charts.Series<TimeSeries, DateTime>> list = [];
          switch (typeChart) {
            case TypeChart.volume:
              list = notifier.getWorkoutVolume(listUserSet, exercice);
              break;
            case TypeChart.reps:
              list = notifier.getWorkoutMaxReps(listUserSet, exercice);
              break;
            case TypeChart.weight:
              list = notifier.getWorkoutMaxWeight(listUserSet, exercice);
              break;
          }

          if (list.isEmpty) {
            return const Text('Aucun élément à afficher');
          } else {
            return ValueListenableBuilder<Tuple2<String, DateTime>>(
              valueListenable: notifier.dateSelected,
              builder: (_, Tuple2<String, DateTime> dateSelected, __) =>
                  SimpleTimeSeriesChart(
                list,
                animate: true,
                initialDateSelection: dateSelected,
                onChange: (charts.SelectionModel<DateTime> model) {
                  if (model.selectedDatum.elementAt(0).datum.object is UserSet) {
                    notifier.selectedUserSet.value = model.selectedDatum.elementAt(0).datum.object;
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
  const UserSetCard({Key? key, required this.userSet, required this.notifier})
      : super(key: key);
  final UserSet userSet;
  final StatExerciceNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: ValueListenableBuilder<UserSet>(
        valueListenable: notifier.selectedUserSet,
        builder: (_, UserSet selected, __) => ListTile(
          selected: selected.uid == userSet.uid,
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
                          Text('${notifier.getVolume(userSet)}'),
                        ],
                      ),
                      Column(
                        children: [
                          const Text(
                            'max reps.',
                            style: text_style.TextStyle(fontSize: 12),
                          ),
                          Text('${notifier.getMaxReps(userSet)}'),
                        ],
                      ),
                      Column(
                        children: [
                          const Text(
                            'max weight',
                            style: text_style.TextStyle(fontSize: 12),
                          ),
                          Text('${notifier.getMaxWeight(userSet)}'),
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
          notifier.dateSelected.value = Tuple2(userSet.uidExercice, userSet.date!);
        }
        notifier.selectedUserSet.value = userSet;
      },
    );
  }
}
