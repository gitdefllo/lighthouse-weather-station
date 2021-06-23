import 'package:equatable/equatable.dart';

abstract class BleEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class Init extends BleEvent {}

class Enabled extends BleEvent {}

class Disabled extends BleEvent {}

class Scanning extends BleEvent {}

class Connected extends BleEvent {}

class Listening extends BleEvent {}

class Failure extends BleEvent {}