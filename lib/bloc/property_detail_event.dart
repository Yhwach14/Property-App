import 'package:equatable/equatable.dart';

abstract class PropertyDetailEvent extends Equatable {
  const PropertyDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadPropertyDetailEvent extends PropertyDetailEvent {
  final String propertyId;
  const LoadPropertyDetailEvent(this.propertyId);

  @override
  List<Object?> get props => [propertyId];
}
