import 'package:fitnc_user/widget/picto.widget.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class MuscleGroupNotifier extends ChangeNotifier {
  List<MuscleGroup> group = [];
}

class MuscleGroup extends StatelessWidget {
  const MuscleGroup({super.key, required this.listMuscle});

  final List<MuscleGroup> listMuscle;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: MuscleGroupNotifier(),
      builder: (context, child) => Consumer<MuscleGroupNotifier>(builder: (context, notifier, child) {
        return PictoAssetWidget(
          group: notifier.group,
        );
      }),
    );
  }
}
