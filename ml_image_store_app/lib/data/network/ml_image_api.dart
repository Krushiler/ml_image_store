import 'package:retrofit/http.dart';
import 'package:dio/dio.dart';

import 'package:ml_image_store/response/auth_response.dart';
import 'package:ml_image_store/request/login_request.dart';
import 'package:ml_image_store/request/register_request.dart';

part 'ml_image_api.g.dart';

@RestApi()
abstract class MlImageApi {
  factory MlImageApi(Dio dio, {required String baseUrl}) => _MlImageApi(dio, baseUrl: baseUrl);

  @POST('/auth/login')
  Future<AuthResponse> login(@Body() LoginRequest request);

  @POST('auth/register')
  Future<AuthResponse> register(@Body() RegisterRequest request);
}
