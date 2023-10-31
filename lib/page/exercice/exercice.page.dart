import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnc_user/fitness_router.dart';
import 'package:fitnc_user/page/exercice/add_exercice.page.dart';
import 'package:fitnc_user/page/exercice/exercice-choice.dialog.dart';
import 'package:fitnc_user/service/exercice.service.dart';
import 'package:fitness_domain/domain/exercice.domain.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

class ExerciseFilterNotifier extends ChangeNotifier {
  final ExerciceService service = GetIt.I.get();
  final StreamController<List<Exercice>> streamController = StreamController();

  List<String> groupFilters = [];
  List<String> groupSelected = [];

  get listenExercise => streamController.stream;

  ExerciseFilterNotifier() {
    init();
  }

  init() {
    service.getAll().then((listExercise) {
      streamController.sink.add(listExercise);
      groupFilters =
          listExercise.map((e) => e.group).where((element) => element != null).map((e) => e as String).toSet().toList();
      notifyListeners();
    });
  }

  bool isSelected(int index) {
    String group = groupFilters.elementAt(index);
    return groupSelected.contains(group);
  }

  setSelected(int index) {
    String group = groupFilters.elementAt(index);
    if (groupSelected.contains(group)) {
      groupSelected.removeWhere((element) => element == group);
    } else {
      groupSelected.add(group);
    }

    if (groupSelected.isNotEmpty) {
      Query query = FirebaseFirestore.instance.collection(service.getCollectionReference().path).where(
            'group',
            whereIn: groupSelected,
          );

      service.getFromQuery(query).then((value) {
        streamController.sink.add(value);
        notifyListeners();
      });
    } else {
      service.getAll().then((listExercise) {
        streamController.sink.add(listExercise);
        notifyListeners();
      });
    }

    notifyListeners();
  }
}

class ExercisePage extends StatelessWidget {
  const ExercisePage({super.key});

  final double bottomAppBarHeight = 60;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: ExerciseFilterNotifier(),
        builder: (context, child) {
          Provider.of<ExerciseFilterNotifier>(context, listen: false).init();
          return SafeArea(
            child: Scaffold(
              floatingActionButton: FloatingActionButton(
                onPressed: () => context.push(FitnessRouter.exercisesNew),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
              appBar: AppBar(
                elevation: 5,
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
                              label: Text(notifier.groupFilters.elementAt(index)),
                              selected: notifier.isSelected(index),
                              onSelected: (bool selected) => notifier.setSelected(index),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ),
              ),
              body: StreamBuilder<List<Exercice>>(
                  stream: Provider.of<ExerciseFilterNotifier>(context, listen: false).listenExercise,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text(snapshot.error.toString());
                    }
                    if (snapshot.hasData) {
                      final List<Exercice> listExercise = snapshot.data!;
                      return ListView.separated(
                        shrinkWrap: true,
                        itemCount: listExercise.length,
                        itemBuilder: (context, index) {
                          final Exercice exercice = listExercise.elementAt(index);
                          return ExerciseChoiceCard(
                            exercise: exercice,
                            selected: false,
                            showSelect: false,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => AddExercisePage(
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
                    }
                    return LoadingBouncingGrid.circle(
                      backgroundColor: Theme.of(context).primaryColor,
                    );
                  }),
            ),
          );
        });
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
                    builder: (context) => AddExercisePage(
                      exercise: Exercice(),
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('back'.i18n()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
