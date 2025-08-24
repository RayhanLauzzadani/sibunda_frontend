import 'package:common/arch/di/usecase_di.dart';
import 'package:common/arch/domain/model/_model_template.dart';
import 'package:common/arch/domain/model/auth.dart';
import 'package:common/arch/domain/model/child.dart';
import 'package:common/arch/domain/model/father.dart';
import 'package:common/arch/domain/model/mother.dart';
import 'package:common/arch/domain/model/profile_data.dart';
import 'package:common/arch/domain/usecase/auth_usecase.dart';
import 'package:common/arch/domain/usecase/data_usecase.dart';
import 'package:common/arch/domain/usecase/family_usecase.dart';
import 'package:common/arch/domain/usecase/firebase_usecase.dart';
import 'package:common/arch/domain/usecase/mother_usecase.dart';
import 'package:common/arch/domain/usecase/profile_usecase.dart';
import 'package:common/arch/ui/vm/vm_auth.dart';
import 'package:common/value/const_values.dart';
import 'package:core/domain/model/result.dart';
import 'package:core/ui/base/async_vm.dart';
import 'package:core/ui/base/live_data.dart';
import 'package:core/util/_consoles.dart';
import 'package:flutter/cupertino.dart';
import 'package:home/core/domain/usecase/_auth_usecase.dart';
import 'package:home/core/domain/usecase/form_get_started_usecase.dart';
import 'package:home/ui/form_get_started/child_form_vm.dart';
import 'package:home/core/di/home_usecase_di.dart';
import 'package:home/ui/form_get_started/do_mother_have_pregnancy_vm.dart';
import 'package:home/ui/form_get_started/father_form_vm.dart';
import 'package:home/ui/form_get_started/mother_form_vm.dart';
import 'package:home/ui/form_get_started/mother_hpl_vm.dart';
import 'package:home/ui/signup/sign_up_vm.dart';

import 'children_count_vm.dart';

class GetStartedFormMainVm extends AsyncAuthVm {
  static const sendDataKey = "sendData";

  GetStartedFormMainVm({
    BuildContext? context,
    required SignUpAndRegisterOtherData signUpAndRegisterOtherData,
    required GetFcmToken getFcmToken,
    required Login login,
    required InitConfig initConfig,
    //required SaveMotherHpl saveMotherHpl,
  }): //_saveMotherHpl = saveMotherHpl,
      _signUpAndRegisterOtherData = signUpAndRegisterOtherData,
      _getFcmToken = getFcmToken,
      _login = login,
      _initConfig = initConfig, super(context: context) {
    signUpFormVm = SignUpFormVm(
      saveSignupData: _signup,
      checkEmailAvailability: UseCaseDi.obj.checkEmailAvailability,
    );
    motherVm = MotherFormVm(
      context: context,
      saveMotherData: _saveMotherData,
      getMotherData: _GetMotherDataImpl(),
      getCityById: _GetCityByIdImpl(),
    );
    fatherVm = FatherFormVm(
      context: context,
      saveFatherData: _saveFatherData,
      getFatherData: _GetFatherDataImpl(),
      getCityById: _GetCityByIdImpl(),
    );
    motherHplVm = MotherHplVm(
      getMotherNik: _getMotherNikDummy,
      saveMotherHpl: _saveMotherHplForChild,
      //saveMotherPregnancy:
    );
    doMotherHavePregnancyVm = DoMotherHavePregnancyVm(deleteCurrentMotherHpl: _deleteCurrentMotherHpl);
    childrenCountVm = ChildrenCountVm(
      saveChildrenCount: _saveChildrenCount,
      //saveLastChildBirthDate: _saveLastChildBirthDate,
    );
    childVm = ChildFormVm(
      getCurrentEmail: _getCurrentEmailDummy,
      childCount: childrenCountVm.childrenCount,
      saveChildrenData: _saveChildrenData,
      getChildData: _GetChildDataImpl(),
      getCityById: _GetCityByIdImpl(),
      pregnancyId: null,
    );
    childrenCountVm.childrenCount.observe(this, (count) {
      prind("GetStartedFormMainVm childrenCountVm.childrenCount.observe count= $count");
    });
    _onSubmit.observe(this, (success) async {
      if(success == true) {
        final signupData = _signup.data.value;
        if(signupData == null) {
          throw "`onSubmit` is success, but current signup data is null.";
        }
        var loginMsg = "";
        final fcmTokenRes = await _getFcmToken();
        if(fcmTokenRes is Success<String>) {
          final loginData = signupData.toLoginData(fcmToken: fcmTokenRes.data,);
          final loginRes = await _login.call(loginData);
          prind("GetStartedFormMainVm loginRes= $loginRes");
          if(loginRes is Success<SessionData>) {
            final configRes = await _initConfig();
            prind("GetStartedFormMainVm configRes= $configRes");
            if(configRes is Success<bool>) {
              // After login & config, persist HPL (if provided during registration) using real usecase.
              final hpl = _saveMotherHplForChild.data.value;
              if(hpl != null) {
                final motherNik = _saveMotherData.data.value?.nik; // mother form collected nik
                if(motherNik != null && motherNik.isNotEmpty) {
                  final hplRes = await HomeUseCaseDi.obj.saveMotherHpl(
                    date: hpl,
                    motherNik: motherNik,
                  );
                  if(hplRes is Fail<bool>) {
                    prine('Failed saving mother HPL post-signup: ' + (hplRes.msg ?? ''));
                  }
                } else {
                  prinw('HPL provided but mother NIK missing; skip saving HPL');
                }
              }
              _onLogin.value = configRes.data;
              return;
            } else {
              loginMsg = "Can't login to server";
            }
          }
        } else {
          loginMsg = "Can't get FCM token from local";
        }
        prine("Error when login; e= $loginMsg");
        _onLogin.value = false;
      }
    });
  }
  final SignUpAndRegisterOtherData _signUpAndRegisterOtherData;
  final GetFcmToken _getFcmToken;
  final Login _login;
  final InitConfig _initConfig;
  //final SaveMotherHpl _saveMotherHpl;

