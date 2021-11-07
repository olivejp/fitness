import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitnc_user/page/exercice/stat-exercice.page.dart';
import 'package:fitness_domain/domain/exercice.domain.dart';
import 'package:fitness_domain/domain/user.line.domain.dart';
import 'package:fitness_domain/domain/user.set.domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:loading_animations/loading_animations.dart';

import 'add_user_set.controller.dart';

class OpenUserSetInstance extends StatelessWidget {
  const OpenUserSetInstance({Key? key, required this.userSet})
      : super(key: key);

  final UserSet userSet;

  @override
  Widget build(BuildContext context) {
    final UserSetController controller =
        Get.put(UserSetController(), tag: userSet.uid);
    controller.init(userSet);
    return UserSetUpdate(userSet: userSet);
  }
}

class UserSetUpdate extends StatelessWidget {
  UserSetUpdate({Key? key, required this.userSet}) : super(key: key);

  final UserSet userSet;
  final double padding = 15;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final ScrollController scrollController = ScrollController();

  List<Widget> getColumns() {
    switch (userSet.typeExercice) {
      case 'REPS_WEIGHT':
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
      case 'REPS_ONLY':
        return [
          const Flexible(
            flex: 4,
            child: Center(child: Text('Reps')),
          )
        ];
      case 'TIME':
        return [
          const Flexible(
            flex: 4,
            child: Center(child: Text('Time')),
          )
        ];
      case 'DIST':
        return [
          const Flexible(
            flex: 4,
            child: Center(child: Text('Dist')),
          )
        ];
      default:
        return [];
    }
  }

  List<Widget> getColumnsByType(
    String? typeExercise,
    UserLine userLine,
    int index,
    UserSetController controller,
    GlobalKey keyReps,
    GlobalKey keyWeight,
    GlobalKey keyTime,
    GlobalKey keyDist,
  ) {
    switch (typeExercise) {
      case 'REPS_ONLY':
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
      case 'DIST':
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
      case 'TIME':
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
      default:
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserSetController controller = Get.find(tag: userSet.uid);
    controller.initList(userSet.lines);
    return SingleChildScrollView(
      controller: scrollController,
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: padding, left: padding),
              child: RowExerciceDetails(controller: controller),
            ),
            Padding(
              padding: EdgeInsets.only(right: padding, left: padding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Flexible(
                    child: Center(child: Text('Sets')),
                  ),
                  ...getColumns(),
                  Flexible(
                    child: Center(
                      child: Obx(
                        () {
                          bool allIsChecked = controller.listLines
                              .every((element) => element.checked);
                          return IconButton(
                            icon: const Icon(Icons.done_all_rounded),
                            color: allIsChecked ? Colors.green : Colors.grey,
                            iconSize: 30,
                            onPressed: () => controller.checkAll(),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Obx(
              () => ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: controller.listLines.length,
                  itemBuilder: (BuildContext context, int index) {
                    final GlobalKey keyReps = GlobalKey();
                    final GlobalKey keyWeight = GlobalKey();
                    final GlobalKey keyTime = GlobalKey();
                    final GlobalKey keyDist = GlobalKey();
                    final UserLine userLine =
                        controller.listLines.elementAt(index);
                    return Padding(
                      padding: EdgeInsets.only(
                          right: padding, left: padding, top: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Flexible(
                            child: Center(child: Text('$index')),
                          ),
                          ...getColumnsByType(
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
                                onPress: controller.changeCheck,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
            ),
            RowAddRemoveSet(controller: controller),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          AddCommentAlertDialog(controller: controller),
                    );
                  },
                  label: const Text('Commentaire'),
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

class TextInputWidget extends StatelessWidget {
  const TextInputWidget({
    Key? key,
    required this.keyWeight,
    required this.callback,
    required this.index,
    required this.initialValue,
  }) : super(key: key);

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
              border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                  borderSide: BorderSide(
                      width: 1, color: Theme.of(context).primaryColor)),
              hintStyle: const TextStyle(fontSize: 14),
              hintText: '0'),
          onChanged: (value) => callback(index, value),
        ),
      ),
    );
  }
}

class RowExerciceDetails extends StatelessWidget {
  const RowExerciceDetails({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final UserSetController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (controller.userSet.value.imageUrlExercice != null)
          SizedBox.square(
            child: Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              child: CachedNetworkImage(
                imageUrl: controller.userSet.value.imageUrlExercice!,
                fit: BoxFit.cover,
                placeholder: (context, url) => LoadingBouncingGrid.circle(),
                errorWidget: (context, url, error) => Container(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            dimension: 100,
          ),
        if (controller.userSet.value.imageUrlExercice == null)
          SizedBox.square(
            child: Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              child: Container(
                color: Theme.of(context).primaryColor,
              ),
            ),
            dimension: 100,
          ),
        Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(controller.userSet.value.nameExercice!),
              IconButton(
                icon: const Icon(
                  Icons.insert_chart_outlined_rounded,
                  color: Colors.grey,
                ),
                onPressed: () {
                  controller
                      .getExercise(controller.userSet.value.uidExercice)
                      .then(
                    (Exercice? exercise) {
                      if (exercise != null) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                StatExercicePage(exercice: exercise),
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
    Key? key,
    required this.controller,
  }) : super(key: key);

  final UserSetController controller;
  final GlobalKey<State<StatefulWidget>> commentKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    String comment = controller.userSet.value.comment ?? '';
    return AlertDialog(
      title: Text('Ajouter un commentaire', style: Theme.of(context).textTheme.headline3,),
      content: TextFormField(
        decoration: const InputDecoration(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(5))),
          hintText: 'Commentaire...',
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
          child: const Text('Sauver'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
      ],
    );
  }
}

class RowAddRemoveSet extends StatelessWidget {
  const RowAddRemoveSet({
    Key? key,
    required this.controller,
  }) : super(key: key);

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
              Obx(() {
                if (controller.userSet.value.lines.length > 1) {
                  return IconButton(
                    onPressed: () => controller.removeLastLine(),
                    iconSize: 40,
                    icon: Icon(Icons.remove_circle_outline,
                        color: Theme.of(context).primaryColor),
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
                icon: Icon(Icons.add_circle_outline,
                    color: Theme.of(context).primaryColor),
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
    Key? key,
    required this.userLine,
    required this.index,
    required this.onPress,
  }) : super(key: key);

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
        (userLine.checked)
            ? Icons.check_box_rounded
            : Icons.check_box_outline_blank_rounded,
        size: 30,
      ),
      color: (userLine.checked) ? Colors.green : Colors.grey,
    );
  }
}
