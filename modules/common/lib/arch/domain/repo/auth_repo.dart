// User and Auth related repository.

import 'package:collection/collection.dart';
import 'package:common/arch/data/local/source/account_local_source.dart';
import 'package:common/arch/data/local/source/check_up_local_source.dart';
import 'package:common/arch/data/local/source/pregnancy_local_source.dart';
import 'package:common/arch/data/remote/api/auth_api.dart';
import 'package:common/arch/data/remote/api/data_api.dart';
import 'package:common/arch/data/remote/model/login_api_model.dart';
import 'package:common/arch/data/remote/model/logout_api_model.dart';
import 'package:common/arch/data/remote/model/register_api_model.dart';
import 'package:common/arch/di/api_di.dart';
import 'package:common/arch/di/config_di.dart';
import 'package:common/arch/domain/model/auth.dart';
import 'package:common/arch/domain/model/child.dart';
import 'package:common/arch/domain/model/father.dart';
import 'package:common/arch/domain/model/mother.dart';
import 'package:common/arch/domain/model/profile_data.dart';
import 'package:common/util/times.dart';
import 'package:common/value/db_const.dart';
import 'package:core/domain/model/result.dart';
import 'package:core/util/_consoles.dart';
import 'package:core/util/annotation/data_annotation.dart';

import '../dummy_data.dart';

mixin AuthRepo {
  Future<Result<bool>> saveSignupData(SignUpData signup);
  Future<Result<bool>> signup({
    required SignUpData signup,
    required Mother? mother,
    required Father? father,
    required List<Child> children,
    required DateTime? motherHpl,
  });
  Future<Result<SessionData>> login(LoginData data);
  Future<Result<bool>> logout(SessionData data);
  Future<Result<bool>> clearUserData();
  Future<Result<bool>> saveSession(SessionData data);
  /// Returns null if user hasn't logged in yet.
  Future<Result<SessionData?>> getSession();
  
  Future<Result<bool>> isEmailAvailable(String email);
  Future<Result<List<BatchProfileServer>>> getBio();
}
/*
 Although it's a repo, but I feel the implementation is like use case.
 */
class AuthRepoImpl with AuthRepo {
  final AuthApi _api;
  DataApi? _dataApi;
  final AccountLocalSrc _accountLocalSrc;
  final PregnancyLocalSrc _pregnancyLocalSrc;
  final CheckUpLocalSrc _checkUpLocalSrc;

  AuthRepoImpl({
    required AuthApi api,
    required DataApi? dataApi,
    required AccountLocalSrc accountLocalSrc,
    required PregnancyLocalSrc pregnancyLocalSrc,
    required CheckUpLocalSrc checkUpLocalSrc,
  }):
    _api = api,
    _dataApi = dataApi,
    _accountLocalSrc = accountLocalSrc,
    _pregnancyLocalSrc = pregnancyLocalSrc,
    _checkUpLocalSrc = checkUpLocalSrc
  ;

  //DataApi getDataApi() => _dataApi ??= ApiDi.dataApi;

  @override
  Future<Result<bool>> saveSignupData(SignUpData signup) async => Success(true); //For now, this is just for gymmic. it is because `SignUpData` is stored together with other get started related data.

  /// This method also calls login and downloads mother, father, and children data
  /// for the ids to be saved in local DB.
  @override
  Future<Result<bool>> signup({
    required SignUpData signup,
    required Mother? mother,
    required Father? father,
    required List<Child> children,
    required DateTime? motherHpl,
  }) async {
    final body = RegisterBody(
      signup: signup,
      mother: mother,
      father: father,
      children: children,
      motherHpl: motherHpl,
    );
    try {
      prind('[signup] sending register body keys: '+body.toJson().keys.join(','));
      RegisterResponse res;
  try { res = await _api.register(body); } catch(e) { return Fail(msg: 'Register failed/parsing', error: e); }
      prind('[signup] parsed register code='+res.code.toString()+' status='+ (res.status?.toString() ?? '-') +' userId=${res.userId} hasUser=${res.user!=null}');
      if(res.code != 200) {
        // Mapping sederhana untuk pesan 422 agar lebih user-friendly
        String msg = res.message;
        if(res.code == 422 && (msg.isEmpty || msg.toLowerCase().contains('validation'))) {
          msg = 'Data tidak valid (mungkin email sudah terpakai)';
        }
        return Fail(code: res.code, msg: msg);
      }
      return Success(true);
    } catch(e, stack) {
      prine(e);
      prine(stack);
      return Fail(msg: "Something error in this `$runtimeType`.signup()", error: e);
    }
  }

