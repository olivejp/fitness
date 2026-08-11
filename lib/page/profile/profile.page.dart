
import 'package:fitnc_user/service/dark-mode.service.dart';
import 'package:fitnc_user/l10n/l10n.dart';
import 'package:fitnc_user/page/exercice/exercice.page.dart';
import 'package:fitnc_user/constants.dart';
import 'package:fitnc_user/di.dart';
import 'package:fitnc_user/domain/fitness-user.domain.dart';
import 'package:fitnc_user/widget/firestore-param-dropdown.widget.dart';
import 'package:fitnc_user/widget/generic-container.widget.dart';
import 'package:fitnc_user/widget/storage-image.widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';
import 'package:fitnc_user/page/profile/profile.notifier.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileNotifier notifier = ProfileNotifier();
  final DarkModeService darkModeService = di<DarkModeService>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    notifier.dispose();
    super.dispose();
  }

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
                  padding: const EdgeInsets.symmetric(
                      horizontal: globalHorizontalPadding),
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 30, bottom: bottomPadding),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ValueListenableBuilder<FitnessUser?>(
                                valueListenable: notifier.user,
                                builder: (_, FitnessUser? user, __) => StorageImageWidget(
                                  radius: 80,
                                  imageUrl: user?.imageUrl,
                                  storageFile: user?.storageFile,
                                  onSaved: notifier.setStoragePair,
                                  onDeleted: () =>
                                      notifier.setStoragePair(null),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: ValueListenableBuilder<FitnessUser?>(
                            valueListenable: notifier.user,
                            builder: (_, FitnessUser? user, __) => Text(
                              '${user?.email}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: bottomPadding),
                          child: ValueListenableBuilder<FitnessUser?>(
                            valueListenable: notifier.user,
                            builder: (_, FitnessUser? user, __) => FitnessDecorationTextFormField(
                                controller: TextEditingController(
                                    text: user?.name),
                                inputBorder: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                                onChanged: (String name) =>
                                    user?.name = name,
                                labelText: context.l10n.name,
                                validator: (String? value) {
                                  if (value == null || value.isEmpty) {
                                    return context.l10n.pleaseFillYourName;
                                  }
                                  return null;
                                }),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: bottomPadding),
                          child: ValueListenableBuilder<FitnessUser?>(
                            valueListenable: notifier.user,
                            builder: (_, FitnessUser? user, __) => FitnessDecorationTextFormField(
                                controller: TextEditingController(
                                    text: user?.prenom),
                                inputBorder: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                                onChanged: (String firstName) =>
                                    user?.prenom = firstName,
                                labelText: context.l10n.surname,
                                validator: (String? value) {
                                  if (value == null || value.isEmpty) {
                                    return context.l10n.pleaseFillYourFirstName;
                                  }
                                  return null;
                                }),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: bottomPadding),
                          child: ValueListenableBuilder<FitnessUser?>(
                            valueListenable: notifier.user,
                            builder: (_, FitnessUser? user, __) {
                            return ParamDropdownButton(
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5),
                                  ),
                                ),
                                labelText: context.l10n.sex,
                                constraints: const BoxConstraints(
                                    maxHeight: FitnessConstants
                                        .textFormFieldHeight),
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                              ),
                              paramName: 'sexe',
                              initialValue: user?.sexe,
                              onChanged: (String? onChangedValue) =>
                                  user!.sexe = onChangedValue,
                            );
                          }),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: bottomPadding),
                          child: ValueListenableBuilder<FitnessUser?>(
                            valueListenable: notifier.user,
                            builder: (_, FitnessUser? user, __) {
                            TextEditingController control = TextEditingController(
                                text: (user?.telephone1) != null
                                    ? user!.telephone1.toString()
                                    : '');
                            return TextFormField(
                              controller: control,
                              maxLength: 6,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              onChanged: (String value) =>
                                  user?.telephone1 = value,
                              decoration: InputDecoration(
                                labelText: context.l10n.phone,
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
                              Text(context.l10n.darkMode),
                              ValueListenableBuilder<bool>(
                                valueListenable: darkModeService.notifier,
                                builder: (_, isDarkMode, __) => Checkbox(
                                  value: isDarkMode,
                                  onChanged: (_) {
                                    darkModeService.switchDarkMode();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState?.validate() == true) {
                              notifier.save().then((_) {
                                showToast(context.l10n.informationsUpdated,
                                    backgroundColor: Colors.green);
                              }).catchError(
                                (_) {
                                  showToast(context.l10n.errorWhileSaving,
                                      backgroundColor: Colors.redAccent);
                                },
                              );
                            }
                          },
                          child: Text(
                            context.l10n.save,
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
                              context.l10n.manageExercise,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 8, bottom: bottomPadding),
                          child: ElevatedButton(
                            onPressed: () => notifier.signOut().then((value) => context.go(FitnessConstants.routeLogin)),
                            child: Text(
                              context.l10n.signOut,
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
