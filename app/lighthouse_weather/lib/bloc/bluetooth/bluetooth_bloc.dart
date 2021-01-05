import 'dart:async';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'bluetooth_event.dart';
import 'bluetooth_state.dart';

class BleBloc extends Bloc<BleEvent, BleState> {
  BleBloc() : super(BleInitial());

  final String _nameLighthouseStation = 'LighthouseWeatherStation';
  final String _addressLighthouseStation = 'XX:XX:XX:XX:XX:XX';
  final FlutterBluetoothSerial _bluetoothSerial =
      FlutterBluetoothSerial.instance;
  BluetoothConnection connection;
  Stream<Uint8List> _streamReceiver;
  StreamSubscription<Uint8List> _streamDataReceiver;
  StreamSubscription<BluetoothDiscoveryResult> _streamDiscovery;

  Stream<Uint8List> get streamReceiver {
    _streamReceiver ??= this.connection.input.asBroadcastStream();
    return _streamReceiver;
  }

  @override
  Stream<BleState> mapEventToState(BleEvent event) async* {
    if (event is Init) {
      yield* _mapInit();
    }

    if (event is Enabled) {
      yield BleEnabled();
    }

    if (event is Disabled) {
      yield BleDisabled();
    }

    if (event is Connecting) {
      yield* _mapConnecting();
    }

    if (event is Connected) {
      yield BleConnected();
    }

    if (event is Listening) {
      listenConnectionState();
    }

    if (event is Failure) {
      yield BleFailure();
    }
  }

  Stream<BleState> _mapInit() async* {
    yield BleInitial();
    await Future.delayed(const Duration(seconds: 4));

    var _state = await _bluetoothSerial.state;
    if (connection != null && connection.isConnected) {
      yield BleConnected();
    } else if (_state == BluetoothState.STATE_OFF) {
      yield BleDisabled();
    } else {
      yield BleEnabled();
    }
  }

  Stream<BleState> _mapConnecting() async* {
    yield BleConnecting();
    _streamDiscovery = _bluetoothSerial.startDiscovery().listen((result) {
      print('Found device: ${result.device.address}');
      if (result.device.name == _nameLighthouseStation &&
          result.device.address == _addressLighthouseStation) {
        print('Lighthouse Weather Station found.');
        connect(result.device);
      }
    })
      ..onError((error) {
        print('Stream discovery error.');
        add(Failure());
      });
  }

  void connect(BluetoothDevice result) async {
    print('Try connecting');
    BluetoothConnection.toAddress(result.address).then((conn) {
      print('Connected to the device');
      connection = conn;
      add(Connected());
    }).catchError((error) {
      print('Cannot connect: $error');
      add(Failure());
    });
  }

  void listenConnectionState() {
    _streamDataReceiver = _streamReceiver.listen((data) {})
      ..onDone(() {
        if (!connection.isConnected) {
          add(Failure());
        }
      })
      ..onError((error) {
        add(Failure());
      });
  }

  @override
  Future<void> close() {
    _streamDiscovery?.cancel();
    _streamDataReceiver?.cancel();
    return super.close();
  }
}
