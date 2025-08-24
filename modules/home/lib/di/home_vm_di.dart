import 'package:common/arch/di/usecase_di.dart';
import 'package:common/arch/domain/model/profile_data.dart';
import 'package:core/ui/base/live_data.dart';
import 'package:flutter/material.dart';
import 'package:home/core/di/home_usecase_di.dart';
import 'package:home/ui/form_get_started/child_form_vm.dart';
import 'package:home/ui/form_get_started/children_count_vm.dart';
import 'package:home/ui/form_get_started/do_mother_have_pregnancy_vm.dart';
import 'package:home/ui/form_get_started/father_form_vm.dart';
import 'package:home/ui/form_get_started/get_started_form_main_vm.dart';
import 'package:home/ui/form_get_started/mother_form_vm.dart';
import 'package:home/ui/form_get_started/mother_hpl_vm.dart';
import 'package:home/ui/home/home_vm.dart';
import 'package:home/ui/home/notif_and_message_vm.dart';
import 'package:home/ui/login/login_vm.dart';
import 'package:home/ui/signup/sign_up_vm.dart';
import 'package:home/ui/splash/splash_vm.dart';


class HomeVmDi {
  HomeVmDi._();

  static HomeVmDiObj obj = HomeVmDiObjImpl();
}


abstract class HomeVmDiObj {
  SplashVm get splashVm;
  GetStartedFormMainVm getStartedFormMainVm({
    BuildContext? context,
  });
  SignUpFormVm get signUpFormVm;
  LoginFormVm get loginFormVm;
  MotherFormVm motherFormVm({
    BuildContext? context,
  });
  FatherFormVm fatherFormVm({
    BuildContext? context,
  });
  MotherHplVm motherHplVm({
    BuildContext? context,
  });
  DoMotherHavePregnancyVm get doMotherHavePregnancyVm;
  ChildrenCountVm get childrenCountVm;
  ChildFormVm childFormVm({
    BuildContext? context,
    LiveData<int>? childCount,
    ProfileCredential? pregnancyId,
  });
  HomeVm homeVm({BuildContext? context,});
  NotifAndMessageVm notifAndMessageVm({BuildContext? context,});
}

class HomeVmDiObjImpl extends HomeVmDiObj {
  @override
  SplashVm get splashVm => SplashVm(
    getCityList: UseCaseDi.obj.getCityList,
    isLoggedInUseCase: UseCaseDi.obj.isLoggedIn,
    initConfig: UseCaseDi.obj.initConfig,
  );
  @override
  GetStartedFormMainVm getStartedFormMainVm({
    BuildContext? context,
  }) => GetStartedFormMainVm(
    context: context,
    getFcmToken: UseCaseDi.obj.getFcmToken,
    signUpAndRegisterOtherData: HomeUseCaseDi.obj.signUpAndRegister,
    login: HomeUseCaseDi.obj.login,
    initConfig: UseCaseDi.obj.initConfig,
    //saveMotherHpl: HomeUseCaseDi.saveMotherHpl,
  );
  @override
  SignUpFormVm get signUpFormVm => SignUpFormVm(
    saveSignupData: HomeUseCaseDi.obj.signUp,
    checkEmailAvailability: UseCaseDi.obj.checkEmailAvailability,
  );
  @override
  LoginFormVm get loginFormVm => LoginFormVm(
    login: HomeUseCaseDi.obj.login,
    getFcmToken: UseCaseDi.obj.getFcmToken,
  );
  @override
  MotherFormVm motherFormVm({
    BuildContext? context,
  }) => MotherFormVm(
    context: context,
    saveMotherData: HomeUseCaseDi.obj.saveMotherData,
  updateMotherData: HomeUseCaseDi.obj.updateMotherData,
    getMotherData: UseCaseDi.obj.getMotherData,
    getCityById: UseCaseDi.obj.getCityById,
  );
  @override
  FatherFormVm fatherFormVm({
    BuildContext? context,
  }) => FatherFormVm(
    context: context,
    saveFatherData: HomeUseCaseDi.obj.saveFatherData,
  updateFatherData: HomeUseCaseDi.obj.updateFatherData,
    getFatherData: UseCaseDi.obj.getFatherData,
    getCityById: UseCaseDi.obj.getCityById,
  );
  @override
  MotherHplVm motherHplVm({
    BuildContext? context,
  }) => MotherHplVm(
    context: context,
    getMotherNik: UseCaseDi.obj.getMotherNik,
    //saveMotherPregnancy: UseCaseDi.saveMotherPregnancy,
    saveMotherHpl: HomeUseCaseDi.obj.saveMotherHpl,
  );
  @override
  DoMotherHavePregnancyVm get doMotherHavePregnancyVm => DoMotherHavePregnancyVm(
    deleteCurrentMotherHpl: HomeUseCaseDi.obj.deleteCurrentMotherHpl,
  );
  @override
  ChildrenCountVm get childrenCountVm => ChildrenCountVm(
    //saveLastChildBirthDate: HomeUseCaseDi.saveLastChildBirthDate,
    saveChildrenCount: HomeUseCaseDi.obj.saveChildrenCount,
  );
  @override
  ChildFormVm childFormVm({
    BuildContext? context,
    LiveData<int>? childCount,
    ProfileCredential? pregnancyId,
  }) => ChildFormVm(
    context: context,
    pregnancyId: pregnancyId,
    getCurrentEmail: UseCaseDi.obj.getCurrentEmail,
    childCount: childCount ?? MutableLiveData(1),
    saveChildrenData: HomeUseCaseDi.obj.saveChildrenData,
  updateChildData: HomeUseCaseDi.obj.updateChildData,
    getChildData: UseCaseDi.obj.getChildData,
    getCityById: UseCaseDi.obj.getCityById,
  );
  @override
  HomeVm homeVm({BuildContext? context,}) => HomeVm(
    context: context,
    getHomeMenuList: HomeUseCaseDi.obj.getHomeMenuList,
    getHomeStatusList: HomeUseCaseDi.obj.getHomeStatusList,
    getHomeTipsList: HomeUseCaseDi.obj.getHomeTipsList,
    getMotherNik: UseCaseDi.obj.getMotherNik,
    getCurrentEmail: UseCaseDi.obj.getCurrentEmail,
    getProfile: UseCaseDi.obj.getProfile,
  );
  @override
  NotifAndMessageVm notifAndMessageVm({BuildContext? context,}) => NotifAndMessageVm(
    context: context,
    getCurrentEmail: UseCaseDi.obj.getCurrentEmail,
    getMessageList: HomeUseCaseDi.obj.getMessageList,
    getNotifList: HomeUseCaseDi.obj.getNotifList,
  );
}