  final _GetMotherNikDummy _getMotherNikDummy = _GetMotherNikDummy();
  final _GetCurrentEmailDummy _getCurrentEmailDummy = _GetCurrentEmailDummy();

  final _SignupImpl _signup = _SignupImpl();
  final _SaveChildrenDataImpl _saveChildrenData = _SaveChildrenDataImpl();
  final _SaveFatherDataImpl _saveFatherData = _SaveFatherDataImpl();
  final _SaveMotherDataImpl _saveMotherData = _SaveMotherDataImpl();
  final _SaveMotherHplImpl _saveMotherHplForChild = _SaveMotherHplImpl();
  //final _SaveLastChildBirthDateImpl _saveLastChildBirthDate = _SaveLastChildBirthDateImpl();
  final _SaveChildrenCountImpl _saveChildrenCount = _SaveChildrenCountImpl();
  final _DeleteCurrentMotherHplImpl _deleteCurrentMotherHpl = _DeleteCurrentMotherHplImpl();

  late final SignUpFormVm signUpFormVm;
  late final MotherFormVm motherVm;
  late final FatherFormVm fatherVm;
  late final ChildFormVm childVm;
  late final DoMotherHavePregnancyVm doMotherHavePregnancyVm;
  late final MotherHplVm motherHplVm;
  late final ChildrenCountVm childrenCountVm;

  final MutableLiveData<bool> _onSubmit = MutableLiveData();
  LiveData<bool> get onSubmit => _onSubmit;

  final MutableLiveData<bool> _onLogin = MutableLiveData();
  LiveData<bool> get onLogin => _onLogin;

  @override
  List<LiveData> get liveDatas => [
    _signup.data,
    _saveMotherData.data,
    _saveFatherData.data,
    _saveChildrenData.data,
    _saveMotherHplForChild.data,
    _onSubmit,
    _onLogin,
  ];


