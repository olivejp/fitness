import 'package:fitnc_user/service/fitness-user.service.dart';
import 'package:fitness_domain/domain/published_programme.domain.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:loading_animations/loading_animations.dart';

class MyProgramsPageController extends GetxController {
  final FitnessUserService fitnessUserService = GetIt.I.get();

  Stream<List<PublishedProgramme>> listenMyPrograms() {
    return fitnessUserService.listenMyPrograms();
  }
}

class MyProgramsPage extends StatelessWidget {
  MyProgramsPage({super.key});
  final MyProgramsPageController controller = Get.put(MyProgramsPageController());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: Column(
        children: <Widget>[
          Text(
            'Mes programmes',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Expanded(
            child: StreamBuilder<List<PublishedProgramme>>(
              stream: controller.listenMyPrograms(),
              initialData: const <PublishedProgramme>[],
              builder: (context, AsyncSnapshot<List<PublishedProgramme>> snapshot) {
                if (snapshot.hasError) {
                  return const Text('Error');
                }
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    List<PublishedProgramme> list = snapshot.data!;
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: list.length,
                      itemBuilder: (_, index) {
                        return Card(
                          child: Text(list[index].name),
                        );
                      },
                    );
                  }
                }
                return Center(
                    child: LoadingBouncingGrid.circle(
                  backgroundColor: Theme.of(context).primaryColor,
                ));
              },
            ),
          ),
        ],
      ),
    );
  }
}
