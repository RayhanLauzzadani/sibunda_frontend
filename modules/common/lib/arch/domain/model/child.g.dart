// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'child.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChildRaw _$ChildRawFromJson(Map<String, dynamic> json) {
  return ChildRaw(
    name: json['nama'] as String?,
    childOrder: json['anak_ke'] as int?,
    gender: json['jenis_kelamin'] as String?,
    birthCertificateNo: json['no_akte_kelahiran'] as String?,
    nik: json['nik'] as String?,
    bloodType: json['gol_darah'] as String?,
    birthCity: json['tempat_lahir'] as int?,
    birthDate: json['tanggal_lahir'] as String?,
    jkn: json['no_jkn'] as String?,
    jknStartDate: json['tanggal_berlaku_jkn'] as String?,
    babyCohortRegistNo: json['no_kohort'] as String?,
    toddlerCohortRegistNo: json['nomor_register_kohort_balita'] as String?,
    hospitalMedicalNumber: json['no_catatan_medik'] as String?,
  );
}

Map<String, dynamic> _$ChildRawToJson(ChildRaw instance) => <String, dynamic>{
      'nama': instance.name,
      'anak_ke': instance.childOrder,
      'jenis_kelamin': instance.gender,
      'no_akte_kelahiran': instance.birthCertificateNo,
      'nik': instance.nik,
      'gol_darah': instance.bloodType,
      'tempat_lahir': instance.birthCity,
      'tanggal_lahir': instance.birthDate,
      'no_jkn': instance.jkn,
      'tanggal_berlaku_jkn': instance.jknStartDate,
      'no_kohort': instance.babyCohortRegistNo,
      'nomor_register_kohort_balita': instance.toddlerCohortRegistNo,
      'no_catatan_medik': instance.hospitalMedicalNumber,
    };
