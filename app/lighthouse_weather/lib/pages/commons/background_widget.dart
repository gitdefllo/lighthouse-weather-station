import 'package:flutter/material.dart';

class BackgroundImage extends StatelessWidget {
  BackgroundImage(this.imageName);

  final String imageName;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/$imageName.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: null,
    );
  }
}