import 'package:fitnc_user/notifier/dark-mode.notifier.dart';
import 'package:fitnc_user/page/exercice/exercice.page.dart';
import 'package:fitnc_user/page/profile/profile.notifier.dart';
import 'package:fitness_domain/constants.dart';
import 'package:fitness_domain/widget/firestore_param_dropdown.widget.dart';
import 'package:fitness_domain/widget/generic_container.widget.dart';
import 'package:fitness_domain/widget/storage_image.widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({Key? key}) : super(key: key);

  final ProfilePageController controller = Get.put(ProfilePageController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  static const double bottomPadding = 10;
  static const double globalHorizontalPadding = 30;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: globalHorizontalPadding),
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 30, bottom: bottomPadding),
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
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: bottomPadding),
                          child: Obx(
                            () => FitnessDecorationTextFormField(
                                controller: TextEditingController(text: controller.user.value?.name),
                                inputBorder:
                                    const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                                onChanged: (String name) => controller.user.value?.name = name,
                                labelText: 'name'.tr,
                                validator: (String? value) {
                                  if (value == null || value.isEmpty) {
                                    return 'pleaseFillYourName'.tr;
                                  }
                                  return null;
                                }),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: bottomPadding),
                          child: Obx(
                            () => FitnessDecorationTextFormField(
                                controller: TextEditingController(text: controller.user.value?.prenom),
                                inputBorder:
                                    const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                                onChanged: (String firstName) => controller.user.value?.prenom = firstName,
                                labelText: 'surname'.tr,
                                validator: (String? value) {
                                  if (value == null || value.isEmpty) {
                                    return 'pleaseFillYourFirstName'.tr;
                                  }
                                  return null;
                                }),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: bottomPadding),
                          child: Obx(() {
                            return ParamDropdownButton(
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5),
                                  ),
                                ),
                                labelText: 'sex'.tr,
                                constraints:
                                    const BoxConstraints(maxHeight: FitnessMobileConstants.textFormFieldHeight),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                              ),
                              paramName: 'sexe',
                              initialValue: controller.user.value?.sexe,
                              onChanged: (String? onChangedValue) => controller.user.value!.sexe = onChangedValue,
                            );
                          }),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: bottomPadding),
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
                              onChanged: (String value) => controller.user.value?.telephone1 = value,
                              decoration: InputDecoration(
                                labelText: 'phone'.tr,
                                border: const OutlineInputBorder(
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
                              Text('darkMode'.tr),
                              Consumer<DarkModeNotifier>(
                                builder: (context, notifier, child) =>
                                    Checkbox(value: notifier.isDark, onChanged: (_) => notifier.switchDarkMode()),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState?.validate() == true) {
                              controller.save().then((_) {
                                showToast('informationsUpdated'.tr, backgroundColor: Colors.green);
                              }).catchError(
                                (_) {
                                  showToast('errorWhileSaving'.tr, backgroundColor: Colors.redAccent);
                                },
                              );
                            }
                          },
                          child: Text(
                            'save'.tr,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const ExercisePage(),
                                ),
                              );
                            },
                            child: Text(
                              'manageExercise'.tr,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: bottomPadding),
                          child: ElevatedButton(
                            onPressed: () =>
                                controller.signOut().then((value) => Get.offNamed(FitnessConstants.routeLogin)),
                            child: Text(
                              'signOut'.tr,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
