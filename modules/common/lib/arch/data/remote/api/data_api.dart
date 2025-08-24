import 'package:common/arch/data/remote/model/_common_api_model.dart';
import 'package:common/arch/data/remote/model/baby_add_api_model.dart';
import 'package:common/arch/data/remote/model/data_api_model.dart';
import 'package:common/arch/domain/model/auth.dart';
import 'package:common/util/net.dart';
import 'package:common/value/const_values.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/http.dart';

part 'data_api.g.dart';

@RestApi(baseUrl: Const.ENDPOINT_DATA)
abstract class DataApi {
  factory DataApi(SessionData session, { Dio? dio }) => _DataApi(
      SibDio.getDefaultInstance(preExisting: dio, session: session)
  );

  @GET("/kota")
  Future<List<CityResponse>> getCity();
  @GET("/bio")
  Future<BioResponse> getBio();
  @POST("/identitas-anak")
  Future<BabyAddResponse> createChild(@Body() BabyAddBody body);
  @POST("/identitas-anak")
  Future<BabyAddResponse> createFetus(@Body() FetusAddBody body);
  // Update endpoints (RESTful PUT with id path params)
  @PUT("/identitas-ibu/{id}")
  Future<CommonResponse> updateMother(@Path("id") int id, @Body() Map<String, dynamic> body);
  @PUT("/identitas-ayah/{id}")
  Future<CommonResponse> updateFather(@Path("id") int id, @Body() Map<String, dynamic> body);
  @PUT("/identitas-anak/{id}")
  Future<CommonResponse> updateChild(@Path("id") int id, @Body() Map<String, dynamic> body);
  @PUT("/save-profile")
  Future<CommonResponse> saveProfile(@Body() SaveProfileBody body);
}