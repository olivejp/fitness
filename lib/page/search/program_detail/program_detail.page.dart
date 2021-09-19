import 'package:fitnc_user/page/search/search.controller.dart';
import 'package:fitness_domain/domain/trainers.domain.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProgramDetailPage extends StatelessWidget {
  ProgramDetailPage({Key? key}) : super(key: key);
  final SearchPageController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(children: [
          Column(
            children: <Widget>[
              Obx(
                () => Image(
                  image: NetworkImage(controller.selectedProgramme.value!.imageUrl!),
                  fit: BoxFit.fill,
                  width: double.infinity,
                ),
              ),
              Obx(
                () => CreatorWidget(
                  trainers: controller.trainer.value,
                  addToFavorite: (trainer) => controller.addToFavorite(trainer),
                ),
              ),
              if (controller.selectedProgramme.value?.description != null) Text(controller.selectedProgramme.value!.description!),
            ],
          ),
          Positioned(
            top: 10,
            left: 10,
            child: FloatingActionButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class CreatorWidget extends StatelessWidget {
  const CreatorWidget({Key? key, required this.trainers, this.addToFavorite}) : super(key: key);
  final Trainers trainers;
  final void Function(Trainers trainers)? addToFavorite;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Column(
        children: [
          const Divider(
            height: 1,
            color: Colors.grey,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                if (trainers.imageUrl != null)
                  CircleAvatar(
                    foregroundImage: NetworkImage(trainers.imageUrl!),
                  ),
                if (trainers.imageUrl == null)
                  CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text("${trainers.name} ${trainers.prenom}"),
                ),
                IconButton(
                    onPressed: () {
                      if (addToFavorite != null) {
                        addToFavorite!(trainers);
                      }
                    },
                    icon: const Icon(Icons.bookmark_border))
              ],
            ),
          ),
          const Divider(
            height: 1,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}
