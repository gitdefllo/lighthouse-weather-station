import 'package:equatable/equatable.dart';

abstract class SettingsState extends Equatable {
  @override
  List<Object> get props => [];
}

class SettingsInitial extends SettingsState {}

class IpAddressReceived extends SettingsState {
  final String ipAddress;

  IpAddressReceived(this.ipAddress);

  @override
  List<Object> get props => [this.ipAddress];
}

class SettingsClosed extends SettingsState {}
