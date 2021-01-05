import 'package:equatable/equatable.dart';

abstract class ColorsEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class ChangeColors extends ColorsEvent {
  final List<int> colors;

  ChangeColors(this.colors);

  @override
  List<Object> get props => [this.colors];
}