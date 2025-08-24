import 'package:common/arch/domain/dummy_form_field_data.dart';
import 'package:common/arch/domain/model/_model_template.dart';
import 'package:common/arch/domain/model/child.dart';
import 'package:common/arch/domain/model/img_data.dart';
import 'package:common/arch/domain/model/profile_data.dart';
import 'package:common/arch/domain/usecase/data_usecase.dart';
import 'package:common/arch/domain/usecase/family_usecase.dart';
import 'package:common/arch/domain/usecase/profile_usecase.dart';
import 'package:common/arch/ui/model/form_data.dart';
import 'package:common/arch/ui/vm/form_vm.dart';
import 'package:common/arch/ui/vm/form_vm_group.dart';
import 'package:common/arch/ui/vm/vm_auth.dart';
import 'package:common/res/string/_string.dart';
import 'package:common/util/collections.dart';
import 'package:common/util/data_mapper.dart';
import 'package:common/util/type_util.dart';
import 'package:common/value/const_values.dart';
import 'package:core/domain/model/range.dart';
import 'package:core/domain/model/result.dart';
import 'package:core/ui/base/live_data.dart';
import 'package:core/util/_consoles.dart';
import 'package:flutter/cupertino.dart';
import 'package:home/core/domain/usecase/form_get_started_usecase.dart';
import 'package:tuple/tuple.dart';


class ChildFormVm extends FormAuthVmGroup {
  static const saveBatchChildrenKey = "saveBatchChildren";
  static const getChildDataKey = "getChildData";

  ChildFormVm({
    BuildContext? context,
    //required SaveChildData saveChildData,
    required SaveChildrenData saveChildrenData,
  UpdateChildData? updateChildData,
    required GetCurrentEmail getCurrentEmail,
    required GetChildData getChildData,
    required GetCityById getCityById,
    required this.childCount,
    required this.pregnancyId,
  }):
    //_saveChildData = saveChildData,
    _saveChildrenData = saveChildrenData,
  _updateChildData = updateChildData,
    _getCurrentEmail = getCurrentEmail,
    _getChildData = getChildData,
    _getCityById = getCityById, super(context: context)
  {
    _currentChild.observe(this, (data) async {
      if(data != null) {
        final map = data.toJson;
        map[Const.KEY_BIRTH_DATE] = parseDate(map[Const.KEY_BIRTH_DATE]);
        map[Const.KEY_JKN_START_DATE] = parseDate(map[Const.KEY_JKN_START_DATE]);
        final cityRes = await _getCityById(map[Const.KEY_BIRTH_PLACE]);
        if(cityRes is Success<IdStringModel>) {
          final data = cityRes.data;
          map[Const.KEY_BIRTH_PLACE] = data;
        } else {
          doOnFailTask(getChildDataKey, cityRes as Fail);
          return;
        }
        patchResponse([map]);
      } else {
        resetResponses();
      }
    }, tag: toString());
    _currentPage.observe(this, (page) {
      Map<String, dynamic>? map;
      if(page != null) {
        //await _saveCurrentResponses(saveIncompleteResponses: canProceed.value != true);
        final child = _children.value![page];
        if(child != null) {
          map = child.toJson;
          map[Const.KEY_BIRTH_PLACE] = _birthPlaces.value![page];
          map[Const.KEY_BIRTH_DATE] = parseDate(map[Const.KEY_BIRTH_DATE]);
          map[Const.KEY_JKN_START_DATE] = parseDate(map[Const.KEY_JKN_START_DATE]);
        } else {
          final incompleteResponses = _currentIncompleteResponses.value![page];
          if(incompleteResponses != null) {
            map = incompleteResponses;
          }
        }
      }
      prind("_currentPage.observe map= $map");
      resetResponses();
      if(map != null) {
        patchResponse([map]);
        //return;
      }
    }, distinctUntilChanged: true,);
    childCount.observe(this, (count) {
      if(count != null) {
        if(count < 0) {
          throw "Can't have negative `count`";
        }
        final childList = _children.value ??= [];
        final cityList = _birthPlaces.value ??= [];
        final incompleteResponses = _currentIncompleteResponses.value ??= [];
        setListSize(childList, count);
        setListSize(cityList, count);
        setListSize(incompleteResponses, count);
      }
    });
    if(childCount.value != null) {
      childCount.notifyObservers();
    }
    init();
  }
  //final SaveChildData _saveChildData; //Now, we use `SaveChildrenData` for batch saving
  final SaveChildrenData _saveChildrenData;
  final UpdateChildData? _updateChildData;
  final GetCurrentEmail _getCurrentEmail;
  final GetChildData _getChildData;
  final GetCityById _getCityById;

