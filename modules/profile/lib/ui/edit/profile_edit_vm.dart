import 'dart:async';

import 'package:common/arch/domain/dummy_data.dart';
import 'package:common/arch/domain/dummy_form_field_data.dart';
import 'package:common/arch/domain/model/img_data.dart';
import 'package:common/arch/domain/model/profile_data.dart';
import 'package:common/arch/domain/repo/profile_repo.dart';
import 'package:common/arch/domain/usecase/auth_usecase.dart';
import 'package:common/arch/ui/model/form_data.dart';
import 'package:common/arch/ui/vm/form_vm_group.dart';
import 'package:common/arch/ui/vm/vm_auth.dart';
import 'package:common/res/string/_string.dart';
import 'package:common/util/data_mapper.dart';
import 'package:common/util/validators.dart';
import 'package:common/value/const_values.dart';
import 'package:core/domain/model/result.dart';
import 'package:core/ui/base/live_data.dart';
import 'package:core/util/_consoles.dart';
import 'package:flutter/material.dart';
import 'package:profile/core/domain/usecase/profile_edit_usecase.dart';
import 'package:email_validator/email_validator.dart';

class ProfileEditVm extends FormAuthVmGroup {
  ProfileEditVm({
    BuildContext? context,
    required SaveProfile saveProfile,
    required CheckEmailAvailability checkEmailAvailability,
  }):
    _saveProfile = saveProfile,
    _checkEmailAvailability = checkEmailAvailability, super(context: context)
  {
    isFormReady.observe(this, (isReady) {
      if(isReady == true) {
        /*
        getResponseLiveDataWithKey(Const.KEY_NAME).observe(this, (final name) {
          checkIsEdited();
        });
         */
        getResponseLiveDataWithKey(Const.KEY_EMAIL).observe(this, (final email) {
          prind("ProfileEditVm getResponseLiveDataWithKey.observe() email= $email _currentEmail= $_currentEmail");
          _emailCheckTimer?.cancel();
          //checkIsEdited();
          if(email == _currentTypedEmail) {
            return;
          }
          _isEmailAvailable.value = false;
          setFieldValidity(0, Const.KEY_EMAIL, false);
          if(email == _currentEmail) { // it means the email doesn't change.
            _isEmailAvailable.value = true;
            setFieldValidity(0, Const.KEY_EMAIL, true);
            return;
          }
          if(email != null) {
            if(!EmailValidator.validate(email)) {
              _isEmailAvailable.value = false;
              return;
            }
            _isEmailAvailable.value = null;
            _emailCheckTimer = Timer(Duration(milliseconds: 2500), () async {
              final res = await _checkEmailAvailability(email!);
              if(res is Success<bool>) {
                _isEmailAvailable.value = res.data;
              } else {
                _isEmailAvailable.value = null; // it means error while checking
              }
              //setResponse(0, Const.KEY_EMAIL, email);
            });
          }
          _currentTypedEmail = email;
        }, distinctUntilChanged: true,);
      }
    }, tag: toString());
    _isEmailAvailable.observe(this, (available) {
      setFieldValidity(0, Const.KEY_EMAIL, available == true);
    });
    _oldPswdCode.observe(this, (code) {
      setFieldValidity(0, Const.KEY_OLD_PSWD, code == Const.CODE_OK);
    });
  }

  final SaveProfile _saveProfile;
  final CheckEmailAvailability _checkEmailAvailability;

  LiveData? _oldPswd;
  LiveData? _newPswd;
  LiveData? _newPswdRe;

  Timer? _emailCheckTimer;

  final MutableLiveData<bool> _isEmailAvailable = MutableLiveData(false);
  LiveData<bool> get isEmailAvailable => _isEmailAvailable;

  final MutableLiveData<int> _oldPswdCode = MutableLiveData();
  LiveData<int> get oldPswdCode => _oldPswdCode;

  final imgProfile = MutableLiveData<ImgData>();

  String? _currentEmail;
  String? _currentName;

  String? _currentTypedEmail;
  bool _isCurrentlyEdited = false;
  bool get isCurrentlyEdited => _isCurrentlyEdited;

  @override
  List<LiveData> get liveDatas {
    final list = <LiveData>[imgProfile, _isEmailAvailable, _oldPswdCode,];
    if(_oldPswd != null) {
      list.add(_oldPswd!);
    }
    if(_newPswd != null) {
      list.add(_newPswd!);
    }
    if(_newPswdRe != null) {
      list.add(_newPswdRe!);
    }
    return list;
  }

  @override
  void dispose() {
    _emailCheckTimer?.cancel();
    super.dispose();
  }

  @override
  Future<List<FormUiGroupData>> getFieldGroupList() async => formDataListToUi(editFormData);

