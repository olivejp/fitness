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
    final bool isReadOnly = exercise?.origin == 'REF';
    final String title = isReadOnly
        ? 'visualize'.i18n()
        : exercise != null
            ? 'update'.i18n()
            : 'createExercise'.i18n();

    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: ExerciseDetailPageNotifier()),
          ChangeNotifierProvider.value(value: ChoiceMuscularNotifier()),
        ],
        builder: (providerContext, child) {
          final ChoiceMuscularNotifier choiceMuscularNotifier =
              Provider.of<ChoiceMuscularNotifier>(providerContext, listen: false);
          final ExerciseDetailPageNotifier exerciseDetailPageNotifier =
              Provider.of<ExerciseDetailPageNotifier>(providerContext, listen: false);

          exerciseDetailPageNotifier.init(exercise, choiceMuscularNotifier.listStream);
          choiceMuscularNotifier.initList(exercise?.group);

          return SafeArea(
            child: Scaffold(
              appBar: AppBar(
                title: Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: Text(
                    title,
                    style: Theme.of(providerContext)
                        .textTheme
                        .displaySmall
                        ?.copyWith(color: Theme.of(providerContext).primaryColor),
                  ),
                ),
                leading: IconButton(
                  onPressed: () => Navigator.of(providerContext).pop(),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.amber,
                    size: 36,
                  ),
                ),
              ),
              floatingActionButton: isReadOnly
                  ? null
                  : FloatingActionButton.extended(
                      onPressed: () {
                        if (formKey.currentState?.validate() == true) {
                          Provider.of<ExerciseDetailPageNotifier>(providerContext, listen: false)
                              .save()
                              .then((_) => Navigator.of(providerContext).pop());
                        }
                      },
                      label: Row(
                        children: [
                          Text('save'.i18n()),
                          const Icon(Icons.save_alt),
                        ],
                      ),
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
                                      readOnly: isReadOnly,
                                      imageUrl: controller.exercise.imageUrl,
                                      storageFile: controller.exercise.storageFile,
                                      onSaved: controller.setStoragePair,
                                      onDeleted: () => controller.setStoragePair(null),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          if (controller.exercise.uid != null)
                                            TextButton.icon(
                                              icon: const Icon(Icons.show_chart),
                                              label: Text(
                                                'displayStat'.i18n(),
                                                style: GoogleFonts.nunito(fontSize: 12),
                                              ),
                                              onPressed: () => Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) => StatExercicePage(exercice: controller.exercise),
                                                ),
                                              ),
                                            ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 20),
                                            child: TextFormField(
                                              style: GoogleFonts.anton(fontSize: 15),
                                              readOnly: isReadOnly,
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
                                                labelStyle: GoogleFonts.anton(fontSize: 15),
                                                hintStyle: GoogleFonts.anton(fontSize: 15),
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
                                        ],
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
                                onChanged: isReadOnly
                                    ? null
                                    : (String? onChangedValue) => controller.exercise.typeExercice = onChangedValue,
                                value: controller.exercise.typeExercice,
                                items: snapshot.data,
                                itemHeight: 50,
                                style: GoogleFonts.anton(fontSize: 15),
                                decoration: InputDecoration(
                                  labelText: 'exerciseType'.i18n(),
                                  labelStyle: GoogleFonts.anton(fontSize: 15),
                                  border: const OutlineInputBorder(),
                                  hintText: 'exerciseType'.i18n(),
                                  hintStyle: GoogleFonts.anton(fontSize: 15),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Theme.of(context).primaryColor),
                                  ),
                                ),
                              );
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: TextFormField(
                              readOnly: isReadOnly,
                              controller: TextEditingController(text: controller.exercise.description),
                              maxLength: 2000,
                              minLines: 5,
                              maxLines: 20,
                              style: GoogleFonts.antonio(),
                              onChanged: (String description) => controller.exercise.description = description,
                              decoration: InputDecoration(
                                labelText: 'description'.i18n(),
                                labelStyle: GoogleFonts.anton(fontSize: 15),
                                hintStyle: GoogleFonts.anton(fontSize: 15),
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
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                border: Border.all(
                                  color: Colors.amber,
                                  style: BorderStyle.solid,
                                  width: 1.0,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: providerContext,
                                        builder: (modalContext) {
                                          final ChoiceMuscularNotifier choiceMuscularNotifier =
                                              Provider.of<ChoiceMuscularNotifier>(providerContext, listen: false);
                                          return ChangeNotifierProvider.value(
                                            value: choiceMuscularNotifier,
                                            builder: (context, child) {
                                              return Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Container(),
                                                        Text(
                                                          'choose'.i18n(),
                                                          style: Theme.of(providerContext)
                                                              .textTheme
                                                              .displaySmall
                                                              ?.copyWith(
                                                                color: Theme.of(providerContext).primaryColor,
                                                              ),
                                                        ),
                                                        IconButton(
                                                          onPressed: () => Navigator.of(context).pop(),
                                                          icon: const Icon(Icons.close),
                                                        ),
                                                      ],
                                                    ),
                                                    const Flexible(
                                                      child: SingleChildScrollView(
                                                        child: ChoiceMuscularGroup(),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      );
                                    },
                                    icon: const Icon(Icons.add_circle_outline),
                                    label: Text(
                                      'choose'.i18n(),
                                      style: GoogleFonts.nunito(fontSize: 12),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: PictoAssetWidget(
                                      group: controller.exercise.group,
                                      height: 300,
                                    ),
                                  ),
                                ],
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
