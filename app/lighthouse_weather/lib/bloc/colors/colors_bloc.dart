import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';

import 'package:lighthouse_weather/bloc/colors/colors_event.dart';
import 'package:lighthouse_weather/bloc/colors/colors_state.dart';
import 'package:lighthouse_weather/data/cmd_types_data.dart';

class ColorsBloc extends Bloc<ColorsEvent, ColorsState> {
  final StreamSink<Uint8List> _streamSender;

  ColorsBloc(StreamSink<Uint8List> streamSender)
      : assert(streamSender != null),
        _streamSender = streamSender,
        super(ColorsInitial());

  @override
  Stream<ColorsState> mapEventToState(ColorsEvent event) async* {
    if (event is ChangeColors) {
      yield* _mapChangeColor(event);
    }
  }

  Stream<ColorsState> _mapChangeColor(ChangeColors event) async* {
    try {
      var cmd = 'CMD=${CmdTypes.COLOR.value},VAL=${event.colors.join(',')}';
      print('Command added: $cmd');
      _streamSender.add(utf8.encode(cmd));
      yield ColorsUpdated();
    } catch (e) {
      print('Color updating failed: $e');
      yield ColorsUpdatingFailed();
    }
  }
}
