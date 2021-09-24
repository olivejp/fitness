import 'package:fitnc_user/page/exercice/add_exercice.page.dart';
import 'package:fitnc_user/page/exercice/exercice-choice.dialog.dart';
import 'package:fitnc_user/page/workout/add_user_set.page.dart';
import 'package:fitnc_user/service/user-set.service.dart';
import 'package:fitnc_user/service/workout-instance.service.dart';
import 'package:fitness_domain/domain/user.set.domain.dart';
import 'package:fitness_domain/domain/workout-instance.domain.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_animations/loading_animations.dart';

class WorkoutPageController extends GetxController {
  final WorkoutInstanceService service = Get.find();
  final UserSetService userSetService = Get.find();
  RxInt initialPage = 0.obs;
  Rx<WorkoutInstance?> workoutInstance = WorkoutInstance().obs;
  RxList<bool> stepperList = <bool>[].obs;
  bool goToLastPage = false;

  void init(WorkoutInstance workoutInstance, {bool goToLastPage = false}) {
    this.workoutInstance.value = workoutInstance;
    this.goToLastPage = goToLastPage;
  }

  Stream<List<UserSet>> listenAllUserSet() {
    return userSetService.orderByListen(workoutInstance.value!.uid!, 'createDate', false).map((listUserSet) {
      stepperList.clear();
      listUserSet.forEach((element) => stepperList.add(false));
      if (goToLastPage) {
        changeStepper(stepperList.length - 1);
        initialPage.value = listUserSet.length - 1;
      } else {
        changeStepper(0);
      }
      return listUserSet;
    });
  }

  void changeStepper(int index) {
    for (int i = 0; i < stepperList.length; i++) {
      stepperList[i] = (i == index);
    }
  }
}

class WorkoutPage extends StatelessWidget {
  WorkoutPage({Key? key, required this.instance, this.goToLastPage = false}) : super(key: key) {
    controller.init(instance, goToLastPage: goToLastPage);
  }

  final WorkoutPageController controller = Get.put(WorkoutPageController());
  final WorkoutInstance instance;
  final bool goToLastPage;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            DateFormat('dd/MM/yy - kk:mm').format(instance.date!),
            style: GoogleFonts.alfaSlabOne(fontSize: 18),
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.amber,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.more_vert),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddExercicePage(),
            ),
          ),
          child: const Icon(
            Icons.timer,
            color: Colors.white,
          ),
        ),
        body: Column(
          children: <Widget>[
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: controller.stepperList.map((bool e) {
                  return e
                      ? Icon(
                          Icons.circle,
                          color: Theme.of(context).primaryColor,
                        )
                      : Icon(
                          Icons.circle_outlined,
                          color: Theme.of(context).primaryColor,
                        );
                }).toList(),
              ),
            ),
            Flexible(
              child: StreamBuilder<List<UserSet>>(
                stream: controller.listenAllUserSet(),
                builder: (_, snapshot) {
                  if (snapshot.hasError) {
                    return Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: Text('Error : ${snapshot.error.toString()}'),
                          ),
                        ),
                      ],
                    );
                  }
                  if (snapshot.hasData) {
                    if (snapshot.data!.isNotEmpty) {
                      List<UserSet> listUserSet = snapshot.data!;
                      return Obx(() {
                        final PageController pageController = PageController(initialPage: controller.initialPage.value);
                        return PageView(
                          controller: pageController,
                          children: listUserSet.map((e) => OpenUserSetInstance(userSet: e)).toList(),
                          onPageChanged: (pageNumber) => controller.changeStepper(pageNumber),
                        );
                      });
                    }
                    if (snapshot.data!.isEmpty) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Ajouter un exercice',
                            textAlign: TextAlign.center,
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ExerciceChoiceDialog(
                                  workoutInstance: instance,
                                  popOnChoice: true,
                                ),
                              ),
                            ),
                            icon: Icon(
                              Icons.add_circle_outline_outlined,
                              color: Theme.of(context).primaryColor,
                              size: 50,
                            ),
                          )
                        ],
                      );
                    }
                  }
                  return Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: LoadingBouncingGrid.circle(),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
