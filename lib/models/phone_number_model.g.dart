// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phone_number_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_PhoneNumberModel _$$_PhoneNumberModelFromJson(Map<String, dynamic> json) =>
    _$_PhoneNumberModel(
      data: (json['data'] as List<dynamic>)
          .map((e) => Datum.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$_PhoneNumberModelToJson(_$_PhoneNumberModel instance) =>
    <String, dynamic>{
      'data': instance.data,
    };

_$_Datum _$$_DatumFromJson(Map<String, dynamic> json) => _$_Datum(
      verified_name: json['verified_name'] as String,
      display_phone_number: json['display_phone_number'] as String,
      id: json['id'] as String,
      quality_rating: json['quality_rating'] as String,
    );

Map<String, dynamic> _$$_DatumToJson(_$_Datum instance) => <String, dynamic>{
      'verified_name': instance.verified_name,
      'display_phone_number': instance.display_phone_number,
      'id': instance.id,
      'quality_rating': instance.quality_rating,
    };
