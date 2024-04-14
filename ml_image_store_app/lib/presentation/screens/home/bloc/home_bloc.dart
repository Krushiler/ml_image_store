import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ml_image_store/model/folder/folder.dart';
import 'package:ml_image_store_app/data/repository/folders_repository.dart';
import 'package:ml_image_store_app/interactor/auth_interactor.dart';
import 'package:ml_image_store_app/presentation/util/error_util.dart';
import 'package:ml_image_store_app/presentation/util/subscription_bloc.dart';

part 'home_bloc.freezed.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> with SubscriptionBloc {
  final AuthInteractor _authInteractor;
  final FoldersRepository _foldersRepository;

  HomeBloc(this._authInteractor, this._foldersRepository) : super(const HomeState()) {
    on<_Started>((event, emit) {
      add(const HomeEvent.loadFoldersRequested());
    });
    on<_LoadFoldersRequested>((event, emit) async {
      try {
        await _foldersRepository.fetchFolders();
      } catch (e) {
        emit(state.copyWith(error: createErrorMessage(e)));
      }
      emit(state.copyWith(error: null));
    }, transformer: restartable());
    on<_LogoutRequested>((event, emit) {
      _authInteractor.logout();
    });
    on<_FoldersChanged>((event, emit) {
      emit(state.copyWith(folders: event.folders, isLoadingFolders: false));
    });
    on<_CreateFolderRequested>((event, emit) async {
      emit(state.copyWith(isCreatingFolder: true));
      try {
        await _foldersRepository.createFolder(event.name);
        add(const HomeEvent.loadFoldersRequested());
      } catch (e) {
        emit(state.copyWith(error: createErrorMessage(e)));
      }
      emit(state.copyWith(isCreatingFolder: false, error: null));
    });
    on<_DeleteFolderRequested>((event, emit) async {
      emit(state.copyWith(isCreatingFolder: true));
      try {
        await _foldersRepository.deleteFolder(event.id);
        add(const HomeEvent.loadFoldersRequested());
      } catch (e) {
        emit(state.copyWith(error: createErrorMessage(e)));
      }
      emit(state.copyWith(isCreatingFolder: false, error: null));
    });

    subscribe(_foldersRepository.watchFolders(), (event) {
      add(HomeEvent.foldersChanged(event ?? const []));
    });
  }
}

@freezed
class HomeState with _$HomeState {
  const HomeState._();

  const factory HomeState({
    @Default([]) List<Folder> folders,
    @Default(true) bool isLoadingFolders,
    @Default(false) bool isCreatingFolder,
    String? error,
  }) = _HomeState;

  bool get isLoading => isLoadingFolders || isCreatingFolder;
}

@freezed
class HomeEvent with _$HomeEvent {
  const factory HomeEvent.started() = _Started;

  const factory HomeEvent.loadFoldersRequested() = _LoadFoldersRequested;

  const factory HomeEvent.logoutRequested() = _LogoutRequested;

  const factory HomeEvent.foldersChanged(List<Folder> folders) = _FoldersChanged;

  const factory HomeEvent.createFolderRequested(String name) = _CreateFolderRequested;

  const factory HomeEvent.deleteFolderRequested(String id) = _DeleteFolderRequested;
}
