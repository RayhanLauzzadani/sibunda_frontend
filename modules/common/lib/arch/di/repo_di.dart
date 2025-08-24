import 'package:common/arch/di/api_di.dart';
import 'package:common/arch/di/data_source_di.dart';
import 'package:common/arch/di/db_di.dart';
import 'package:common/arch/di/usecase_di.dart';
import 'package:common/arch/domain/repo/_repos.dart';
import 'package:common/arch/domain/repo/bayiku_repo.dart';
import 'package:common/arch/domain/repo/chart_baby_repo.dart';
import 'package:common/arch/domain/repo/chart_mother_repo.dart';
import 'package:common/arch/domain/repo/covid_repo.dart';
import 'package:common/arch/domain/repo/data_repo.dart';
import 'package:common/arch/domain/repo/education_repo.dart';
import 'package:common/arch/domain/repo/firebase_repo.dart';
import 'package:common/arch/domain/repo/form_field_repo.dart';
import 'package:common/arch/domain/repo/form_warning_status_repo.dart';
import 'package:common/arch/domain/repo/immunization_repo.dart';
import 'package:common/arch/domain/repo/profile_repo.dart';
import 'package:common/util/_storage.dart';


class RepoDi {
  RepoDi._();

  static RepoDiObj obj = RepoDiObjImpl();
}


abstract class RepoDiObj {

  FirebaseRepo get firebaseRepo;

  DataRepo get dataRepo;

  AuthRepo get authRepo;

  ProfileRepo get profileRepo;
  HomeStatusRepo get homeStatusRepo;
  HomeMenuRepo get homeMenuRepo;
  //static TipsRepo get tipsRepo => TipsRepoDummy.obj;
  EducationRepo get educationRepo;
  NotifRepo get notifRepo;

  FormFieldRepo get formFieldRepo;

  //static FamilyRepo getFamilyRepo() => FamilyDummyRepo();
  MotherRepo get motherRepo;
  FatherRepo get fatherRepo;
  ChildRepo get childRepo;
  PregnancyRepo get pregnancyRepo;
  //static MotherFoodRecomRepo get foodRepo => MotherFoodRecomRepoDummy.obj;
  //static MotherHomeRepo get pregnancyRepo => MotherPregnancyRepoDummy.obj;
  //static PregnancyCheckRepo get pregnancyCheckRepo => PregnancyCheckRepoDummy.obj;
  //static FormWarningStatusRepo get formWarningStatusRepo => FormWarningStatusRepoDummy.obj;
  ImmunizationRepo get immunizationRepo;

  MyBabyRepo get myBabyRepo;

  CovidRepo get covidRepo;

  BabyChartRepo get babyChartRepo;
  MotherChartRepo get motherChartRepo;
}


class RepoDiObjImpl extends RepoDiObj {
  @override
  FirebaseRepo get firebaseRepo => FirebaseRepoImpl(
    sharedPref: Prefs.prefs,
  );

  @override
  DataRepo get dataRepo => DataRepoImpl(
    localSrc: LocalSrcDi.obj.dataSrc,
    api: ApiDi.obj.dataApi,
  );

  @override
  AuthRepo get authRepo => AuthRepoImpl(
    api: ApiDi.obj.authApi,
    //dataApi: ApiDi.obj.dataApi,
    dataApi: null,
    accountLocalSrc: LocalSrcDi.obj.accountSrc,
    pregnancyLocalSrc: LocalSrcDi.obj.pregnancySrc,
    checkUpLocalSrc: LocalSrcDi.obj.checkUpSrc,
  ); //AuthDummyRepo.obj; //

