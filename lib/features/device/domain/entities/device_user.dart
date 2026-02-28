import 'package:equatable/equatable.dart';

/// Entidad de dominio pura — no sabe nada de JSON ni de Drift.
/// Representa un usuario registrado en el dispositivo de control de acceso.
class DeviceUser extends Equatable {
  final int id;

  /// Nombre completo tal como está registrado en el dispositivo.
  final String name;

  /// Número de registro / número de nómina del empleado.
  final String registration;

  const DeviceUser({
    required this.id,
    required this.name,
    required this.registration,
  });

  @override
  List<Object?> get props => [id, name, registration];

  @override
  String toString() => 'DeviceUser(id: $id, name: $name, registration: $registration)';
}