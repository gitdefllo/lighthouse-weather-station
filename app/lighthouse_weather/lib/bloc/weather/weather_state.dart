import 'package:equatable/equatable.dart';

import 'package:lighthouse_weather/models/city.dart';
import 'package:lighthouse_weather/models/weather.dart';

abstract class WeatherState extends Equatable {
  @override
  List<Object> get props => [];
}

class WeatherInitial extends WeatherState {}

class WeatherUpdated extends WeatherState {
  final Weather weather;
  final City city;

  WeatherUpdated(this.weather, this.city);

  @override
  List<Object> get props => [this.weather, this.city];
}
