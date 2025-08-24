import 'package:common/arch/domain/model/child.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'baby_add_api_model.freezed.dart';
part 'baby_add_api_model.g.dart';

//@freezed
class BabyAddBody {
  final int ibu_id;
  final ChildRaw child;

  const BabyAddBody({
    required this.ibu_id,
    required this.child,
  });

  Map<String, dynamic> toJson() {
  final childMap = child.toJson;
    childMap["ibu_id"] = ibu_id;
    childMap["is_janin"] = 0;
    childMap["janin_hpl"] = DateTime.fromMicrosecondsSinceEpoch(0).toString(); // Cuz, the endpoint needs it.
    return childMap;
  }
}

class FetusAddBody {
  final int ibu_id;
  final String janin_hpl;

  const FetusAddBody({
    required this.ibu_id,
    required this.janin_hpl,
  });

  Map<String, dynamic> toJson() => {
    "ibu_id": ibu_id,
    "is_janin": 1,
    "janin_hpl": janin_hpl,
  };
}

/// For all add baby or fetus
@freezed
class BabyAddResponse with _$BabyAddResponse {
  const factory BabyAddResponse({
    required int code,
    required String message,
    required String status,
    required int? anak_id,
  }) = _BabyAddResponse;
  factory BabyAddResponse.fromJson(Map<String, dynamic> map) = _BabyAddResponse.fromJson;
}