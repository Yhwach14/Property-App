import 'package:equatable/equatable.dart';
import '../models/property.dart';

enum MyPropertiesStatus { initial, loading, success, failure }

class MyPropertiesState extends Equatable {
  final MyPropertiesStatus status;
  final List<Property> properties;
  final String? errorMessage;

  const MyPropertiesState({
    this.status = MyPropertiesStatus.initial,
    this.properties = const [],
    this.errorMessage,
  });

  MyPropertiesState copyWith({
    MyPropertiesStatus? status,
    List<Property>? properties,
    String? errorMessage,
  }) {
    return MyPropertiesState(
      status: status ?? this.status,
      properties: properties ?? this.properties,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, properties, errorMessage];
}
