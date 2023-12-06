// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'retrieve_media_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_RetrieveMediaModel _$$_RetrieveMediaModelFromJson(
        Map<String, dynamic> json) =>
    _$_RetrieveMediaModel(
      url: json['url'] as String,
      mimeType: json['mimeType'] as String,
      sha256: json['sha256'] as String,
      fileSize: json['fileSize'] as int,
      id: json['id'] as String,
      messagingProduct: json['messagingProduct'] as String,
    );

Map<String, dynamic> _$$_RetrieveMediaModelToJson(
        _$_RetrieveMediaModel instance) =>
    <String, dynamic>{
      'url': instance.url,
      'mimeType': instance.mimeType,
      'sha256': instance.sha256,
      'fileSize': instance.fileSize,
      'id': instance.id,
      'messagingProduct': instance.messagingProduct,
    };
