import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'bluetooth_event.dart';
import 'bluetooth_state.dart';

class BleBloc extends Bloc<BleEvent, BleState> {
  BleBloc() : super(BleInitial());

  final String _nameLighthouseStation = 'LighthouseStationBLE';
  final DeviceIdentifier _addressLighthouseStation = DeviceIdentifier('B8:27:EB:C7:6F:51');

  final FlutterBlue _flutterBlue = FlutterBlue.instance;
  BluetoothDevice _bleDevice;
  StreamSubscription<BluetoothState> _streamBleState;
  StreamSubscription<BluetoothDeviceState> _streamBleDevice;
  StreamSubscription<List<ScanResult>> _streamBleScan;
  List<BluetoothService> bleServices;

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

    if (event is Scanning) {
      yield* _mapScanning();
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

    var bleEnabled = await _flutterBlue.isOn;
    if (bleEnabled) {
      yield BleEnabled();
    } else {
      yield BleDisabled();
    }

    _streamBleState = _flutterBlue.state.listen((state) {
      if (state == BluetoothState.on) {
        add(Enabled());
      } else {
        add(Disabled());
      }
    });
  }

  Stream<BleState> _mapScanning() async* {
    yield BleScanning();
    _flutterBlue.startScan();

    _streamBleScan = _flutterBlue.scanResults.listen((results) {
      for (ScanResult result in results) {
        print('${result.device.name} found! id: ${result.device.id}');
        if (result.device.name == _nameLighthouseStation && result.device.id == _addressLighthouseStation) {
          connect(result.device);
        }
      }
    });
  }

  void connect(BluetoothDevice device) async {
    print('Try connecting');
    _streamBleScan.cancel();
    _bleDevice = device;

    await _bleDevice.connect().then((value) => {
      discoverServices()
    }).catchError((error) {
      print('Cannot connect: $error');
      add(Failure());
    });
  }

  void discoverServices() async {
    bleServices = await _bleDevice.discoverServices();
    add(Connected());
  }

  void listenConnectionState() {
    _streamBleDevice = _bleDevice.state.listen((state) {
      if (state == BluetoothDeviceState.connecting) {
        add(Scanning());
      } else if (state == BluetoothDeviceState.disconnecting || state == BluetoothDeviceState.disconnected) {
        add(Failure());
      }
    });
  }

  BluetoothService getServiceByGuid(Guid guid) {
    return bleServices.firstWhere((service) => service.uuid == guid, orElse: null);
  }

  @override
  Future<void> close() {
    _streamBleScan?.cancel();
    _streamBleDevice?.cancel();
    _streamBleState?.cancel();
    return super.close();
  }
}
