import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ml_image_store/model/folder/folder.dart';

part 'home_bloc.freezed.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeState()) {
    on<_Started>((event, emit) {
      add(const HomeEvent.loadFoldersRequested());
    });
    on<_LoadFoldersRequested>((event, emit) {}, transformer: restartable());
  }
}

@freezed
class HomeState with _$HomeState {
  const factory HomeState({
    @Default([]) List<Folder> folders,
    @Default(true) bool isLoading,
  }) = _HomeState;
}

@freezed
class HomeEvent with _$HomeEvent {
  const factory HomeEvent.started() = _Started;

  const factory HomeEvent.loadFoldersRequested() = _LoadFoldersRequested;
}
