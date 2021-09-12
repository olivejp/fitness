import 'package:fitnc_user/service/fitness-user.service.dart';
import 'package:fitness_domain/domain/published_programme.domain.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyProgramsPageController extends GetxController {
  final FitnessUserService fitnessUserService = Get.find();

  Stream<List<PublishedProgramme>> listenMyPrograms() {
    return fitnessUserService.listenMyPrograms();
  }
}

class MyProgramsPage extends StatelessWidget {
  MyProgramsPage({Key? key}) : super(key: key);
  final MyProgramsPageController controller = Get.put(MyProgramsPageController());

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PublishedProgramme>>(
      stream: controller.listenMyPrograms(),
      initialData: const <PublishedProgramme>[],
      builder: (context, AsyncSnapshot<List<PublishedProgramme>> snapshot) {
        if (snapshot.hasError) {
          return const Text('Error');
        } else {
          List<PublishedProgramme> list = snapshot.data!;
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, index) {
              return Card(
                child: Text(list[index].name),
              );
            },
          );
        }
      },
    );
  }
}
