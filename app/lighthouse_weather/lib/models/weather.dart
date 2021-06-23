import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class Weather {
  final String temperature;
  final int weatherId;
  IconData icon;

  Weather(this.temperature, this.weatherId, {this.icon}) {
    if (icon == null) {
      icon = getIconWeatherWithId(weatherId);
    }
  }

  IconData getIconWeatherWithId(int weatherId) {
    if (weatherId >= 200 && weatherId <= 232) {
      return MdiIcons.weatherLightningRainy;
    } else if (weatherId >= 300 && weatherId <= 321) {
      return MdiIcons.weatherPartlyRainy;
    } else if (weatherId >= 500 && weatherId <= 531) {
      return MdiIcons.weatherPouring;
    } else if (weatherId >= 600 && weatherId <= 622) {
      return MdiIcons.weatherSnowyHeavy;
    } else if (weatherId >= 701 && weatherId <= 781) {
      return MdiIcons.weatherFog;
    } else if (weatherId >= 801 && weatherId <= 804) {
      return MdiIcons.weatherCloudy;
    } else {
      return MdiIcons.weatherSunny;
    }
  }
}