import 'package:equatable/equatable.dart';

abstract class PropertiesEvent extends Equatable {
  const PropertiesEvent();

  @override
  List<Object?> get props => [];
}

class LoadPropertiesEvent extends PropertiesEvent {}
