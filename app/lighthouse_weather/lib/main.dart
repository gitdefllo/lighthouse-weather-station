import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/bluetooth/bluetooth.dart';

import 'pages/landing/landing_page.dart';
import 'pages/homepage/home_page.dart';

void main() {
  runApp(BlocProvider<BleBloc>(
    create: (_) => BleBloc()..add(Init()),
    child: LighthouseWeatherApp(),
  ));
}

class LighthouseWeatherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lighthouse Weather App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
//      theme: ThemeData(
//          primarySwatch: Colors.red,
//          primaryColor: Colors.red,
//          primaryColorDark: Colors.black87,
//          accentColor: Colors.redAccent),
      home: BlocBuilder<BleBloc, BleState>(builder: (context, state) {
        if (state is BleConnected) {
          return HomePage();
        }
        return LandingPage();
      }),
    );
  }
}
