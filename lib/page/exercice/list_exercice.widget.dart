import 'package:fitnc_user/service/exercice.service.dart';
import 'package:fitness_domain/controller/abstract.controller.dart';
import 'package:fitness_domain/domain/exercice.domain.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ListExerciceController extends LocalSearchControllerMixin<Exercice, ExerciceService> {
  Stream<List<Exercice>> listenAllExercice() {
    return service.listenAll();
  }
}

class ListExercice extends StatelessWidget {
  ListExercice({Key? key}) : super(key: key);
  final ListExerciceController controller = Get.put(ListExerciceController());

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          onChanged: (String value) => controller.query(value),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search),
            hintText: 'Recherche...',
          ),
        ),
        StreamBuilder<List<Exercice>>(
          initialData: const <Exercice>[],
          stream: controller.listenAllExercice(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text('Une erreur est survenue.'),
              );
            }
            if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
              final List<Exercice> listExercice = snapshot.data!;
              return ListView.builder(
                shrinkWrap: true,
                itemCount: listExercice.length,
                itemBuilder: (context, index) {
                  final Exercice exercice = listExercice.elementAt(index);
                  return Card(
                    child: Text(exercice.name),
                  );
                },
              );
            } else {
              return const Center(
                child: Text('Aucun élément trouvé'),
              );
            }
          },
        )
      ],
    );
  }
}
