import 'package:fitnc_user/l10n/l10n.dart';
import 'package:fitnc_user/widget/network-image.widget.dart';
import 'package:fitnc_user/domain/exercice.domain.dart';
import 'package:fitnc_user/domain/workout-instance.domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:loading_animations/loading_animations.dart';

import 'package:fitnc_user/page/add-exercice/add-exercice.page.dart';
import 'package:fitnc_user/page/exercice-choice/exercice-choice.notifier.dart';

class ExerciseChoiceDialog extends StatefulWidget {
  const ExerciseChoiceDialog({
    Key? key,
    this.workoutInstance,
    this.popOnChoice = false,
    this.isCreation = false,
    this.date,
    this.onValidated,
  })  : assert(
            ((isCreation && workoutInstance == null) ||
                (!isCreation && workoutInstance != null)),
            "If isCreation then workoutInstance should be null."),
        assert((isCreation && date != null) || ((!isCreation && date == null)),
            "If isCreation, date should not be null."),
        super(key: key);

  final WorkoutInstance? workoutInstance;
  final bool popOnChoice;
  final bool isCreation;
  final DateTime? date;

  /// Appelé après ajout quand le dialogue se referme sur la séance appelante.
  final VoidCallback? onValidated;

  @override
  State<ExerciseChoiceDialog> createState() => _ExerciseChoiceDialogState();
}

class _ExerciseChoiceDialogState extends State<ExerciseChoiceDialog> {
  late final ExerciseChoiceNotifier notifier;
  final TextEditingController searchTextController = TextEditingController();

  WorkoutInstance? get workoutInstance => widget.workoutInstance;

  bool get popOnChoice => widget.popOnChoice;

  bool get isCreation => widget.isCreation;

  DateTime? get date => widget.date;

  VoidCallback? get onValidated => widget.onValidated;

  ///
  /// Un notifier neuf par ouverture : la sélection repart vide sans avoir à
  /// la réinitialiser depuis build(), et sa destruction ferme le stream de
  /// recherche porté par SearchMixin.
  ///
  @override
  void initState() {
    super.initState();
    notifier = ExerciseChoiceNotifier();
  }

  @override
  void dispose() {
    searchTextController.dispose();
    notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (isCreation) {
            notifier.createNewWorkoutInstance(date!).then((instance) =>
                notifier.validate(
                    context, popOnChoice, instance, onValidated));
          } else {
            notifier.validate(
                context, popOnChoice, workoutInstance!, onValidated);
          }
        },
        child: const Icon(
          Icons.check,
          color: Colors.white,
        ),
      ),
      appBar: AppBar(
        elevation: 0,
        title: Text(
          context.l10n.exerciseChoice,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        foregroundColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size(double.infinity, 50),
          child: Padding(
            padding: const EdgeInsets.only(left: 12, right: 12),
            child: TextFormField(
              controller: searchTextController,
              onChanged: notifier.search,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(5),
                border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25))),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: () {
                    notifier.clearSearch();
                    searchTextController.clear();
                  },
                  icon: const Icon(Icons.clear),
                ),
                hintText: context.l10n.searching,
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 5,
        color: Colors.white,
        child: SizedBox(
          height: 60,
          child: Padding(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  label: Text(context.l10n.createExercise),
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  onPressed: () {
                    if (popOnChoice) {
                      Navigator.of(context).pop();
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddExercisePage(
                            exercise: null,
                          ),
                        ),
                      );
                    }
                  },
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(context.l10n.cancel),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: SizedBox(
              width: 1000,
              child: StreamBuilder<List<Exercice>>(
                stream: notifier.streamList,
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
                        return InkWell(
                          onTap: () => notifier.toggle(exercice),
                          child: ValueListenableBuilder<List<Exercice>>(
                            valueListenable: notifier.listChosen,
                            builder: (_, __, ___) => ExerciseChoiceCard(
                              exercise: exercice,
                              selected: notifier.isChosen(exercice),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          const Divider(
                        height: 2.0,
                        color: Colors.grey,
                      ),
                    );
                  }
                  return LoadingBouncingGrid.circle(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ExerciseChoiceCard extends StatelessWidget {
  const ExerciseChoiceCard({
    Key? key,
    required this.exercise,
    required this.selected,
  }) : super(key: key);
  final Exercice exercise;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
                child: Text(
                  exercise.name,
                  textAlign: TextAlign.start,
                ),
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected ? Colors.green : Colors.grey,
            )
          ],
        ),
      ),
    );
  }
}
