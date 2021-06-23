import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'package:lighthouse_weather/bloc/city/city_event.dart';
import 'package:lighthouse_weather/bloc/city/city_state.dart';

class CityBloc extends Bloc<CityEvent, CityState> {
  final Guid _CITY_ID_CHARACTERISTIC_GUID = Guid('00000003-8cb1-44ce-9a66-001dca0941a6');
  final BluetoothService _bleService;

  CityBloc(BluetoothService bleService)
      : assert(bleService != null), _bleService = bleService,
        super(CityInitial());

  @override
  Stream<CityState> mapEventToState(CityEvent event) async* {
    if (event is ChangeCity) {
      yield* _mapChangeCity(event);
    }
  }

  Stream<CityState> _mapChangeCity(ChangeCity event) async* {
    final characteristic = _bleService.characteristics.firstWhere(
            (c) => c.uuid == _CITY_ID_CHARACTERISTIC_GUID);
    final data = utf8.encode(event.cityId.toString());
    await characteristic.write(data);
    yield CityUpdated();
  }
}
