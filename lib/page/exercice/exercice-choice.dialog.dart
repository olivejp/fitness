import 'dart:async';

import 'package:badges/badges.dart' as badges;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnc_user/page/exercice/exercice.page.dart';
import 'package:fitnc_user/page/workout/workout-instance.page.dart';
import 'package:fitnc_user/service/debug_printer.dart';
import 'package:fitnc_user/service/exercice.service.dart';
import 'package:fitnc_user/service/muscular_group.service.dart';
import 'package:fitnc_user/service/user-set.service.dart';
import 'package:fitnc_user/service/workout-instance.service.dart';
import 'package:fitnc_user/widget/network_image.widget.dart';
import 'package:fitness_domain/domain/exercice.domain.dart';
import 'package:fitness_domain/domain/user.set.domain.dart';
import 'package:fitness_domain/domain/workout-instance.domain.dart';
import 'package:fitness_domain/enum/type_workout.enum.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/streams.dart';

class ExerciseChoiceFilterNotifier extends ChangeNotifier {
  final MuscularGroupService muscularGroupService = GetIt.I.get();

  List<Picto> groupFilters = [];
  List<Picto> groupSelected = [];

  ExerciseChoiceFilterNotifier() {
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

class ExerciseChoiceDialogController extends ChangeNotifier {
  final ExerciceService exerciceService = GetIt.I.get();
  final UserSetService userSetService = GetIt.I.get();
  final WorkoutInstanceService workoutInstanceService = GetIt.I.get();

  final List<Exercice> listChosen = <Exercice>[];
  StreamSubscription<List<Exercice>>? strSubExercice;
  List<Exercice> localListExercice = [];

  loadData() {
    listChosen.clear();
    strSubExercice?.cancel();

    strSubExercice = exerciceService.listenAllAndRef().listen((listExercice) {
      localListExercice = listExercice;
      notifyListeners();
    });
  }

  searchByGroup(List<Picto>? groupSelected) {
    strSubExercice?.cancel();
    if (groupSelected != null && groupSelected.isNotEmpty) {
      strSubExercice = ZipStream(
          [
            exerciceService.whereListen('group', arrayContainsAny: groupSelected.map((e) => e.name).toList()),
          ],
          (values) => values.reduce((value, element) {
                value.addAll(element);
                return value;
              })).listen((listExercice) {
        localListExercice = listExercice;
        notifyListeners();
      });
    } else {
      strSubExercice = exerciceService.listenAllAndRef().listen((listExercice) {
        localListExercice = listExercice;
        notifyListeners();
      });
    }
  }

  Future<WorkoutInstance> createNewWorkoutInstance(DateTime dateTime, TypeWorkout typeWorkout) async {
    final DateTime now = DateTime.now();
    final WorkoutInstance instance = WorkoutInstance();
    instance.typeWorkout = typeWorkout;
    final DateTime date = DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      now.hour,
      now.minute,
      now.second,
    );
    instance.date = Timestamp.fromMicrosecondsSinceEpoch(date.microsecondsSinceEpoch);
    workoutInstanceService.create(instance);
    return instance;
  }

  void toggle(Exercice exercise) {
    if (listChosen.map((element) => element.uid).toList().contains(exercise.uid)) {
      listChosen.removeWhere((element) => element.uid == exercise.uid);
    } else {
      listChosen.add(exercise);
    }
    notifyListeners();
  }

  void validate(
    BuildContext context,
    bool popOnChoice,
    WorkoutInstance workoutInstance,
  ) {
    _addUserSet(workoutInstance).then(
      (userSet) {
        if (popOnChoice) {
          // TODO Sur le clik on doit rafraichir le UserSet.
          final WorkoutPageNotifier? workoutPageNotifier = Provider.of<WorkoutPageNotifier?>(context, listen: false);
          workoutPageNotifier?.refreshWorkoutPage();
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => WorkoutPage(
                instance: workoutInstance,
                goToLastPage: true,
              ),
            ),
          );
        }
      },
    );
  }

  Future<List<dynamic>> _addUserSet(WorkoutInstance workoutInstance) async {
    List<Future<void>> listFutureUserSet = listChosen
        .map((exercise) => UserSet(
            uidExercice: exercise.uid!,
            uidWorkout: workoutInstance.uid!,
            nameExercice: exercise.name,
            imageUrlExercice: exercise.imageUrl,
            typeExercice: exercise.typeExercice,
            date: DateTime.fromMicrosecondsSinceEpoch((workoutInstance.date as Timestamp).microsecondsSinceEpoch)))
        .map((e) => userSetService.save(e))
        .toList();

    return Future.wait(listFutureUserSet);
  }
}

