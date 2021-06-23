import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'package:lighthouse_weather/bloc/weather/weather_event.dart';
import 'package:lighthouse_weather/bloc/weather/weather_state.dart';

import 'package:lighthouse_weather/data/cities_data.dart';

import 'package:lighthouse_weather/models/weather.dart';
import 'package:lighthouse_weather/models/city.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final Guid _WEATHER_CHARACTERISTIC_GUID = Guid('00000001-8cb1-44ce-9a66-001dca0941a6');
  final Guid _RESUME_WEATHER_CHARACTERISTIC_GUID = Guid('00000002-8cb1-44ce-9a66-001dca0941a6');
  final BluetoothService _bleService;
  StreamSubscription<List<int>> _streamBleWeatherCharacteristic;

  WeatherBloc(BluetoothService bleService)
      : assert(bleService != null), _bleService = bleService,
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

    final characteristic = _bleService.characteristics.firstWhere(
            (c) => c.uuid == _WEATHER_CHARACTERISTIC_GUID);
    await characteristic.setNotifyValue(true);

    _streamBleWeatherCharacteristic = characteristic.value.listen((value) {
      print('W: value received : $value');
      if (value == null || value.isEmpty) {
        print('W: value is empty');
        return;
      }

      var data = utf8.decode(value);
      print('W: Data decoded : $data');

      var dataReceived = data.split(',');
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

  void restartUpdates() async {
    final characteristic = _bleService.characteristics.firstWhere(
            (c) => c.uuid == _RESUME_WEATHER_CHARACTERISTIC_GUID);
    await characteristic.write([]);
  }

  Stream<WeatherState> _mapWeatherReceived(WeatherReceived event) async* {
    yield WeatherUpdated(event.weather, event.city);
  }

  @override
  Future<void> close() {
    _streamBleWeatherCharacteristic?.cancel();
    return super.close();
  }
}
