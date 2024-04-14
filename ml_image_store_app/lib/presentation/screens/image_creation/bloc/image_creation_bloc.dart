import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ml_image_store/model/image/point.dart';
import 'package:ml_image_store_app/data/repository/folders_repository.dart';
import 'package:ml_image_store_app/data/repository/images_repository.dart';
import 'package:ml_image_store_app/presentation/util/error_util.dart';

part 'image_creation_bloc.freezed.dart';

class ImageCreationBloc extends Bloc<ImageCreationEvent, ImageCreationState> {
  final ImagesRepository _imagesRepository;
  final FoldersRepository _foldersRepository;

  ImageCreationBloc(final String folderId, this._imagesRepository, this._foldersRepository)
      : super(ImageCreationState.pickingImage(folderId: folderId)) {
    on<_Started>((event, emit) {});
    on<_ImagePicked>((event, emit) {
      emit(ImageCreationState.pickingImage(folderId: state.folderId, image: event.image));
    });
    on<_EditingRequested>((event, emit) {
      if (state is! PickingState) return;
      final prevState = state as PickingState;
      if (prevState.image == null) return;
      emit(ImageCreationState.editingImage(folderId: state.folderId, image: prevState.image!));
    });
    on<_LeftTopChanged>((event, emit) {
      if (state is! EditingState) return;
      final prevState = state as EditingState;
      emit(prevState.copyWith(leftTop: event.leftTop));
    });
    on<_RightBottomChanged>((event, emit) {
      if (state is! EditingState) return;
      final prevState = state as EditingState;
      emit(prevState.copyWith(rightBottom: event.rightBottom));
    });
    on<_PointsCleared>((event, emit) {
      if (state is! EditingState) return;
      final prevState = state as EditingState;
      emit(prevState.copyWith(leftTop: null, rightBottom: null));
    });
    on<_BackToPickRequested>((event, emit) {
      if (state is! EditingState) return;
      final prevState = state as EditingState;
      emit(ImageCreationState.pickingImage(folderId: state.folderId, image: prevState.image));
    });
    on<_SendRequested>((event, emit) async {
      if (state is! EditingState) return;
      final prevState = state as EditingState;
      if (prevState.leftTop == null || prevState.rightBottom == null) {
        return;
      }
      emit(prevState.copyWith(sending: true));
      try {
        await _imagesRepository.createImage(
          state.folderId,
          prevState.leftTop!,
          prevState.rightBottom!,
          prevState.image,
        );
        _foldersRepository.fetchFolders();
        emit(ImageCreationState.created(folderId: state.folderId));
      } catch (e) {
        emit(prevState.copyWith(error: createErrorMessage(e), sending: false));
      }
    });
  }
}

@freezed
class ImageCreationState with _$ImageCreationState {
  const factory ImageCreationState.pickingImage({
    required String folderId,
    Uint8List? image,
  }) = PickingState;

  const factory ImageCreationState.editingImage({
    required String folderId,
    required Uint8List image,
    Point? leftTop,
    Point? rightBottom,
    @Default(false) bool sending,
    String? error,
  }) = EditingState;

  const factory ImageCreationState.created({
    required String folderId,
  }) = CreatedState;
}

@freezed
class ImageCreationEvent with _$ImageCreationEvent {
  const factory ImageCreationEvent.started() = _Started;

  const factory ImageCreationEvent.imagePicked(Uint8List? image) = _ImagePicked;

  const factory ImageCreationEvent.editingRequested() = _EditingRequested;

  const factory ImageCreationEvent.leftTopChanged(Point? leftTop) = _LeftTopChanged;

  const factory ImageCreationEvent.rightBottomChanged(Point? rightBottom) = _RightBottomChanged;

  const factory ImageCreationEvent.pointsCleared() = _PointsCleared;

  const factory ImageCreationEvent.backToPickRequested() = _BackToPickRequested;

  const factory ImageCreationEvent.sendRequested() = _SendRequested;
}
