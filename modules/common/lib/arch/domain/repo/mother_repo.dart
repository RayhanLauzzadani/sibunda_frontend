import 'package:common/arch/data/local/db/app_db.dart';
import 'package:common/arch/data/local/source/account_local_source.dart';
import 'package:common/arch/data/local/dao/account_dao.dart';
import 'package:common/arch/data/local/source/pregnancy_local_source.dart';
import 'package:common/arch/data/remote/api/data_api.dart';
import 'package:common/arch/data/remote/model/baby_add_api_model.dart';
import 'package:common/arch/data/remote/model/kehamilanku_overview_api_model.dart';
import 'package:common/arch/domain/model/chart_data.dart';
import 'package:common/arch/domain/model/chart_data_mother.dart';
import 'package:common/arch/domain/model/kehamilanku_data.dart';
import 'package:common/arch/domain/model/mother.dart';
import 'package:common/arch/domain/model/profile_data.dart';
import 'package:common/value/const_values.dart';
import 'package:common/value/db_const.dart';
import 'package:core/domain/model/result.dart';
import 'package:core/util/_consoles.dart';
import 'package:core/util/annotation/data_annotation.dart';

import '../dummy_data.dart';

mixin MotherRepo {
  Future<Result<String>> getMotherNik();
  Future<Result<Mother>> getMotherData(ProfileCredential credential);
  Future<Result<bool>> saveMotherData(Mother data);
  Future<Result<bool>> updateMotherData({required int id, required Map<String, dynamic> body});

  //Future<Result<List<MotherHomeData>>> getMotherHomeData();

  Future<Result<bool>> saveMotherHpl({
    required DateTime date,
    required String motherNik,
  });
  Future<Result<DateTime>> getMotherHpl(int pregnancyId);
  Future<Result<bool>> deleteCurrentMotherHpl();

  //Future<Result<bool>> saveMotherHpht(DateTime date);
  //Future<Result<DateTime?>> getCurrentMotherHpht();

  //Future<Result<int?>> getCurrentPregnancyId();
  //Future<Result<bool>> saveCurrentPregnancyId(int pregnancyId);

  Future<Result<List<PregnancyEntity>>> getPregnancyOfUser(String motherNik,);
  Future<Result<bool>> savePregnancy({
    required int id,
    required String motherNik,
    required DateTime hpl,
  });
}

class MotherRepoImpl with MotherRepo {
  final DataApi _dataApi;
  final AccountLocalSrc _accountLocalSrc;
  final PregnancyLocalSrc _pregnancyLocalSrc;
  final ProfileDao _profileDao;

  MotherRepoImpl({
    required DataApi dataApi,
    required AccountLocalSrc accountLocalSrc,
    required PregnancyLocalSrc pregnancyLocalSrc,
    required ProfileDao profileDao,
  }):
    _dataApi = dataApi,
    _accountLocalSrc = accountLocalSrc,
    _pregnancyLocalSrc = pregnancyLocalSrc,
    _profileDao = profileDao
  ;

  @override
  Future<Result<String>> getMotherNik() async {
    final res1 = await _accountLocalSrc.getCurrentEmail();
    if(res1 is Success<String>) {
      final email = res1.data;
      return await _accountLocalSrc.getMotherNik(email);
    } else {
      return res1 as Fail<String>;
    }
  }

  @override @mayChangeInFuture
  Future<Result<Mother>> getMotherData(ProfileCredential credential) async {
    try {
      final res = await _dataApi.getBio();
      if(res.code != 200) {
        return Fail(msg: "Can't get mother data from server with `credential` of '$credential'", code: res.code);
      }
      final map = res.data.first.toJson();
      final data = Mother.fromJson(map);
      return Success(data);
    } catch(e, stack) {
      final msg = "Error calling `getMotherData`";
      prine("$msg; e= $e");
      prine(stack);
      return Fail(msg: msg, error: e, stack: stack);
    }
  }
  /*
      try {
        final name = body['nama'];
        final bd = body['tanggal_lahir'];
        final bp = body['tempat_lahir'];
        if(name != null || bd != null || bp != null) {
          await _profileDao.updateProfileMeta(
            serverId: id,
            name: name is String && name.isNotEmpty ? name : null,
            birthDateIso: bd is String ? bd : null,
            birthPlace: (bp is int) ? bp : (bp is String ? int.tryParse(bp) : null),
          );
        }
      } catch(e,_) { prinw('Failed syncing local mother meta (non-fatal): $e'); }
      return Fail();
    }
  }
   */

  @override @mayChangeInFuture
  Future<Result<bool>> saveMotherData(Mother data) async => Success(true);
  @override
  Future<Result<bool>> updateMotherData({required int id, required Map<String, dynamic> body}) async {
    try {
      final res = await _dataApi.updateMother(id, body);
      if(res.code != 200) return Fail(msg: 'Failed updating mother with id $id', code: res.code);
      // Sync local cache (name, birth date, birth place) if present in body.
      try {
        final name = body['nama'];
        final bd = body['tanggal_lahir'];
        final bp = body['tempat_lahir'];
        if(name != null || bd != null || bp != null) {
          await _accountLocalSrc.updateProfileMeta(
            serverId: id,
            name: (name is String && name.isNotEmpty) ? name : null,
            birthDateIso: bd is String ? bd : null,
            birthPlace: (bp is int) ? bp : (bp is String ? int.tryParse(bp) : null),
          );
        }
      } catch(e,_) { prinw('Failed syncing local mother meta (non-fatal): $e'); }
      return Success(true);
    } catch(e, stack) {
      final msg = 'Error calling updateMotherData';
      prine('$msg; e= $e');
      prine(stack);
      return Fail(msg: msg, error: e, stack: stack);
    }
  }

