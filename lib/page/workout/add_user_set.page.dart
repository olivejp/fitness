import 'dart:async';

import 'package:fitnc_user/service/exercice.service.dart';
import 'package:fitnc_user/service/user-set.service.dart';
import 'package:fitness_domain/domain/user.line.domain.dart';
import 'package:fitness_domain/domain/user.set.domain.dart';
import 'package:fitness_domain/domain/workout.domain.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class UserSetController extends GetxController {
  final ExerciceService exerciceService = Get.find();
  final UserSetService userSetService = Get.find();
  final Rx<UserSet> userSet = UserSet().obs;
  final Rx<Workout> workout = Workout().obs;
  final RxList<UserLine> listLines = <UserLine>[].obs;
  final int debounceTime = 200;
  Timer? _debounce;

  void init(UserSet userSet) {
    if (userSet.lines.isEmpty) {
      userSet.lines.add(UserLine());
    }
    this.userSet.value = userSet;
  }

  void initList(List<UserLine> lines) {
    listLines.clear();
    listLines.addAll(lines);
    listLines.refresh();
  }

  void addLine() {
    userSet.update((val) {
      val!.lines.add(UserLine());
    });
    initList(userSet.value.lines);
  }

  void afterDebounce(void Function() callback) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: debounceTime), () {
      callback.call();
    });
  }

  void removeLastLine() {
    userSet.update((val) {
      val!.lines.removeAt(val.lines.length - 1);
    });
    userSetService.save(userSet.value).then((value) {
      initList(userSet.value.lines);
    });
  }

  void changeReps(int index, String reps) {
    userSet.value.lines[index].reps = reps;
    afterDebounce(() {
      userSetService.save(userSet.value);
    });
  }

  void changeWeight(int index, String weight) {
    userSet.value.lines[index].weight = weight;
    afterDebounce(() {
      userSetService.save(userSet.value);
    });
  }

  void changeCheck(int index, bool checked) {
    userSet.value.lines[index].checked = checked;
    userSetService.save(userSet.value);
    listLines[index].checked = checked;
    listLines.refresh();
  }
}

class OpenUserSetInstance extends StatelessWidget {
  const OpenUserSetInstance({Key? key, required this.userSet}) : super(key: key);

  final UserSet userSet;

  @override
  Widget build(BuildContext context) {
    final UserSetController controller = Get.put(UserSetController(), tag: userSet.uid);
    controller.init(userSet);
    return UserSetUpdate(userSet: userSet);
  }
}

class UserSetUpdate extends StatelessWidget {
  UserSetUpdate({Key? key, required this.userSet}) : super(key: key);

  final UserSet userSet;
  final double padding = 15;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final UserSetController controller = Get.find(tag: userSet.uid);
    controller.initList(userSet.lines);
    return SingleChildScrollView(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: padding, left: padding),
              child: Row(
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
                        child: Image(
                          image: NetworkImage(controller.userSet.value.imageUrlExercice!),
                          fit: BoxFit.cover,
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
                    child: Text(controller.userSet.value.nameExercice!),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: padding, left: padding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const <Widget>[
                  Flexible(
                    child: Center(child: Text('Sets')),
                  ),
                  Flexible(
                    flex: 2,
                    child: Center(child: Text('Reps')),
                  ),
                  Flexible(
                    flex: 2,
                    child: Center(child: Text('Weight')),
                  ),
                  Flexible(
                    child: Center(
                      child: Icon(
                        Icons.check_circle_outlined,
                        color: Colors.green,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Obx(
              () => ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.listLines.length,
                  itemBuilder: (BuildContext context, int index) {
                    final GlobalKey keyReps = GlobalKey();
                    final GlobalKey keyWeight = GlobalKey();
                    final GlobalKey keyTime = GlobalKey();
                    final UserLine userLine = controller.listLines.elementAt(index);
                    return Padding(
                      padding: EdgeInsets.only(right: padding, left: padding, top: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Flexible(
                            child: Center(child: Text('$index')),
                          ),
                          Flexible(
                            flex: 2,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5, right: 5),
                                child: TextFormField(
                                  key: keyReps,
                                  initialValue: userLine.reps,
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                  ],
                                  decoration: InputDecoration(
                                      constraints: BoxConstraints(maxHeight: 36),
                                      border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(Radius.circular(5)),
                                        borderSide: BorderSide(width: 1, color: Theme.of(context).primaryColor),
                                      ),
                                      hintStyle: const TextStyle(fontSize: 14),
                                      hintText: '0'),
                                  onChanged: (value) => controller.changeReps(index, value),
                                ),
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 2,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5, right: 5),
                                child: TextFormField(
                                  key: keyWeight,
                                  initialValue: userLine.weight,
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                  ],
                                  decoration: InputDecoration(
                                      constraints: BoxConstraints(maxHeight: 36),
                                      border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius: const BorderRadius.all(Radius.circular(5)),
                                          borderSide: BorderSide(width: 1, color: Theme.of(context).primaryColor)),
                                      hintStyle: const TextStyle(fontSize: 14),
                                      hintText: '0'),
                                  onChanged: (value) => controller.changeWeight(index, value),
                                ),
                              ),
                            ),
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
            Row(
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
                            icon: Icon(Icons.remove_circle_outline, color: Theme.of(context).primaryColor),
                          );
                        } else {
                          return IconButton(
                            onPressed: () {},
                            iconSize: 40,
                            icon: Icon(
                              Icons.remove_circle_outline,
                              color: Colors.grey,
                            ),
                          );
                        }
                      }),
                      Text('Set'),
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
            )
          ],
        ),
      ),
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
        (userLine.checked) ? Icons.check_circle : Icons.circle_outlined,
        size: 30,
      ),
      color: Colors.green,
    );
  }
}
