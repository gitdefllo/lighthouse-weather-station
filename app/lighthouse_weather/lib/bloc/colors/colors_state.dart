import 'package:equatable/equatable.dart';

abstract class ColorsState extends Equatable {
  @override
  List<Object> get props => [];
}

class ColorsInitial extends ColorsState {}

class ColorsUpdated extends ColorsState {}

class ColorsUpdatingFailed extends ColorsState {}
