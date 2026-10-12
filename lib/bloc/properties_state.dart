import 'package:equatable/equatable.dart';
import '../models/property.dart';

enum PropertiesStatus { initial, loading, success, failure }

class PropertiesState extends Equatable {
  final PropertiesStatus status;
  final List<Property> properties;
  final String? errorMessage;

  const PropertiesState({
    this.status = PropertiesStatus.initial,
    this.properties = const [],
    this.errorMessage,
  });

  PropertiesState copyWith({
    PropertiesStatus? status,
    List<Property>? properties,
    String? errorMessage,
  }) {
    return PropertiesState(
      status: status ?? this.status,
      properties: properties ?? this.properties,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, properties, errorMessage];
}
