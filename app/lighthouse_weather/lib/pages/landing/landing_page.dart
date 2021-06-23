import 'package:flutter/material.dart';

import 'package:lighthouse_weather/pages/bluetooth/bluetooth_widget.dart';
import 'package:lighthouse_weather/pages/commons/background_widget.dart';
import 'package:lighthouse_weather/pages/commons/appname_widget.dart';

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BackgroundImage('bg_bluetooth'),
          Column(
            children: [
              AppNameWidget(),
              BluetoothWidget(),
            ],
          ),
        ],
      ),
    );
  }
}
