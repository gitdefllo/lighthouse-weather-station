import 'package:equatable/equatable.dart';

import 'package:lighthouse_weather/models/city.dart';
import 'package:lighthouse_weather/models/weather.dart';

abstract class WeatherEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class ListenToUpdates extends WeatherEvent {}

class RestartUpdates extends WeatherEvent {}

class WeatherReceived extends WeatherEvent {
  final Weather weather;
  final City city;

  WeatherReceived(this.weather, this.city);

  @override
  List<Object> get props => [this.weather, this.city];
}