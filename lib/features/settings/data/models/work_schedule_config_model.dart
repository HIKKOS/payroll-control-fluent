import '../../domain/entities/work_schedule_config.dart';

/// Modelo de Settings para persistencia.
/// Convierte Duration a minutos (int) para almacenar en SQLite via Drift.
class WorkScheduleConfigModel {
  final int weekStartDay;
  final int weekEndDay;
  final int workStartMinutes;   // minutos desde medianoche
  final int workEndMinutes;
  final int lunchDurationMinutes;
  final int graceMinutes;
  final int exitGraceMinutes;
  final bool bonusEnabled;

  const WorkScheduleConfigModel({
    required this.weekStartDay,
    required this.weekEndDay,
    required this.workStartMinutes,
    required this.workEndMinutes,
    required this.lunchDurationMinutes,
    required this.graceMinutes,
    required this.exitGraceMinutes,
    required this.bonusEnabled,
  });

  factory WorkScheduleConfigModel.fromEntity(WorkScheduleConfig e) =>
      WorkScheduleConfigModel(
        weekStartDay: e.weekStartDay,
        weekEndDay: e.weekEndDay,
        workStartMinutes: e.workStartTime.inMinutes,
        workEndMinutes: e.workEndTime.inMinutes,
        lunchDurationMinutes: e.lunchDuration.inMinutes,
        graceMinutes: e.graceMinutes,
        exitGraceMinutes: e.exitGraceMinutes,
        bonusEnabled: e.bonusEnabled,
      );

  WorkScheduleConfig toEntity() => WorkScheduleConfig(
        weekStartDay: weekStartDay,
        weekEndDay: weekEndDay,
        workStartTime: Duration(minutes: workStartMinutes),
        workEndTime: Duration(minutes: workEndMinutes),
        lunchDuration: Duration(minutes: lunchDurationMinutes),
        graceMinutes: graceMinutes,
        exitGraceMinutes: exitGraceMinutes,
        bonusEnabled: bonusEnabled,
      );

  factory WorkScheduleConfigModel.fromJson(Map<String, dynamic> json) =>
      WorkScheduleConfigModel(
        weekStartDay: json['week_start_day'] as int,
        weekEndDay: json['week_end_day'] as int,
        workStartMinutes: json['work_start_minutes'] as int,
        workEndMinutes: json['work_end_minutes'] as int,
        lunchDurationMinutes: json['lunch_duration_minutes'] as int,
        graceMinutes: json['grace_minutes'] as int,
        exitGraceMinutes: json['exit_grace_minutes'] as int,
        bonusEnabled: (json['bonus_enabled'] as int) == 1,
      );

  Map<String, dynamic> toJson() => {
        'week_start_day': weekStartDay,
        'week_end_day': weekEndDay,
        'work_start_minutes': workStartMinutes,
        'work_end_minutes': workEndMinutes,
        'lunch_duration_minutes': lunchDurationMinutes,
        'grace_minutes': graceMinutes,
        'exit_grace_minutes': exitGraceMinutes,
        'bonus_enabled': bonusEnabled ? 1 : 0,
      };
}
