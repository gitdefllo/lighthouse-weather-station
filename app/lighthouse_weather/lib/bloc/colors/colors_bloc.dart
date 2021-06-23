import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'package:lighthouse_weather/bloc/colors/colors_event.dart';
import 'package:lighthouse_weather/bloc/colors/colors_state.dart';

class ColorsBloc extends Bloc<ColorsEvent, ColorsState> {
  final Guid _RGB_COLOR_CHARACTERISTIC_GUID = Guid('00000001-8194-4451-aaf5-7874c7c16a27');
  final BluetoothService _bleService;

  ColorsBloc(BluetoothService bleService)
      : assert(bleService != null), _bleService = bleService,
        super(ColorsInitial());

  @override
  Stream<ColorsState> mapEventToState(ColorsEvent event) async* {
    if (event is ChangeColors) {
      yield* _mapChangeColor(event);
    }
  }

  Stream<ColorsState> _mapChangeColor(ChangeColors event) async* {
    final characteristic = _bleService.characteristics.firstWhere(
            (c) => c.uuid == _RGB_COLOR_CHARACTERISTIC_GUID);
    final data = utf8.encode(event.colors.join(','));
    await characteristic.write(data);
    yield ColorsUpdated();
  }
}
