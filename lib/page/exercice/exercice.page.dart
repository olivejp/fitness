import 'package:fitnc_user/page/exercice/add_exercice.page.dart';
import 'package:fitnc_user/page/exercice/exercice-choice.dialog.dart';
import 'package:fitnc_user/service/exercice.service.dart';
import 'package:fitnc_user/widget/network_image.widget.dart';
import 'package:fitness_domain/domain/exercice.domain.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:localization/localization.dart';

class ExercisePage extends StatelessWidget {
  const ExercisePage({super.key});

  final double bottomAppBarHeight = 60;

  @override
  Widget build(BuildContext context) {
    final ExerciceService exerciceService = GetIt.I.get();
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 5,
          title: Text(
            'exercises'.i18n(),
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Theme.of(context).primaryColor,
                ),
          ),
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            StreamBuilder<List<Exercice>>(
                stream: exerciceService.listenAll(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  }
                  if (snapshot.hasData) {
                    final List<Exercice> listExercise = snapshot.data!;
                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: listExercise.length,
                      itemBuilder: (context, index) {
                        final Exercice exercice = listExercise.elementAt(index);
                        return ExerciseChoiceCard(
                          exercise: exercice,
                          selected: false,
                          showSelect: false,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AddExercisePage(
                                exercise: exercice,
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) => const Divider(
                        height: 2.0,
                        color: Colors.grey,
                      ),
                    );
                  }
                  return LoadingBouncingGrid.circle(
                    backgroundColor: Theme.of(context).primaryColor,
                  );
                }),
            // StreamList<Exercice>(
            //   emptyWidget: const Column(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     crossAxisAlignment: CrossAxisAlignment.center,
            //     children: [
            //       Text('Aucun exercice trouvé.'),
            //     ],
            //   ),
            //   padding: EdgeInsets.only(bottom: bottomAppBarHeight, top: 8, left: 8, right: 8),
            //   stream: exerciceService.listenAll(),
            //   builder: (_, domain) => ExerciseCard(
            //     exercise: domain,
            //     onTap: () => Navigator.of(context).push(
            //       MaterialPageRoute(
            //         builder: (context) => AddExercisePage(
            //           exercise: domain,
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ExerciseBottomAppBar(bottomAppBarHeigth: bottomAppBarHeight),
            ),
          ],
        ),
      ),
    );
  }
}

class ExerciseBottomAppBar extends StatelessWidget {
  const ExerciseBottomAppBar({
    super.key,
    required this.bottomAppBarHeigth,
  });

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
                label: Text('createExercise'.i18n()),
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
                child: Text('back'.i18n()),
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
    super.key,
    required this.exercise,
    this.onTap,
  });

  final Exercice exercise;
  final GestureTapCallback? onTap;
  final double cardHeight = 80;
  final double imageDimension = 60;
  final double imagePadding = 10;
  final double iconSize = 20;

  @override
  Widget build(BuildContext context) {
    final ExerciceService service = GetIt.I.get();
    return InkWell(
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
                  padding: EdgeInsets.only(left: imagePadding, right: imagePadding),
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
              tooltip: 'showMore'.i18n(),
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              itemBuilder: (_) => <PopupMenuEntry<dynamic>>[
                PopupMenuItem<dynamic>(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('stats'.i18n()),
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
                      Text('delete'.i18n()),
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
    );
  }
}
