// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'retrieve_media_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

RetrieveMediaModel _$RetrieveMediaModelFromJson(Map<String, dynamic> json) {
  return _RetrieveMediaModel.fromJson(json);
}

/// @nodoc
mixin _$RetrieveMediaModel {
  String get url => throw _privateConstructorUsedError;
  String get mimeType => throw _privateConstructorUsedError;
  String get sha256 => throw _privateConstructorUsedError;
  int get fileSize => throw _privateConstructorUsedError;
  String get id => throw _privateConstructorUsedError;
  String get messagingProduct => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RetrieveMediaModelCopyWith<RetrieveMediaModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RetrieveMediaModelCopyWith<$Res> {
  factory $RetrieveMediaModelCopyWith(
          RetrieveMediaModel value, $Res Function(RetrieveMediaModel) then) =
      _$RetrieveMediaModelCopyWithImpl<$Res, RetrieveMediaModel>;
  @useResult
  $Res call(
      {String url,
      String mimeType,
      String sha256,
      int fileSize,
      String id,
      String messagingProduct});
}

/// @nodoc
class _$RetrieveMediaModelCopyWithImpl<$Res, $Val extends RetrieveMediaModel>
    implements $RetrieveMediaModelCopyWith<$Res> {
  _$RetrieveMediaModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? mimeType = null,
    Object? sha256 = null,
    Object? fileSize = null,
    Object? id = null,
    Object? messagingProduct = null,
  }) {
    return _then(_value.copyWith(
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      mimeType: null == mimeType
          ? _value.mimeType
          : mimeType // ignore: cast_nullable_to_non_nullable
              as String,
      sha256: null == sha256
          ? _value.sha256
          : sha256 // ignore: cast_nullable_to_non_nullable
              as String,
      fileSize: null == fileSize
          ? _value.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int,
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      messagingProduct: null == messagingProduct
          ? _value.messagingProduct
          : messagingProduct // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_RetrieveMediaModelCopyWith<$Res>
    implements $RetrieveMediaModelCopyWith<$Res> {
  factory _$$_RetrieveMediaModelCopyWith(_$_RetrieveMediaModel value,
          $Res Function(_$_RetrieveMediaModel) then) =
      __$$_RetrieveMediaModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String url,
      String mimeType,
      String sha256,
      int fileSize,
      String id,
      String messagingProduct});
}

/// @nodoc
class __$$_RetrieveMediaModelCopyWithImpl<$Res>
    extends _$RetrieveMediaModelCopyWithImpl<$Res, _$_RetrieveMediaModel>
    implements _$$_RetrieveMediaModelCopyWith<$Res> {
  __$$_RetrieveMediaModelCopyWithImpl(
      _$_RetrieveMediaModel _value, $Res Function(_$_RetrieveMediaModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? mimeType = null,
    Object? sha256 = null,
    Object? fileSize = null,
    Object? id = null,
    Object? messagingProduct = null,
  }) {
    return _then(_$_RetrieveMediaModel(
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      mimeType: null == mimeType
          ? _value.mimeType
          : mimeType // ignore: cast_nullable_to_non_nullable
              as String,
      sha256: null == sha256
          ? _value.sha256
          : sha256 // ignore: cast_nullable_to_non_nullable
              as String,
      fileSize: null == fileSize
          ? _value.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int,
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      messagingProduct: null == messagingProduct
          ? _value.messagingProduct
          : messagingProduct // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_RetrieveMediaModel implements _RetrieveMediaModel {
  const _$_RetrieveMediaModel(
      {required this.url,
      required this.mimeType,
      required this.sha256,
      required this.fileSize,
      required this.id,
      required this.messagingProduct});

  factory _$_RetrieveMediaModel.fromJson(Map<String, dynamic> json) =>
      _$$_RetrieveMediaModelFromJson(json);

  @override
  final String url;
  @override
  final String mimeType;
  @override
  final String sha256;
  @override
  final int fileSize;
  @override
  final String id;
  @override
  final String messagingProduct;

  @override
  String toString() {
    return 'RetrieveMediaModel(url: $url, mimeType: $mimeType, sha256: $sha256, fileSize: $fileSize, id: $id, messagingProduct: $messagingProduct)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_RetrieveMediaModel &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.mimeType, mimeType) ||
                other.mimeType == mimeType) &&
            (identical(other.sha256, sha256) || other.sha256 == sha256) &&
            (identical(other.fileSize, fileSize) ||
                other.fileSize == fileSize) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.messagingProduct, messagingProduct) ||
                other.messagingProduct == messagingProduct));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, url, mimeType, sha256, fileSize, id, messagingProduct);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_RetrieveMediaModelCopyWith<_$_RetrieveMediaModel> get copyWith =>
      __$$_RetrieveMediaModelCopyWithImpl<_$_RetrieveMediaModel>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_RetrieveMediaModelToJson(
      this,
    );
  }
}

abstract class _RetrieveMediaModel implements RetrieveMediaModel {
  const factory _RetrieveMediaModel(
      {required final String url,
      required final String mimeType,
      required final String sha256,
      required final int fileSize,
      required final String id,
      required final String messagingProduct}) = _$_RetrieveMediaModel;

  factory _RetrieveMediaModel.fromJson(Map<String, dynamic> json) =
      _$_RetrieveMediaModel.fromJson;

  @override
  String get url;
  @override
  String get mimeType;
  @override
  String get sha256;
  @override
  int get fileSize;
  @override
  String get id;
  @override
  String get messagingProduct;
  @override
  @JsonKey(ignore: true)
  _$$_RetrieveMediaModelCopyWith<_$_RetrieveMediaModel> get copyWith =>
      throw _privateConstructorUsedError;
}
