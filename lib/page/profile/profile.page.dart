import 'package:fitnc_user/fitness_router.dart';
import 'package:fitnc_user/notifier/application_settings_notifier.dart';
import 'package:fitnc_user/page/exercice/exercice.page.dart';
import 'package:fitnc_user/page/profile/profile.notifier.dart';
import 'package:fitness_domain/widget/firestore_param_dropdown.widget.dart';
import 'package:fitness_domain/widget/generic_container.widget.dart';
import 'package:fitness_domain/widget/storage_image.widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  static const double bottomPadding = 10;
  static const double globalHorizontalPadding = 30;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: ProfilePageNotifier(),
        builder: (context, child) {
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
                          child: Consumer<ProfilePageNotifier>(builder: (context, controller, child) {
                            return Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(top: 30, bottom: bottomPadding),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      StorageImageWidget(
                                        radius: 80,
                                        imageUrl: controller.user?.imageUrl,
                                        storageFile: controller.user?.storageFile,
                                        onSaved: controller.setStoragePair,
                                        onDeleted: () => controller.setStoragePair(null),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  child: Text(
                                    '${controller.user?.email}',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: bottomPadding),
                                  child: FitnessDecorationTextFormField(
                                      controller: TextEditingController(text: controller.user?.name),
                                      inputBorder:
                                          const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                                      onChanged: (String name) => controller.user?.name = name,
                                      labelText: 'name'.tr,
                                      validator: (String? value) {
                                        if (value == null || value.isEmpty) {
                                          return 'pleaseFillYourName'.tr;
                                        }
                                        return null;
                                      }),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: bottomPadding),
                                  child: FitnessDecorationTextFormField(
                                      controller: TextEditingController(text: controller.user?.prenom),
                                      inputBorder:
                                          const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                                      onChanged: (String firstName) => controller.user?.prenom = firstName,
                                      labelText: 'surname'.tr,
                                      validator: (String? value) {
                                        if (value == null || value.isEmpty) {
                                          return 'pleaseFillYourFirstName'.tr;
                                        }
                                        return null;
                                      }),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: bottomPadding),
                                  child: ParamDropdownButton(
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
                                    initialValue: controller.user?.sexe,
                                    onChanged: (String? onChangedValue) => controller.user!.sexe = onChangedValue,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: bottomPadding),
                                  child: Builder(builder: (context) {
                                    TextEditingController control = TextEditingController(
                                        text: (controller.user?.telephone1) != null
                                            ? controller.user!.telephone1.toString()
                                            : '');
                                    return TextFormField(
                                      controller: control,
                                      maxLength: 6,
                                      keyboardType: TextInputType.phone,
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                      onChanged: (String value) => controller.user?.telephone1 = value,
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
                                      Consumer<ApplicationSettingsNotifier>(
                                        builder: (context, notifier, child) =>
                                            Checkbox(value: notifier.dark, onChanged: (_) => notifier.switchDark()),
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
                                        controller.signOut().then((value) => context.go(FitncRouter.sign_in)),
                                    child: Text(
                                      'signOut'.tr,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
