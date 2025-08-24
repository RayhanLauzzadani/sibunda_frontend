
import 'package:common/arch/data/local/dao/account_dao.dart';
import 'package:common/arch/data/local/dao/pregnancy_dao.dart';
import 'package:common/arch/data/local/db/app_db.dart';
import 'package:common/arch/data/local/source/account_local_source.dart';
import 'package:common/arch/data/remote/api/data_api.dart';
import 'package:common/arch/data/remote/model/baby_add_api_model.dart';
import 'package:common/arch/domain/model/child.dart';
import 'package:common/arch/domain/model/father.dart';
import 'package:common/arch/domain/model/profile_data.dart';
import 'package:common/util/type_util.dart';
import 'package:common/value/db_const.dart';
import 'package:core/domain/model/result.dart';
import 'package:core/util/_consoles.dart';

import '../dummy_data.dart';


mixin ChildRepo {
  Future<Result<ChildEntity>> getChildData(ProfileCredential credential);
  Future<Result<bool>> saveChildrenData({
    required List<ChildEntity> data,
    required String email,
    int? pregnancyId,
  });
  Future<Result<bool>> updateChildData({required int id, required Map<String, dynamic> body});
  Future<Result<bool>> saveFetusesData({
    required List<DateTime> hpls,
    required String email,
  });
  //Future<Result<bool>> saveLastChildBirthDate(DateTime date);
  Future<Result<bool>> saveChildrenCount(int count);
  Future<Result<Profile>> getProfileByPregnancyId(int pregnancyId);
}

class ChildRepoImpl with ChildRepo {
  final AccountLocalSrc _accountLocalSrc;
  final ProfileDao _profileDao;
  final PregnancyDao _pregnancyDao;
  final DataApi _dataApi;

  ChildRepoImpl({
    required ProfileDao profileDao,
    required AccountLocalSrc accountLocalSrc,
    required PregnancyDao pregnancyDao,
    required DataApi dataApi,
  }):
    _profileDao = profileDao,
    _accountLocalSrc = accountLocalSrc,
    _pregnancyDao = pregnancyDao,
    _dataApi = dataApi
  ;

  @override
  Future<Result<ChildEntity>> getChildData(ProfileCredential credential) async {
    try {
      final res = await _dataApi.getBio();
      if(res.code != 200) {
        return Fail(msg: "Can't get child data from server with `credential` of '$credential'", code: res.code);
      }
      final map = res.data.first.kia_anak.firstWhere((e) => e.id == credential.id).toJson();
      prind("child map= $map");
      _sanitizeChildMap(map);
  final dataRaw = ChildRaw.fromJson(map);
  final entity = mapChildRaw(dataRaw);
  return Success(entity);
    } catch(e, stack) {
      final msg = "Error calling `getChildData`";
      prine("$msg; e= $e");
      prine(stack);
      return Fail(msg: msg, error: e, stack: stack);
    }
  }

  // Provide defaults for nullable fields returned by backend so generated Child.fromJson doesn't crash.
  void _sanitizeChildMap(Map<String, dynamic> map) {
    // Required string fields in Child model
    const requiredStringKeys = [
      'no_akte_kelahiran','nik','gol_darah','no_jkn','tanggal_berlaku_jkn',
      'no_kohort','no_catatan_medik'
    ];
    for(final k in requiredStringKeys) {
      final v = map[k];
      if(v == null || (v is String && v.isEmpty)) {
        map[k] = '-';
      }
    }
    // Birth city int
    if(map['tempat_lahir'] == null) {
      map['tempat_lahir'] = 0; // sentinel unknown
    }
    // Gender sometimes might be null → fallback 'L' (arbitrary) if missing
    if(map['jenis_kelamin'] == null) {
      map['jenis_kelamin'] = 'L';
    }
    if(map['tanggal_lahir'] == null) {
      map['tanggal_lahir'] = DateTime.fromMillisecondsSinceEpoch(0).toIso8601String().substring(0,10);
    }
    if(map['nama'] == null) {
      map['nama'] = 'Anak';
    }
    if(map['anak_ke'] == null) {
      map['anak_ke'] = 1;
    }
  }
  @override
  Future<Result<bool>> saveChildrenData({
  required List<ChildEntity> data,
    required String email,
    int? pregnancyId,
  }) async {
    try {
      final profiles = await _profileDao.getProfilesByEmail(email);
      final userId = profiles.values.firstWhere((e) => e.isNotEmpty).first.userId;
      final motherId = profiles.values.firstWhere((e1) =>
        e1.length == 1 && e1.any((e2) =>
          e2.type == DbConst.TYPE_MOTHER
        )).first.serverId;
      final childProfiles = <ProfileEntity>[];
      var i = 0;
      for(final child in data) {
        final raw = ChildRaw(
          name: child.name,
          childOrder: child.childOrder,
          gender: child.gender,
          birthCertificateNo: child.birthCertificateNo,
          nik: child.nik ?? '',
          bloodType: child.bloodType ?? '',
          birthCity: child.birthCity ?? 0,
          birthDate: child.birthDate,
          jkn: child.jkn ?? '',
          jknStartDate: child.jknStartDate ?? '',
          babyCohortRegistNo: child.babyCohortRegistNo ?? '',
          toddlerCohortRegistNo: child.toddlerCohortRegistNo,
          hospitalMedicalNumber: child.hospitalMedicalNumber ?? '',
        );
        final body = BabyAddBody(ibu_id: motherId, child: raw);
        final res = await _dataApi.createChild(body);
        if(res.code != 200) {
          final msg = "Can't upload baby data in index $i with data raw= ${raw.toJson} \n res= $res";
          prine(msg);
          return Fail(msg: msg);
        }
        final serverId = res.anak_id!;
        final childProfile = ProfileEntity(
          userId: userId,
          type: DbConst.TYPE_CHILD,
          serverId: serverId,
          name: child.name,
          nik: child.nik ?? '',
          birthDate: parseDate(child.birthDate),
          birthPlace: child.birthCity ?? 0,
          pregnancyId: pregnancyId,
        );
        childProfiles.add(childProfile);
        i++;
      }
      final locRes = await _profileDao.insertAll(childProfiles);
      return Success(true);
    } catch(e, stack) {
      final msg = "Error calling `saveChildrenData()`";
      prine("$msg; e= $e");
      prine(stack);
      return Fail(msg: msg, error: e);
    }
  }

