import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ml_image_store/model/folder/folder.dart';
import 'package:ml_image_store/model/image/image.dart';
import 'package:ml_image_store/model/paging/paging_params.dart';
import 'package:ml_image_store_app/data/repository/folders_repository.dart';
import 'package:ml_image_store_app/data/repository/images_repository.dart';
import 'package:ml_image_store_app/presentation/util/error_util.dart';
import 'package:ml_image_store_app/presentation/util/subscription_bloc.dart';

part 'folder_bloc.freezed.dart';

class FolderBloc extends Bloc<FolderEvent, FolderState> with SubscriptionBloc {
  final ImagesRepository _imagesRepository;
  final FoldersRepository _foldersRepository;

  FolderBloc(String folderId, this._imagesRepository, this._foldersRepository)
      : super(FolderState(folderId: folderId)) {
    on<_Started>((event, emit) async {
      _imagesRepository.clearImages(folderId);
      add(const FolderEvent.loadFolderRequested());
      try {
        await _foldersRepository.fetchFolder(state.folderId);
      } catch (e) {
        emit(state.copyWith(error: createErrorMessage(e)));
      }
    });
    on<_RefreshRequested>((event, emit) async {
      _imagesRepository.clearImages(folderId);
      emit(state.copyWith(offset: 0));
      add(const FolderEvent.loadFolderRequested());
    });
    on<_LoadMoreRequested>((event, emit) async {
      if (!state.isLoadingImages) {
        emit(state.copyWith(offset: state.offset + state.limit));
        add(const FolderEvent.loadFolderRequested());
      }
    });
    on<_LoadFolderRequested>((event, emit) async {
      try {
        await _imagesRepository.fetchImages(folderId, PagingParams(limit: state.limit, offset: state.offset));
      } catch (e) {
        emit(state.copyWith(error: createErrorMessage(e)));
      }
    }, transformer: restartable());
    on<_FolderChanged>((event, emit) async {
      emit(state.copyWith(folder: event.folder, isLoadingImages: false));
    });
    on<_ImagesChanged>((event, emit) {
      emit(state.copyWith(images: event.images, isLoadingImages: false));
    });
    on<_DeleteImageRequested>((event, emit) async {
      emit(state.copyWith(isDeletingImage: true));
      try {
        await _imagesRepository.deleteImage(state.folderId, event.id);
      } catch (e) {
        emit(state.copyWith(error: createErrorMessage(e)));
      }
      emit(state.copyWith(isDeletingImage: false, error: null));
    });

    subscribe(_foldersRepository.watchFolder(state.folderId), (event) {
      add(FolderEvent.folderChanged(event));
    });
    subscribe(_imagesRepository.watchImages(state.folderId), (event) {
      add(FolderEvent.imagesChanged(event));
    });
  }
}

@freezed
class FolderState with _$FolderState {
  const FolderState._();

  const factory FolderState({
    required String folderId,
    @Default([]) List<Image> images,
    Folder? folder,
    String? error,
    @Default(true) isLoadingImages,
    @Default(false) isDeletingImage,
    @Default(50) int limit,
    @Default(0) int offset,
  }) = _FolderState;

  bool get isLoading => isLoadingImages || isDeletingImage || folder == null;
}

@freezed
class FolderEvent with _$FolderEvent {
  const factory FolderEvent.started() = _Started;

  const factory FolderEvent.loadFolderRequested() = _LoadFolderRequested;

  const factory FolderEvent.folderChanged(Folder? folder) = _FolderChanged;

  const factory FolderEvent.imagesChanged(List<Image> images) = _ImagesChanged;

  const factory FolderEvent.deleteImageRequested(String id) = _DeleteImageRequested;

  const factory FolderEvent.refreshRequested(String id) = _RefreshRequested;

  const factory FolderEvent.loadMoreRequested() = _LoadMoreRequested;
}
