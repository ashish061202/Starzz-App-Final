// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'retrieve_media_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RetrieveMediaModelImpl _$$RetrieveMediaModelImplFromJson(
        Map<String, dynamic> json) =>
    _$RetrieveMediaModelImpl(
      url: json['url'] as String,
      mimeType: json['mimeType'] as String,
      sha256: json['sha256'] as String,
      fileSize: json['fileSize'] as int,
      id: json['id'] as String,
      messagingProduct: json['messagingProduct'] as String,
    );

Map<String, dynamic> _$$RetrieveMediaModelImplToJson(
        _$RetrieveMediaModelImpl instance) =>
    <String, dynamic>{
      'url': instance.url,
      'mimeType': instance.mimeType,
      'sha256': instance.sha256,
      'fileSize': instance.fileSize,
      'id': instance.id,
      'messagingProduct': instance.messagingProduct,
    };