  @override
  Future<Result<bool>> saveMotherHpl({
    required DateTime date,
    required String motherNik,
  }) async {
    try {
      final motherIdRes = await _accountLocalSrc.getMotherId(motherNik);
      if(motherIdRes is! Success<int>) {
        final msg = "Can't get `motherId` with `motherNik` of '$motherNik' in `saveMotherHpl()`";
        prine(msg);
        return Fail(msg: msg);
      }
      final motherId = motherIdRes.data;
      final body = FetusAddBody(
        ibu_id: motherId,
        janin_hpl: date.toString(),
      );
      final res = await _dataApi.createFetus(body);
      if(res.code != 200) {
        final msg = "Can't upload mother hpl with `motherNik` of '$motherNik' in `saveMotherHpl()`";
        prine(msg);
        return Fail(msg: msg);
      }
      final pregId = res.anak_id!;
      var locRes = await _pregnancyLocalSrc.savePregnancy(id: pregId, motherNik: motherNik, hpl: date);
      if(locRes is! Success<bool>) {
        return Fail(msg: "Can't save pregnancy data with `motherNik` of '$motherNik' to local in `saveMotherHpl()`");
      }
      /*
      locRes = await _pregnancyLocalSrc.saveMotherHpl(date);
      if(locRes is! Success<bool>) {
        return Fail(msg: "Can't save pregnancy data with `motherNik` of '$motherNik' to local in `saveMotherHpl()`");
      }
       */
      return Success(true);
    } catch(e, stack) {
      final msg = "Error calling `saveMotherHpl()`";
      prine("$msg; e= $e");
      prine(stack);
      return Fail(msg: msg, error: e,);
    }
  }
  @override
  Future<Result<DateTime>> getMotherHpl(int pregnancyId) => _pregnancyLocalSrc.getMotherHpl(pregnancyId);
  @override
  Future<Result<bool>> deleteCurrentMotherHpl() async => Success(true); // For now, it is just to mimic to temporary mother hpl.
  /*
  @override
  Future<Result<DateTime?>> getCurrentMotherHpl() => _pregnancyLocalSrc.getCurrentMotherHpl();
  @override
  Future<Result<bool>> deleteCurrentMotherHpl() => _pregnancyLocalSrc.deleteCurrentMotherHpl();

  @override
  Future<Result<bool>> saveMotherHpht(DateTime date) => _pregnancyLocalSrc.saveMotherHpht(date);
  @override
  Future<Result<DateTime?>> getCurrentMotherHpht() => _pregnancyLocalSrc.getCurrentMotherHpht();

  @override
  Future<Result<int?>> getCurrentPregnancyId() => _pregnancyLocalSrc.getCurrentPregnancyId();
  @override
  Future<Result<bool>> saveCurrentPregnancyId(int pregnancyId) => _pregnancyLocalSrc.saveCurrentPregnancyId(pregnancyId);
   */

  @override
  Future<Result<List<PregnancyEntity>>> getPregnancyOfUser(String motherNik,) =>
      _pregnancyLocalSrc.getPregnancyOfUser(motherNik);
  @override
  Future<Result<bool>> savePregnancy({
    required int id,
    required String motherNik,
    required DateTime hpl,
  }) => _pregnancyLocalSrc.savePregnancy(id: id, motherNik: motherNik, hpl: hpl);
}


class MotherRepoDummy with MotherRepo {
  MotherRepoDummy._();
  static final obj = MotherRepoDummy._();

  @override
  Future<Result<String>> getMotherNik() async => Success("0123012");
  @override
  Future<Result<Mother>> getMotherData(ProfileCredential credential) async => Success(dummyMother);
  @override
  Future<Result<bool>> saveMotherData(Mother data) async => Success(true);
  @override
  Future<Result<bool>> updateMotherData({required int id, required Map<String, dynamic> body}) async => Success(true);
/*
  @override
  Future<Result<List<MotherHomeData>>> getMotherHomeData() async => Success(motherHomeData);
 */
  @override
  Future<Result<bool>> saveMotherHpl({
    required DateTime date,
    required String motherNik,
  }) async => Success(true);
  /*
  @override
  Future<Result<DateTime?>> getCurrentMotherHpl() async => Success(dummyMotherHpl);
  @override
  Future<Result<bool>> deleteCurrentMotherHpl() async => Success(true);

  @override
  Future<Result<bool>> saveMotherHpht(DateTime date) async => Success(true);
  @override
  Future<Result<DateTime?>> getCurrentMotherHpht() async => Success(dummyMotherHpht);

  @override
  Future<Result<int?>> getCurrentPregnancyId() async => Success(1);
  @override
  Future<Result<bool>> saveCurrentPregnancyId(int pregnancyId) async => Success(true);
   */
  @override
  Future<Result<List<PregnancyEntity>>> getPregnancyOfUser(String motherNik,) async => Success([
    PregnancyEntity(id: 1, credentialId: 1, hpl: dummyMotherHpl)
  ]);
  @override
  Future<Result<bool>> savePregnancy({
    required int id,
    required String motherNik,
    required DateTime hpl,
  }) async => Success(true);

  @override
  Future<Result<DateTime>> getMotherHpl(int pregnancyId) async => Success(DateTime.now());

  @override
  Future<Result<bool>> deleteCurrentMotherHpl() async => Success(true);
}