class ExerciseChoiceDialog extends StatelessWidget {
  ExerciseChoiceDialog({
    super.key,
    this.typeWorkout,
    this.workoutInstance,
    this.popOnChoice = false,
    this.isCreation = false,
    this.date,
  }) {
    DebugPrinter.printLn('Date : $date & isCreation : $isCreation');
    assert((isCreation && workoutInstance == null) || (!isCreation && workoutInstance != null),
        "If isCreation then workoutInstance should be null.");
    assert((isCreation && date != null) || (!isCreation), "If isCreation, date should not be null.");
  }

  final WorkoutInstance? workoutInstance;
  final bool popOnChoice;
  final bool isCreation;
  final DateTime? date;
  final TextEditingController searchTextController = TextEditingController();
  final TypeWorkout? typeWorkout;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: ExerciseChoiceFilterNotifier()),
        ChangeNotifierProvider.value(value: ExerciseChoiceDialogController()),
      ],
      builder: (scaffoldContext, child) {
        final ExerciseChoiceDialogController controller =
            Provider.of<ExerciseChoiceDialogController>(scaffoldContext, listen: false);
        controller.loadData();
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'exerciseChoice'.i18n(),
              style: Theme.of(scaffoldContext).textTheme.displaySmall?.copyWith(
                    color: Theme.of(scaffoldContext).primaryColor,
                  ),
            ),
            leading: IconButton(
              onPressed: Navigator.of(scaffoldContext).pop,
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.amber,
                size: 36,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => showModalBottomSheet(
                  context: scaffoldContext,
                  builder: (context) {
                    final ExerciseChoiceFilterNotifier notifierFilter = Provider.of(scaffoldContext, listen: false);
                    return ChangeNotifierProvider.value(
                        value: notifierFilter,
                        builder: (context, child) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Filtrer',
                                  style: Theme.of(scaffoldContext).textTheme.displaySmall?.copyWith(
                                        color: Theme.of(scaffoldContext).primaryColor,
                                      ),
                                ),
                              ),
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Groupes musculaires',
                                        style: GoogleFonts.nunito(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      Flexible(
                                        child:
                                            Consumer<ExerciseChoiceFilterNotifier>(builder: (_, notifierFilter, child) {
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
                                                        Provider.of<ExerciseChoiceDialogController>(scaffoldContext,
                                                                listen: false)
                                                            .searchByGroup(notifierFilter.groupSelected);
                                                      },
                                                    ),
                                                  );
                                                }).toList()),
                                          );
                                        }),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        });
                  },
                ),
                icon: const Icon(Icons.filter_list),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (isCreation) {
                controller
                    .createNewWorkoutInstance(date!, typeWorkout!)
                    .then((instance) => controller.validate(scaffoldContext, popOnChoice, instance));
              } else {
                controller.validate(scaffoldContext, popOnChoice, workoutInstance!);
              }
            },
            child: const Icon(
              Icons.check,
              color: Colors.white,
            ),
          ),
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: SizedBox(
                  width: 1000,
                  child: Consumer<ExerciseChoiceDialogController>(
                    builder: (context, controller, snapshot) {
                      final List<Exercice> listExercise = controller.localListExercice;
                      return ListView.separated(
                        shrinkWrap: true,
                        itemCount: listExercise.length,
                        itemBuilder: (context, index) {
                          final Exercice exercice = listExercise.elementAt(index);
                          return Consumer<ExerciseChoiceDialogController>(builder: (context, notifier, child) {
                            return ExerciseCard(
                              exercise: exercice,
                              showSelect: true,
                              onTap: () => notifier.toggle(exercice),
                              selected:
                                  notifier.listChosen.map((element) => element.uid).toList().contains(exercice.uid),
                            );
                          });
                        },
                        separatorBuilder: (BuildContext context, int index) => const Divider(
                          height: 2.0,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ExerciseCard extends StatelessWidget {
  const ExerciseCard({
    super.key,
    required this.exercise,
    this.selected = false,
    this.showSelect = false,
    required this.onTap,
  });

  final Exercice exercise;
  final bool selected;
  final bool showSelect;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 80,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NetworkImageExerciseChoice(
                imageUrl: exercise.imageUrl,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: (exercise.origin != null && exercise.origin!.isNotEmpty)
                                ? badges.Badge(
                                    child: Text(
                                      exercise.name,
                                      textAlign: TextAlign.start,
                                      style: GoogleFonts.anton(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  )
                                : Text(
                                    exercise.name,
                                    textAlign: TextAlign.start,
                                    style: GoogleFonts.anton(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Text(
                                exercise.typeExercice?.toLowerCase().i18n() ?? '',
                                style: GoogleFonts.nunito(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (exercise.description.isNotEmpty)
                        Flexible(
                          child: Text(
                            exercise.description,
                            textAlign: TextAlign.start,
                            style: GoogleFonts.nunito(fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (showSelect)
                Icon(
                  selected ? Icons.check_circle : Icons.circle_outlined,
                  color: selected ? Colors.green : Colors.grey,
                )
            ],
          ),
        ),
      ),
    );
  }
}
