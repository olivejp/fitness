import 'package:flutter/material.dart';

class BottomCu extends StatelessWidget {
  const BottomCu({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 50, minHeight: 50),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
                onPressed: () => print('hello'),
                child: const Text(
                  'Copyrigth @Deveo.nc',
                  style: TextStyle(color: Colors.grey),
                )),
            TextButton(
                onPressed: () => print('hello'),
                child: const Text(
                  'Conditions d\'utilisation',
                  style: TextStyle(color: Colors.grey),
                )),
          ],
        ),
      ),
    );
  }
}
