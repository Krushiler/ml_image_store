import 'package:dio/dio.dart';
import 'package:ml_image_store/model/folder/folder.dart';
import 'package:ml_image_store/model/image/image.dart';
import 'package:ml_image_store/request/create_folder_request.dart';
import 'package:ml_image_store/request/login_request.dart';
import 'package:ml_image_store/request/register_request.dart';
import 'package:ml_image_store/response/auth_response.dart';
import 'package:ml_image_store/response/folder_response.dart';
import 'package:retrofit/retrofit.dart';

part 'ml_image_api.g.dart';

@RestApi()
abstract class MlImageApi {
  factory MlImageApi(Dio dio, {required String baseUrl}) => _MlImageApi(dio, baseUrl: baseUrl);

  @POST('/auth/login')
  Future<AuthResponse> login(@Body() LoginRequest request);

  @POST('/auth/register')
  Future<AuthResponse> register(@Body() RegisterRequest request);

  @POST('/folders')
  Future<void> createFolder(@Body() CreateFolderRequest request);

  @GET('/folders')
  Future<List<Folder>> getFolders();

  @GET('/folders/{id}')
  Future<FolderResponse> getFolder(@Path('id') String id);

  @DELETE('/folders/{id}')
  Future<void> deleteFolder(@Path('id') String id);

  @GET('/files/{id}')
  @DioResponseType(ResponseType.bytes)
  Future<HttpResponse<List<int>>> getFile(@Path('id') String id);

  @POST('/images')
  @MultiPart()
  Future<void> createImage({
    @Part(name: 'folderId') required String folderId,
    @Part(name: 'leftTop') required String leftTop,
    @Part(name: 'rightBottom') required String rightBottom,
    @Part(name: 'image') required List<MultipartFile> image,
  });

  @GET('/images/{id}')
  Future<Image> getImage(@Path('id') String id);

  @DELETE('/images/{id}')
  Future<void> deleteImage(@Path('id') String id);
}
