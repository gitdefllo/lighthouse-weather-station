import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:lighthouse_weather/bloc/bluetooth/bluetooth.dart';

import 'package:lighthouse_weather/pages/bluetooth/bluetooth_info_widget.dart';
import 'package:lighthouse_weather/pages/commons/button_widget.dart';

class BluetoothWidget extends StatefulWidget {
  @override
  BluetoothWidgetState createState() {
    return BluetoothWidgetState();
  }
}

class BluetoothWidgetState extends State<BluetoothWidget> {
  @override
  Widget build(BuildContext context) {
    final bleBloc = BlocProvider.of<BleBloc>(context);
    return _showContent(bleBloc);
  }

  Widget _showContent(BleBloc bleBloc) {
    var _state = bleBloc.state;

    if (_state is BleEnabled) {
      return Expanded(
          child: Stack(children: [
        BluetoothInfo(icon: MdiIcons.bluetooth, label: 'Ready to connect'),
        _showAction(MdiIcons.bluetoothAudio, 'Connect to the station',
            () => bleBloc.add(Scanning()))
      ]));
    }

    if (_state is BleDisabled) {
      return BluetoothInfo(
          icon: MdiIcons.bluetoothOff, label: 'Turn bluetooth on');
    }

    if (_state is BleScanning) {
      return Column(children: [
        BluetoothInfo(icon: MdiIcons.bluetoothAudio, label: 'Connecting..'),
        Container(
          margin: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
      ]);
    }

    if (_state is BleFailure) {
      return Expanded(
          child: Stack(children: [
        BluetoothInfo(icon: MdiIcons.alertCircle, label: 'An error occured'),
        _showAction(MdiIcons.refresh, 'Retry to connect',
            () => bleBloc.add(Scanning())),
      ]));
    }

    return Column(children: [
      BluetoothInfo(icon: MdiIcons.bluetoothSettings, label: 'Checking..'),
      Container(
        margin: EdgeInsets.all(16.0),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      )
    ]);
  }

  Widget _showAction(IconData icon, String label, Function action) {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.only(left: 40.0, right: 40.0, bottom: 20.0),
      child: Card(
          color: Colors.transparent,
          elevation: 0.5,
          child: Container(
            padding: EdgeInsets.only(top: 20.0),
            child: ButtonWidget(label: label, iconData: icon, action: action),
          )),
    );
  }
}
