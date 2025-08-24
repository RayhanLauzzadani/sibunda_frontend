import 'package:home/core/domain/usecase/_auth_usecase.dart';
import 'package:common/arch/di/repo_di.dart';
import 'package:home/core/domain/usecase/form_get_started_usecase.dart';
import 'package:home/core/domain/usecase/home_page_use_case.dart';
import 'package:home/core/domain/usecase/notif_and_message_use_case.dart';


class HomeUseCaseDi {
  HomeUseCaseDi._();
  static HomeUseCaseDiObj obj = HomeUseCaseDiObjImpl();
}

abstract class HomeUseCaseDiObj {
  SignUpAndRegisterOtherData get signUpAndRegister;
  SaveSignUpData get signUp;
  Login get login;
  //Logout get logout => LogoutImpl(RepoDi.authRepo);
  SaveMotherData get saveMotherData;
  SaveFatherData get saveFatherData;
  UpdateMotherData get updateMotherData;
  UpdateFatherData get updateFatherData;
  //SaveChildData get saveChildData => SaveChildDataImpl(RepoDi.childRepo);
  SaveChildrenData get saveChildrenData;
  UpdateChildData get updateChildData;
  SaveMotherHpl get saveMotherHpl;
  DeleteCurrentMotherHpl get deleteCurrentMotherHpl;
  //SaveLastChildBirthDate get saveLastChildBirthDate => SaveLastChildBirthDateImpl(RepoDi.childRepo);
  SaveChildrenCount get saveChildrenCount;

  GetHomeStatusList get getHomeStatusList;
  GetHomeMenuList get getHomeMenuList;
  GetHomeTipsList get getHomeTipsList;

  GetNotifList get getNotifList;
  GetMessageList get getMessageList;
}
class HomeUseCaseDiObjImpl extends HomeUseCaseDiObj {
  @override
  SignUpAndRegisterOtherData get signUpAndRegister => SignUpAndRegisterOtherDataImpl(RepoDi.obj.authRepo);
  @override
  SaveSignUpData get signUp => SaveSignUpDataImpl(RepoDi.obj.authRepo);
  @override
  Login get login => LoginImpl(RepoDi.obj.authRepo);
  //Logout get logout => LogoutImpl(RepoDi.authRepo);
  @override
  SaveMotherData get saveMotherData => SaveMotherDataImpl(RepoDi.obj.motherRepo);
  @override
  SaveFatherData get saveFatherData => SaveFatherDataImpl(RepoDi.obj.fatherRepo);
  @override
  UpdateMotherData get updateMotherData => UpdateMotherDataImpl(RepoDi.obj.motherRepo);
  @override
  UpdateFatherData get updateFatherData => UpdateFatherDataImpl(RepoDi.obj.fatherRepo);
  //SaveChildData get saveChildData => SaveChildDataImpl(RepoDi.childRepo);
  @override
  SaveChildrenData get saveChildrenData => SaveChildrenDataImpl(RepoDi.obj.childRepo);
  @override
  UpdateChildData get updateChildData => UpdateChildDataImpl(RepoDi.obj.childRepo);
  @override
  SaveMotherHpl get saveMotherHpl => SaveMotherHplImpl(RepoDi.obj.motherRepo);
  @override
  DeleteCurrentMotherHpl get deleteCurrentMotherHpl => DeleteCurrentMotherHplImpl(RepoDi.obj.motherRepo);
  //SaveLastChildBirthDate get saveLastChildBirthDate => SaveLastChildBirthDateImpl(RepoDi.childRepo);
  @override
  SaveChildrenCount get saveChildrenCount => SaveChildrenCountImpl(RepoDi.obj.childRepo);

  GetHomeStatusList get getHomeStatusList => GetHomeStatusListImpl(RepoDi.obj.homeStatusRepo);
  GetHomeMenuList get getHomeMenuList => GetHomeMenuListImpl(RepoDi.obj.homeMenuRepo);
  GetHomeTipsList get getHomeTipsList => GetHomeTipsListImpl(RepoDi.obj.educationRepo);

  GetNotifList get getNotifList => GetNotifListImpl(RepoDi.obj.notifRepo);
  GetMessageList get getMessageList => GetMessageListImpl(RepoDi.obj.notifRepo);
}