import 'package:fitnc_user/service/muscular_group.service.dart';
import 'package:fitness_domain/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

class ChoiceMuscularNotifier extends ChangeNotifier {
  final List<MuscularGroup> _listFront = [];
  final List<MuscularGroup> _listBack = [];

  List<MuscularGroup> getListFront() {
    _listFront.sort((a, b) => a.order.compareTo(b.order));
    return _listFront;
  }

  List<MuscularGroup> getListBack() {
    _listBack.sort((a, b) => a.order.compareTo(b.order));
    return _listBack;
  }

  void changeFrontGroup(MuscularGroup frontGroup, bool? isSelected) {
    if (isSelected == true) {
      addFrontGroup(frontGroup);
    } else {
      removeFrontGroup(frontGroup);
    }
  }

  void changeBackGroup(MuscularGroup backGroup, bool? isSelected) {
    if (isSelected == true) {
      addBackGroup(backGroup);
    } else {
      removeBackGroup(backGroup);
    }
  }

  void addFrontGroup(MuscularGroup frontGroup) {
    if (!_listFront.contains(frontGroup)) {
      _listFront.add(frontGroup);
      notifyListeners();
    }
  }

  void removeFrontGroup(MuscularGroup frontGroup) {
    if (_listFront.contains(frontGroup)) {
      _listFront.remove(frontGroup);
      notifyListeners();
    }
  }

  void addBackGroup(MuscularGroup backGroup) {
    if (!_listBack.contains(backGroup)) {
      _listBack.add(backGroup);
      notifyListeners();
    }
  }

  void removeBackGroup(MuscularGroup backGroup) {
    if (_listBack.contains(backGroup)) {
      _listBack.remove(backGroup);
      notifyListeners();
    }
  }

  bool isFrontSelected(MuscularGroup frontGroup) {
    return _listFront.contains(frontGroup);
  }

  bool isBackSelected(MuscularGroup backGroup) {
    return _listBack.contains(backGroup);
  }
}

class ChoiceMuscularGroup extends StatelessWidget {
  const ChoiceMuscularGroup({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChoiceMuscularNotifier>(builder: (context, notifier, child) {
      return Column(
        children: [
          Text(MuscularPart.FRONT.name.i18n()),
          Column(
            children: MuscularGroup.values
                .map((e) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(e.name),
                        Checkbox(
                          value: notifier.isFrontSelected(e),
                          onChanged: (isSelected) => notifier.changeFrontGroup(e, isSelected),
                        ),
                      ],
                    ))
                .toList(),
          ),
          Text(MuscularPart.BACK.name.i18n()),
          Column(
            children: MuscularGroup.values
                .map((e) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(e.name),
                        Checkbox(
                          value: notifier.isBackSelected(e),
                          onChanged: (isSelected) => notifier.changeBackGroup(e, isSelected),
                        ),
                      ],
                    ))
                .toList(),
          )
        ],
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
