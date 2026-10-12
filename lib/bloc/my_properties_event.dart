import 'package:equatable/equatable.dart';

abstract class MyPropertiesEvent extends Equatable {
  const MyPropertiesEvent();

  @override
  List<Object?> get props => [];
}

class LoadMyPropertiesEvent extends MyPropertiesEvent {}
