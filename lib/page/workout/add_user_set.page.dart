import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitnc_user/page/exercice/stat-exercice.page.dart';
import 'package:fitness_domain/constants.dart';
import 'package:fitness_domain/domain/exercice.domain.dart';
import 'package:fitness_domain/domain/user.line.domain.dart';
import 'package:fitness_domain/domain/user.set.domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animations/loading_animations.dart';
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
        const Flexible(
          flex: 2,
          child: Center(child: Text('Reps')),
        ),
        const Flexible(
          flex: 2,
          child: Center(child: Text('Weight')),
        )
      ];
    } else if (userSet.typeExercice == TypeExercice.REPS_ONLY.name) {
      return [
        const Flexible(
          flex: 4,
          child: Center(child: Text('Reps')),
        )
      ];
    } else if (userSet.typeExercice == TypeExercice.TIME.name) {
      return [
        const Flexible(
          flex: 4,
          child: Center(child: Text('Time')),
        )
      ];
    } else if (userSet.typeExercice == TypeExercice.DIST.name) {
      return [
        const Flexible(
          flex: 4,
          child: Center(child: Text('Dist')),
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
    GlobalKey keyTime,
    GlobalKey keyDist,
  ) {
    if (typeExercise == TypeExercice.REPS_ONLY.name) {
      return [
        Flexible(
          flex: 4,
          child: TextInputWidget(
            keyWeight: keyReps,
            initialValue: userLine.reps,
            index: index,
            callback: controller.changeReps,
          ),
        ),
      ];
    } else if (typeExercise == TypeExercice.DIST.name) {
      return [
        Flexible(
          flex: 4,
          child: TextInputWidget(
            keyWeight: keyDist,
            initialValue: userLine.dist,
            index: index,
            callback: controller.changeDist,
          ),
        ),
      ];
    } else if (typeExercise == TypeExercice.TIME.name) {
      return [
        Flexible(
          flex: 4,
          child: TextInputWidget(
            keyWeight: keyTime,
            initialValue: userLine.time,
            index: index,
            callback: controller.changeTime,
          ),
        ),
      ];
    } else if (typeExercise == TypeExercice.REPS_WEIGHT.name) {
      return [
        Flexible(
          flex: 2,
          child: TextInputWidget(
            keyWeight: keyReps,
            initialValue: userLine.reps,
            index: index,
            callback: controller.changeReps,
          ),
        ),
        Flexible(
          flex: 2,
          child: TextInputWidget(
            keyWeight: keyWeight,
            initialValue: userLine.weight,
            index: index,
            callback: controller.changeWeight,
          ),
        )
      ];
    } else {
      throw Exception('Type exercise unknown');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserSetController>(builder: (context, controller, child) {
      controller.initList(userSet.lines, false);
      bool allIsChecked = controller.listLines.every((element) => element.checked);
      return SingleChildScrollView(
        controller: scrollController,
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(right: padding, left: padding),
                child: RowExerciseDetails(controller: controller),
              ),
              Padding(
                padding: EdgeInsets.only(right: padding, left: padding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Flexible(
                      child: Center(child: Text('Sets')),
                    ),
                    ...getColumnsHeadersByType(),
                    Flexible(
                      child: Center(
                        child: IconButton(
                          icon: const Icon(Icons.done_all_rounded),
                          color: allIsChecked ? Colors.green : Colors.grey,
                          iconSize: 30,
                          onPressed: () => controller.checkAll(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: controller.listLines.length,
                  itemBuilder: (BuildContext context, int index) {
                    final GlobalKey keyReps = GlobalKey();
                    final GlobalKey keyWeight = GlobalKey();
                    final GlobalKey keyTime = GlobalKey();
                    final GlobalKey keyDist = GlobalKey();
                    final UserLine userLine = controller.listLines.elementAt(index);
                    return Padding(
                      padding: EdgeInsets.only(
                        right: padding,
                        left: padding,
                        top: 5,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Flexible(
                            child: Center(child: Text('${index + 1}')),
                          ),
                          ...getColumnsFieldsByType(
                            userSet.typeExercice,
                            userLine,
                            index,
                            controller,
                            keyReps,
                            keyWeight,
                            keyTime,
                            keyDist,
                          ),
                          Flexible(
                            child: Center(
                              child: UserLineCheckWidget(
                                index: index,
                                userLine: userLine,
                                onPress: (index, checked) => controller.changeCheck(context, index, checked),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              RowAddRemoveSet(controller: controller),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AddCommentAlertDialog(controller: controller),
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
    });
  }
}

class TextInputWidget extends StatelessWidget {
  const TextInputWidget({
    super.key,
    required this.keyWeight,
    required this.callback,
    required this.index,
    required this.initialValue,
  });

  final GlobalKey<State<StatefulWidget>> keyWeight;
  final String? initialValue;
  final int index;
  final void Function(int index, String value) callback;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: TextFormField(
          key: keyWeight,
          initialValue: initialValue,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
          ],
          decoration: InputDecoration(
              constraints: const BoxConstraints(maxHeight: 36),
              border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                  borderSide: BorderSide(width: 1, color: Theme.of(context).primaryColor)),
              hintStyle: const TextStyle(fontSize: 14),
              hintText: '0'),
          onChanged: (value) => callback(index, value),
        ),
      ),
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
        FutureBuilder<String>(
          future: controller.getExerciceImageUrl(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final String imageUrl = snapshot.data!;
              if (imageUrl.isNotEmpty) {
                return SizedBox.square(
                  dimension: 100,
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => LoadingBouncingGrid.circle(),
                      errorWidget: (context, url, error) => Container(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                );
              } else {
                return SizedBox.square(
                  dimension: 100,
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Container(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                );
              }
            } else {
              return LoadingBouncingGrid.square();
            }
          },
        ),
        Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                controller.userSet.nameExercice!,
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
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
