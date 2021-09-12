import 'package:fitnc_user/service/fitness-user.service.dart';
import 'package:fitnc_user/service/published_programme.service.dart';
import 'package:fitnc_user/service/trainers.service.dart';
import 'package:fitness_domain/domain/published_programme.domain.dart';
import 'package:fitness_domain/domain/trainers.domain.dart';
import 'package:fitness_domain/service/abstract.service.dart';
import 'package:get/get.dart';

class SearchPageController extends SearchControllerMixin<PublishedProgramme, PublishedProgrammeService> {
  SearchPageController() : super();

  final PublishedProgrammeService publishedProgrammeService = Get.find();
  final FitnessUserService fitnessUserService = Get.find();
  final TrainersService trainersService = Get.find();

  final RxList<PublishedProgramme> listMyPrograms = <PublishedProgramme>[].obs;
  final Rx<PublishedProgramme?> selectedProgramme = PublishedProgramme().obs;
  final Rx<Trainers> trainer = Trainers().obs;

  void selectProgramme(PublishedProgramme? programme) {
    selectedProgramme.value = programme;
    if (programme?.creatorUid != null) {
      trainersService.read(programme!.creatorUid!).then((value) {
        if (value != null) {
          trainer.value = value;
        }
      });
    } else {
      trainer.value = Trainers();
    }
  }

  void initMyPrograms() {
    fitnessUserService.getMyPrograms().then((List<PublishedProgramme> list) => listMyPrograms.value = list);
  }

  Stream<List<PublishedProgramme>> listenAll() {
    return publishedProgrammeService.listenAll();
  }

  Future<void> register(PublishedProgramme publishedProgramme) async {
    fitnessUserService.register(publishedProgramme);
    return initMyPrograms();
  }

  Future<void> unregister(PublishedProgramme publishedProgramme) async {
    fitnessUserService.unregister(publishedProgramme);
    return initMyPrograms();
  }

  Future<Trainers?> getTrainers(String uid) {
    return trainersService.read(uid);
  }

  Future<void> addToFavorite(Trainers trainer) {
    return fitnessUserService.addToFavorite(trainer);
  }
}
