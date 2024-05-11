import 'package:freezed_annotation/freezed_annotation.dart';

part 'paging_params.freezed.dart';

part 'paging_params.g.dart';

@freezed
class PagingParams with _$PagingParams {
  const factory PagingParams({
    required int limit,
    required int offset,
  }) = _PagingParams;

  factory PagingParams.fromJson(Map<String, dynamic> json) => _$PagingParamsFromJson(json);
}
