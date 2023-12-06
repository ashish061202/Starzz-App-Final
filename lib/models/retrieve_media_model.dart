import 'package:meta/meta.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'retrieve_media_model.freezed.dart';
part 'retrieve_media_model.g.dart';

RetrieveMediaModel retrieveMediaModelFromJson(String str) =>
    RetrieveMediaModel.fromJson(json.decode(str));

String retrieveMediaModelToJson(RetrieveMediaModel data) =>
    json.encode(data.toJson());

@freezed
class RetrieveMediaModel with _$RetrieveMediaModel {
  const factory RetrieveMediaModel({
    required String url,
    required String mimeType,
    required String sha256,
    required int fileSize,
    required String id,
    required String messagingProduct,
  }) = _RetrieveMediaModel;

  factory RetrieveMediaModel.fromJson(Map<String, dynamic> json) =>
      _$RetrieveMediaModelFromJson(json);
}
