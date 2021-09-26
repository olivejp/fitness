import 'package:fitnc_user/service/exercice.service.dart';
import 'package:fitness_domain/controller/abstract.controller.dart';
import 'package:fitness_domain/domain/exercice.domain.dart';
import 'package:fitness_domain/domain/storage-file.dart';
import 'package:fitness_domain/widget/storage_image.widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AddExercicePageController extends LocalSearchControllerMixin<Exercice, ExerciceService> {
  final ExerciceService exerciceService = Get.find();
  final Rx<Exercice> exercice = Exercice().obs;

  void init(Exercice? exercice) {
    if (exercice == null) {
      this.exercice.value = Exercice();
    } else {
      this.exercice.value = exercice;
    }
  }

  Future<void> save() {
    return exerciceService.save(exercice.value);
  }

  void setStoragePair(StorageFile? storageFile) {
    exercice.update((val) {
      if (val != null) {
        val.storageFile = storageFile;
      }
    });
  }
}

class AddExercicePage extends StatelessWidget {
  AddExercicePage({Key? key, this.exercice}) : super(key: key);
  final AddExercicePageController controller = Get.put(AddExercicePageController());
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final Exercice? exercice;

  @override
  Widget build(BuildContext context) {
    controller.init(exercice);

    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: BottomAppBar(
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
                    icon: Icon(Icons.save),
                    label: Text('Enregistrer'),
                    onPressed: () {
                      if (formKey.currentState?.validate() == true) {
                        controller.save().then((_) => Navigator.of(context).pop());
                      }
                    },
                  ),
                  TextButton(
                    child: Text('Retour'),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ),
            ),
          ),
        ),
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
                                imageUrl: controller.exercice.value.imageUrl,
                                storageFile: controller.exercice.value.storageFile,
                                onSaved: controller.setStoragePair,
                                onDeleted: () => controller.setStoragePair(null),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Obx(
                                  () => TextFormField(
                                    controller: TextEditingController(text: controller.exercice.value.name),
                                    autofocus: true,
                                    onChanged: (String name) => controller.exercice.value.name = name,
                                    validator: (String? value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Merci de renseigner le nom du exercice.';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Nom',
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
                  // ParamDropdownButton(
                  //   decoration: const InputDecoration(
                  //       labelText: "Type d'exercice",
                  //       constraints: BoxConstraints(maxHeight: FitnessConstants.textFormFieldHeight),
                  //       contentPadding: EdgeInsets.symmetric(horizontal: 10)),
                  //   paramName: 'type_exercice',
                  //   initialValue: controller.exercice.value.typeExercice,
                  //   onChanged: (String? onChangedValue) => controller.exercice.value.typeExercice = onChangedValue,
                  // ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Obx(
                      () => TextFormField(
                        controller: TextEditingController(text: controller.exercice.value.description),
                        maxLength: 2000,
                        minLines: 5,
                        maxLines: 20,
                        onChanged: (String description) => controller.exercice.value.description = description,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          helperText: 'Optionnel',
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
            ),
          ),
        ),
      ),
    );
  }
}