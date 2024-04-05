// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'image.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Image _$ImageFromJson(Map<String, dynamic> json) {
  return _Image.fromJson(json);
}

/// @nodoc
mixin _$Image {
  int get width => throw _privateConstructorUsedError;
  int get height => throw _privateConstructorUsedError;
  Point get topLeft => throw _privateConstructorUsedError;
  Point get bottomRight => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ImageCopyWith<Image> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ImageCopyWith<$Res> {
  factory $ImageCopyWith(Image value, $Res Function(Image) then) =
      _$ImageCopyWithImpl<$Res, Image>;
  @useResult
  $Res call(
      {int width, int height, Point topLeft, Point bottomRight, String url});

  $PointCopyWith<$Res> get topLeft;
  $PointCopyWith<$Res> get bottomRight;
}

/// @nodoc
class _$ImageCopyWithImpl<$Res, $Val extends Image>
    implements $ImageCopyWith<$Res> {
  _$ImageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? width = null,
    Object? height = null,
    Object? topLeft = null,
    Object? bottomRight = null,
    Object? url = null,
  }) {
    return _then(_value.copyWith(
      width: null == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as int,
      height: null == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int,
      topLeft: null == topLeft
          ? _value.topLeft
          : topLeft // ignore: cast_nullable_to_non_nullable
              as Point,
      bottomRight: null == bottomRight
          ? _value.bottomRight
          : bottomRight // ignore: cast_nullable_to_non_nullable
              as Point,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $PointCopyWith<$Res> get topLeft {
    return $PointCopyWith<$Res>(_value.topLeft, (value) {
      return _then(_value.copyWith(topLeft: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $PointCopyWith<$Res> get bottomRight {
    return $PointCopyWith<$Res>(_value.bottomRight, (value) {
      return _then(_value.copyWith(bottomRight: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ImageImplCopyWith<$Res> implements $ImageCopyWith<$Res> {
  factory _$$ImageImplCopyWith(
          _$ImageImpl value, $Res Function(_$ImageImpl) then) =
      __$$ImageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int width, int height, Point topLeft, Point bottomRight, String url});

  @override
  $PointCopyWith<$Res> get topLeft;
  @override
  $PointCopyWith<$Res> get bottomRight;
}

/// @nodoc
class __$$ImageImplCopyWithImpl<$Res>
    extends _$ImageCopyWithImpl<$Res, _$ImageImpl>
    implements _$$ImageImplCopyWith<$Res> {
  __$$ImageImplCopyWithImpl(
      _$ImageImpl _value, $Res Function(_$ImageImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? width = null,
    Object? height = null,
    Object? topLeft = null,
    Object? bottomRight = null,
    Object? url = null,
  }) {
    return _then(_$ImageImpl(
      width: null == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as int,
      height: null == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int,
      topLeft: null == topLeft
          ? _value.topLeft
          : topLeft // ignore: cast_nullable_to_non_nullable
              as Point,
      bottomRight: null == bottomRight
          ? _value.bottomRight
          : bottomRight // ignore: cast_nullable_to_non_nullable
              as Point,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ImageImpl implements _Image {
  const _$ImageImpl(
      {required this.width,
      required this.height,
      required this.topLeft,
      required this.bottomRight,
      required this.url});

  factory _$ImageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ImageImplFromJson(json);

  @override
  final int width;
  @override
  final int height;
  @override
  final Point topLeft;
  @override
  final Point bottomRight;
  @override
  final String url;

  @override
  String toString() {
    return 'Image(width: $width, height: $height, topLeft: $topLeft, bottomRight: $bottomRight, url: $url)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ImageImpl &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.topLeft, topLeft) || other.topLeft == topLeft) &&
            (identical(other.bottomRight, bottomRight) ||
                other.bottomRight == bottomRight) &&
            (identical(other.url, url) || other.url == url));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, width, height, topLeft, bottomRight, url);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ImageImplCopyWith<_$ImageImpl> get copyWith =>
      __$$ImageImplCopyWithImpl<_$ImageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ImageImplToJson(
      this,
    );
  }
}

abstract class _Image implements Image {
  const factory _Image(
      {required final int width,
      required final int height,
      required final Point topLeft,
      required final Point bottomRight,
      required final String url}) = _$ImageImpl;

  factory _Image.fromJson(Map<String, dynamic> json) = _$ImageImpl.fromJson;

  @override
  int get width;
  @override
  int get height;
  @override
  Point get topLeft;
  @override
  Point get bottomRight;
  @override
  String get url;
  @override
  @JsonKey(ignore: true)
  _$$ImageImplCopyWith<_$ImageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
