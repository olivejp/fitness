import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class DarkModeWidget extends StatelessWidget {
  const DarkModeWidget({Key? key, required this.builder}) : super(key: key);
  static const String isDarkModeKey = 'isDarkMode';
  final Widget Function() builder;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: GetStorage.init(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!) {
          final GetStorage box = GetStorage();
          dynamic isDarkMode = box.read(isDarkModeKey);
          if (isDarkMode == null || isDarkMode is! bool) {
            box.write(isDarkModeKey, false);
          }
          return builder();
        } else {
          return Container();
        }
      },
    );
  }
}
