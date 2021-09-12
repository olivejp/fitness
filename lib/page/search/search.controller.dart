import 'package:fitnc_user/service/fitness-user.service.dart';
import 'package:fitnc_user/service/published_programme.service.dart';
import 'package:fitness_domain/domain/published_programme.domain.dart';
import 'package:fitness_domain/service/abstract.service.dart';
import 'package:get/get.dart';

class SearchPageController extends SearchControllerMixin<PublishedProgramme, PublishedProgrammeService> {
  SearchPageController() : super();

  final PublishedProgrammeService publishedProgrammeService = Get.find();
  final FitnessUserService fitnessUserService = Get.find();

  Stream<List<PublishedProgramme>> listenAll() {
    return publishedProgrammeService.listenAll();
  }

  Future<void> register(PublishedProgramme publishedProgramme) {
    return fitnessUserService.register(publishedProgramme);
  }
}
