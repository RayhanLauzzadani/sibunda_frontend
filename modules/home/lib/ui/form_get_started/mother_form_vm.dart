import 'package:common/arch/domain/dummy_form_field_data.dart';
import 'package:common/arch/domain/model/_model_template.dart';
import 'package:common/arch/domain/model/img_data.dart';
import 'package:common/arch/domain/model/mother.dart';
import 'package:common/arch/domain/model/profile_data.dart';
import 'package:common/arch/domain/usecase/data_usecase.dart';
import 'package:common/arch/domain/usecase/family_usecase.dart';
import 'package:common/arch/ui/model/form_data.dart';
import 'package:common/arch/ui/vm/form_vm.dart';
import 'package:common/arch/ui/vm/form_vm_group.dart';
import 'package:common/arch/ui/vm/vm_auth.dart';
import 'package:common/res/string/_string.dart';
import 'package:common/util/data_mapper.dart';
import 'package:common/value/const_values.dart';
import 'package:core/domain/model/result.dart';
import 'package:core/ui/base/live_data.dart';
import 'package:core/util/_consoles.dart';
import 'package:flutter/cupertino.dart';
import 'package:home/core/domain/usecase/form_get_started_usecase.dart';
import 'package:tuple/tuple.dart';


class MotherFormVm extends FormAuthVmGroup {
  static const getMotherDataKey = "getMotherData";

  MotherFormVm({
    BuildContext? context,
    required SaveMotherData saveMotherData,
  UpdateMotherData? updateMotherData,
    required GetMotherData getMotherData,
    required GetCityById getCityById,
  }):
    _saveMotherData = saveMotherData,
  _updateMotherData = updateMotherData,
    _getMotherData = getMotherData,
    _getCityById = getCityById, super(context: context,)
  {
    init();
    _motherData.observe(this, (data) async {
      if(data != null) {
        final map = data.toJson;
        final cityRes = await _getCityById(map[Const.KEY_BIRTH_PLACE]);
        if(cityRes is Success<IdStringModel>) {
          final data = cityRes.data;
          map[Const.KEY_BIRTH_PLACE] = data;
        } else {
          doOnFailTask(getMotherDataKey, cityRes as Fail);
          return;
        }
        patchResponse([map]);
      } else {
        resetResponses();
      }
    }, tag: toString());
  }
  final SaveMotherData _saveMotherData;
  final UpdateMotherData? _updateMotherData;
  final GetMotherData _getMotherData;
  final GetCityById _getCityById;

  final imgProfile = MutableLiveData<ImgData>();
  final isDataPresent = MutableLiveData<bool>();
  final _motherData = MutableLiveData<Mother>();

  ProfileCredential? _credential;
  bool _isEdit = false;
  Mother? _originalData;

  @override
  List<LiveData> get liveDatas => [imgProfile, isDataPresent, _motherData];

  @override
  Set<String>? get mappedKey => {
    Const.KEY_BIRTH_PLACE,
    Const.KEY_BIRTH_DATE,
  };
  @override
  mapResponse(int groupPosition, String key, response) {
    switch(key) {
      case Const.KEY_BIRTH_PLACE:
        if(response is IdStringModel) {
          return response.id;
        }
        throw "Expected type of response with `key` of '$key' is `IdStringModel`";
      case Const.KEY_BIRTH_DATE:
        if(response is DateTime) {
          return response.toString();
        }
        throw "Expected type of response with `key` of '$key' is `DateTime`";
    }
    return super.mapResponse(groupPosition, key, response);
  }

  @override
  Future<Result<String>> doSubmitJob() async {
    final txtMap = getResponseMap();
    prind("MotherFormVm txtMap = $txtMap");
    if(_isEdit && _credential != null && _updateMotherData != null) {
      final diff = <String, dynamic>{};
      final newMap = Map<String,dynamic>.from(txtMap);
      final old = _originalData?.toJson;
      newMap.forEach((k,v) { if(v != null && (old == null || old[k] != v)) diff[k] = v; });
      if(diff.isEmpty) return Success("no_changes");
      final body = <String,dynamic>{};
      void put(String backendKey, String frontKey){ if(diff.containsKey(frontKey)) body[backendKey] = diff[frontKey]; }
      put('nama', Const.KEY_NAME_INDO); put('nama', Const.KEY_NAME);
      put('nik', Const.KEY_NIK);
      put('gol_darah', Const.KEY_BLOOD_TYPE);
      put('tempat_lahir', Const.KEY_BIRTH_PLACE);
      put('tanggal_lahir', Const.KEY_BIRTH_DATE);
      put('pendidikan','pendidikan');
      put('pekerjaan','pekerjaan');
      put('alamat_rumah','alamat_rumah');
      put('telp','telp');
      put('no_jkn', Const.KEY_JKN);
      put('pembiayaan','pembiayaan');
      put('faskes_tk1','faskes_tk1');
      put('faskes_rujukan','faskes_rujukan');
      put('puskesmas_domisili','puskesmas_domisili');
      put('nomor_register_kohort_ibu','nomor_register_kohort_ibu');
      if(body['tanggal_lahir'] is String && (body['tanggal_lahir'] as String).length >= 10) {
        body['tanggal_lahir'] = (body['tanggal_lahir'] as String).substring(0,10);
      }
      final res = await _updateMotherData!(id: _credential!.id, body: body);
      if(res is Success<bool>) {
        // Optimistic local refresh: apply changed fields to current LiveData so UI updates immediately.
        if(_motherData.value != null) {
          final curr = _motherData.value!;
          final json = curr.toJson;
          body.forEach((k,v) { json[k] = v; });
          final patched = Mother.fromJson(json);
          _motherData.value = patched;
          _originalData = patched;
        }
        return Success("");
      }
      final f = res as Fail<bool>; return Fail<String>(code: f.code, msg: f.msg, error: f.error, stack: f.stack);
    } else {
      final data = Mother.fromJson(txtMap);
      return await _saveMotherData(data).then<Result<String>>((value) => value is Success ? Success("") : value as Fail<String>);
    }
  }

  @override
  Future<List<FormUiGroupData>> getFieldGroupList() async => formDataListToUi(motherFormData);

  @override
  String getResponseStringRepr(int groupPosition, String inputKey, response) {
    if(groupPosition == 0) {
      switch(inputKey) {
        case Const.KEY_BIRTH_PLACE: return (response as IdStringModel?)?.name ?? "";
      }
    }
    return super.getResponseStringRepr(groupPosition, inputKey, response);
  }

  void getMotherData({
    required ProfileCredential? credential,
    bool forceLoad = false,
  }) {
    if(!forceLoad && credential == _credential) return;
    if(credential == null) {
      _credential = null;
      return;
    }
    startJob(getMotherDataKey, (isActive) async {
      final res = await _getMotherData(credential);
      if(res is Success<Mother>) {
        _motherData.value = res.data;
        _credential = credential;
  _originalData = res.data;
  _isEdit = true;
      } else {
        return res as Fail;
      }
    });
  }
}