  @override
  ProfileRepo get profileRepo => ProfileRepoImpl(
    localSrc: LocalSrcDi.obj.accountSrc,
    dataApi: ApiDi.obj.dataApi,
  ); //ProfileRepoDummy.obj; //ProfileRepoImpl(localSrc: LocalSrcDi.accountSrc); //
  @override
  HomeStatusRepo get homeStatusRepo => HomeStatusRepoImpl(homeApi: ApiDi.obj.homeApi); //HomeStatusRepoDummy.obj;
  @override
  HomeMenuRepo get homeMenuRepo => HomeMenuRepoDummy.obj;
  //static TipsRepo get tipsRepo => TipsRepoDummy.obj;
  @override
  EducationRepo get educationRepo => EducationRepoImpl(homeApi: ApiDi.obj.homeApi); //EducationRepoDummy.obj;
  @override
  NotifRepo get notifRepo => NotifRepoImpl(api: ApiDi.obj.homeApi); //NotifRepoDummy.obj;

  @override
  FormFieldRepo get formFieldRepo => FormFieldRepoImpl(
    babyApi: ApiDi.obj.babyApi,
    covidApi: ApiDi.obj.covidApi,
  ); //FormFieldRepoDummy.obj;

  //@override
  //FamilyRepo getFamilyRepo() => FamilyDummyRepo();
  @override
  MotherRepo get motherRepo => MotherRepoImpl(
    dataApi: ApiDi.obj.dataApi,
    accountLocalSrc: LocalSrcDi.obj.accountSrc,
    pregnancyLocalSrc: LocalSrcDi.obj.pregnancySrc,
    profileDao: DbDi.obj.profileDao,
  ); //MotherRepoDummy.obj;
  @override
  FatherRepo get fatherRepo => FatherRepoImpl(
    dataApi: ApiDi.obj.dataApi,
  );
  @override
  ChildRepo get childRepo => ChildRepoImpl(
    accountLocalSrc: LocalSrcDi.obj.accountSrc,
    profileDao: DbDi.obj.profileDao,
    pregnancyDao: DbDi.obj.pregnancyDao,
    dataApi: ApiDi.obj.dataApi,
  ); //ChildRepoDummy.obj;
  @override
  PregnancyRepo get pregnancyRepo => PregnancyRepoImpl(
    api: ApiDi.obj.kehamilankuApi,
    checkUpLocalSrc: LocalSrcDi.obj.checkUpSrc,
  ); //PregnancyRepoDummy.obj; //
  //static MotherFoodRecomRepo get foodRepo => MotherFoodRecomRepoDummy.obj;
  //static MotherHomeRepo get pregnancyRepo => MotherPregnancyRepoDummy.obj;
  //static PregnancyCheckRepo get pregnancyCheckRepo => PregnancyCheckRepoDummy.obj;
  //static FormWarningStatusRepo get formWarningStatusRepo => FormWarningStatusRepoDummy.obj;
  @override
  ImmunizationRepo get immunizationRepo => ImmunizationRepoImpl(
    pregnancyApi: ApiDi.obj.kehamilankuApi,
    babyApi: ApiDi.obj.babyApi,
    accountLocalSrc: LocalSrcDi.obj.accountSrc,
  ); //ImmunizationRepoDummy.obj;

  @override
  MyBabyRepo get myBabyRepo => MyBabyRepoImpl(
    api: ApiDi.obj.babyApi,
    accountLocalSrc: LocalSrcDi.obj.accountSrc,
    checkUpLocalSrc: LocalSrcDi.obj.checkUpSrc,
    pregnancyLocalSrc: LocalSrcDi.obj.pregnancySrc,
  ); //MyBabyRepoDummy.obj;

  @override
  CovidRepo get covidRepo => CovidRepoImpl(
    api: ApiDi.obj.covidApi,
    accountLocalSrc: LocalSrcDi.obj.accountSrc,
  ); //CovidRepoDummy.obj;

  @override
  BabyChartRepo get babyChartRepo => BabyChartRepoImpl(
    api: ApiDi.obj.babyApi,
    accountLocalSrc: LocalSrcDi.obj.accountSrc,
  ); //BabyChartRepoDummy.obj;
  @override
  MotherChartRepo get motherChartRepo => MotherChartRepoImpl(
    api: ApiDi.obj.kehamilankuApi,
  ); //MotherChartRepoDummy.obj;
}