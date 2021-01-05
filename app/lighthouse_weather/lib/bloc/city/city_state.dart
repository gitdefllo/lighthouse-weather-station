import 'package:equatable/equatable.dart';

abstract class CityState extends Equatable {
  @override
  List<Object> get props => [];
}

class CityInitial extends CityState {}

class CityUpdated extends CityState {}

class CityUpdatingFailed extends CityState {}
