import 'package:common/arch/data/remote/api/data_api.dart';
import 'package:common/arch/domain/model/father.dart';
import 'package:common/arch/domain/model/profile_data.dart';
import 'package:core/domain/model/result.dart';
import 'package:core/util/_consoles.dart';

import '../dummy_data.dart';


mixin FatherRepo {
  Future<Result<Father>> getFatherData(ProfileCredential credential);
  Future<Result<bool>> saveFatherData(Father data);
  Future<Result<bool>> updateFatherData({required int id, required Map<String, dynamic> body});
}

class FatherRepoImpl with FatherRepo {
  final DataApi _dataApi;

  FatherRepoImpl({
    required DataApi dataApi,
  }):
    _dataApi = dataApi
  ;

  @override
  Future<Result<Father>> getFatherData(ProfileCredential credential) async {
    try {
      final res = await _dataApi.getBio();
      if(res.code != 200) {
        return Fail(msg: "Can't get father data from server with `credential` of '$credential'", code: res.code);
      }
      final map = res.data.first.kia_ayah.toJson();
      final data = Father.fromJson(map);
      return Success(data);
    } catch(e, stack) {
      final msg = "Error calling `getFatherData`";
      prine("$msg; e= $e");
      prine(stack);
      return Fail(msg: msg, error: e, stack: stack);
    }
  }
  @override
  Future<Result<bool>> saveFatherData(Father data) async => Success(true);
  @override
  Future<Result<bool>> updateFatherData({required int id, required Map<String, dynamic> body}) async {
    try {
      final res = await _dataApi.updateFather(id, body);
      if(res.code != 200) return Fail(msg: 'Failed updating father with id $id', code: res.code);
      return Success(true);
    } catch(e, stack) {
      final msg = 'Error calling updateFatherData';
      prine('$msg; e= $e');
      prine(stack);
      return Fail(msg: msg, error: e, stack: stack);
    }
  }
}

class FatherRepoDummy with FatherRepo {
  FatherRepoDummy._();
  static final obj = FatherRepoDummy._();

  @override
  Future<Result<Father>> getFatherData(ProfileCredential credential) async => Success(dummyFather);
  @override
  Future<Result<bool>> saveFatherData(Father data) async => Success(true);
  @override
  Future<Result<bool>> updateFatherData({required int id, required Map<String, dynamic> body}) async => Success(true);
}