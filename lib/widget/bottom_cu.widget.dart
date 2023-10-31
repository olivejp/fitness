import 'package:flutter/material.dart';

class BottomCu extends StatelessWidget {
  const BottomCu({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 50,
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () => print('hello'),
            child: const Text(
              'Copyrigth @Deveo.nc',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
          TextButton(
            onPressed: () => print('hello'),
            child: const Text(
              'Conditions d\'utilisation',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
