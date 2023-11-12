import 'package:fitnc_user/page/exercice/stat-exercice.page.dart';
import 'package:fitness_domain/constants.dart';
import 'package:fitness_domain/domain/exercice.domain.dart';
import 'package:fitness_domain/domain/user.line.domain.dart';
import 'package:fitness_domain/domain/user.set.domain.dart';
import 'package:fitness_domain/enum/dist_unit.enum.dart';
import 'package:fitness_domain/enum/time_unit.enum.dart';
import 'package:fitness_domain/enum/weight_unit.enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import 'add_user_set.controller.dart';

class OpenUserSetInstance extends StatelessWidget {
  const OpenUserSetInstance({super.key, required this.userSet});

  final UserSet userSet;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: UserSetController(),
        builder: (context, child) {
          Provider.of<UserSetController>(context, listen: false).init(userSet);
          return UserSetUpdate(userSet: userSet);
        });
  }
}

class UserSetUpdate extends StatelessWidget {
  UserSetUpdate({super.key, required this.userSet});

  final UserSet userSet;
  final double padding = 15;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final ScrollController scrollController = ScrollController();

  /// Returns headers columns depending on the Exercise type.
  List<Widget> getColumnsHeadersByType() {
    if (userSet.typeExercice == TypeExercice.REPS_WEIGHT.name) {
      return [
        Flexible(
          flex: 2,
          child: Center(
            child: Text(
              'Reps',
              style: GoogleFonts.antonio(),
            ),
          ),
        ),
        Flexible(
          flex: 2,
          child: Center(
            child: Text(
              'Weight',
              style: GoogleFonts.antonio(),
            ),
          ),
        )
      ];
    } else if (userSet.typeExercice == TypeExercice.REPS_ONLY.name) {
      return [
        Flexible(
          flex: 4,
          child: Center(
            child: Text(
              'Reps',
              style: GoogleFonts.antonio(),
            ),
          ),
        )
      ];
    } else if (userSet.typeExercice == TypeExercice.TIME.name) {
      return [
        Flexible(
          flex: 4,
          child: Center(
            child: Text(
              'Time',
              style: GoogleFonts.antonio(),
            ),
          ),
        )
      ];
    } else if (userSet.typeExercice == TypeExercice.DIST.name) {
      return [
        Flexible(
          flex: 4,
          child: Center(
            child: Text(
              'Dist',
              style: GoogleFonts.antonio(),
            ),
          ),
        )
      ];
    } else {
      throw Exception('Type exercise unknown');
    }
  }