  @override
  Future<Result<SessionData>> login(LoginData data) async {
    final body = LoginBody(data);
    try {
      final res = await _api.login(body);
      if(res.code != 200) {
        return Fail(code: res.code, msg: res.message);
      }
      final session = SessionData(token: res.data!.token, tokenType: res.data!.tokenType,);
      VarDi.session = session;
      VarDi.isSessionValid.value = true;

      final bioRes = await getBio();
      if(bioRes is! Success<List<BatchProfileServer>>) {
        return Fail(msg: "Can't download `bio` when login");
      }

      final bioData = bioRes.data;

      for(final bio in bioData) {
        final saveBioRes = await _accountLocalSrc.saveBatchProfileRaw(
          userRole: DbConst.ROLE_USER, //TODO: Hardcoded role type
          signup: SignUpData(
            name: bio.mother.name,
            email: data.email,
            password: data.password,
          ),
          batchProfiles: bio,
        );
        if(saveBioRes is Fail<bool>) {
          return Fail(msg: "Can't save `bio` of '$bio' in local");
        }
      }
      VarDi.motherNik.value = bioData.first.mother.nik;
      prind("AuthRepo.login() VarDi.motherNik= ${VarDi.motherNik}");
      //VarDi.pregnancyWeek.value = bioData.first.mother;

      var locRes = await _accountLocalSrc.saveSession(session);
      if(locRes is! Success<bool>) {
        return Fail(msg: "Can't save `session` in local");
      }
      locRes = await _accountLocalSrc.saveCurrentEmail(data.email);
      if(locRes is! Success<bool>) {
        return Fail(msg: "Can't save `email` in local");
      }
      locRes = await _accountLocalSrc.saveCurrentPswd(data.password);
      if(locRes is! Success<bool>) {
        return Fail(msg: "Can't save `pswd` in local");
      }

      /*
      //final unbornChild = bioData.first.children.firstWhereOrNull((e) => e.)
      final motherHpl = bioData.first.motherHpl;
      if(motherHpl != null) {
        locRes = await _pregnancyLocalSrc.saveMotherHpl(motherHpl);
        if(locRes is! Success<bool>) {
          return Fail(msg: "Can't save `hpl` in local");
        }
        final hpht = getHpht(motherHpl);
        locRes = await _pregnancyLocalSrc.saveMotherHpht(hpht);
        if(locRes is! Success<bool>) {
          return Fail(msg: "Can't save `hpht` in local");
        }
      }
       */
      return Success(session, 200);
    } catch(e, stack) {
      final msg = "Error calling `login()`";
      prine("$msg, e= $e");
      prine(stack);
      return Fail(msg: msg, error: e);
    }
  }
  @override
  Future<Result<bool>> logout(SessionData data) async {
    final body = LogoutBody(data);
    try {
      final res = await _api.logout(body);
      if(res.code != 200) {
        return Fail(code: res.code, msg: res.message);
      }
      return await clearUserData();
    } catch(e, stack) {
      final msg = "Error calling `logout()`";
      prine("$msg, e= $e");
      prine(stack);
      return Fail(msg: msg, error: e);
    }
  }
  @override
  Future<Result<bool>> clearUserData() async {
    try {
      var locRes = await _pregnancyLocalSrc.clear();
      if(locRes is! Success<bool>) {
        return Fail(msg: "Can't delete `hpl` and `hpht` in local");
      }
      locRes = await _checkUpLocalSrc.clear();
      if(locRes is! Success<bool>) {
        return Fail(msg: "Can't delete `checkUps` data in local");
      }
/*
      if(locRes is! Success<bool>) {
        return Fail(msg: "Can't delete `pregnancy` data in local");
      }
 */
      locRes = await _accountLocalSrc.deleteSession();
      if(locRes is! Success<bool>) {
        return Fail(msg: "Can't delete `session` in local");
      }
      locRes = await _accountLocalSrc.deleteCurrentEmail();
      if(locRes is! Success<bool>) {
        return Fail(msg: "Can't delete `email` in local");
      }

      locRes = await _accountLocalSrc.clear();
      if(locRes is! Success<bool>) {
        return Fail(msg: "Can't clear all `profile` and `credential` in local");
      }
      return Success(true);
    } catch(e, stack) {
      final msg = "Error calling `clearUserData()`";
      prine("$msg, e= $e");
      prine(stack);
      return Fail(msg: msg, error: e);
    }
  }

