import 'package:equatable/equatable.dart';

abstract class BleState extends Equatable {
  @override
  List<Object> get props => [];
}

class BleInitial extends BleState {}

class BleEnabled extends BleState {}

class BleDisabled extends BleState {}

class BleScanning extends BleState {}

class BleConnected extends BleState {}

class BleFailure extends BleState {}