  @override
  Future<Result<bool>> updateChildData({required int id, required Map<String, dynamic> body}) async {
    try {
      final res = await _dataApi.updateChild(id, body);
      if(res.code != 200) return Fail(msg: 'Failed updating child with id $id', code: res.code);
      final name = body['nama'];
      final birthDate = body['tanggal_lahir'];
      final birthPlace = body['tempat_lahir'];
      if(name != null || birthDate != null || birthPlace != null) {
        try {
          await _profileDao.updateProfileMeta(
            serverId: id,
            name: name is String && name.isNotEmpty ? name : null,
            birthDateIso: birthDate is String ? birthDate : null,
            birthPlace: (birthPlace is int) ? birthPlace : (birthPlace is String ? int.tryParse(birthPlace) : null),
          );
        } catch(e, _) { prinw('Failed updating local child meta cache: $e'); }
      }
      return Success(true);
    } catch(e, stack) {
      final msg = 'Error calling updateChildData()';
      prine('$msg; e= $e');
      prine(stack);
      return Fail(msg: msg, error: e);
    }
  }

  @override
  Future<Result<bool>> saveFetusesData({
    required List<DateTime> hpls,
    required String email,
  }) async {
    try {
      final profiles = await _profileDao.getProfilesByEmail(email);
      final userId = profiles.values.firstWhere((e) => e.isNotEmpty).first.userId;
      final motherId = profiles.values.firstWhere((e1) =>
      e1.length == 1 && e1.any((e2) =>
      e2.type == DbConst.TYPE_MOTHER
      )).first.serverId;
      final pregnancies = <PregnancyEntity>[];
      var i = 0;
      for(final hpl in hpls) {
        final body = FetusAddBody(ibu_id: motherId, janin_hpl: hpl.toString());
        final res = await _dataApi.createFetus(body);
        if(res.code != 200) {
          final msg = "Can't upload fetus data in index $i with hpl of $hpl \n res= $res";
          return Fail(msg: msg);
        }
        final serverId = res.anak_id!;
        final pregnancy = PregnancyEntity(
          id: serverId,
          credentialId: userId,
          hpl: hpl,
        );
        pregnancies.add(pregnancy);
        i++;
      }
      final locRes = await _pregnancyDao.insertAll(pregnancies);
      return Success(true);
    } catch(e, stack) {
      final msg = "Error calling `saveChildrenData()`";
      prine("$msg; e= $e");
      prine(stack);
      return Fail(msg: msg, error: e);
    }
  }
  /*
  @override
  Future<Result<bool>> saveLastChildBirthDate(DateTime date);
   */
  @override Future<Result<bool>> saveChildrenCount(int count) async => Success(true);

  @override
  Future<Result<Profile>> getProfileByPregnancyId(int pregnancyId) async {
    try {
      final res = await _accountLocalSrc.getProfileByPregnancyId(pregnancyId);
      if(res is! Success<ProfileEntity>) {
        if(res.code == 1) {
          final msg = "Can't get baby profile with `pregnancyId` of '$pregnancyId'. It means the baby is not born yet";
          prinw(msg);
          return Fail(msg: msg);
        } else {
          return res as Fail<Profile>;
        }
      }
      return await _accountLocalSrc.getProfileByServerId(res.data.serverId);
    } catch(e, stack) {
      final msg = "Error calling `getProfileByPregnancyId()`";
      prine("$msg; e= $e");
      prine(stack);
      return Fail(msg: msg, error: e);
    }
  }
}


class ChildRepoDummy with ChildRepo {
  ChildRepoDummy._();
  static final obj = ChildRepoDummy._();

  @override
  Future<Result<ChildEntity>> getChildData(ProfileCredential credential) async => Success(mapChildRaw(ChildRaw(
    name: dummyChild.name,
    childOrder: dummyChild.childOrder,
    gender: dummyChild.gender,
    birthCertificateNo: dummyChild.birthCertificateNo,
    nik: dummyChild.nik,
    bloodType: dummyChild.bloodType,
    birthCity: dummyChild.birthCity,
    birthDate: dummyChild.birthDate,
    jkn: dummyChild.jkn,
    jknStartDate: dummyChild.jknStartDate,
    babyCohortRegistNo: dummyChild.babyCohortRegistNo,
    toddlerCohortRegistNo: dummyChild.toddlerCohortRegistNo,
    hospitalMedicalNumber: dummyChild.hospitalMedicalNumber,
  )));
  @override
  Future<Result<bool>> saveChildrenData({
    required List<ChildEntity> data,
    required String email,
    int? pregnancyId,
  }) async => Success(true);
  @override
  Future<Result<bool>> updateChildData({required int id, required Map<String, dynamic> body}) async => Success(true);

  @override
  Future<Result<bool>> saveFetusesData({required List<DateTime> hpls, required String email}) async => Success(true);

  @override Future<Result<bool>> saveChildrenCount(int count) async => Success(true);
  @override
  Future<Result<Profile>> getProfileByPregnancyId(int pregnancyId) async => Success(dummyProfile);
}