  /// Returns fields columns depending on the Exercise type.
  List<Widget> getColumnsFieldsByType(
    String? typeExercise,
    UserLine userLine,
    int index,
    UserSetController controller,
    GlobalKey keyReps,
    GlobalKey keyWeight,
    GlobalKey keyWeightUnit,
    GlobalKey keyTime,
    GlobalKey keyTimeUnit,
    GlobalKey keyDist,
    GlobalKey keyDistUnit,
  ) {
    if (typeExercise == TypeExercice.REPS_ONLY.name) {
      return [
        Flexible(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: NumberInputWidget(
              customKey: keyReps,
              initialValue: userLine.reps,
              index: index,
              callback: controller.changeReps,
            ),
          ),
        ),
      ];
    } else if (typeExercise == TypeExercice.DIST.name) {
      return [
        Flexible(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: NumberInputWidget(
              customKey: keyDist,
              initialValue: userLine.dist,
              index: index,
              callback: controller.changeDist,
            ),
          ),
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: DropdownButtonFormField<DistUnit>(
              isDense: true,
              iconSize: 0.0,
              key: keyDistUnit,
              itemHeight: 48.0,
              value: userLine.distUnit ?? DistUnit.KM,
              style: GoogleFonts.anton(),
              items: DistUnit.values
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        e.name.i18n(),
                        style: GoogleFonts.anton(),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (DistUnit? value) => controller.changeDistUnit(index, value ?? DistUnit.KM),
            ),
          ),
        ),
      ];
    } else if (typeExercise == TypeExercice.TIME.name) {
      return [
        Flexible(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: NumberInputWidget(
              customKey: keyTime,
              initialValue: userLine.time,
              index: index,
              callback: controller.changeTime,
            ),
          ),
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: DropdownButtonFormField<TimeUnit>(
              key: keyTimeUnit,
              isDense: true,
              iconSize: 0.0,
              itemHeight: 48.0,
              value: userLine.timeUnit ?? TimeUnit.MIN,
              style: GoogleFonts.anton(),
              items: TimeUnit.values
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        e.name.i18n(),
                        style: GoogleFonts.anton(),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (TimeUnit? value) => controller.changeTimeUnit(index, value ?? TimeUnit.MIN),
            ),
          ),
        ),
      ];
    } else if (typeExercise == TypeExercice.REPS_WEIGHT.name) {
      return [
        Flexible(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: NumberInputWidget(
              customKey: keyReps,
              initialValue: userLine.reps,
              index: index,
              callback: controller.changeReps,
            ),
          ),
        ),
        Flexible(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: NumberInputWidget(
              customKey: keyWeight,
              initialValue: userLine.weight,
              index: index,
              callback: controller.changeWeight,
            ),
          ),
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: DropdownButtonFormField<WeightUnit>(
              key: keyWeightUnit,
              isDense: true,
              iconSize: 0.0,
              itemHeight: 48.0,
              value: userLine.weightUnit ?? WeightUnit.KG,
              style: GoogleFonts.anton(),
              items: WeightUnit.values
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        e.name.i18n(),
                        style: GoogleFonts.anton(),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (WeightUnit? value) => controller.changeWeightUnit(index, value ?? WeightUnit.KG),
            ),
          ),
        ),
      ];
    } else {
      throw Exception('Type exercise unknown');
    }
  }

  @override
  Widget build(BuildContext context) {
    /// Initialize the userSet list.
    Provider.of<UserSetController>(context, listen: false).initList(userSet.lines, false);

    return SingleChildScrollView(
      controller: scrollController,
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: padding, left: padding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                    child: Center(
                      child: Text(
                        'Sets',
                        style: GoogleFonts.antonio(),
                      ),
                    ),
                  ),
                  ...getColumnsHeadersByType(),
                  Flexible(
                    child: Center(
                      child: Consumer<UserSetController>(
                        builder: (_, controller, icon) {
                          return IconButton(
                            icon: icon!,
                            color:
                                controller.listLines.every((element) => element.checked) ? Colors.green : Colors.grey,
                            iconSize: 30,
                            onPressed: () => controller.checkAll(),
                          );
                        },
                        child: const Icon(Icons.done_all_rounded),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Consumer<UserSetController>(builder: (_, controller, child) {
              return ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: controller.listLines.length,
                  itemBuilder: (BuildContext context, int index) {
                    final GlobalKey keyReps = GlobalKey();
                    final GlobalKey keyWeight = GlobalKey();
                    final GlobalKey keyWeightUnit = GlobalKey();
                    final GlobalKey keyDist = GlobalKey();
                    final GlobalKey keyDistUnit = GlobalKey();
                    final GlobalKey keyTime = GlobalKey();
                    final GlobalKey keyTimeUnit = GlobalKey();
                    final GlobalKey keyRestTime = GlobalKey();
                    final GlobalKey keyRestTimeUnit = GlobalKey();
                    final UserLine userLine = controller.listLines.elementAt(index);
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('${index + 1}'),
                        ),
                        ...getColumnsFieldsByType(
                          userSet.typeExercice,
                          userLine,
                          index,
                          controller,
                          keyReps,
                          keyWeight,
                          keyWeightUnit,
                          keyTime,
                          keyTimeUnit,
                          keyDist,
                          keyDistUnit,
                        ),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: NumberInputWidget(
                              customKey: keyRestTime,
                              initialValue: userLine.restTime,
                              index: index,
                              callback: controller.changeRestTime,
                            ),
                          ),
                        ),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: DropdownButtonFormField<TimeUnit>(
                              iconSize: 0.0,
                              isDense: true,
                              itemHeight: 48.0,
                              key: keyRestTimeUnit,
                              value: userLine.restTimeUnit ?? TimeUnit.MIN,
                              style: GoogleFonts.anton(),
                              items: TimeUnit.values
                                  .map((e) => DropdownMenuItem(
                                      value: e, child: Text(e.name.i18n(), style: GoogleFonts.anton())))
                                  .toList(),
                              onChanged: (TimeUnit? value) =>
                                  controller.changeRestTimeUnit(index, value ?? TimeUnit.MIN),
                            ),
                          ),
                        ),
                      ],
                    );
                  });
            }),
            RowAddRemoveSet(controller: Provider.of<UserSetController>(context, listen: false)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          AddCommentAlertDialog(controller: Provider.of<UserSetController>(context, listen: false)),
                    );
                  },
                  label: Text('comment'.i18n()),
                  icon: const Icon(Icons.note_outlined),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class NumberInputWidget extends StatelessWidget {
  const NumberInputWidget({
    super.key,
    required this.customKey,
    required this.callback,
    required this.index,
    required this.initialValue,
  });

  final GlobalKey<State<StatefulWidget>> customKey;
  final String? initialValue;
  final int index;
  final void Function(int index, String value) callback;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: customKey,
      initialValue: initialValue,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
      decoration: const InputDecoration(hintText: '0'),
      onChanged: (value) => callback(index, value),
    );
  }
}