  @override
  Future<Result<bool>> saveSession(SessionData data) async {
    var locRes = await _accountLocalSrc.saveSession(data);
    if(locRes is! Success<bool>) {
      return Fail(msg: "Can't save `session` in local");
    }
    VarDi.session = data;
    return Success(true);
  }

  @override
  Future<Result<SessionData?>> getSession() => _accountLocalSrc.getSession();

  @override
  Future<Result<bool>> isEmailAvailable(String email) async {
    try {
      final res = await _api.checkEmailAvailability(email);
      if(res.code != 200) {
        final msg = "Can't check email availability in server";
        prine(msg);
        return Fail(msg: "$msg; remote msg = ${res.message}", code: res.code,);
      }
      return Success(res.available);
    } catch(e, stack) {
      final msg = "Error calling `isEmailAvailable()`";
      prine("$msg; e= $e");
      prine(stack);
      return Fail(msg: msg, error: e,);
    }
  }

  @override
  Future<Result<List<BatchProfileServer>>> getBio() async {
    /*
    if(_dataApi == null) {
      throw "Can't get bio with `_dataApi == null`";
    }
     */
    try {
      final res = await (_dataApi ??= ApiDi.obj.dataApi).getBio();
      if(res.code != 200) {
        return Fail(code: res.code, msg: "msg= '${res.message}', status= '${res.status}'",);
      }
      final list = res.data.map<BatchProfileServer>((e) =>
          BatchProfileServer.fromBioResponse(e))
          .toList(growable: false);

      return Success(list);
    } catch(e, stack) {
      prine(e);
      prine(stack);
      return Fail(msg: "Error calling `getBio()`, e= $e");
    }
  }
}

/*
class AuthApiRepo with AuthRepo {
  static AuthApiRepo? _instance;

  factory AuthApiRepo() => _instance ??= AuthApiRepo._();
  AuthApiRepo._();

  @override
  Future<Result<SessionData>> login(LoginData data) async {
    final resp = await Auth.login(data.email, data.password, NetConfig.CLIENT_SECRET, NetConfig.CLIENT_ID.toString());
    if(resp.statusCode == 200) {
      final token = resp.data["data"][Const.KEY_ACCESS_TOKEN];
      final session = SessionData(token);
      return Success(session);
    } else {
      return Fail(msg: resp.message, data: resp.data, code: resp.statusCode);
    }
  }

  @override
  Future<Result<bool>> signup(SignUpData data) async {
    final resp = await Auth.signUp(data.name, data.email, data.password);
    if(resp.statusCode == 200) {
      return Success(true, 200);
    } else {
      return Fail(msg: resp.message, data: resp.data, code: resp.statusCode);
    }
  }

  Future<Result<bool>> logout(String accessToken) async {
    final resp = await Auth.logout(accessToken);
    if(resp.statusCode == 200) {
      return Success(true, 200);
    } else {
      return Fail(msg: resp.message, data: resp.data, code: resp.statusCode);
    }
  }

  @override
  Future<Result<bool>> saveSession(SessionData data) {
    // TODO: implement saveSession
    throw UnimplementedError();
  }

  @override
  Future<Result<SessionData>> getSession() {
    // TODO: implement getSession
    throw UnimplementedError();
  }
}
 */


class AuthDummyRepo with AuthRepo {
  //static AuthDummyRepo? _instance;

  //factory AuthDummyRepo() => _instance ??= AuthDummyRepo._();
  AuthDummyRepo._();
  static final obj = AuthDummyRepo._();

  @override
  Future<Result<bool>> saveSignupData(SignUpData signup) async => Success(true);

  @override
  Future<Result<SessionData>> login(LoginData data) async => Success(dummySessionData1);

  @override
  Future<Result<bool>> signup({
    required SignUpData signup,
    required Mother? mother,
    required Father? father,
    required List<Child> children,
    required DateTime? motherHpl,
  }) async => Success(true, 200);

  @override
  Future<Result<bool>> logout(SessionData data) async => Success(true, 200);

  @override
  Future<Result<bool>> clearUserData() async => Success(true);

  @override
  Future<Result<SessionData?>> getSession() async => Success(dummySessionData1);

  @override
  Future<Result<bool>> saveSession(SessionData data) async => Success(true);

  @override
  Future<Result<bool>> isEmailAvailable(String email) async => Success(true);

  @override
  Future<Result<List<BatchProfileServer>>> getBio() async => Success([dummyBatchProfile]);
}