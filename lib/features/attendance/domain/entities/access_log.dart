import 'package:equatable/equatable.dart';

/// Un registro de acceso crudo tal como llega del ControlID.
/// Solo contiene el timestamp y el ID del usuario — sin lógica de negocio.
class AccessLog extends Equatable {
  final int id;
  final int userId;
  final DateTime timestamp;

  const AccessLog({
    required this.id,
    required this.userId,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, userId, timestamp];

  @override
  String toString() =>
      'AccessLog(userId: $userId, time: $timestamp)';
}