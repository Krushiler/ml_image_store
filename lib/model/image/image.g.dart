// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ImageImpl _$$ImageImplFromJson(Map<String, dynamic> json) => _$ImageImpl(
      width: json['width'] as int,
      height: json['height'] as int,
      topLeft: Point.fromJson(json['topLeft'] as Map<String, dynamic>),
      bottomRight: Point.fromJson(json['bottomRight'] as Map<String, dynamic>),
      url: json['url'] as String,
    );

Map<String, dynamic> _$$ImageImplToJson(_$ImageImpl instance) =>
    <String, dynamic>{
      'width': instance.width,
      'height': instance.height,
      'topLeft': instance.topLeft,
      'bottomRight': instance.bottomRight,
      'url': instance.url,
    };
