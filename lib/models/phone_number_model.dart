// To parse this JSON data, do
//
//     final phoneNumberModel = phoneNumberModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'phone_number_model.freezed.dart';
part 'phone_number_model.g.dart';

PhoneNumberModel phoneNumberModelFromJson(String str) =>
    PhoneNumberModel.fromJson(json.decode(str));

String phoneNumberModelToJson(PhoneNumberModel data) =>
    json.encode(data.toJson());

@freezed
class PhoneNumberModel with _$PhoneNumberModel {
  const factory PhoneNumberModel({
    required List<Datum> data,
  }) = _PhoneNumberModel;

  factory PhoneNumberModel.fromJson(Map<String, dynamic> json) =>
      _$PhoneNumberModelFromJson(json);
}

@freezed
class Datum with _$Datum {
  const factory Datum({
    required String verified_name,
    required String display_phone_number,
    required String id,
    required String quality_rating,
  }) = _Datum;

  factory Datum.fromJson(Map<String, dynamic> json) => _$DatumFromJson(json);
}
