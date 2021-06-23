import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue/flutter_blue.dart' show Guid;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:lighthouse_weather/bloc/bluetooth/bluetooth.dart';
import 'package:lighthouse_weather/bloc/weather/weather.dart';

import 'package:lighthouse_weather/pages/cities/cities_page.dart';
import 'package:lighthouse_weather/pages/colorpicker/colors_page.dart';
import 'package:lighthouse_weather/pages/commons/appname_widget.dart';
import 'package:lighthouse_weather/pages/commons/background_widget.dart';
import 'package:lighthouse_weather/pages/commons/button_widget.dart';
import 'package:lighthouse_weather/pages/settings/settings_page.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  final Guid _WEATHER_SERVICE_GUID = Guid('00000000-8cb1-44ce-9a66-001dca0941a6');

  @override
  Widget build(BuildContext context) {
    var bleBloc = BlocProvider.of<BleBloc>(context);
    bleBloc.add(Listening());

    return BlocProvider(
        create: (_) =>
            WeatherBloc(bleBloc.getServiceByGuid(_WEATHER_SERVICE_GUID))
              ..add(ListenToUpdates()),
        child:
            BlocBuilder<WeatherBloc, WeatherState>(builder: (context, state) {
          return Scaffold(
              body: Stack(
            children: [
              BackgroundImage('bg_home'),
              setSettingButton(),
              setContent(state),
              setActions(context),
            ],
          ));
        }));
  }

  Widget setSettingButton() {
    return Container(
        alignment: Alignment.topRight,
        margin: const EdgeInsets.only(top: 20.0),
        padding: const EdgeInsets.all(10.0),
        child: IconButton(
          icon: Icon(MdiIcons.accountCog),
          iconSize: 32.0,
          color: Colors.white,
          tooltip: 'Settings',
          alignment: Alignment.topCenter,
          onPressed: () => _navigateToSettingsPage(),
        ));
  }

  void _navigateToSettingsPage() async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SettingsPage()));
  }

  Widget setContent(WeatherState state) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    if (state is WeatherUpdated) {
      return Container(
          alignment: Alignment.topCenter,
          padding: EdgeInsets.only(
              left: 40.0, right: 40.0, top: statusBarHeight + 120.0),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(state.weather.temperature,
                    style: TextStyle(
                        fontWeight: FontWeight.w200,
                        fontSize: 160.0,
                        color: Colors.white)),
                Flexible(
                    child: Container(
                  padding: EdgeInsets.only(top: 30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('°C',
                          style:
                              TextStyle(fontSize: 20.0, color: Colors.white)),
                      Text(state.city.name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 24.0,
                              color: Colors.white)),
                      Container(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Icon(
                            state.weather.icon,
                            size: 42.0,
                            color: Colors.white,
                            semanticLabel: 'Weather',
                          )),
                    ],
                  ),
                ))
              ]));
    }

    return Container(alignment: Alignment.topCenter, child: AppNameWidget());
  }

  Container setActions(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.only(left: 40.0, right: 40.0, bottom: 20.0),
      child: Card(
          color: Colors.transparent,
          elevation: 0.5,
          child: Container(
            padding: EdgeInsets.only(top: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ButtonWidget(
                    label: 'Change city',
                    iconData: MdiIcons.earth,
                    action: () => _navigateToCityPage()),
                ButtonWidget(
                    label: 'Change colors',
                    iconData: MdiIcons.palette,
                    action: () => _navigateToColorPickerPage(context)),
              ],
            ),
          )),
    );
  }

  void _navigateToCityPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => CitiesPage()));
  }

  void _navigateToColorPickerPage(BuildContext context) async {
    var weatherBloc = BlocProvider.of<WeatherBloc>(context);

    await Navigator.push(
            context, MaterialPageRoute(builder: (context) => ColorsPage()))
        .then((value) => weatherBloc.add(RestartUpdates()));
  }
}