  int? _pageInParent;
  int? get pageInParent => _pageInParent;
  final LiveData<int> childCount;
  final ProfileCredential? pregnancyId;

  //void Function()? onActiveInParent;

  //TODO: <tag>ChildFromVM</tag>
  final MutableLiveData<int> _currentPage = MutableLiveData();
  LiveData<int> get currentPage => _currentPage;

  final MutableLiveData<List<Map<String, dynamic>?>> _currentIncompleteResponses = MutableLiveData();
  final MutableLiveData<List<Child?>> _children = MutableLiveData();
  final MutableLiveData<List<IdStringModel?>> _birthPlaces = MutableLiveData();

  final MutableLiveData<Child> _currentChild = MutableLiveData();
  // Helper snapshot getter used by UI after update.
  Child? get currentChildSnapshot => _currentChild.value;
  int? get currentCredentialId => _currentCredential?.id;

  final MutableLiveData<bool> _onSaveBatch = MutableLiveData(false);
  LiveData<bool> get onSaveBatch => _onSaveBatch;

  // Flag loading khusus proses update / simpan anak
  final MutableLiveData<bool> _isUpdatingChild = MutableLiveData(false);
  LiveData<bool> get isUpdatingChild => _isUpdatingChild;

  final imgProfile = MutableLiveData<ImgData>();

  /// True bila ada perubahan field dibanding data asli saat mode edit.
  bool get hasEditChanges {
    if(!_isEdit) return true; // for create mode always treat as changed when valid
    if(_originalChild == null) return false;
    try {
      final txtMap = getResponseMap();
      final old = _originalChild!.toJson;
      for(final e in txtMap.entries) {
        final k = e.key;
        final v = e.value;
        if(v != null && old[k] != v) return true;
      }
    } catch(_) {}
    return false;
  }

  //LiveData<List<Child>> get children => _children;

  ProfileCredential? _currentCredential;
  bool _isEdit = false;
  Child? _originalChild;

  @override
  List<LiveData> get liveDatas => [
    _currentPage, _children, _onSaveBatch, imgProfile,
  _currentChild, _isUpdatingChild,
  ];

  // Convenience single-fire observer
  void observeOnce<T>(LiveData<T> live, void Function(T? v) onData) {
    void Function(T?)? sub;
    sub = (v){
      onData(v);
      live.removeObserver(sub!);
    };
    live.observeForever(sub);
  }


  bool checkPageActiveInParent(int page, { bool force = false }) {
    if(childCount.value == null || childCount.value! <= 0) return false;
    if(force || _pageInParent == null) {
      _pageInParent = page;
    }
    return page == _pageInParent;
  }

  void initPage(int page, { bool force = false }) {
    prind("initPage page= $page _currentPage= $_currentPage force= $force");
    if(!force && page == _currentPage.value) return;
    //final currPage = _currentPage.value;
    if(_currentPage.value != null) {
      _saveCurrentResponses(saveIncompleteResponses: canProceed.value != true);
    }
    _currentPage.value = page;
  }

  @override
  Set<String>? get mappedKey => {
    Const.KEY_BIRTH_PLACE,
    Const.KEY_BIRTH_DATE,
    Const.KEY_JKN_START_DATE,
    Const.KEY_CHILD_ORDER,
  };
  @override
  mapResponse(int groupPosition, String key, response) {
    switch(key) {
      case Const.KEY_CHILD_ORDER:
        final i = tryParseInt(response);
        if(i != null) {
          return i;
        }
        throw "Can't parse `response` of '$response' to `int`";
      case Const.KEY_BIRTH_PLACE:
        if(response is IdStringModel) {
          return response.id;
        }
        throw "Expected type of response with `key` of '$key' is `IdStringModel`";
      case Const.KEY_JKN_START_DATE:
      case Const.KEY_BIRTH_DATE:
        if(response is DateTime) {
          return response.toString();
        }
        throw "Expected type of response with `key` of '$key' is `DateTime`";
    }
    return super.mapResponse(groupPosition, key, response);
  }

