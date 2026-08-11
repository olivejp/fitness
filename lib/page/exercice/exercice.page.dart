import 'package:fitnc_user/l10n/l10n.dart';
import 'package:fitnc_user/page/add-exercice/add-exercice.page.dart';
import 'package:fitnc_user/service/exercice.service.dart';
import 'package:fitnc_user/widget/network-image.widget.dart';
import 'package:fitnc_user/di.dart';
import 'package:fitnc_user/domain/exercice.domain.dart';
import 'package:fitnc_user/widget/generic-container.widget.dart';
import 'package:flutter/material.dart';

class ExercisePage extends StatelessWidget {
  const ExercisePage({Key? key}) : super(key: key);
  final double bottomAppBarHeight = 60;

  @override
  Widget build(BuildContext context) {
    final ExerciceService exerciceService = di<ExerciceService>();
    return SafeArea(
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            StreamList<Exercice>(
              emptyWidget: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Text('Aucun exercice trouvé.'),
                ],
              ),
              padding: EdgeInsets.only(
                  bottom: bottomAppBarHeight, top: 8, left: 8, right: 8),
              stream: exerciceService.listenAll(),
              builder: (_, domain) => ExerciseCard(
                exercise: domain,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddExercisePage(
                      exercise: domain,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child:
                  ExerciseBottomAppBar(bottomAppBarHeigth: bottomAppBarHeight),
            ),
          ],
        ),
      ),
    );
  }
}

class ExerciseBottomAppBar extends StatelessWidget {
  const ExerciseBottomAppBar({
    Key? key,
    required this.bottomAppBarHeigth,
  }) : super(key: key);

  final double bottomAppBarHeigth;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Theme.of(context).bottomAppBarTheme.color,
      elevation: 10,
      child: SizedBox(
        height: bottomAppBarHeigth,
        child: Padding(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                label: Text(context.l10n.createExercise),
                icon: const Icon(Icons.add_circle_outline_rounded),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddExercisePage(
                      exercise: Exercice(),
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(context.l10n.back),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExerciseCard extends StatelessWidget {
  const ExerciseCard({
    Key? key,
    required this.exercise,
    this.onTap,
  }) : super(key: key);

  final Exercice exercise;
  final GestureTapCallback? onTap;
  final double cardHeight = 80;
  final double imageDimension = 60;
  final double imagePadding = 10;
  final double iconSize = 20;

  @override
  Widget build(BuildContext context) {
    final ExerciceService service = di<ExerciceService>();
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: cardHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        left: imagePadding, right: imagePadding),
                    child: NetworkImageExerciseChoice(
                      imageUrl: exercise.imageUrl,
                      radius: 5,
                    ),
                  ),
                  Text(exercise.name),
                ],
              ),
              PopupMenuButton<dynamic>(
                iconSize: iconSize,
                tooltip: context.l10n.showMore,
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                itemBuilder: (_) => <PopupMenuEntry<dynamic>>[
                  PopupMenuItem<dynamic>(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(context.l10n.stats),
                        const Icon(
                          Icons.bar_chart_outlined,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                    onTap: () {},
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem<dynamic>(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(context.l10n.delete),
                        const Icon(
                          Icons.delete,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                    onTap: () => service.delete(exercise),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
