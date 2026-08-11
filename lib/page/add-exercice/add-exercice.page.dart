import 'package:fitnc_user/l10n/l10n.dart';
import 'package:fitnc_user/page/stat-exercice/stat-exercice.page.dart';
import 'package:fitnc_user/domain/exercice.domain.dart';
import 'package:fitnc_user/service/param.service.dart';
import 'package:fitnc_user/widget/storage-image.widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fitnc_user/page/add-exercice/add-exercice.notifier.dart';

///
/// Widget page to add a new exercise.
///
class AddExercisePage extends StatefulWidget {
  const AddExercisePage({Key? key, this.exercise}) : super(key: key);

  final Exercice? exercise;

  @override
  State<AddExercisePage> createState() => _AddExercisePageState();
}

class _AddExercisePageState extends State<AddExercisePage> {
  late final AddExerciseNotifier notifier =
      AddExerciseNotifier(widget.exercise);
  final ParamService paramService = ParamService.getInstance();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        bottomNavigationBar:
            AddExerciseBottomAppBar(formKey: formKey, notifier: notifier),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            ValueListenableBuilder<Exercice>(
                              valueListenable: notifier.exercise,
                              builder: (_, Exercice exercise, __) => StorageImageWidget(
                                imageUrl: exercise.imageUrl,
                                storageFile:
                                    exercise.storageFile,
                                onSaved: notifier.setStoragePair,
                                onDeleted: () =>
                                    notifier.setStoragePair(null),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: ValueListenableBuilder<Exercice>(
                                  valueListenable: notifier.exercise,
                                  builder: (_, Exercice exercise, __) => TextFormField(
                                    controller: TextEditingController(
                                        text: exercise.name),
                                    onChanged: (String name) =>
                                        exercise.name = name,
                                    validator: (String? value) {
                                      if (value == null || value.isEmpty) {
                                        return context.l10n.pleaseFillExerciseName;
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      labelText: context.l10n.name,
                                      hintStyle:
                                          GoogleFonts.roboto(fontSize: 15),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          width: 0.5,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          width: 0.5,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          width: 0.5,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  FutureBuilder<List<DropdownMenuItem<String?>>>(
                    initialData: const [],
                    future: paramService.getFutureParamAsDropdown(
                        'type_exercice',
                        onlyName: true),
                    builder: (_, snapshot) {
                      return DropdownButtonFormField<String?>(
                        onChanged: (String? onChangedValue) => notifier
                            .exercise.value.typeExercice = onChangedValue,
                        value: notifier.exercise.value.typeExercice,
                        items: snapshot.data,
                        itemHeight: 50,
                        decoration: InputDecoration(
                          labelText: context.l10n.exerciseType,
                          border: const OutlineInputBorder(),
                          hintText: context.l10n.exerciseType,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary),
                          ),
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: ValueListenableBuilder<Exercice>(
                      valueListenable: notifier.exercise,
                      builder: (_, Exercice exercise, __) => TextFormField(
                        controller: TextEditingController(
                            text: exercise.description),
                        maxLength: 2000,
                        minLines: 5,
                        maxLines: 20,
                        onChanged: (String description) =>
                            exercise.description = description,
                        decoration: InputDecoration(
                          labelText: context.l10n.description,
                          helperText: context.l10n.optional,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 0.5,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 0.5,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 0.5,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (notifier.exercise.value.uid != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.bar_chart),
                          label: Text(context.l10n.displayStat),
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => StatExercicePage(
                                  exercice: notifier.exercise.value),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AddExerciseBottomAppBar extends StatelessWidget {
  const AddExerciseBottomAppBar({
    Key? key,
    required this.formKey,
    required this.notifier,
  }) : super(key: key);

  final GlobalKey<FormState> formKey;
  final AddExerciseNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      elevation: 5,
      color: Colors.white,
      child: SizedBox(
        height: 60,
        child: Padding(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.save),
                label: Text(context.l10n.save),
                onPressed: () {
                  if (formKey.currentState?.validate() == true) {
                    notifier.save().then((_) => Navigator.of(context).pop());
                  }
                },
              ),
              TextButton(
                child: Text(context.l10n.back),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
