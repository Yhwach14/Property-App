import 'package:equatable/equatable.dart';
import '../models/property.dart';

enum PropertyDetailStatus { loading, success, failure }

class PropertyDetailState extends Equatable {
  final PropertyDetailStatus status;
  final PropertyDetail? property;
  final String? errorMessage;

  const PropertyDetailState({
    this.status = PropertyDetailStatus.loading,
    this.property,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, property, errorMessage];
}