  @override
  Future<Result<String>> doSubmitJob() async {
    if(!checkIsEdited()) {
      return Success("unedited");
    }
    final respMap = getResponse().responseGroups.values.first;
    final data = AccountData(
      name: respMap[Const.KEY_NAME],
      email: respMap[Const.KEY_EMAIL],
      pswd: respMap[Const.KEY_PSWD],
      img: dummyImg, //TODO: img edit profile msh dummy.
    );
    final String? oldPswd = respMap[Const.KEY_OLD_PSWD];
    final res = await _saveProfile(data, oldPswd);
    if(res is Success<bool>) {
      _oldPswdCode.value = Const.CODE_OK;
      _currentName = data.name;
      _currentEmail = data.email;
      _isCurrentlyEdited = false;
      return Success("ok");
    } else {
      _oldPswdCode.value = res is Fail<bool> ? res.code : Const.CODE_NOT_OK;
      String? failMsg;
      if(res is Fail) {
        // ignore: invalid_use_of_protected_member
        failMsg = (res as dynamic).msg ?? "Gagal menyimpan perubahan profil";
      } else {
        failMsg = "Gagal menyimpan perubahan profil";
      }
      return Fail<String>(msg: failMsg);
    }
  }

  @override
  void onReady() {
    final list = responseGroupList.first;
    (list[Const.KEY_OLD_PSWD]!.isValid as MutableLiveData).value = true;
    (_newPswd = list[Const.KEY_PSWD]!.isValid as MutableLiveData).value = true;
    (_newPswdRe = list[Const.KEY_RE_PSWD]!.isValid as MutableLiveData).value = true;
  }

  @override
  void preValidateField(int groupPosition, String inputKey, response) {
    if(inputKey == Const.KEY_EMAIL) {
      if(response != _currentTypedEmail) {
        _isEmailAvailable.value = false;
      }
    }
  }
  @override
  Future<bool> validateField(int groupPosition, String inputKey, response) async {
    prind("ProfileEditVm.validateField() groupPosition= $groupPosition inputKey= $inputKey response= $response _isEmailAvailable= $_isEmailAvailable _currentEmail= $_currentEmail");
    if((inputKey == Const.KEY_OLD_PSWD
    || inputKey == Const.KEY_PSWD
    || inputKey == Const.KEY_RE_PSWD)
    && _oldPswd == null
    ) {
      final list = responseGroupList.first;
      _oldPswd = list[Const.KEY_OLD_PSWD]!.response;
      _newPswd = list[Const.KEY_PSWD]!.response;
      _newPswdRe = list[Const.KEY_RE_PSWD]!.response;
    }
    switch(inputKey) {
      case Const.KEY_EMAIL:
        return (_currentEmail != null && response == _currentEmail)
           || _isEmailAvailable.value == true && EmailValidator.validate(response);
      case Const.KEY_OLD_PSWD:
        return (_newPswd!.value?.isNotEmpty != true && _newPswdRe!.value?.isNotEmpty != true)
            || response.isNotEmpty;
      case Const.KEY_PSWD:
        return _oldPswd!.value?.isNotEmpty != true
            || validatePswd(_newPswd!.value);
      case Const.KEY_RE_PSWD:
        return _oldPswd!.value?.isNotEmpty != true
            || validatePswdRe(_newPswdRe!.value, _newPswd!.value);
    }
    return (response as String).isNotEmpty;
  }

  @override
  String getInvalidMsg(String inputKey, response) {
    switch(inputKey) {
      case Const.KEY_EMAIL:
        if(!EmailValidator.validate(response)) {
          return Strings.please_type_correct_email;
        }
        if(_isEmailAvailable.value != true) {
          if(_isEmailAvailable.value == false) {
            return Strings.email_already_exists;
          } else {
            return Strings.still_checking_email_availability;
          }
        }
        return Strings.please_type_correct_email;
      case Const.KEY_OLD_PSWD:
        if(_oldPswdCode.value == ProfileRepo.CODE_PSWD_MISMATCH) return Strings.old_pswd_not_match;
        if(_oldPswdCode.value == Const.CODE_NOT_OK) return Strings.cant_check_old_pswd;
        return Strings.password_at_least_8;
      case Const.KEY_PSWD: return Strings.password_at_least_8;
      case Const.KEY_RE_PSWD: return Strings.password_re_does_not_match;
    }
    return defaultInvalidMsg;
  }

  void setProfile(Profile data) {
    final list = responseGroupList.first as Map<String, MutableFormVmResponse>;
    list[Const.KEY_NAME]!.response.value = _currentName = data.name;
    list[Const.KEY_EMAIL]!.response.value = _currentEmail = data.email;
    _isCurrentlyEdited = false;
  }

  bool checkIsEdited() {
    final isNameSame = _currentName == getResponseWithKey(Const.KEY_NAME);
    final isEmailSame = _currentEmail == getResponseWithKey(Const.KEY_EMAIL);
    return _isCurrentlyEdited =
        !isNameSame || !isEmailSame
      || _oldPswd?.value?.isNotEmpty == true
      || _newPswd?.value?.isNotEmpty == true
      || _newPswdRe?.value?.isNotEmpty == true
    ;
  }
}