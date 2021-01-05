import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';

import 'package:lighthouse_weather/bloc/settings/settings_event.dart';
import 'package:lighthouse_weather/bloc/settings/settings_state.dart';
import 'package:lighthouse_weather/data/cmd_types_data.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final StreamSink<Uint8List> _streamSender;
  final Stream<Uint8List> _streamReceiver;
  StreamSubscription<Uint8List> _streamDataReceived;

  SettingsBloc(StreamSink<Uint8List> streamSender, Stream<Uint8List> streamReceiver)
      : assert(streamSender != null, streamReceiver != null),
        _streamSender = streamSender,
        _streamReceiver = streamReceiver,
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
    _streamDataReceived = _streamReceiver.listen((data) {
      var dataReceived = utf8.decode(data);
      print('S: Data received: $dataReceived');
      if (!dataReceived.startsWith('IP=')) {
        return;
      }
      var ipAddress = dataReceived.substring(3);

      add(IpAddressUpdated(ipAddress));
    });

    try {
      var cmd = 'CMD=${CmdTypes.IP.value}';
      print('Command added: $cmd');
      _streamSender.add(utf8.encode(cmd));
      yield SettingsInitial();
    } catch (e) {
      print('Get ip address failed: $e');
    }
  }

  Stream<SettingsState> _mapIpAddressUpdated(IpAddressUpdated event) async* {
    yield IpAddressReceived(event.ipAddress);
  }

  Stream<SettingsState> _mapShouldShutdown() async* {
    try {
      var cmd = 'CMD=${CmdTypes.SHUTDOWN.value}';
      print('Command added: $cmd');
      _streamSender.add(utf8.encode(cmd));
      yield SettingsClosed();
    } catch (e) {
      print('Shutdown failed: $e');
    }
  }

  @override
  Future<void> close() {
    _streamDataReceived?.cancel();
    return super.close();
  }
}
