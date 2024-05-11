import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ml_image_store/model/theme/theme_config.dart';
import 'package:ml_image_store_app/data/repository/config_repository.dart';
import 'package:ml_image_store_app/presentation/util/bloc_transformer_util.dart';
import 'package:ml_image_store_app/presentation/util/subscription_bloc.dart';

part 'settings_bloc.freezed.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> with SubscriptionBloc {
  final ConfigRepository _configRepository;

  SettingsBloc(this._configRepository) : super(const SettingsState()) {
    on<_PrimaryColorChanged>((event, emit) {
      emit(state.copyWith(primaryColor: event.color));
      add(const SettingsEvent.saveConfig());
    });
    on<_IsDarkChanged>((event, emit) {
      emit(state.copyWith(isDark: event.isDark));
      add(const SettingsEvent.saveConfig());
    });
    on<_SaveConfig>((event, emit) async {
      await _configRepository.saveConfig(
        primaryColor: state.primaryColor,
        accentColor: state.accentColor,
        isDark: state.isDark,
      );
    }, transformer: debounceSequential(const Duration(milliseconds: 500)));

    on<_ConfigChanged>((event, emit) {
      emit(state.copyWith(
        primaryColor: event.config?.primaryColor,
        accentColor: event.config?.accentColor,
        isDark: event.config?.isDark,
      ));
    });

    subscribe(_configRepository.watchConfig(), (event) {
      add(SettingsEvent.configChanged(event));
    });
  }
}

@freezed
class SettingsEvent with _$SettingsEvent {
  const factory SettingsEvent.primaryColorChanged(String color) = _PrimaryColorChanged;

  const factory SettingsEvent.isDarkChanged(bool isDark) = _IsDarkChanged;

  const factory SettingsEvent.saveConfig() = _SaveConfig;

  const factory SettingsEvent.configChanged(ThemeConfig? config) = _ConfigChanged;
}

@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default(false) bool isLoading,
    bool? isDark,
    String? primaryColor,
    String? accentColor,
  }) = _SettingsState;
}
