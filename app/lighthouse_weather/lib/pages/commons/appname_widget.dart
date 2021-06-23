import 'package:flutter/material.dart';

class AppNameWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      margin: new EdgeInsets.only(top: statusBarHeight + 40.0, bottom: 60.0),
      child: Text(
        'Lighthouse\n\t\t\t\tWeather App',
        style: TextStyle(
            color: Colors.white, fontSize: 28.0, fontWeight: FontWeight.bold),
      ),
    );
  }
}
