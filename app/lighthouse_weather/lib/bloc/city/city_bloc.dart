import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';

import 'package:lighthouse_weather/bloc/city/city_event.dart';
import 'package:lighthouse_weather/bloc/city/city_state.dart';
import 'package:lighthouse_weather/data/cmd_types_data.dart';

class CityBloc extends Bloc<CityEvent, CityState> {
  final StreamSink<Uint8List> _streamSender;

  CityBloc(StreamSink<Uint8List> streamSender)
      : assert(streamSender != null),
        _streamSender = streamSender,
        super(CityInitial());

  @override
  Stream<CityState> mapEventToState(CityEvent event) async* {
    if (event is ChangeCity) {
      yield* _mapChangeCity(event);
    }
  }

  Stream<CityState> _mapChangeCity(ChangeCity event) async* {
    try {
      var cmd = 'CMD=${CmdTypes.CITY.value},VAL=${event.cityId}';
      print('Command added: $cmd');
      _streamSender.add(utf8.encode(cmd));
      yield CityUpdated();
    } catch (e) {
      print('City updating failed: $e');
      yield CityUpdatingFailed();
    }
  }
}
