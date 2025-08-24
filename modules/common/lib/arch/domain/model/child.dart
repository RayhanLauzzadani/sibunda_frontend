
import 'package:common/value/const_values.dart';
import 'package:json_annotation/json_annotation.dart';

part 'child.g.dart';

@JsonSerializable()
class ChildRaw { // Raw response from backend; many fields nullable.
  @JsonKey(name: Const.KEY_NAME_INDO)
  final String? name;
  @JsonKey(name: Const.KEY_CHILD_ORDER)
  final int? childOrder;
  @JsonKey(name: Const.KEY_BABY_GENDER)
  final String? gender; //'L' or 'P'
  @JsonKey(name: Const.KEY_BIRTH_CERT_NO)
  final String? birthCertificateNo;
  @JsonKey(name: Const.KEY_NIK)
  final String? nik;
  @JsonKey(name: Const.KEY_BLOOD_TYPE)
  final String? bloodType;
  @JsonKey(name: Const.KEY_BIRTH_PLACE)
  final int? birthCity;
  @JsonKey(name: Const.KEY_BIRTH_DATE)
  final String? birthDate; // iso (yyyy-MM-dd)
  @JsonKey(name: Const.KEY_JKN)
  final String? jkn;
  @JsonKey(name: Const.KEY_JKN_START_DATE)
  final String? jknStartDate;
  @JsonKey(name: Const.KEY_BABY_COHORT_REG)
  final String? babyCohortRegistNo;
  @JsonKey(name: Const.KEY_TODDLER_COHORT_REG)
  final String? toddlerCohortRegistNo;
  @JsonKey(name: Const.KEY_HOSPITAL_MEDIC_NO)
  final String? hospitalMedicalNumber;

  ChildRaw({
    this.name,
    this.childOrder,
    this.gender,
    this.birthCertificateNo,
    this.nik,
    this.bloodType,
    this.birthCity,
    this.birthDate,
    this.jkn,
    this.jknStartDate,
    this.babyCohortRegistNo,
    this.toddlerCohortRegistNo,
    this.hospitalMedicalNumber,
  });

  factory ChildRaw.fromJson(Map<String, dynamic> json) => _$ChildRawFromJson(json);
  Map<String, dynamic> get toJson => _$ChildRawToJson(this);
}

// Stable, non-null model for app logic/UI.
class ChildEntity {
  final String name;
  final int childOrder;
  final String gender; // 'L' or 'P'
  final String? birthCertificateNo;
  final String? nik;
  final String? bloodType;
  final int? birthCity;
  final String birthDate; // guaranteed yyyy-MM-dd fallback
  final String? jkn;
  final String? jknStartDate;
  final String? babyCohortRegistNo;
  final String? toddlerCohortRegistNo;
  final String? hospitalMedicalNumber;

  ChildEntity({
    required this.name,
    required this.childOrder,
    required this.gender,
    required this.birthCertificateNo,
    required this.nik,
    required this.bloodType,
    required this.birthCity,
    required this.birthDate,
    required this.jkn,
    required this.jknStartDate,
    required this.babyCohortRegistNo,
    required this.toddlerCohortRegistNo,
    required this.hospitalMedicalNumber,
  });

  bool get isNikEmpty => nik == null || nik!.isEmpty;
  bool get isBirthCertEmpty => birthCertificateNo == null || birthCertificateNo!.isEmpty;
  double get completenessRatio {
    final total = 6; // nik, birthCert, birthCity, jkn, cohort, hospitalNumber
    var filled = 0;
    if(!isNikEmpty) filled++;
    if(!isBirthCertEmpty) filled++;
    if(birthCity != null && birthCity! > 0) filled++;
    if(jkn != null && jkn!.isNotEmpty) filled++;
    if(babyCohortRegistNo != null && babyCohortRegistNo!.isNotEmpty) filled++;
    if(hospitalMedicalNumber != null && hospitalMedicalNumber!.isNotEmpty) filled++;
    return filled / total;
  }
}

ChildEntity mapChildRaw(ChildRaw raw) {
  String fallbackDate(String? d) {
    if(d == null || d.isEmpty) return DateTime.fromMillisecondsSinceEpoch(0).toIso8601String().substring(0,10);
    return d.length >= 10 ? d.substring(0,10) : d;
  }
  return ChildEntity(
    name: raw.name ?? 'Anak',
    childOrder: raw.childOrder ?? 1,
    gender: raw.gender ?? 'L',
    birthCertificateNo: raw.birthCertificateNo,
    nik: raw.nik,
    bloodType: raw.bloodType,
    birthCity: raw.birthCity,
    birthDate: fallbackDate(raw.birthDate),
    jkn: raw.jkn,
    jknStartDate: raw.jknStartDate,
    babyCohortRegistNo: raw.babyCohortRegistNo,
    toddlerCohortRegistNo: raw.toddlerCohortRegistNo,
    hospitalMedicalNumber: raw.hospitalMedicalNumber,
  );
}
// Backward compatibility for code that still uses Child (deprecated)
@deprecated
typedef Child = ChildRaw;