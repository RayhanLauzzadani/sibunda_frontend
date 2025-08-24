import 'package:common/arch/domain/model/auth.dart';
import 'package:common/arch/domain/model/child.dart';
import 'package:common/arch/domain/model/father.dart';
import 'package:common/arch/domain/model/mother.dart';
import 'package:common/arch/domain/repo/auth_repo.dart';
import 'package:core/domain/model/result.dart';

mixin SaveSignUpData {
  Future<Result<bool>> call(SignUpData data);
}

// Use ChildEntity for stable non-null data during signup.
mixin SignUpAndRegisterOtherData {
  Future<Result<bool>> call({
    required SignUpData signup,
    required Mother? mother,
    required Father? father,
    required List<ChildEntity> children,
    required DateTime? motherHpl,
  });
}


class SaveSignUpDataImpl with SaveSignUpData {
  final AuthRepo repo;
  SaveSignUpDataImpl(this.repo);
  @override
  Future<Result<bool>> call(SignUpData data) => repo.saveSignupData(data);
}

class SignUpAndRegisterOtherDataImpl with SignUpAndRegisterOtherData {
  final AuthRepo _repo;
  SignUpAndRegisterOtherDataImpl(this._repo);
  @override
  Future<Result<bool>> call({
    required SignUpData signup,
    required Mother? mother,
    required Father? father,
    required List<ChildEntity> children,
    required DateTime? motherHpl,
  }) => _repo.signup(
    signup: signup, mother: mother, father: father,
    children: children.map((e) => ChildRaw(
      name: e.name,
      childOrder: e.childOrder,
      gender: e.gender,
      birthCertificateNo: e.birthCertificateNo,
      nik: e.nik,
      bloodType: e.bloodType,
      birthCity: e.birthCity,
      birthDate: e.birthDate,
      jkn: e.jkn,
      jknStartDate: e.jknStartDate,
      babyCohortRegistNo: e.babyCohortRegistNo,
      toddlerCohortRegistNo: e.toddlerCohortRegistNo,
      hospitalMedicalNumber: e.hospitalMedicalNumber,
    )).toList(),
    motherHpl: motherHpl,
  );
}
