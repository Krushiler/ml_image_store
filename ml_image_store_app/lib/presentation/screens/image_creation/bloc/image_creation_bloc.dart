import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ml_image_store/model/folder/folder.dart';
import 'package:ml_image_store/model/image/feature.dart';
import 'package:ml_image_store_app/data/model/server_config.dart';
import 'package:ml_image_store_app/data/repository/folders_repository.dart';
import 'package:ml_image_store_app/data/repository/images_repository.dart';
import 'package:ml_image_store_app/presentation/util/error_util.dart';
import 'package:ml_image_store_app/presentation/util/image_util.dart';
import 'package:http/http.dart' as http;

part 'image_creation_bloc.freezed.dart';

class ImageCreationBloc extends Bloc<ImageCreationEvent, ImageCreationState> {
  final ImagesRepository _imagesRepository;
  final FoldersRepository _foldersRepository;

  ImageCreationBloc(final String folderId, final String? imageId, final ServerConfig serverConfig,
      this._imagesRepository, this._foldersRepository)
      : super(ImageCreationState.loading(folderId: folderId, imageId: imageId, folder: null)) {
    on<_Started>((event, emit) {});
    on<_ImagePicked>((event, emit) {
      emit(ImageCreationState.pickingImage(
        folderId: state.folderId,
        image: event.image,
        imageId: state.imageId,
        folder: state.folder,
      ));
    });
    on<_EditingRequested>((event, emit) {
      if (state is! PickingState) return;
      final prevState = state as PickingState;
      if (prevState.image == null) return;
      emit(ImageCreationState.editingImage(
        folderId: state.folderId,
        image: prevState.image!,
        imageId: state.imageId,
        folder: state.folder,
      ));
    });
    on<_AddFeature>((event, emit) {
      if (state is! EditingState) return;
      final prevState = state as EditingState;
      emit(prevState.copyWith(features: [...prevState.features, event.feature]));
    });
    on<_RemoveFeature>((event, emit) {
      if (state is! EditingState) return;
      final prevState = state as EditingState;
      emit(prevState.copyWith(features: [...prevState.features.where((element) => element.id != event.featureId)]));
    });
    on<_PointsCleared>((event, emit) {
      if (state is! EditingState) return;
      final prevState = state as EditingState;
      emit(prevState.copyWith(features: const []));
    });
    on<_BackToPickRequested>((event, emit) {
      if (state is! EditingState) return;
      final prevState = state as EditingState;
      emit(ImageCreationState.pickingImage(folderId: state.folderId, image: prevState.image, folder: state.folder));
    });
    on<_SendRequested>((event, emit) async {
      if (state is! EditingState) return;
      final prevState = state as EditingState;
      emit(prevState.copyWith(sending: true));
      try {
        await _imagesRepository.createImage(
          state.folderId,
          prevState.features.toList(),
          prevState.image,
          state.imageId,
        );
        _foldersRepository.fetchFolder(state.folderId);
        emit(ImageCreationState.created(folderId: state.folderId, imageId: state.imageId, folder: state.folder));
      } catch (e) {
        emit(prevState.copyWith(error: createErrorMessage(e), sending: false));
      }
    });
    on<_LoadImageRequested>((event, emit) async {
      try {
        final folder = await _foldersRepository.getFolder(event.folderId);
        if (event.imageId != null) {
          final image = await _imagesRepository.getImage(event.imageId!);
          final file = await http.get(Uri.parse(createImageUrl(serverConfig, image.fileId)));
          final bytes = file.bodyBytes;
          emit(ImageCreationState.editingImage(
            folderId: state.folderId,
            image: bytes,
            imageId: event.imageId,
            features: image.features,
            folder: folder,
          ));
        } else {
          emit(ImageCreationState.pickingImage(folderId: event.folderId, folder: folder));
        }
      } catch (_) {}
    });

    add(_LoadImageRequested(folderId, imageId));
  }
}

@freezed
class ImageCreationState with _$ImageCreationState {
  const factory ImageCreationState.loading({
    required String folderId,
    required Folder? folder,
    String? imageId,
  }) = LoadingState;

  const factory ImageCreationState.pickingImage({
    required String folderId,
    Uint8List? image,
    required Folder? folder,
    String? imageId,
  }) = PickingState;

  const factory ImageCreationState.editingImage({
    required String folderId,
    required Uint8List image,
    @Default([]) List<Feature> features,
    @Default(false) bool sending,
    String? error,
    String? imageId,
    required Folder? folder,
  }) = EditingState;

  const factory ImageCreationState.created({
    required String folderId,
    required Folder? folder,
    String? imageId,
  }) = CreatedState;
}

@freezed
class ImageCreationEvent with _$ImageCreationEvent {
  const factory ImageCreationEvent.started() = _Started;

  const factory ImageCreationEvent.loadImageRequested(final String folderId, String? imageId) = _LoadImageRequested;

  const factory ImageCreationEvent.imagePicked(Uint8List? image) = _ImagePicked;

  const factory ImageCreationEvent.editingRequested() = _EditingRequested;

  const factory ImageCreationEvent.addFeature(Feature feature) = _AddFeature;

  const factory ImageCreationEvent.removeFeature(String featureId) = _RemoveFeature;

  const factory ImageCreationEvent.pointsCleared() = _PointsCleared;

  const factory ImageCreationEvent.backToPickRequested() = _BackToPickRequested;

  const factory ImageCreationEvent.sendRequested() = _SendRequested;
}