class RowExerciseDetails extends StatelessWidget {
  const RowExerciseDetails({
    super.key,
    required this.controller,
  });

  final UserSetController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                controller.userSet.nameExercice!,
                style: GoogleFonts.antonio(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(
                  Icons.insert_chart_outlined_rounded,
                  color: Colors.grey,
                ),
                onPressed: () {
                  controller.getExercise(controller.userSet.uidExercice).then(
                    (Exercice? exercise) {
                      if (exercise != null) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => StatExercicePage(exercice: exercise),
                          ),
                        );
                      }
                    },
                  );
                },
              )
            ],
          ),
        )
      ],
    );
  }
}

class AddCommentAlertDialog extends StatelessWidget {
  AddCommentAlertDialog({
    super.key,
    required this.controller,
  });

  final UserSetController controller;
  final GlobalKey<State<StatefulWidget>> commentKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    String comment = controller.userSet.comment ?? '';
    return AlertDialog(
      title: Text(
        'addComment'.i18n(),
        style: Theme.of(context).textTheme.displaySmall,
      ),
      content: TextFormField(
        decoration: InputDecoration(
          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
          hintText: '${'comment'.i18n()}...',
        ),
        controller: TextEditingController(text: comment),
        key: commentKey,
        maxLines: 10,
        onChanged: (value) => comment = value,
      ),
      actions: [
        TextButton(
          onPressed: () {
            controller.addComment(comment);
            Navigator.of(context).pop();
          },
          child: Text('save'.i18n()),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('cancel'.i18n()),
        ),
      ],
    );
  }
}

class RowAddRemoveSet extends StatelessWidget {
  const RowAddRemoveSet({
    super.key,
    required this.controller,
  });

  final UserSetController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          flex: 1,
          child: Container(),
        ),
        Flexible(
          flex: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Consumer<UserSetController>(builder: (context, controller, child) {
                if (controller.userSet.lines.length > 1) {
                  return IconButton(
                    onPressed: () => controller.removeLastLine(),
                    iconSize: 40,
                    icon: Icon(Icons.remove_circle_outline, color: Theme.of(context).primaryColor),
                  );
                } else {
                  return IconButton(
                    onPressed: () {},
                    iconSize: 40,
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: Colors.grey,
                    ),
                  );
                }
              }),
              const Text('Set'),
              IconButton(
                onPressed: () => controller.addLine(),
                iconSize: 40,
                icon: Icon(Icons.add_circle_outline, color: Theme.of(context).primaryColor),
              ),
            ],
          ),
        ),
        Flexible(
          flex: 1,
          child: Container(),
        )
      ],
    );
  }
}

class UserLineCheckWidget extends StatelessWidget {
  UserLineCheckWidget({
    super.key,
    required this.userLine,
    required this.index,
    required this.onPress,
  });

  final UserLine userLine;
  final int index;
  final void Function(int index, bool value) onPress;
  final GlobalKey<State<StatefulWidget>> keyChecked = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: keyChecked,
      onPressed: () => onPress(index, !userLine.checked),
      icon: Icon(
        (userLine.checked) ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
        size: 30,
      ),
      color: (userLine.checked) ? Colors.green : Colors.grey,
    );
  }
}
