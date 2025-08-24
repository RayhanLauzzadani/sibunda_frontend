import 'package:common/value/const_values.dart';
import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'data_api_model.g.dart';
part 'data_api_model.freezed.dart';

class SaveProfileBody extends Equatable {
  final String email;
  final String name;
  final String? password;

  const SaveProfileBody({
    required this.email,
    required this.name,
    this.password,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      "email": email,
      "name": name,
    };
    if(password?.isNotEmpty == true) {
      map["password"] = password;
    }
    return map;
  }

  @override
  List<Object?> get props => [
    email, name, password,
  ];
}


@JsonSerializable()
class CityResponse extends Equatable {
  final int id;
  @JsonKey(name: Const.KEY_NAME_INDO)
  final String name;

  CityResponse({
    required this.id,
    required this.name,
  });

  factory CityResponse.fromJson(Map<String, dynamic> map) => _$CityResponseFromJson(map);
  Map<String, dynamic> toEntityJson() => {
    "id": id, "name": name,
  };

  @override
  List<Object?> get props => [id, name];
}


@freezed
class BioResponse with _$BioResponse {
  const factory BioResponse({
    required String message,
    required String status,
    required int code,
    required List<BioMotherResponse> data,
  }) = _BioResponse;
  factory BioResponse.fromJson(Map<String, dynamic> map) = _BioResponse.fromJson;
}

@freezed
class BioMotherResponse with _$BioMotherResponse {
  const factory BioMotherResponse({
    required int id,
    required int user_id,
    required String nama,
    required String nik,
  required String pembiayaan,
  required String no_jkn,
  required String faskes_tk1,
  required String faskes_rujukan,
  required String gol_darah,
  required int tempat_lahir,
  required String tanggal_lahir,
  required String pendidikan,
  required String pekerjaan,
  required String alamat_rumah,
  required String telp,
  required String puskesmas_domisili,
  required String nomor_register_kohort_ibu,
    required BioFatherResponse kia_ayah,
    required List<BioChildResponse> kia_anak,
  }) = _BioMotherResponse;
  factory BioMotherResponse.fromJson(Map<String, dynamic> map) = _BioMotherResponse.fromJson;
      //_BioMotherResponse.fromJson(filterBioChildResponse(map));
}

@freezed
class BioFatherResponse with _$BioFatherResponse {
  const factory BioFatherResponse({
    required int id,
    required String nama,
    required String nik,
  required String pembiayaan,
  required String no_jkn,
  required String faskes_tk1,
  required String faskes_rujukan,
  required String gol_darah,
  required int tempat_lahir,
  required String tanggal_lahir,
  required String pendidikan,
  required String pekerjaan,
  required String alamat_rumah,
  required String telp,
  }) = _BioFatherResponse;
  factory BioFatherResponse.fromJson(Map<String, dynamic> map) = _BioFatherResponse.fromJson;
}

@freezed
class BioChildResponse with _$BioChildResponse {
  const factory BioChildResponse({
    required int id,
    required String nama,
    required int? anak_ke, // null if this is unborn child (fetus).
    required String? no_akte_kelahiran,
    required String? nik,
    required String? jenis_kelamin,
    required String? gol_darah,
    required int? tempat_lahir,
    required String? tanggal_lahir,
    required String? no_jkn,
    required String? tanggal_berlaku_jkn,
    required String? no_kohort,
    required String? no_catatan_medik,
    required String? hpl,
    required String? hpht,
    required bool is_janin,
  }) = _BioChildResponse;
  factory BioChildResponse.fromJson(Map<String, dynamic> map) = _BioChildResponse.fromJson;
}



Map<String, dynamic> filterBioChildResponse(Map<String, dynamic> bioMotherResponse) {
  final list = bioMotherResponse["kia_anak"] as List<dynamic>?;
  if(list == null) {
    throw "This method is designed to filter `BioMotherResponse`'s response map";
  }
  final filtered = list
      .where((map) => map is Map<String, dynamic> && map.containsKey("anak_ke") && map["anak_ke"] != null)
      .toList(growable: false);
  bioMotherResponse["kia_anak"] = filtered;
  return bioMotherResponse;
}