  @override
  Future<Result<String>> doSubmitJob() => _saveCurrentResponses(
    saveIncompleteResponses: false,
  );

  Future<Result<String>> _saveCurrentResponses({
    bool saveIncompleteResponses = false,
  }) async {
    prind("_saveCurrentResponses() _currentPage = $_currentPage saveIncompleteResponses= $saveIncompleteResponses");
    if(saveIncompleteResponses) {
      _currentIncompleteResponses.value![_currentPage.value!] = getRawResponseMap();
      return Success("ok");
    }
    try {
  final txtMap = getResponseMap();
  // Parse as raw (nullable) then map to entity to avoid crash on null fields
  final dataRaw = ChildRaw.fromJson(txtMap);
  final data = mapChildRaw(dataRaw);
  _children.value![_currentPage.value!] = dataRaw; // keep raw list for backward; entity could be stored elsewhere if needed
      _birthPlaces.value![_currentPage.value!] = responseGroupList[0][Const.KEY_BIRTH_PLACE]!.response.value as IdStringModel?;
      //final res = await _saveChildData(data, _currentPage.value!); //.then<Result<String>>((value) => );
      return Success("ok");
    } catch(e, stack) {
      prine(e);
      prine(stack);
      return Fail(msg: "Error submitting in `$runtimeType`", error: e);
    }
  }

  @override
  Future<List<FormUiGroupData>> getFieldGroupList() async => formDataListToUi(childFormData);

  @override
  String getResponseStringRepr(int groupPosition, String inputKey, response) {
    if(groupPosition == 0) {
      switch(inputKey) {
        case Const.KEY_BIRTH_PLACE: return (response as IdStringModel?)?.name ?? "";
      }
    }
    return super.getResponseStringRepr(groupPosition, inputKey, response);
  }

  @override
  Future<bool> validateField(int groupPosition, String inputKey, response) async {
    prind("ChildFormVm groupPosition= $groupPosition inputKey= $inputKey response= $response");
    switch(inputKey) {
      case Const.KEY_CHILD_ORDER:
        final input = tryParseInt(response); // != null;
        if(input == null) {
          return false;
        }
        return input <= 32000;
    }
    return super.validateField(groupPosition, inputKey, response);
  }

  @override
  String getInvalidMsg(String inputKey, response) {
    switch(inputKey) {
      case Const.KEY_CHILD_ORDER: return Strings.field_must_be_small_number;
    }
    return defaultInvalidMsg;
  }

