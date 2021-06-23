import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class ShouldGetIpAddress extends SettingsEvent {}

class IpAddressUpdated extends SettingsEvent {
  final String ipAddress;

  IpAddressUpdated(this.ipAddress);

  @override
  List<Object> get props => [this.ipAddress];
}

class ShouldShutdown extends SettingsEvent {}