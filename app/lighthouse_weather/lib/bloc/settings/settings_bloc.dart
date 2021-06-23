import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'package:lighthouse_weather/bloc/settings/settings_event.dart';
import 'package:lighthouse_weather/bloc/settings/settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final Guid _IP_ADDRESS_CHARACTERISTIC_GUID = Guid('00000001-61c8-471e-94f3-5050570167b2');
  final Guid _SHUTDOWN_CHARACTERISTIC_GUID = Guid('00000002-61c8-471e-94f3-5050570167b2');
  final BluetoothService _bleService;

  SettingsBloc(BluetoothService bleService)
      : assert(bleService != null), _bleService = bleService,
        super(SettingsInitial());

  @override
  Stream<SettingsState> mapEventToState(SettingsEvent event) async* {
    if (event is ShouldGetIpAddress) {
      yield* _mapShouldGetIpAddress();
    }

    if (event is IpAddressUpdated) {
      yield* _mapIpAddressUpdated(event);
    }

    if (event is ShouldShutdown) {
      yield* _mapShouldShutdown();
    }
  }

  Stream<SettingsState> _mapShouldGetIpAddress() async* {
    final characteristic = _bleService.characteristics.firstWhere(
            (c) => c.uuid == _IP_ADDRESS_CHARACTERISTIC_GUID);
    final value = await characteristic.read();
    final data = utf8.decode(value);
    print('S: Data received: $data');

    add(IpAddressUpdated(data));
  }

  Stream<SettingsState> _mapIpAddressUpdated(IpAddressUpdated event) async* {
    yield IpAddressReceived(event.ipAddress);
  }

  Stream<SettingsState> _mapShouldShutdown() async* {
    final characteristic = _bleService.characteristics.firstWhere(
            (c) => c.uuid == _SHUTDOWN_CHARACTERISTIC_GUID);
    await characteristic.write([]);
  }
}
