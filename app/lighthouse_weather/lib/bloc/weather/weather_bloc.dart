import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';

import 'package:lighthouse_weather/bloc/weather/weather_event.dart';
import 'package:lighthouse_weather/bloc/weather/weather_state.dart';

import 'package:lighthouse_weather/data/cities_data.dart';
import 'package:lighthouse_weather/data/cmd_types_data.dart';

import 'package:lighthouse_weather/models/weather.dart';
import 'package:lighthouse_weather/models/city.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final StreamSink<Uint8List> _streamSender;
  final Stream<Uint8List> _streamReceiver;
  StreamSubscription<Uint8List> _streamDataReceiver;

  WeatherBloc(StreamSink<Uint8List> streamSender, Stream<Uint8List> streamReceiver)
      : assert(streamSender != null), assert(streamReceiver != null),
        _streamSender = streamSender,
        _streamReceiver = streamReceiver,
        super(WeatherInitial());

  @override
  Stream<WeatherState> mapEventToState(WeatherEvent event) async* {
    if (event is ListenToUpdates) {
      yield* _mapListenToUpdates();
    }

    if (event is RestartUpdates) {
      restartUpdates();
    }

    if (event is WeatherReceived) {
      yield* _mapWeatherReceived(event);
    }
  }

  Stream<WeatherState> _mapListenToUpdates() async* {
    yield WeatherInitial();

    _streamDataReceiver = _streamReceiver.listen((data) {
      var dataDecoded = utf8.decode(data);
      print('W: Data decoded : $dataDecoded');
      if (dataDecoded.startsWith('IP=')) {
        return;
      }

      var dataReceived = dataDecoded.split(',');
      print('W: Data received: $dataReceived');

      var dataTemp = dataReceived[0];
      var temperature = dataTemp.substring(2);
      var dataWeather = dataReceived[1];
      var weatherId = dataWeather.substring(2);
      var weather = Weather(temperature, int.parse(weatherId));

      var dataCity = dataReceived[2];
      var cityId = dataCity.substring(2);
      var city = City(int.parse(cityId));

      var citiesData = CitiesData();
      citiesData.cities.forEach((element) {
        if (element.containsValue(city.id)) {
          city.name = element['name'];
          city.icon = element['icon'];
        }
      });

      add(WeatherReceived(weather, city));
    });
  }

  void restartUpdates() {
    try {
      var cmd = 'CMD=${CmdTypes.UPDATE.value}';
      print('Command added: $cmd');
      _streamSender.add(utf8.encode(cmd));
    } catch (e) {
      print('Restart updating failed: $e');
    }
  }

  Stream<WeatherState> _mapWeatherReceived(WeatherReceived event) async* {
    yield WeatherUpdated(event.weather, event.city);
  }

  @override
  Future<void> close() {
    _streamDataReceiver?.cancel();
    return super.close();
  }
}
