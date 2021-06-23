import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue/flutter_blue.dart' show Guid;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:lighthouse_weather/bloc/bluetooth/bluetooth.dart';
import 'package:lighthouse_weather/bloc/settings/settings.dart';

import 'package:lighthouse_weather/pages/commons/appname_widget.dart';
import 'package:lighthouse_weather/pages/commons/background_widget.dart';
import 'package:lighthouse_weather/pages/commons/button_widget.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage();

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  final Guid _SYSTEM_SERVICE_GUID = Guid('00000000-61c8-471e-94f3-5050570167b2');

  @override
  Widget build(BuildContext context) {
    var bleBloc = BlocProvider.of<BleBloc>(context);

    return BlocProvider(
        create: (_) => SettingsBloc(bleBloc.getServiceByGuid(_SYSTEM_SERVICE_GUID))
          ..add(ShouldGetIpAddress()),
        child:
            BlocBuilder<SettingsBloc, SettingsState>(builder: (context, state) {
          return Scaffold(
              body: Stack(
            children: [
              BackgroundImage('bg_settings'),
              Container(alignment: Alignment.topCenter, child: AppNameWidget()),
              _showContent(state),
              _setAction(context)
            ],
          ));
        }));
  }

  Widget _showContent(SettingsState state) {
    if (state is SettingsClosed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
    }

    var ipAddress = 'x.x.x.x';
    if (state is IpAddressReceived) {
      ipAddress = state.ipAddress;
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
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Icon(
                                  MdiIcons.wifi,
                                  color: Colors.white,
                                ),
                                Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                      ipAddress,
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w300),
                                    )),
                              ])))))
        ]);
  }

  Widget _setAction(BuildContext context) {
    var settingsBloc = BlocProvider.of<SettingsBloc>(context);

    return Container(
        alignment: Alignment.bottomCenter,
        padding: EdgeInsets.only(left: 40.0, right: 40.0, bottom: 20.0),
        child: Card(
          color: Colors.transparent,
          elevation: 0.5,
          child: Container(
              padding: EdgeInsets.only(top: 20.0),
              child: ButtonWidget(
                  label: 'Shutdown the station',
                  iconData: MdiIcons.power,
                  action: () => settingsBloc.add(ShouldShutdown()))),
        ));
  }
}
