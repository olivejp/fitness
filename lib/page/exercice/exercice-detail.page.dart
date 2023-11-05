import 'package:fitnc_user/page/exercice/exercice-detail.notifier.dart';
import 'package:fitnc_user/page/exercice/stat-exercice.page.dart';
import 'package:fitnc_user/widget/picto.widget.dart';
import 'package:fitness_domain/domain/exercice.domain.dart';
import 'package:fitness_domain/service/param.service.dart';
import 'package:fitness_domain/widget/storage_image.widget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

///
/// Widget page to add a new exercise.
///
class ExerciseDetailPage extends StatelessWidget {
  ExerciseDetailPage({super.key, this.exercise});

  final ParamService paramService = GetIt.I.get();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final Exercice? exercise;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: ExerciseDetailPageNotifier(),
        builder: (context, child) {
          Provider.of<ExerciseDetailPageNotifier>(context, listen: false).init(exercise);
          return SafeArea(
            child: Scaffold(
              appBar: AppBar(
                toolbarHeight: 70,
                title: Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: Text(
                    exercise != null ? 'update'.i18n() : 'createExercise'.i18n(),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Theme.of(context).primaryColor),
                  ),
                ),
                leading: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.amber,
                    size: 36,
                  ),
                ),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  if (formKey.currentState?.validate() == true) {
                    Provider.of<ExerciseDetailPageNotifier>(context, listen: false)
                        .save()
                        .then((_) => Navigator.of(context).pop());
                  }
                },
                child: const Icon(Icons.check),
              ),
              // bottomNavigationBar: AddExerciseBottomAppBar(formKey: formKey),
              body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Consumer<ExerciseDetailPageNotifier>(builder: (context, controller, child) {
                      return Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    StorageImageWidget(
                                      imageUrl: controller.exercise.imageUrl,
                                      storageFile: controller.exercise.storageFile,
                                      onSaved: controller.setStoragePair,
                                      onDeleted: () => controller.setStoragePair(null),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 20),
                                        child: TextFormField(
                                          controller: TextEditingController(text: controller.exercise.name),
                                          onChanged: (String name) => controller.exercise.name = name,
                                          validator: (String? value) {
                                            if (value == null || value.isEmpty) {
                                              return 'pleaseFillExerciseName'.i18n();
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                            labelText: 'name'.i18n(),
                                            hintStyle: GoogleFonts.roboto(fontSize: 15),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                width: 0.5,
                                                color: Theme.of(context).primaryColor,
                                              ),
                                            ),
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                width: 0.5,
                                                color: Theme.of(context).primaryColor,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                width: 0.5,
                                                color: Theme.of(context).primaryColor,
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
                          // Row(
                          //   crossAxisAlignment: CrossAxisAlignment.end,
                          //   children: [
                          //     // Flexible(
                          //     //   child: TypeExerciseCard(
                          //     //     title: const Text('Type'),
                          //     //     child: const Icon(Icons.create),
                          //     //     onTap: () {},
                          //     //   ),
                          //     // ),
                          //     // Flexible(
                          //     //   child: TypeExerciseCard(
                          //     //     title: const Text('Groupe'),
                          //     //     child: controller.exercise.group != null && controller.exercise.group!.isNotEmpty
                          //     //         ? Text(controller.exercise.group!)
                          //     //         : const Icon(Icons.create),
                          //     //     onTap: () {
                          //     //       showDialog(
                          //     //         context: context,
                          //     //         builder: (context) => GroupExerciceChoice(
                          //     //           onChoose: controller.setGroup,
                          //     //         ),
                          //     //       );
                          //     //     },
                          //     //   ),
                          //     // ),
                          //   ],
                          // ),
                          FutureBuilder<List<DropdownMenuItem<String?>>>(
                            initialData: const [],
                            future: paramService.getFutureParamAsDropdown('type_exercice', onlyName: true),
                            builder: (_, snapshot) {
                              return DropdownButtonFormField<String?>(
                                key: key,
                                onChanged: (String? onChangedValue) =>
                                    controller.exercise.typeExercice = onChangedValue,
                                value: controller.exercise.typeExercice,
                                items: snapshot.data,
                                itemHeight: 50,
                                decoration: InputDecoration(
                                  labelText: 'exerciseType'.i18n(),
                                  border: const OutlineInputBorder(),
                                  hintText: 'exerciseType'.i18n(),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Theme.of(context).primaryColor),
                                  ),
                                ),
                              );
                            },
                          ),
                          // TextFormField(
                          //   controller: TextEditingController(text: controller.exercise.group),
                          //   onChanged: (String group) => controller.exercise.group = group,
                          //   decoration: InputDecoration(
                          //     labelText: 'group'.i18n(),
                          //     hintStyle: GoogleFonts.roboto(fontSize: 15),
                          //     focusedBorder: OutlineInputBorder(
                          //       borderSide: BorderSide(
                          //         width: 0.5,
                          //         color: Theme.of(context).primaryColor,
                          //       ),
                          //     ),
                          //     border: OutlineInputBorder(
                          //       borderSide: BorderSide(
                          //         width: 0.5,
                          //         color: Theme.of(context).primaryColor,
                          //       ),
                          //     ),
                          //     enabledBorder: OutlineInputBorder(
                          //       borderSide: BorderSide(
                          //         width: 0.5,
                          //         color: Theme.of(context).primaryColor,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: TextFormField(
                              controller: TextEditingController(text: controller.exercise.description),
                              maxLength: 2000,
                              minLines: 5,
                              maxLines: 20,
                              onChanged: (String description) => controller.exercise.description = description,
                              decoration: InputDecoration(
                                labelText: 'description'.i18n(),
                                helperText: 'optional'.i18n(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    width: 0.5,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    width: 0.5,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    width: 0.5,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Muscles ciblés',
                                style: GoogleFonts.nunito(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              PictoAssetWidget(
                                group: controller.exercise.group,
                                height: 300,
                              ),
                              if (controller.exercise.group != null)
                                Wrap(
                                  spacing: 5,
                                  runSpacing: 5,
                                  children: controller.exercise.group!
                                      .map(
                                        (e) => Chip(
                                          label: Text(e),
                                          labelPadding: EdgeInsets.all(2),
                                        ),
                                      )
                                      .toList(),
                                )
                            ],
                          ),
                          if (controller.exercise.uid != null)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.bar_chart),
                                  label: Text('displayStat'.i18n()),
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => StatExercicePage(exercice: controller.exercise),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
          );
        });
  }
}

class AddExerciseBottomAppBar extends StatelessWidget {
  const AddExerciseBottomAppBar({
    super.key,
    required this.formKey,
  });

  final GlobalKey<FormState> formKey;

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
                label: Text('save'.i18n()),
                onPressed: () {
                  if (formKey.currentState?.validate() == true) {
                    Provider.of<ExerciseDetailPageNotifier>(context, listen: false)
                        .save()
                        .then((_) => Navigator.of(context).pop());
                  }
                },
              ),
              TextButton(
                child: Text('return'.i18n()),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
