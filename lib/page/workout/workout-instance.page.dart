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
  RxBool onRefresh = false.obs;

  void init(WorkoutInstance workoutInstance, {bool goToLastPage = false}) {
    this.workoutInstance.value = workoutInstance;
    this.goToLastPage = goToLastPage;
  }

  void refreshWorkoutPage() {
    onRefresh.update((val) {
      val = !val!;
    });
  }

  Future<List<UserSet>> getAllUserSet() {
    return userSetService.orderByGet(workoutInstance.value!.uid!, 'createDate', false).then((listUserSet) {
      stepperList.clear();
      listUserSet.forEach((element) => stepperList.add(false));
      if (goToLastPage) {
        changeStepper(stepperList.length - 1);
        initialPage.value = listUserSet.length - 1;
      } else {
        changeStepper(0);
        initialPage.value = 0;
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
    return Obx(
      () {
        bool onRefresh = controller.onRefresh.value;
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
                PopupMenuButton<dynamic>(
                  iconSize: 24,
                  tooltip: 'Voir plus',
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  itemBuilder: (_) => <PopupMenuItem<dynamic>>[
                    // TODO voir pour mettre des options.
                    PopupMenuItem<dynamic>(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const <Widget>[
                          Text('Options'),
                          Icon(
                            Icons.shop_two,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                      onTap: () {},
                    ),
                  ],
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
                    children: controller.stepperList
                        .map(
                          (bool e) => Icon(
                            e ? Icons.circle : Icons.circle_outlined,
                            color: Theme.of(context).primaryColor,
                          ),
                        )
                        .toList(),
                  ),
                ),
                Flexible(
                  child: FutureBuilder<List<UserSet>>(
                    future: controller.getAllUserSet(),
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
                              TextButton.icon(
                                label: Text('Ajouter un exercice'),
                                icon: Icon(Icons.add_circle_outline),
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ExerciceChoiceDialog(
                                      workoutInstance: instance,
                                      popOnChoice: true,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                      }
                      return Column(
                        children: [
                          Expanded(
                            child: Center(
                              child: LoadingBouncingGrid.circle(
                                backgroundColor: Theme.of(context).primaryColor,
                              ),
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
      },
    );
  }
}
