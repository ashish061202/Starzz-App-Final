// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phone_number_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PhoneNumberModelImpl _$$PhoneNumberModelImplFromJson(
        Map<String, dynamic> json) =>
    _$PhoneNumberModelImpl(
      data: (json['data'] as List<dynamic>)
          .map((e) => Datum.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$PhoneNumberModelImplToJson(
        _$PhoneNumberModelImpl instance) =>
    <String, dynamic>{
      'data': instance.data,
    };

_$DatumImpl _$$DatumImplFromJson(Map<String, dynamic> json) => _$DatumImpl(
      verified_name: json['verified_name'] as String,
      display_phone_number: json['display_phone_number'] as String,
      id: json['id'] as String,
      quality_rating: json['quality_rating'] as String,
    );

Map<String, dynamic> _$$DatumImplToJson(_$DatumImpl instance) =>
    <String, dynamic>{
      'verified_name': instance.verified_name,
      'display_phone_number': instance.display_phone_number,
      'id': instance.id,
      'quality_rating': instance.quality_rating,
    };
