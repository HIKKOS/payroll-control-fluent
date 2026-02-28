import '../../domain/entities/device_user.dart';

/// Modelo de la capa de datos.
/// Sabe cómo convertirse desde/hacia el JSON que devuelve el ControlID
/// y cómo mapearse a la entidad de dominio [DeviceUser].
///
/// El ControlID responde algo como:
/// ```json
/// {
///   "user": [
///     { "id": 1, "name": "Juan Pérez", "registration": "EMP001" }
///   ]
/// }
/// ```
class UserModel extends DeviceUser {
  const UserModel({
    required super.id,
    required super.name,
    required super.registration,
  });

  // ── JSON ──────────────────────────────────────────────────────────────────

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      // El ControlID puede devolver el nombre en distintos campos según
      // la versión del firmware; intentamos los más comunes.
      name: (json['name'] as String?)?.trim() ??
          (json['nome'] as String?)?.trim() ??
          'Sin nombre',
      registration: (json['registration'] as String?)?.trim() ??
          (json['matricula'] as String?)?.trim() ??
          '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'registration': registration,
      };

  // ── Mapeo desde dominio (útil si necesitas serializar entidades) ──────────

  factory UserModel.fromEntity(DeviceUser entity) => UserModel(
        id: entity.id,
        name: entity.name,
        registration: entity.registration,
      );
}
