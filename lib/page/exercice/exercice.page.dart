import 'dart:async';

import 'package:fitnc_user/fitness_router.dart';
import 'package:fitnc_user/page/exercice/exercice-choice.dialog.dart';
import 'package:fitnc_user/page/exercice/exercice-detail.page.dart';
import 'package:fitnc_user/service/debug_printer.dart';
import 'package:fitnc_user/service/exercice.service.dart';
import 'package:fitnc_user/service/group_exercice.service.dart';
import 'package:fitnc_user/service/muscular_group.service.dart';
import 'package:fitness_domain/domain/exercice.domain.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

class Picto {
  final String name;
  final String label;
  final MuscularPart part;

  Picto(this.name, this.label, this.part);
}

class ExerciseListNotifier extends ChangeNotifier {
  final ExerciceService service = GetIt.I.get();
  StreamSubscription<List<Exercice>>? strSubExercice;

  List<Exercice> localListExercice = [];

  loadData() {
    strSubExercice?.cancel();

    strSubExercice = service.listenAll().listen((listExercice) {
      localListExercice = listExercice;
      notifyListeners();
    });
  }

  searchByGroup(List<Picto>? groupSelected) {
    strSubExercice?.cancel();
    if (groupSelected != null && groupSelected.isNotEmpty) {
      strSubExercice = service
          .whereListen('group', arrayContainsAny: groupSelected.map((e) => e.name).toList())
          .listen((listExercice) {
        localListExercice = listExercice;
        notifyListeners();
      });
    } else {
      strSubExercice = service.listenAll().listen((listExercice) {
        localListExercice = listExercice;
        notifyListeners();
      });
    }
  }
}

class ExerciseFilterNotifier extends ChangeNotifier {
  final GroupExerciceService typeExerciceService = GetIt.I.get();
  final MuscularGroupService muscularGroupService = GetIt.I.get();

  List<Picto> groupFilters = [];
  List<Picto> groupSelected = [];

  loadData() {
    groupFilters.addAll(
        MuscularGroupService.getListFront().map((e) => Picto(e.name, e.name.toLowerCase().i18n(), e.part)).toList());
    groupFilters.addAll(
        MuscularGroupService.getListBack().map((e) => Picto(e.name, e.name.toLowerCase().i18n(), e.part)).toList());

    DebugPrinter.printLn(groupFilters.toString());
  }

  bool isSelected(int index) {
    final Picto picto = groupFilters.elementAt(index);
    return groupSelected.contains(picto);
  }

  setSelected(int index) {
    final Picto picto = groupFilters.elementAt(index);
    if (groupSelected.contains(picto)) {
      groupSelected.removeWhere((element) => element == picto);
    } else {
      groupSelected.add(picto);
    }
    notifyListeners();
  }
}

class ExercisePage extends StatelessWidget {
  const ExercisePage({super.key});

  final double bottomAppBarHeight = 60;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: ExerciseListNotifier()),
        ChangeNotifierProvider.value(value: ExerciseFilterNotifier()),
      ],
      builder: (context, child) {
        Provider.of<ExerciseListNotifier>(context, listen: false).loadData();
        Provider.of<ExerciseFilterNotifier>(context, listen: false).loadData();
        return SafeArea(
          child: Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () => context.push(FitnessRouter.exercisesNew),
              child: const Icon(
                Icons.add,
              ),
            ),
            appBar: AppBar(
              title: Text(
                'exercises'.i18n(),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(40),
                child: SizedBox(
                  height: 40,
                  child: Consumer<ExerciseFilterNotifier>(builder: (context, notifier, child) {
                    return ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      itemCount: notifier.groupFilters.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: ChoiceChip(
                            label: Text(notifier.groupFilters.elementAt(index).label),
                            selected: notifier.isSelected(index),
                            onSelected: (bool selected) {
                              notifier.setSelected(index);
                              Provider.of<ExerciseListNotifier>(context, listen: false)
                                  .searchByGroup(notifier.groupSelected);
                            },
                          ),
                        );
                      },
                    );
                  }),
                ),
              ),
            ),
            body: Consumer<ExerciseListNotifier>(builder: (context, notifier, child) {
              final List<Exercice> listExercise = notifier.localListExercice;
              return ListView.separated(
                shrinkWrap: true,
                itemCount: listExercise.length,
                itemBuilder: (context, index) {
                  final Exercice exercice = listExercise.elementAt(index);
                  return ExerciseChoiceCard(
                    exercise: exercice,
                    showSelect: false,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ExerciseDetailPage(
                          exercise: exercice,
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) => const Divider(
                  height: 2.0,
                  color: Colors.grey,
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

class ExerciseBottomAppBar extends StatelessWidget {
  const ExerciseBottomAppBar({
    super.key,
    required this.bottomAppBarHeigth,
  });

  final double bottomAppBarHeigth;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Theme.of(context).bottomAppBarTheme.color,
      elevation: 10,
      child: SizedBox(
        height: bottomAppBarHeigth,
        child: Padding(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                label: Text('createExercise'.i18n()),
                icon: const Icon(Icons.add_circle_outline_rounded),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ExerciseDetailPage(
                      exercise: Exercice(),
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('return'.i18n()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
