import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ml_image_store_app/interactor/auth_interactor.dart';
import 'package:ml_image_store_app/presentation/util/error_util.dart';

part 'login_bloc.freezed.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthInteractor _authInteractor;

  LoginBloc(this._authInteractor) : super(const LoginState()) {
    on<_LoginChanged>((event, emit) {
      emit(state.copyWith(login: event.login));
    });
    on<_PasswordChanged>((event, emit) {
      emit(state.copyWith(password: event.password));
    });
    on<_LoginRequested>((event, emit) async {
      emit(state.copyWith(loading: true));
      try {
        await _authInteractor.login(state.login, state.password);
      } catch (e) {
        emit(state.copyWith(error: createErrorMessage(e)));
      }
      emit(state.copyWith(loading: false, error: null));
    });
    on<_RegisterRequested>((event, emit) async {
      emit(state.copyWith(loading: true));
      try {
        await _authInteractor.login(state.login, state.password);
      } catch (e) {
        emit(state.copyWith(error: createErrorMessage(e)));
      }
      emit(state.copyWith(loading: false, error: null));
    });
  }
}

@freezed
class LoginState with _$LoginState {
  const factory LoginState({
    @Default('') String login,
    @Default('') String password,
    @Default(false) bool loading,
    String? error,
  }) = _LoginState;
}

@freezed
class LoginEvent with _$LoginEvent {
  const factory LoginEvent.loginChanged(String login) = _LoginChanged;

  const factory LoginEvent.passwordChanged(String password) = _PasswordChanged;

  const factory LoginEvent.loginRequested() = _LoginRequested;

  const factory LoginEvent.registerRequested() = _RegisterRequested;
}
