import 'package:common/arch/domain/model/profile_data.dart';
import 'package:common/arch/domain/usecase/profile_usecase.dart';
import 'package:common/arch/ui/vm/vm_auth.dart';
import 'package:core/domain/model/result.dart';
import 'package:core/ui/base/live_data.dart';
import 'package:flutter/cupertino.dart';

class EditFamilyHomeVm extends AsyncAuthVm {
  static const getFamilyDataKey = "getFamilyData";

  EditFamilyHomeVm({
    BuildContext? context,
    required GetFamilyProfile getFamilyProfile,
    required GetCurrentEmail getCurrentEmail,
  }):
      _getFamilyProfile = getFamilyProfile,
      _getCurrentEmail = getCurrentEmail,
      super(context: context,)
  ;

  final GetFamilyProfile _getFamilyProfile;
  final GetCurrentEmail _getCurrentEmail;

  final _familyDataList = MutableLiveData<List<Profile>>();
  LiveData<List<Profile>> get familyDataList => _familyDataList;

  @override
  List<LiveData> get liveDatas => [_familyDataList];

  void getFamilyData({ bool forceLoad = false }) {
    if(!forceLoad && _familyDataList.value != null) return;
    startJob(getFamilyDataKey, (isActive) async {
      final emailRes = await _getCurrentEmail();
      if(emailRes is Success<String>) {
        final email = emailRes.data;
        final res = await _getFamilyProfile(email);
        if(res is Success<List<Profile>>) {
          final data = res.data;
          _familyDataList.value = data;
        } else {
          return res as Fail;
        }
      } else {
        return emailRes as Fail;
      }
    });
  }

  /// Update an existing child profile object locally after edit (so UI refresh tanpa logout).
  void patchChildProfileLocally({required int id, String? newName, DateTime? newBirthDate}) {
    final current = _familyDataList.value;
    if(current == null) return;
    bool changed = false;
    final updated = current.map((p){
      if(p.id == id) {
        var np = p;
        if(newName != null && newName.isNotEmpty && newName != p.name) {
          np = np.copyWithNewName(newName);
          changed = true;
        }
        if(newBirthDate != null && newBirthDate != p.birthDate) {
          np = np.copyWithNewBirthDate(newBirthDate);
          changed = true;
        }
        return np;
      }
      return p;
    }).toList(growable: false);
    if(changed) {
      _familyDataList.value = updated;
    }
  }
}