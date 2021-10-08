import 'package:flutter/material.dart';

class GradientText extends StatelessWidget {
  const GradientText(this.text,
      {Key? key,
      this.primaryColor = Colors.amberAccent,
      this.secondaryColor = Colors.purple,
      this.textStyle})
      : super(key: key);

  final String text;
  final Color primaryColor;
  final Color secondaryColor;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: <Color>[
          primaryColor,
          secondaryColor,
        ],
      ).createShader(Rect.fromLTWH(0.0, 0.0, bounds.width, bounds.height)),
      child: Text(
        text,
        style: textStyle?.copyWith(color: Colors.white),
      ),
    );
  }
}
