import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ml_image_store/model/image/image.dart';
import 'package:ml_image_store_app/data/repository/images_repository.dart';
import 'package:ml_image_store_app/presentation/util/error_util.dart';

part 'image_bloc.freezed.dart';

class ImageBloc extends Bloc<ImageEvent, ImageState> {
  final String imageId;
  final ImagesRepository _imagesRepository;

  ImageBloc(this.imageId, this._imagesRepository) : super(const ImageState()) {
    on<_Started>((event, emit) async {
      emit(state.copyWith(loading: true, error: null));
      try {
        final image = await _imagesRepository.getImage(imageId);
        emit(state.copyWith(image: image));
      } catch (e) {
        emit(state.copyWith(error: createErrorMessage(e)));
      }
      emit(state.copyWith(loading: false));
    });
  }
}

@freezed
class ImageState with _$ImageState {
  const factory ImageState({
    Image? image,
    String? error,
    bool? loading,
  }) = _ImageState;
}

@freezed
class ImageEvent with _$ImageEvent {
  const factory ImageEvent.started() = _Started;
}
