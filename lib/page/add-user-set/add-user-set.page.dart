import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitnc_user/l10n/l10n.dart';
import 'package:fitnc_user/page/stat-exercice/stat-exercice.page.dart';
import 'package:fitnc_user/constants.dart';
import 'package:fitnc_user/domain/exercice.domain.dart';
import 'package:fitnc_user/domain/user-line.domain.dart';
import 'package:fitnc_user/domain/user-set.domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animations/loading_animations.dart';

import 'package:fitnc_user/page/add-user-set/add-user-set.notifier.dart';
import 'package:fitnc_user/page/workout-instance/workout-instance.notifier.dart';

///
/// Un UserSetNotifier est instancié par set et détruit avec lui. Il reçoit le
/// notifier de la séance, dont il a besoin pour déclencher le chrono.
///
class OpenUserSetInstance extends StatefulWidget {
  const OpenUserSetInstance(
      {Key? key, required this.userSet, required this.pageController})
      : super(key: key);

  final UserSet userSet;
  final WorkoutNotifier pageController;

  @override
  State<OpenUserSetInstance> createState() => _OpenUserSetInstanceState();
}

class _OpenUserSetInstanceState extends State<OpenUserSetInstance> {
  late final UserSetNotifier notifier =
      UserSetNotifier(pageController: widget.pageController)
        ..init(widget.userSet);

  @override
  void dispose() {
    notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UserSetUpdate(userSet: widget.userSet, notifier: notifier);
  }
}

class UserSetUpdate extends StatelessWidget {
  UserSetUpdate({Key? key, required this.userSet, required this.notifier})
      : super(key: key);

  final UserSet userSet;
  final UserSetNotifier notifier;
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
    UserSetNotifier notifier,
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
            callback: notifier.changeReps,
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
            callback: notifier.changeDist,
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
            callback: notifier.changeTime,
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
            callback: notifier.changeReps,
          ),
        ),
        Flexible(
          flex: 2,
          child: TextInputWidget(
            keyWeight: keyWeight,
            initialValue: userLine.weight,
            index: index,
            callback: notifier.changeWeight,
          ),
        )
      ];
    } else {
      throw Exception('Type exercise unknown');
    }
  }

  @override
  Widget build(BuildContext context) {
    notifier.initList(userSet.lines);
    return SingleChildScrollView(
      controller: scrollController,
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: padding, left: padding),
              child: RowExerciseDetails(notifier: notifier),
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
                      child: ValueListenableBuilder<List<UserLine>>(
                        valueListenable: notifier.listLines,
                        builder: (_, List<UserLine> lines, __) {
                          final bool allIsChecked =
                              lines.every((UserLine element) => element.checked);
                          return IconButton(
                            icon: const Icon(Icons.done_all_rounded),
                            color: allIsChecked ? Colors.green : Colors.grey,
                            iconSize: 30,
                            onPressed: () => notifier.checkAll(),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ValueListenableBuilder<List<UserLine>>(
              valueListenable: notifier.listLines,
              builder: (_, List<UserLine> lines, __) => ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: lines.length,
                  itemBuilder: (BuildContext context, int index) {
                    final GlobalKey keyReps = GlobalKey();
                    final GlobalKey keyWeight = GlobalKey();
                    final GlobalKey keyTime = GlobalKey();
                    final GlobalKey keyDist = GlobalKey();
                    final UserLine userLine = lines.elementAt(index);
                    return Padding(
                      padding: EdgeInsets.only(
                          right: padding, left: padding, top: 5),
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
                            notifier,
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
                                onPress: notifier.changeCheck,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
            ),
            RowAddRemoveSet(notifier: notifier),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          AddCommentAlertDialog(notifier: notifier),
                    );
                  },
                  label: Text(context.l10n.comment),
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
                      width: 1, color: Theme.of(context).colorScheme.primary)),
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
    Key? key,
    required this.notifier,
  }) : super(key: key);

  final UserSetNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (notifier.userSet.value.imageUrlExercice != null)
          SizedBox.square(
            child: Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              child: CachedNetworkImage(
                imageUrl: notifier.userSet.value.imageUrlExercice!,
                fit: BoxFit.cover,
                placeholder: (context, url) => LoadingBouncingGrid.circle(),
                errorWidget: (context, url, error) => Container(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            dimension: 100,
          ),
        if (notifier.userSet.value.imageUrlExercice == null)
          SizedBox.square(
            child: Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              child: Container(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            dimension: 100,
          ),
        Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(notifier.userSet.value.nameExercice!),
              IconButton(
                icon: const Icon(
                  Icons.insert_chart_outlined_rounded,
                  color: Colors.grey,
                ),
                onPressed: () {
                  notifier
                      .getExercise(notifier.userSet.value.uidExercice)
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
    required this.notifier,
  }) : super(key: key);

  final UserSetNotifier notifier;
  final GlobalKey<State<StatefulWidget>> commentKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    String comment = notifier.userSet.value.comment ?? '';
    return AlertDialog(
      title: Text(
        context.l10n.addComment,
        style: Theme.of(context).textTheme.displaySmall,
      ),
      content: TextFormField(
        decoration: InputDecoration(
          border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(5))),
          hintText: '${context.l10n.comment}...',
        ),
        controller: TextEditingController(text: comment),
        key: commentKey,
        maxLines: 10,
        onChanged: (value) => comment = value,
      ),
      actions: [
        TextButton(
          onPressed: () {
            notifier.addComment(comment);
            Navigator.of(context).pop();
          },
          child: Text(context.l10n.save),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.cancel),
        ),
      ],
    );
  }
}

class RowAddRemoveSet extends StatelessWidget {
  const RowAddRemoveSet({
    Key? key,
    required this.notifier,
  }) : super(key: key);

  final UserSetNotifier notifier;

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
              ValueListenableBuilder<UserSet>(
                  valueListenable: notifier.userSet,
                  builder: (_, UserSet userSet, __) {
                if (userSet.lines.length > 1) {
                  return IconButton(
                    onPressed: () => notifier.removeLastLine(),
                    iconSize: 40,
                    icon: Icon(Icons.remove_circle_outline,
                        color: Theme.of(context).colorScheme.primary),
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
                onPressed: () => notifier.addLine(),
                iconSize: 40,
                icon: Icon(Icons.add_circle_outline,
                    color: Theme.of(context).colorScheme.primary),
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
