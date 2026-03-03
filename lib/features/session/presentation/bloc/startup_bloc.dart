import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nomina_control/features/device/domain/entities/device_credentials.dart';
import 'package:nomina_control/features/device/domain/usecases/restore_device_session.dart';
import '../../domain/entities/saved_session.dart';
import '../../domain/usecases/app_startup_usecase.dart';

// ── Eventos ───────────────────────────────────────────────────────────────────
abstract class StartupEvent extends Equatable {
  const StartupEvent();

  @override
  List<Object?> get props => [];
}

class StartupCheckRequested extends StartupEvent {
  const StartupCheckRequested();
}

// ── Estados ───────────────────────────────────────────────────────────────────
abstract class StartupState extends Equatable {
  const StartupState();

  @override
  List<Object?> get props => [];
}

class StartupChecking extends StartupState {
  const StartupChecking();
}

/// Sesión restaurada — ir al shell online.
class StartupDone extends StartupState {
  final SavedSession session;

  const StartupDone(this.session);

  @override
  List<Object?> get props => [session];
}

/// Sin red — ir al shell offline.
class StartupDoneOffline extends StartupState {
  final SavedSession session;

  const StartupDoneOffline(this.session);

  @override
  List<Object?> get props => [session];
}

/// Sin sesión o credenciales inválidas — ir al login.
class StartupLoginRequired extends StartupState {
  const StartupLoginRequired();
}

// ── BLoC ──────────────────────────────────────────────────────────────────────
class StartupBloc extends Bloc<StartupEvent, StartupState> {
  final AppStartupUseCase _useCase;
  final RestoreDeviceSession _restoreSession;

  StartupBloc(
      {required AppStartupUseCase appStartup,
      required RestoreDeviceSession restoreSession})
      : _useCase = appStartup,
        _restoreSession = restoreSession,
        super(const StartupChecking()) {
    on<StartupCheckRequested>(_onCheck);
  }

  Future<void> _onCheck(
      StartupCheckRequested event, Emitter<StartupState> emit) async {
    emit(const StartupChecking());
    final result = await _useCase();
    switch (result) {
      case StartupOnline(:final session):
        await _restoreSession(DeviceCredentials(
            host: session.host,
            port: session.port,
            login: session.login,
            password: session.password));
        emit(StartupDone(session));
      case StartupOffline(:final session):
        emit(StartupDoneOffline(session));
      case StartupNeedsLogin():
        emit(const StartupLoginRequired());
    }
  }
}
