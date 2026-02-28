import '../../domain/entities/access_log.dart';

/// El ControlID devuelve access_logs con esta estructura aproximada:
/// ```json
/// {
///   "access_log": [
///     {
///       "id": 1,
///       "user_id": 42,
///       "time": 1709481600,   ← Unix timestamp en segundos
///       "event": 7            ← tipo de evento (7 = acceso permitido)
///     }
///   ]
/// }
/// ```
class AccessLogModel extends AccessLog{


  const AccessLogModel({
    required super.id,
    required super.userId,
    required super.timestamp,
  });

  factory AccessLogModel.fromJson(Map<String, dynamic> json) {
    // El ControlID puede usar 'time' (unix) o 'date_time' (string ISO)
    DateTime ts;
    if (json['time'] != null) {
      ts = DateTime.fromMillisecondsSinceEpoch(
        (json['time'] as int) * 1000,
        isUtc: false,
      );
    } else if (json['date_time'] != null) {
      ts = DateTime.parse(json['date_time'] as String);
    } else {
      ts = DateTime.now();
    }

    return AccessLogModel(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ??
          json['userId'] as int? ??
          0,
      timestamp: ts,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'time': timestamp.millisecondsSinceEpoch ~/ 1000,
  };



  factory AccessLogModel.fromEntity(AccessLog e) => AccessLogModel(
    id: e.id,
    userId: e.userId,
    timestamp: e.timestamp,
  );
}