  Future<void> sendData() {
    prind("sendData()");
    return startJob(sendDataKey, (isActive) async {
      final signup = _signup.data.value;

      final isMotherPresent = motherVm.isDataPresent.value != false;
      var mother = isMotherPresent ? _saveMotherData.data.value : null;

      final isFatherPresent = fatherVm.isDataPresent.value != false;
      var father = isFatherPresent ? _saveFatherData.data.value : null;

  final children = _saveChildrenData.data.value; // List<ChildEntity>
      prind("sendData() Current data (signup=$signup), (mother=$mother), (father=$father), (children=$children)");

      if(signup == null || /*mother == null || father == null ||*/ children == null) {
        throw "`signup` and `child` are both non-nullable.\n Current data (signup=$signup), (children=$children)";
      }
      if(father == null && isFatherPresent) {
        throw "`father` is null and not nullable";
      }
      if(mother == null && isMotherPresent) {
        throw "`mother` is null and not nullable";
      }
      final res1 = await _signUpAndRegisterOtherData(
        signup: signup,
        mother: mother,
        father: father,
  children: children,
        motherHpl: _saveMotherHplForChild.data.value,
      );
      prind("sendData() res1= $res1");

      _onSubmit.value = res1 is Success<bool>;
      if(res1 is Fail<bool>) {
        return res1;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    signUpFormVm.dispose();
    motherVm.dispose();
    fatherVm.dispose();
    childVm.dispose();
    motherHplVm.dispose();
  }
}


/// 'Cause in this context (signup), email isn't needed.
class _GetCurrentEmailDummy with GetCurrentEmail {
  @override
  Future<Result<String>> call() async => Success("<dummy>");
}

class _GetMotherNikDummy with GetMotherNik {
  @override
  Future<Result<String>> call() async => Success("<dummy>");
}

class _SignupImpl with SaveSignUpData {
  final MutableLiveData<SignUpData> _data = MutableLiveData();
  LiveData<SignUpData> get data => _data;

  @override
  Future<Result<bool>> call(SignUpData data) async {
    prind("_SignupImpl.call() data= $data");
    _data.value = data;
    return Success(true);
  }
}

class _SaveChildrenDataImpl with SaveChildrenData {
  final MutableLiveData<List<ChildEntity>> _data = MutableLiveData([]);
  LiveData<List<ChildEntity>> get data => _data;
  @override
  Future<Result<bool>> call({
    required List<ChildEntity> data,
    required String email,
    required int? pregnancyId,
  }) async {
    _data.value = data;
    return Success(true);
  }
}

class _SaveFatherDataImpl with SaveFatherData {
  final MutableLiveData<Father> _data = MutableLiveData();
  LiveData<Father> get data => _data;
  @override
  Future<Result<bool>> call(Father data) async {
    _data.value = data;
    return Success(true);
  }
}
class _GetFatherDataImpl with GetFatherData {
  @override
  Future<Result<Father>> call(ProfileCredential credential) {
    throw UnimplementedError("`_GetFatherDataImpl.call()` shouldn't be used");
  }
}

class _SaveMotherDataImpl with SaveMotherData {
  final MutableLiveData<Mother> _data = MutableLiveData();
  LiveData<Mother> get data => _data;
  @override
  Future<Result<bool>> call(Mother data) async {
    _data.value = data;
    return Success(true);
  }
}
class _GetMotherDataImpl with GetMotherData {
  @override
  Future<Result<Mother>> call(ProfileCredential credential) {
    throw UnimplementedError("`_GetMotherDataImpl.call()` shouldn't be used");
  }
}

class _GetChildDataImpl with GetChildData {
  @override
  Future<Result<ChildEntity>> call(ProfileCredential credential) {
    throw UnimplementedError("`_GetChildDataImpl.call()` shouldn't be used");
  }
}

class _GetCityByIdImpl with GetCityById {
  @override
  Future<Result<IdStringModel>> call(int id) {
    throw UnimplementedError("`_GetCityByIdImpl.call()` shouldn't be used");
  }
}

class _SaveMotherHplImpl with SaveMotherHpl {
  final MutableLiveData<DateTime> _data = MutableLiveData();
  LiveData<DateTime> get data => _data;
  @override
  Future<Result<bool>> call({
    required DateTime date,
    required String motherNik,
  }) async {
    _data.value = date;
    return Success(true);
  }
}

class _SaveChildrenCountImpl with SaveChildrenCount {
  final MutableLiveData<int> _data = MutableLiveData();
  LiveData<int> get data => _data;
  @override
  Future<Result<bool>> call(int count) async {
    _data.value = count;
    return Success(true);
  }
}

class _DeleteCurrentMotherHplImpl with DeleteCurrentMotherHpl {
  @override
  Future<Result<bool>> call() async {
    return Success(true);
  }
}