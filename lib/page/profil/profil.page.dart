import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_user/controller/dark-mode.controller.dart';
import 'package:fitnc_user/page/exercice/exercice.page.dart';
import 'package:fitnc_user/service/fitness-user.service.dart';
import 'package:fitness_domain/domain/fitness-user.domain.dart';
import 'package:fitness_domain/domain/storage-file.dart';
import 'package:fitness_domain/service/auth.service.dart';
import 'package:fitness_domain/widget/firestore_param_dropdown.widget.dart';
import 'package:fitness_domain/widget/generic_container.widget.dart';
import 'package:fitness_domain/widget/storage_image.widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';

import '../../constants.dart';

class ProfilPageController extends GetxController {
  ProfilPageController() {
    User? currentUser = authService.getCurrentUser();
    if (currentUser == null) throw Exception('Aucun utilisateur connecté');

    authService.listenUserConnected().listen((User? userConnected) {
      fitnessUserService.read(userConnected!.uid).then((FitnessUser? value) {
        if (value != null) {
          // L'utilisateur existe déjà, on le récupère.
          user.value = value;
        } else {
          // L'utilisateur n'existe pas dans la base distante, on récupère
          user.value = FitnessUser()
            ..uid = currentUser.uid
            ..email = currentUser.email;
        }
      });
    });
  }

  final AuthService authService = Get.find();
  final FitnessUserService fitnessUserService = Get.find();
  final Rx<FitnessUser?> user = FitnessUser().obs;

  void setStoragePair(StorageFile? stFile) {
    user.update((FitnessUser? user) {
      if (user != null) {
        user.storageFile = stFile ?? StorageFile();
        user.imageUrl = null;
      }
    });
  }

  Future<void> save() async {
    if (user.value != null) {
      await fitnessUserService.save(user.value!);
    } else {
      throw Exception('Aucun domain Trainer a sauvegardé');
    }
  }

  void signOut() {
    authService.signOut();
  }
}

class ProfilPage extends StatelessWidget {
  ProfilPage({Key? key}) : super(key: key);
  final ProfilPageController controller = Get.put(ProfilPageController());
  final DarkModeController darkModeController = Get.find();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 30, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Obx(
                        () => StorageImageWidget(
                          radius: 80,
                          imageUrl: controller.user.value?.imageUrl,
                          storageFile: controller.user.value?.storageFile,
                          onSaved: controller.setStoragePair,
                          onDeleted: () => controller.setStoragePair(null),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Obx(
                    () => Text(
                      '${controller.user.value?.email}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Obx(
                    () => FitnessDecorationTextFormField(
                        controller: TextEditingController(
                            text: controller.user.value?.name),
                        inputBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        onChanged: (String name) =>
                            controller.user.value?.name = name,
                        labelText: 'Nom',
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Merci de renseigner votre nom.';
                          }
                          return null;
                        }),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Obx(
                    () => FitnessDecorationTextFormField(
                        controller: TextEditingController(
                            text: controller.user.value?.prenom),
                        inputBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        onChanged: (String prenom) =>
                            controller.user.value?.prenom = prenom,
                        labelText: 'Prénom',
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Merci de renseigner votre prénom.';
                          }
                          return null;
                        }),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Obx(() {
                    return ParamDropdownButton(
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                          labelText: 'Sexe',
                          constraints: BoxConstraints(
                              maxHeight: FitnessConstants.textFormFieldHeight),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 10)),
                      paramName: 'sexe',
                      initialValue: controller.user.value?.sexe,
                      onChanged: (String? onChangedValue) =>
                          controller.user.value!.sexe = onChangedValue,
                    );
                  }),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Obx(() {
                    TextEditingController control = TextEditingController(
                        text: (controller.user.value?.telephone1) != null
                            ? controller.user.value!.telephone1.toString()
                            : '');
                    return TextFormField(
                      controller: control,
                      maxLength: 6,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (String value) =>
                          controller.user.value?.telephone1 = int.parse(value),
                      decoration: const InputDecoration(
                        labelText: 'Téléphone',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(5),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Mode sombre'),
                      ValueListenableBuilder<bool>(
                        valueListenable: darkModeController.notifier,
                        builder: (_, isDarkMode, __) => Checkbox(
                          value: isDarkMode,
                          onChanged: (_) {
                            darkModeController.switchDarkMode();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 35),
                  ),
                  onPressed: () {
                    if (_formKey.currentState?.validate() == true) {
                      controller.save().then((_) {
                        showToast('Vos informations ont été mises à jour',
                            backgroundColor: Colors.green);
                      }).catchError(
                        (_) => showToast('Erreur lors de la sauvegarde',
                            backgroundColor: Colors.redAccent),
                      );
                    }
                  },
                  child: const Text('Enregistrer',
                      style: TextStyle(color: Colors.white)),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 35),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => const ExercicePage()),
                      );
                    },
                    child: const Text('Gérer mes exercices',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 35),
                    ),
                    onPressed: () => controller.signOut(),
                    child: const Text('Me déconnecter',
                        style: TextStyle(color: Colors.red)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
