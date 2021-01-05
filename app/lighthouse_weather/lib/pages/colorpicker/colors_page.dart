import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:lighthouse_weather/bloc/bluetooth/bluetooth.dart';
import 'package:lighthouse_weather/bloc/colors/colors.dart';

import 'package:lighthouse_weather/pages/commons/background_widget.dart';
import 'package:lighthouse_weather/pages/commons/button_widget.dart';

class ColorsPage extends StatefulWidget {
  @override
  ColorsPageState createState() {
    return ColorsPageState();
  }
}

class ColorsPageState extends State<ColorsPage> {
  Color currentColor = Color(0xff375670);

  @override
  Widget build(BuildContext context) {
    var bleBloc = BlocProvider.of<BleBloc>(context);

    return BlocProvider(
        create: (_) => ColorsBloc(bleBloc.connection.output),
        child: BlocBuilder<ColorsBloc, ColorsState>(builder: (context, state) {
          return Scaffold(
              body: Stack(
            children: [
              BackgroundImage('bg_colors'),
              _showContent(state),
              _setAction(context)
            ],
          ));
        }));
  }

  Widget _showContent(ColorsState state) {
    if (state is ColorsUpdatingFailed) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('An error occurred, the color is not updated'),
        duration: const Duration(seconds: 3),
      ));
    }

    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
              child: Container(
                  alignment: Alignment.center,
                  padding:
                      EdgeInsets.only(left: 40.0, right: 40.0, bottom: 20.0),
                  child: Card(
                      color: Colors.transparent,
                      elevation: 0.5,
                      child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(20.0),
                          child: ColorPicker(
                            pickerColor: currentColor,
                            pickerAreaHeightPercent: 0.8,
                            showLabel: false,
                            enableAlpha: false,
                            onColorChanged: (color) =>
                                setState(() => currentColor = color),
                          ))))),
        ]);
  }

  Widget _setAction(BuildContext context) {
    var colorsBloc = BlocProvider.of<ColorsBloc>(context);

    return Container(
        alignment: Alignment.bottomCenter,
        padding: EdgeInsets.only(left: 40.0, right: 40.0, bottom: 20.0),
        child: Card(
          color: Colors.transparent,
          elevation: 0.5,
          child: Container(
              padding: EdgeInsets.only(top: 20.0),
              child: ButtonWidget(
                  label: 'Update the color',
                  iconData: MdiIcons.palette,
                  action: () => colorsBloc.add(ChangeColors([
                        currentColor.red,
                        currentColor.green,
                        currentColor.blue
                      ])))),
        ));
  }
}
