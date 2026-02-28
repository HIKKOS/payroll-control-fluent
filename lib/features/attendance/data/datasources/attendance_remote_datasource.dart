import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/access_log_model.dart';

abstract class AttendanceRemoteDatasource {
  Future<List<AccessLogModel>> getAccessLogs({
    required int userId,
    required DateTime from,
    required DateTime to,
  });
}

class ControlIdAttendanceDatasourceImpl implements AttendanceRemoteDatasource {
  final DioClient _client;

  const ControlIdAttendanceDatasourceImpl(this._client);

  @override
  Future<List<AccessLogModel>> getAccessLogs({
    required int userId,
    required DateTime from,
    required DateTime to,
  }) async {
    if (!_client.hasActiveSession) throw const SessionExpiredException();

    try {
      // El ControlID filtra por rango de tiempo usando unix timestamps
      final fromTs = from.millisecondsSinceEpoch ~/ 1000;
      final toTs = to.millisecondsSinceEpoch ~/ 1000;

      final response = await _client.dio.post(
        AppConfig.loadObjectsEndpoint,
        data: {
          'object': AppConfig.accessLogsObject,
          'where': [
            {
              "object": "access_logs",
              "field": "time",
              "operator": ">=",
              "value": (fromTs).floor(),
            },
            {
              "object": "access_logs",
              "field": "time",
              "operator": "<=",
              "value": (toTs).floor(),
            },
            {
              "object": "users",
              "field": "user_id",
              "operator": "=",
              "value": userId,
            },
          ],
          // Ordenamos por tiempo ascendente para facilitar el parseo
          'order_by': [
            {'access_log': 'time'}
          ],
        },
      );

      if (response.statusCode == 401) throw const SessionExpiredException();
      if (response.statusCode != null && response.statusCode! >= 400) {
        throw ServerException('Error ${response.statusCode}',
            statusCode: response.statusCode);
      }

      final body = response.data as Map<String, dynamic>?;
      if (body == null) return [];

      final rawList = body[AppConfig.accessLogsObject];
      if (rawList == null || rawList is! List) return [];

      return rawList
          .whereType<Map<String, dynamic>>()
          .map(AccessLogModel.fromJson)
          .toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkException('Sin conexión al dispositivo.');
      }
      throw NetworkException(e.message ?? 'Error de red.');
    }
  }
}
