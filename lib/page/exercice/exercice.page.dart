import 'dart:async';

import 'package:badges/badges.dart' as badges;
import 'package:fitnc_user/fitness_router.dart';
import 'package:fitnc_user/page/exercice/exercice-choice.dialog.dart';
import 'package:fitnc_user/page/exercice/exercice-detail.page.dart';
import 'package:fitnc_user/service/exercice.service.dart';
import 'package:fitnc_user/service/muscular_group.service.dart';
import 'package:fitnc_user/service/ref-exercice.service.dart';
import 'package:fitness_domain/domain/exercice.domain.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class Picto {
  final String name;
  final String label;
  final MuscularPart part;

  Picto(this.name, this.label, this.part);
}

class ExerciseListNotifier extends ChangeNotifier {
  final ExerciceService service = GetIt.I.get();
  final RefExerciceService refExerciceService = GetIt.I.get();
  StreamSubscription<List<Exercice>>? strSubExercice;

  List<Exercice> localListExercice = [];

  loadData() {
    strSubExercice?.cancel();

    strSubExercice = service.listenAllAndRef().listen((listExercice) {
      localListExercice = listExercice;
      notifyListeners();
    });
  }

  searchByGroup(List<Picto>? groupSelected) {
    strSubExercice?.cancel();
    if (groupSelected != null && groupSelected.isNotEmpty) {
      strSubExercice = ZipStream(
          [
            service.whereListen('group', arrayContainsAny: groupSelected.map((e) => e.name).toList()),
            refExerciceService.whereListen('group', arrayContainsAny: groupSelected.map((e) => e.name).toList()),
          ],
          (values) => values.reduce((value, element) {
                value.addAll(element);
                return value;
              })).listen((listExercice) {
        localListExercice = listExercice;
        notifyListeners();
      });
    } else {
      strSubExercice = service.listenAllAndRef().listen((listExercice) {
        localListExercice = listExercice;
        notifyListeners();
      });
    }
  }
}

class ExerciseFilterNotifier extends ChangeNotifier {
  final MuscularGroupService muscularGroupService = GetIt.I.get();

  List<Picto> groupFilters = [];
  List<Picto> groupSelected = [];

  loadData() {
    groupFilters.addAll(MuscularGroupService.getListFront().map((e) => Picto(e.name, e.name.i18n(), e.part)).toList());
    groupFilters.addAll(MuscularGroupService.getListBack().map((e) => Picto(e.name, e.name.i18n(), e.part)).toList());
  }

  bool isSelected(Picto picto) {
    return groupSelected.contains(picto);
  }

  setSelected(Picto picto) {
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
          child: Builder(
            builder: (scaffoldContext) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(
                    'exercises'.i18n(),
                    style: Theme.of(scaffoldContext).textTheme.displaySmall?.copyWith(
                          color: Theme.of(scaffoldContext).primaryColor,
                        ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: IconButton(
                        onPressed: () => showModalBottomSheet(
                          context: scaffoldContext,
                          builder: (context) {
                            final ExerciseFilterNotifier notifierFilter = Provider.of(scaffoldContext, listen: false);
                            return ChangeNotifierProvider.value(
                                value: notifierFilter,
                                builder: (context, child) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(),
                                            Flexible(
                                              child: Text(
                                                'Filtrer',
                                                style: Theme.of(scaffoldContext).textTheme.displaySmall?.copyWith(
                                                      color: Theme.of(scaffoldContext).primaryColor,
                                                    ),
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () => Navigator.of(context).pop(),
                                              icon: const Icon(Icons.close),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 10.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Groupes musculaires',
                                              style: GoogleFonts.anton(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                            Consumer<ExerciseFilterNotifier>(builder: (_, notifierFilter, child) {
                                              return SingleChildScrollView(
                                                child: Wrap(
                                                    runSpacing: 5.0,
                                                    children: notifierFilter.groupFilters.map((e) {
                                                      return Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                                        child: ChoiceChip(
                                                          label: Text(e.label),
                                                          selected: notifierFilter.isSelected(e),
                                                          onSelected: (bool selected) {
                                                            notifierFilter.setSelected(e);
                                                            Provider.of<ExerciseListNotifier>(scaffoldContext,
                                                                    listen: false)
                                                                .searchByGroup(notifierFilter.groupSelected);
                                                          },
                                                        ),
                                                      );
                                                    }).toList()),
                                              );
                                            }),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                });
                          },
                        ),
                        icon: Consumer<ExerciseFilterNotifier>(builder: (context, not, child) {
                          return badges.Badge(
                            showBadge: not.groupSelected.isNotEmpty,
                            child: const Icon(Icons.filter_list),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
                floatingActionButton: FloatingActionButton.extended(
                  onPressed: () => context.push(FitnessRouter.exercisesNew),
                  label: Row(
                    children: [
                      Text('createExercise'.i18n()),
                      const Icon(
                        Icons.add,
                      ),
                    ],
                  ),
                ),
                body: Consumer<ExerciseListNotifier>(builder: (context, notifier, child) {
                  final List<Exercice> listExercise = notifier.localListExercice;
                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: listExercise.length,
                    itemBuilder: (context, index) {
                      final Exercice exercice = listExercise.elementAt(index);
                      return ExerciseCard(
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
              );
            },
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
