import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyInfos extends StatelessWidget {
  const MyInfos({super.key});

  final double squareSize = 120;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              'Mes informations',
              style: GoogleFonts.antonio(fontSize: 16, fontWeight: FontWeight.w900),
            ),
          ),
          SizedBox(
            height: squareSize,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              shrinkWrap: true,
              itemCount: 4,
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, index) {
                switch (index) {
                  default:
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: SizedBox(width: squareSize, child: const Card()),
                    );
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
