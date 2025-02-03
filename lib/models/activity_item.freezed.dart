// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activity_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ActivityItem _$ActivityItemFromJson(Map<String, dynamic> json) {
  return _ActivityItem.fromJson(json);
}

/// @nodoc
mixin _$ActivityItem {
  String get title => throw _privateConstructorUsedError;
  String get time => throw _privateConstructorUsedError;
  String get kcal => throw _privateConstructorUsedError;
  ActivityType get type => throw _privateConstructorUsedError;
  List<MealItem>? get mealItems => throw _privateConstructorUsedError;

  /// Serializes this ActivityItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ActivityItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActivityItemCopyWith<ActivityItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActivityItemCopyWith<$Res> {
  factory $ActivityItemCopyWith(
          ActivityItem value, $Res Function(ActivityItem) then) =
      _$ActivityItemCopyWithImpl<$Res, ActivityItem>;
  @useResult
  $Res call(
      {String title,
      String time,
      String kcal,
      ActivityType type,
      List<MealItem>? mealItems});
}

/// @nodoc
class _$ActivityItemCopyWithImpl<$Res, $Val extends ActivityItem>
    implements $ActivityItemCopyWith<$Res> {
  _$ActivityItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ActivityItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? time = null,
    Object? kcal = null,
    Object? type = null,
    Object? mealItems = freezed,
  }) {
    return _then(_value.copyWith(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as String,
      kcal: null == kcal
          ? _value.kcal
          : kcal // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ActivityType,
      mealItems: freezed == mealItems
          ? _value.mealItems
          : mealItems // ignore: cast_nullable_to_non_nullable
              as List<MealItem>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ActivityItemImplCopyWith<$Res>
    implements $ActivityItemCopyWith<$Res> {
  factory _$$ActivityItemImplCopyWith(
          _$ActivityItemImpl value, $Res Function(_$ActivityItemImpl) then) =
      __$$ActivityItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String title,
      String time,
      String kcal,
      ActivityType type,
      List<MealItem>? mealItems});
}

/// @nodoc
class __$$ActivityItemImplCopyWithImpl<$Res>
    extends _$ActivityItemCopyWithImpl<$Res, _$ActivityItemImpl>
    implements _$$ActivityItemImplCopyWith<$Res> {
  __$$ActivityItemImplCopyWithImpl(
      _$ActivityItemImpl _value, $Res Function(_$ActivityItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of ActivityItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? time = null,
    Object? kcal = null,
    Object? type = null,
    Object? mealItems = freezed,
  }) {
    return _then(_$ActivityItemImpl(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as String,
      kcal: null == kcal
          ? _value.kcal
          : kcal // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ActivityType,
      mealItems: freezed == mealItems
          ? _value._mealItems
          : mealItems // ignore: cast_nullable_to_non_nullable
              as List<MealItem>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ActivityItemImpl implements _ActivityItem {
  const _$ActivityItemImpl(
      {required this.title,
      required this.time,
      required this.kcal,
      required this.type,
      final List<MealItem>? mealItems})
      : _mealItems = mealItems;

  factory _$ActivityItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActivityItemImplFromJson(json);

  @override
  final String title;
  @override
  final String time;
  @override
  final String kcal;
  @override
  final ActivityType type;
  final List<MealItem>? _mealItems;
  @override
  List<MealItem>? get mealItems {
    final value = _mealItems;
    if (value == null) return null;
    if (_mealItems is EqualUnmodifiableListView) return _mealItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'ActivityItem(title: $title, time: $time, kcal: $kcal, type: $type, mealItems: $mealItems)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActivityItemImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.kcal, kcal) || other.kcal == kcal) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality()
                .equals(other._mealItems, _mealItems));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, title, time, kcal, type,
      const DeepCollectionEquality().hash(_mealItems));

  /// Create a copy of ActivityItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActivityItemImplCopyWith<_$ActivityItemImpl> get copyWith =>
      __$$ActivityItemImplCopyWithImpl<_$ActivityItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ActivityItemImplToJson(
      this,
    );
  }
}

abstract class _ActivityItem implements ActivityItem {
  const factory _ActivityItem(
      {required final String title,
      required final String time,
      required final String kcal,
      required final ActivityType type,
      final List<MealItem>? mealItems}) = _$ActivityItemImpl;

  factory _ActivityItem.fromJson(Map<String, dynamic> json) =
      _$ActivityItemImpl.fromJson;

  @override
  String get title;
  @override
  String get time;
  @override
  String get kcal;
  @override
  ActivityType get type;
  @override
  List<MealItem>? get mealItems;

  /// Create a copy of ActivityItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActivityItemImplCopyWith<_$ActivityItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MealItem _$MealItemFromJson(Map<String, dynamic> json) {
  return _MealItem.fromJson(json);
}

/// @nodoc
mixin _$MealItem {
  String get name => throw _privateConstructorUsedError;
  String get kcal => throw _privateConstructorUsedError;

  /// Serializes this MealItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MealItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MealItemCopyWith<MealItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MealItemCopyWith<$Res> {
  factory $MealItemCopyWith(MealItem value, $Res Function(MealItem) then) =
      _$MealItemCopyWithImpl<$Res, MealItem>;
  @useResult
  $Res call({String name, String kcal});
}

/// @nodoc
class _$MealItemCopyWithImpl<$Res, $Val extends MealItem>
    implements $MealItemCopyWith<$Res> {
  _$MealItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MealItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? kcal = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      kcal: null == kcal
          ? _value.kcal
          : kcal // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MealItemImplCopyWith<$Res>
    implements $MealItemCopyWith<$Res> {
  factory _$$MealItemImplCopyWith(
          _$MealItemImpl value, $Res Function(_$MealItemImpl) then) =
      __$$MealItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String kcal});
}

/// @nodoc
class __$$MealItemImplCopyWithImpl<$Res>
    extends _$MealItemCopyWithImpl<$Res, _$MealItemImpl>
    implements _$$MealItemImplCopyWith<$Res> {
  __$$MealItemImplCopyWithImpl(
      _$MealItemImpl _value, $Res Function(_$MealItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of MealItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? kcal = null,
  }) {
    return _then(_$MealItemImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      kcal: null == kcal
          ? _value.kcal
          : kcal // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MealItemImpl implements _MealItem {
  const _$MealItemImpl({required this.name, required this.kcal});

  factory _$MealItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$MealItemImplFromJson(json);

  @override
  final String name;
  @override
  final String kcal;

  @override
  String toString() {
    return 'MealItem(name: $name, kcal: $kcal)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MealItemImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.kcal, kcal) || other.kcal == kcal));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, kcal);

  /// Create a copy of MealItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MealItemImplCopyWith<_$MealItemImpl> get copyWith =>
      __$$MealItemImplCopyWithImpl<_$MealItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MealItemImplToJson(
      this,
    );
  }
}

abstract class _MealItem implements MealItem {
  const factory _MealItem(
      {required final String name,
      required final String kcal}) = _$MealItemImpl;

  factory _MealItem.fromJson(Map<String, dynamic> json) =
      _$MealItemImpl.fromJson;

  @override
  String get name;
  @override
  String get kcal;

  /// Create a copy of MealItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MealItemImplCopyWith<_$MealItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
