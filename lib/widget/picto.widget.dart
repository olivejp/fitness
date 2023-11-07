import 'dart:async';

import 'package:fitnc_user/service/muscular_group.service.dart';
import 'package:fitness_domain/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

class ChoiceMuscularNotifier extends ChangeNotifier {
  final List<MuscularGroup> _list = [];
  final StreamController<List<MuscularGroup>> _str = StreamController();

  List<MuscularGroup> get listFront =>
      MuscularGroup.values.where((element) => element.part == MuscularPart.FRONT).toList();

  List<MuscularGroup> get listBack =>
      MuscularGroup.values.where((element) => element.part == MuscularPart.BACK).toList();

  Stream<List<MuscularGroup>> get listStream => _str.stream;

  void initList(List<dynamic>? list) {
    if (list == null) {
      return;
    }

    for (var element in list) {
      for (var muscularGroup in MuscularGroup.values) {
        if (muscularGroup.name.trim().toUpperCase() == element.toString().trim().toUpperCase()) {
          _list.add(muscularGroup);
          break;
        }
      }
    }
  }

  void changeGroup(MuscularGroup group, bool? isSelected) {
    if (isSelected == true) {
      addGroup(group);
    } else {
      removeGroup(group);
    }
  }

  void addGroup(MuscularGroup group) {
    if (!_list.contains(group)) {
      _list.add(group);
      _str.sink.add(_list);
      notifyListeners();
    }
  }

  void removeGroup(MuscularGroup group) {
    if (_list.contains(group)) {
      _list.remove(group);
      _str.sink.add(_list);
      notifyListeners();
    }
  }

  bool isSelected(MuscularGroup group) {
    return _list.contains(group);
  }
}

class ChoiceMuscularGroup extends StatelessWidget {
  const ChoiceMuscularGroup({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChoiceMuscularNotifier>(builder: (context, notifier, child) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              MuscularPart.FRONT.name.i18n(),
              style: GoogleFonts.anton(
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            Wrap(
                runSpacing: 5.0,
                children: notifier.listFront.map((e) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: ChoiceChip(
                      label: Text(e.name.i18n()),
                      selected: notifier.isSelected(e),
                      onSelected: (bool selected) => notifier.changeGroup(e, selected),
                    ),
                  );
                }).toList()),
            const SizedBox(
              height: 10.0,
            ),
            Text(
              MuscularPart.BACK.name.i18n(),
              style: GoogleFonts.anton(
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            Wrap(
                runSpacing: 5.0,
                children: notifier.listBack.map((e) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: ChoiceChip(
                      label: Text(e.name.i18n()),
                      selected: notifier.isSelected(e),
                      onSelected: (bool selected) => notifier.changeGroup(e, selected),
                    ),
                  );
                }).toList()),
          ],
        ),
      );
    });
  }
}

class PictoAssetWidget extends StatelessWidget {
  const PictoAssetWidget({super.key, required this.group, this.height = 100});

  final List<dynamic>? group;
  final double? height;

  String getAssetPath(String part) {
    return 'images/picto/${part.toLowerCase()}.svg';
  }

  String getPartAssetPath(MuscularPart part) {
    return getAssetPath(part.name);
  }

  String getFrontAssetPath(MuscularGroup part) {
    return getAssetPath(part.name);
  }

  String getBackAssetPath(MuscularGroup part) {
    return getAssetPath(part.name);
  }

  @override
  Widget build(BuildContext context) {
    final List<MuscularGroup> listFront = [];
    final List<MuscularGroup> listBack = [];

    group?.forEach((element) {
      MuscularGroupService.getListFront().forEach((muscularGroup) {
        if (muscularGroup.name == element) {
          listFront.add(muscularGroup);
        }
      });

      MuscularGroupService.getListBack().forEach((muscularGroup) {
        if (muscularGroup.name == element) {
          listBack.add(muscularGroup);
        }
      });
    });

    return SizedBox(
      height: height,
      child: Row(
        children: [
          Flexible(
            child: Stack(children: [
              SvgPicture.asset(getPartAssetPath(MuscularPart.FRONT)),
              Stack(children: listFront.map((e) => SvgPicture.asset(getFrontAssetPath(e))).toList()),
            ]),
          ),
          const VerticalDivider(
            thickness: 2.0,
            indent: 10,
            endIndent: 10,
            color: FitnessNcColors.primary,
          ),
          Flexible(
            child: Stack(children: [
              SvgPicture.asset(getPartAssetPath(MuscularPart.BACK)),
              Stack(children: listBack.map((e) => SvgPicture.asset(getBackAssetPath(e))).toList()),
            ]),
          ),
        ],
      ),
    );
  }
}