  void saveBatchChildren() {
    prind("ChildFormVm.saveBatchChildren() pregnancyId= $pregnancyId");
    if(_isEdit && _currentCredential != null && _updateChildData != null) {
      try {
        final txtMap = getResponseMap();
        final diff = <String,dynamic>{};
        final old = _originalChild?.toJson;
        txtMap.forEach((k,v){ if(v != null && (old == null || old[k] != v)) diff[k]=v; });
  if(diff.isEmpty) { _onSaveBatch.value = true; return; }

        // Map frontend keys -> backend expected keys
        final body = <String,dynamic>{};
        void put(String backendKey, String frontKey){ if(diff.containsKey(frontKey)) body[backendKey] = diff[frontKey]; }
        put('nama', Const.KEY_NAME_INDO); // or KEY_NAME_INDO
        put('nama', Const.KEY_NAME); // fallback if form uses generic key
        put('anak_ke', Const.KEY_CHILD_ORDER);
        put('no_akte_kelahiran', Const.KEY_BIRTH_CERT_NO);
        put('nik', Const.KEY_NIK);
        put('gol_darah', Const.KEY_BLOOD_TYPE);
        put('tempat_lahir', Const.KEY_BIRTH_PLACE);
        put('tanggal_lahir', Const.KEY_BIRTH_DATE);
        put('no_jkn', Const.KEY_JKN);
        put('tanggal_berlaku_jkn', Const.KEY_JKN_START_DATE);
        put('no_kohort', Const.KEY_BABY_COHORT_REG);
        put('no_catatan_medik', Const.KEY_HOSPITAL_MEDIC_NO);
        // gender conversion
        String? g = diff[Const.KEY_BABY_GENDER] ?? diff[Const.KEY_GENDER];
        if(g != null) {
          g = g.toUpperCase();
          // Backend expects L / P
            if(g == 'M') g = 'L';
            else if(g == 'F') g = 'P';
          body['jenis_kelamin'] = g;
        }
        // Normalize dates to yyyy-MM-dd
        void norm(String k){
          final val = body[k];
          if(val is String && val.length >= 10) body[k] = val.substring(0,10);
        }
        norm('tanggal_lahir');
        norm('tanggal_berlaku_jkn');
        if(body.isEmpty) { _onSaveBatch.value = true; return; }
        _isUpdatingChild.value = true;
        startJob(saveBatchChildrenKey, (isActive) async {
          prind('[ChildFormVm] updateChild body=$body');
          final res = await _updateChildData!(id: _currentCredential!.id, body: body);
          if(res is Success<bool>) {
            _onSaveBatch.value = true;
            _isUpdatingChild.value = false;
            return null;
          }
          _isUpdatingChild.value = false;
          return res as Fail;
        });
        return;
      } catch(e, stack) { prine(e); prine(stack); _onSaveBatch.value = false; _isUpdatingChild.value = false; return; }
    }
    if(_currentPage.value != childCount.value! -1) {
      throw "`currentPage` is '${_currentPage.value}' and total children count (`pageCount`) is '$childCount'.\n"
            "There are still some `Child`s with no data.\n"
            "Thus, can't save batch all `Child`s";
    }
    if(_children.value!.any((e) => e == null)) {
      throw "`_children.value` can't have any null value";
    }
  _isUpdatingChild.value = true;
  startJob(saveBatchChildrenKey, (isActive) async {
      final emailRes = await _getCurrentEmail();
      Fail? fail;
      if(emailRes is Success<String>) {
        final email = emailRes.data;
        final rawList = _children.value!.map<ChildRaw>((e) => e!).toList(growable: false);
        final entityList = rawList.map(mapChildRaw).toList(growable: false);
        final res = await _saveChildrenData(
          data: entityList,
          email: email,
          pregnancyId: pregnancyId?.id,
        );
        if(res is Success<bool>) {
          _onSaveBatch.value = res.data;
      _isUpdatingChild.value = false;
      return null;
        }
        fail = (res as Fail<bool>);
      } else {
        fail = (emailRes as Fail<String>);
      }
    _isUpdatingChild.value = false;
    return fail;
    });
  }

  void getChildData({
    required ProfileCredential? credential,
    bool forceLoad = false,
  }) {
    if(!forceLoad && credential == _currentCredential) return;
    if(credential == null) {
      _currentCredential = null;
      return;
    }
    startJob(getChildDataKey, (isActive) async {
      final res = await _getChildData(credential);
      if(res is Success<ChildEntity>) {
        final ent = res.data;
        final raw = ChildRaw(
          name: ent.name,
          childOrder: ent.childOrder,
          gender: ent.gender,
          birthCertificateNo: ent.birthCertificateNo,
          nik: ent.nik,
          bloodType: ent.bloodType,
          birthCity: ent.birthCity,
          birthDate: ent.birthDate,
          jkn: ent.jkn,
          jknStartDate: ent.jknStartDate,
          babyCohortRegistNo: ent.babyCohortRegistNo,
          toddlerCohortRegistNo: ent.toddlerCohortRegistNo,
          hospitalMedicalNumber: ent.hospitalMedicalNumber,
        );
        _currentChild.value = raw;
        _currentCredential = credential;
  _originalChild = raw;
  _isEdit = true;
      } else {
        return res as Fail;
      }
    });
  }
}
