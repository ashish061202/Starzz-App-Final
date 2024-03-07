// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'phone_number_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

PhoneNumberModel _$PhoneNumberModelFromJson(Map<String, dynamic> json) {
  return _PhoneNumberModel.fromJson(json);
}

/// @nodoc
mixin _$PhoneNumberModel {
  List<Datum> get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PhoneNumberModelCopyWith<PhoneNumberModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PhoneNumberModelCopyWith<$Res> {
  factory $PhoneNumberModelCopyWith(
          PhoneNumberModel value, $Res Function(PhoneNumberModel) then) =
      _$PhoneNumberModelCopyWithImpl<$Res, PhoneNumberModel>;
  @useResult
  $Res call({List<Datum> data});
}

/// @nodoc
class _$PhoneNumberModelCopyWithImpl<$Res, $Val extends PhoneNumberModel>
    implements $PhoneNumberModelCopyWith<$Res> {
  _$PhoneNumberModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
  }) {
    return _then(_value.copyWith(
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as List<Datum>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PhoneNumberModelImplCopyWith<$Res>
    implements $PhoneNumberModelCopyWith<$Res> {
  factory _$$PhoneNumberModelImplCopyWith(_$PhoneNumberModelImpl value,
          $Res Function(_$PhoneNumberModelImpl) then) =
      __$$PhoneNumberModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<Datum> data});
}

/// @nodoc
class __$$PhoneNumberModelImplCopyWithImpl<$Res>
    extends _$PhoneNumberModelCopyWithImpl<$Res, _$PhoneNumberModelImpl>
    implements _$$PhoneNumberModelImplCopyWith<$Res> {
  __$$PhoneNumberModelImplCopyWithImpl(_$PhoneNumberModelImpl _value,
      $Res Function(_$PhoneNumberModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
  }) {
    return _then(_$PhoneNumberModelImpl(
      data: null == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as List<Datum>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PhoneNumberModelImpl implements _PhoneNumberModel {
  const _$PhoneNumberModelImpl({required final List<Datum> data})
      : _data = data;

  factory _$PhoneNumberModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PhoneNumberModelImplFromJson(json);

  final List<Datum> _data;
  @override
  List<Datum> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  String toString() {
    return 'PhoneNumberModel(data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PhoneNumberModelImpl &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_data));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PhoneNumberModelImplCopyWith<_$PhoneNumberModelImpl> get copyWith =>
      __$$PhoneNumberModelImplCopyWithImpl<_$PhoneNumberModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PhoneNumberModelImplToJson(
      this,
    );
  }
}

abstract class _PhoneNumberModel implements PhoneNumberModel {
  const factory _PhoneNumberModel({required final List<Datum> data}) =
      _$PhoneNumberModelImpl;

  factory _PhoneNumberModel.fromJson(Map<String, dynamic> json) =
      _$PhoneNumberModelImpl.fromJson;

  @override
  List<Datum> get data;
  @override
  @JsonKey(ignore: true)
  _$$PhoneNumberModelImplCopyWith<_$PhoneNumberModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Datum _$DatumFromJson(Map<String, dynamic> json) {
  return _Datum.fromJson(json);
}

/// @nodoc
mixin _$Datum {
  String get verified_name => throw _privateConstructorUsedError;
  String get display_phone_number => throw _privateConstructorUsedError;
  String get id => throw _privateConstructorUsedError;
  String get quality_rating => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DatumCopyWith<Datum> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DatumCopyWith<$Res> {
  factory $DatumCopyWith(Datum value, $Res Function(Datum) then) =
      _$DatumCopyWithImpl<$Res, Datum>;
  @useResult
  $Res call(
      {String verified_name,
      String display_phone_number,
      String id,
      String quality_rating});
}

/// @nodoc
class _$DatumCopyWithImpl<$Res, $Val extends Datum>
    implements $DatumCopyWith<$Res> {
  _$DatumCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? verified_name = null,
    Object? display_phone_number = null,
    Object? id = null,
    Object? quality_rating = null,
  }) {
    return _then(_value.copyWith(
      verified_name: null == verified_name
          ? _value.verified_name
          : verified_name // ignore: cast_nullable_to_non_nullable
              as String,
      display_phone_number: null == display_phone_number
          ? _value.display_phone_number
          : display_phone_number // ignore: cast_nullable_to_non_nullable
              as String,
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      quality_rating: null == quality_rating
          ? _value.quality_rating
          : quality_rating // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DatumImplCopyWith<$Res> implements $DatumCopyWith<$Res> {
  factory _$$DatumImplCopyWith(
          _$DatumImpl value, $Res Function(_$DatumImpl) then) =
      __$$DatumImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String verified_name,
      String display_phone_number,
      String id,
      String quality_rating});
}

/// @nodoc
class __$$DatumImplCopyWithImpl<$Res>
    extends _$DatumCopyWithImpl<$Res, _$DatumImpl>
    implements _$$DatumImplCopyWith<$Res> {
  __$$DatumImplCopyWithImpl(
      _$DatumImpl _value, $Res Function(_$DatumImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? verified_name = null,
    Object? display_phone_number = null,
    Object? id = null,
    Object? quality_rating = null,
  }) {
    return _then(_$DatumImpl(
      verified_name: null == verified_name
          ? _value.verified_name
          : verified_name // ignore: cast_nullable_to_non_nullable
              as String,
      display_phone_number: null == display_phone_number
          ? _value.display_phone_number
          : display_phone_number // ignore: cast_nullable_to_non_nullable
              as String,
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      quality_rating: null == quality_rating
          ? _value.quality_rating
          : quality_rating // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DatumImpl implements _Datum {
  const _$DatumImpl(
      {required this.verified_name,
      required this.display_phone_number,
      required this.id,
      required this.quality_rating});

  factory _$DatumImpl.fromJson(Map<String, dynamic> json) =>
      _$$DatumImplFromJson(json);

  @override
  final String verified_name;
  @override
  final String display_phone_number;
  @override
  final String id;
  @override
  final String quality_rating;

  @override
  String toString() {
    return 'Datum(verified_name: $verified_name, display_phone_number: $display_phone_number, id: $id, quality_rating: $quality_rating)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DatumImpl &&
            (identical(other.verified_name, verified_name) ||
                other.verified_name == verified_name) &&
            (identical(other.display_phone_number, display_phone_number) ||
                other.display_phone_number == display_phone_number) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.quality_rating, quality_rating) ||
                other.quality_rating == quality_rating));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, verified_name, display_phone_number, id, quality_rating);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DatumImplCopyWith<_$DatumImpl> get copyWith =>
      __$$DatumImplCopyWithImpl<_$DatumImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DatumImplToJson(
      this,
    );
  }
}

abstract class _Datum implements Datum {
  const factory _Datum(
      {required final String verified_name,
      required final String display_phone_number,
      required final String id,
      required final String quality_rating}) = _$DatumImpl;

  factory _Datum.fromJson(Map<String, dynamic> json) = _$DatumImpl.fromJson;

  @override
  String get verified_name;
  @override
  String get display_phone_number;
  @override
  String get id;
  @override
  String get quality_rating;
  @override
  @JsonKey(ignore: true)
  _$$DatumImplCopyWith<_$DatumImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
