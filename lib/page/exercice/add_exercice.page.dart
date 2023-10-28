import 'package:fitnc_user/page/exercice/add_exercice.notifier.dart';
import 'package:fitnc_user/page/exercice/stat-exercice.page.dart';
import 'package:fitness_domain/domain/exercice.domain.dart';
import 'package:fitness_domain/service/param.service.dart';
import 'package:fitness_domain/widget/storage_image.widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

///
/// Widget page to add a new exercise.
///
class AddExercisePage extends StatelessWidget {
  AddExercisePage({super.key, this.exercise});
  final ParamService paramService = GetIt.I.get();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final Exercice? exercise;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: AddExercisePageNotifier(),
        builder: (context, child) {
          return Consumer<AddExercisePageNotifier>(builder: (context, controller, child) {
            controller.init(exercise);
            return SafeArea(
              child: Scaffold(
                bottomNavigationBar: AddExerciseBottomAppBar(formKey: formKey, controller: controller),
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
                                    Obx(
                                      () => StorageImageWidget(
                                        imageUrl: controller.exercise.value.imageUrl,
                                        storageFile: controller.exercise.value.storageFile,
                                        onSaved: controller.setStoragePair,
                                        onDeleted: () => controller.setStoragePair(null),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 20),
                                        child: Obx(
                                          () => TextFormField(
                                            controller: TextEditingController(text: controller.exercise.value.name),
                                            onChanged: (String name) => controller.exercise.value.name = name,
                                            validator: (String? value) {
                                              if (value == null || value.isEmpty) {
                                                return 'pleaseFillExerciseName'.tr;
                                              }
                                              return null;
                                            },
                                            decoration: InputDecoration(
                                              labelText: 'name'.tr,
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
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          FutureBuilder<List<DropdownMenuItem<String?>>>(
                            initialData: const [],
                            future: paramService.getFutureParamAsDropdown('type_exercice', onlyName: true),
                            builder: (_, snapshot) {
                              return DropdownButtonFormField<String?>(
                                key: key,
                                onChanged: (String? onChangedValue) =>
                                    controller.exercise.value.typeExercice = onChangedValue,
                                value: controller.exercise.value.typeExercice,
                                items: snapshot.data,
                                itemHeight: 50,
                                decoration: InputDecoration(
                                  labelText: 'exerciseType'.tr,
                                  border: const OutlineInputBorder(),
                                  hintText: 'exerciseType'.tr,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Theme.of(context).primaryColor),
                                  ),
                                ),
                              );
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Obx(
                              () => TextFormField(
                                controller: TextEditingController(text: controller.exercise.value.description),
                                maxLength: 2000,
                                minLines: 5,
                                maxLines: 20,
                                onChanged: (String description) => controller.exercise.value.description = description,
                                decoration: InputDecoration(
                                  labelText: 'description'.tr,
                                  helperText: 'optional'.tr,
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
                          if (controller.exercise.value.uid != null)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.bar_chart),
                                  label: Text('displayStat'.tr),
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => StatExercicePage(exercice: controller.exercise.value),
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
          });
        });
  }
}

class AddExerciseBottomAppBar extends StatelessWidget {
  const AddExerciseBottomAppBar({
    super.key,
    required this.formKey,
    required this.controller,
  });

  final GlobalKey<FormState> formKey;
  final AddExercisePageNotifier controller;

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
                label: Text('save'.tr),
                onPressed: () {
                  if (formKey.currentState?.validate() == true) {
                    controller.save().then((_) => Navigator.of(context).pop());
                  }
                },
              ),
              TextButton(
                child: Text('back'.tr),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
