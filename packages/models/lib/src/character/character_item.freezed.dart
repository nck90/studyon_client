// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'character_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CharacterItem _$CharacterItemFromJson(Map<String, dynamic> json) {
  return _CharacterItem.fromJson(json);
}

/// @nodoc
mixin _$CharacterItem {
  String get id => throw _privateConstructorUsedError;
  String get category =>
      throw _privateConstructorUsedError; // HAT, GLASSES, OUTFIT, BACKGROUND, EXPRESSION
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  int get price => throw _privateConstructorUsedError;
  String get svgKey => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;
  bool get isDefault => throw _privateConstructorUsedError;
  bool get owned => throw _privateConstructorUsedError;

  /// Serializes this CharacterItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CharacterItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CharacterItemCopyWith<CharacterItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CharacterItemCopyWith<$Res> {
  factory $CharacterItemCopyWith(
    CharacterItem value,
    $Res Function(CharacterItem) then,
  ) = _$CharacterItemCopyWithImpl<$Res, CharacterItem>;
  @useResult
  $Res call({
    String id,
    String category,
    String name,
    String? description,
    int price,
    String svgKey,
    int sortOrder,
    bool isDefault,
    bool owned,
  });
}

/// @nodoc
class _$CharacterItemCopyWithImpl<$Res, $Val extends CharacterItem>
    implements $CharacterItemCopyWith<$Res> {
  _$CharacterItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CharacterItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? category = null,
    Object? name = null,
    Object? description = freezed,
    Object? price = null,
    Object? svgKey = null,
    Object? sortOrder = null,
    Object? isDefault = null,
    Object? owned = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            price: null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as int,
            svgKey: null == svgKey
                ? _value.svgKey
                : svgKey // ignore: cast_nullable_to_non_nullable
                      as String,
            sortOrder: null == sortOrder
                ? _value.sortOrder
                : sortOrder // ignore: cast_nullable_to_non_nullable
                      as int,
            isDefault: null == isDefault
                ? _value.isDefault
                : isDefault // ignore: cast_nullable_to_non_nullable
                      as bool,
            owned: null == owned
                ? _value.owned
                : owned // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CharacterItemImplCopyWith<$Res>
    implements $CharacterItemCopyWith<$Res> {
  factory _$$CharacterItemImplCopyWith(
    _$CharacterItemImpl value,
    $Res Function(_$CharacterItemImpl) then,
  ) = __$$CharacterItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String category,
    String name,
    String? description,
    int price,
    String svgKey,
    int sortOrder,
    bool isDefault,
    bool owned,
  });
}

/// @nodoc
class __$$CharacterItemImplCopyWithImpl<$Res>
    extends _$CharacterItemCopyWithImpl<$Res, _$CharacterItemImpl>
    implements _$$CharacterItemImplCopyWith<$Res> {
  __$$CharacterItemImplCopyWithImpl(
    _$CharacterItemImpl _value,
    $Res Function(_$CharacterItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CharacterItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? category = null,
    Object? name = null,
    Object? description = freezed,
    Object? price = null,
    Object? svgKey = null,
    Object? sortOrder = null,
    Object? isDefault = null,
    Object? owned = null,
  }) {
    return _then(
      _$CharacterItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        price: null == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as int,
        svgKey: null == svgKey
            ? _value.svgKey
            : svgKey // ignore: cast_nullable_to_non_nullable
                  as String,
        sortOrder: null == sortOrder
            ? _value.sortOrder
            : sortOrder // ignore: cast_nullable_to_non_nullable
                  as int,
        isDefault: null == isDefault
            ? _value.isDefault
            : isDefault // ignore: cast_nullable_to_non_nullable
                  as bool,
        owned: null == owned
            ? _value.owned
            : owned // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CharacterItemImpl implements _CharacterItem {
  const _$CharacterItemImpl({
    required this.id,
    required this.category,
    required this.name,
    this.description,
    this.price = 0,
    required this.svgKey,
    this.sortOrder = 0,
    this.isDefault = false,
    this.owned = false,
  });

  factory _$CharacterItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$CharacterItemImplFromJson(json);

  @override
  final String id;
  @override
  final String category;
  // HAT, GLASSES, OUTFIT, BACKGROUND, EXPRESSION
  @override
  final String name;
  @override
  final String? description;
  @override
  @JsonKey()
  final int price;
  @override
  final String svgKey;
  @override
  @JsonKey()
  final int sortOrder;
  @override
  @JsonKey()
  final bool isDefault;
  @override
  @JsonKey()
  final bool owned;

  @override
  String toString() {
    return 'CharacterItem(id: $id, category: $category, name: $name, description: $description, price: $price, svgKey: $svgKey, sortOrder: $sortOrder, isDefault: $isDefault, owned: $owned)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CharacterItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.svgKey, svgKey) || other.svgKey == svgKey) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault) &&
            (identical(other.owned, owned) || other.owned == owned));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    category,
    name,
    description,
    price,
    svgKey,
    sortOrder,
    isDefault,
    owned,
  );

  /// Create a copy of CharacterItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CharacterItemImplCopyWith<_$CharacterItemImpl> get copyWith =>
      __$$CharacterItemImplCopyWithImpl<_$CharacterItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CharacterItemImplToJson(this);
  }
}

abstract class _CharacterItem implements CharacterItem {
  const factory _CharacterItem({
    required final String id,
    required final String category,
    required final String name,
    final String? description,
    final int price,
    required final String svgKey,
    final int sortOrder,
    final bool isDefault,
    final bool owned,
  }) = _$CharacterItemImpl;

  factory _CharacterItem.fromJson(Map<String, dynamic> json) =
      _$CharacterItemImpl.fromJson;

  @override
  String get id;
  @override
  String get category; // HAT, GLASSES, OUTFIT, BACKGROUND, EXPRESSION
  @override
  String get name;
  @override
  String? get description;
  @override
  int get price;
  @override
  String get svgKey;
  @override
  int get sortOrder;
  @override
  bool get isDefault;
  @override
  bool get owned;

  /// Create a copy of CharacterItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CharacterItemImplCopyWith<_$CharacterItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StudentCharacter _$StudentCharacterFromJson(Map<String, dynamic> json) {
  return _StudentCharacter.fromJson(json);
}

/// @nodoc
mixin _$StudentCharacter {
  String get id => throw _privateConstructorUsedError;
  String get studentId => throw _privateConstructorUsedError;
  String? get hatItemId => throw _privateConstructorUsedError;
  String? get glassesItemId => throw _privateConstructorUsedError;
  String? get outfitItemId => throw _privateConstructorUsedError;
  String? get bgItemId => throw _privateConstructorUsedError;
  String? get expressionItemId => throw _privateConstructorUsedError;
  List<CharacterItem> get equippedItems => throw _privateConstructorUsedError;

  /// Serializes this StudentCharacter to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StudentCharacter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StudentCharacterCopyWith<StudentCharacter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudentCharacterCopyWith<$Res> {
  factory $StudentCharacterCopyWith(
    StudentCharacter value,
    $Res Function(StudentCharacter) then,
  ) = _$StudentCharacterCopyWithImpl<$Res, StudentCharacter>;
  @useResult
  $Res call({
    String id,
    String studentId,
    String? hatItemId,
    String? glassesItemId,
    String? outfitItemId,
    String? bgItemId,
    String? expressionItemId,
    List<CharacterItem> equippedItems,
  });
}

/// @nodoc
class _$StudentCharacterCopyWithImpl<$Res, $Val extends StudentCharacter>
    implements $StudentCharacterCopyWith<$Res> {
  _$StudentCharacterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StudentCharacter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? studentId = null,
    Object? hatItemId = freezed,
    Object? glassesItemId = freezed,
    Object? outfitItemId = freezed,
    Object? bgItemId = freezed,
    Object? expressionItemId = freezed,
    Object? equippedItems = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            studentId: null == studentId
                ? _value.studentId
                : studentId // ignore: cast_nullable_to_non_nullable
                      as String,
            hatItemId: freezed == hatItemId
                ? _value.hatItemId
                : hatItemId // ignore: cast_nullable_to_non_nullable
                      as String?,
            glassesItemId: freezed == glassesItemId
                ? _value.glassesItemId
                : glassesItemId // ignore: cast_nullable_to_non_nullable
                      as String?,
            outfitItemId: freezed == outfitItemId
                ? _value.outfitItemId
                : outfitItemId // ignore: cast_nullable_to_non_nullable
                      as String?,
            bgItemId: freezed == bgItemId
                ? _value.bgItemId
                : bgItemId // ignore: cast_nullable_to_non_nullable
                      as String?,
            expressionItemId: freezed == expressionItemId
                ? _value.expressionItemId
                : expressionItemId // ignore: cast_nullable_to_non_nullable
                      as String?,
            equippedItems: null == equippedItems
                ? _value.equippedItems
                : equippedItems // ignore: cast_nullable_to_non_nullable
                      as List<CharacterItem>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StudentCharacterImplCopyWith<$Res>
    implements $StudentCharacterCopyWith<$Res> {
  factory _$$StudentCharacterImplCopyWith(
    _$StudentCharacterImpl value,
    $Res Function(_$StudentCharacterImpl) then,
  ) = __$$StudentCharacterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String studentId,
    String? hatItemId,
    String? glassesItemId,
    String? outfitItemId,
    String? bgItemId,
    String? expressionItemId,
    List<CharacterItem> equippedItems,
  });
}

/// @nodoc
class __$$StudentCharacterImplCopyWithImpl<$Res>
    extends _$StudentCharacterCopyWithImpl<$Res, _$StudentCharacterImpl>
    implements _$$StudentCharacterImplCopyWith<$Res> {
  __$$StudentCharacterImplCopyWithImpl(
    _$StudentCharacterImpl _value,
    $Res Function(_$StudentCharacterImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StudentCharacter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? studentId = null,
    Object? hatItemId = freezed,
    Object? glassesItemId = freezed,
    Object? outfitItemId = freezed,
    Object? bgItemId = freezed,
    Object? expressionItemId = freezed,
    Object? equippedItems = null,
  }) {
    return _then(
      _$StudentCharacterImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        studentId: null == studentId
            ? _value.studentId
            : studentId // ignore: cast_nullable_to_non_nullable
                  as String,
        hatItemId: freezed == hatItemId
            ? _value.hatItemId
            : hatItemId // ignore: cast_nullable_to_non_nullable
                  as String?,
        glassesItemId: freezed == glassesItemId
            ? _value.glassesItemId
            : glassesItemId // ignore: cast_nullable_to_non_nullable
                  as String?,
        outfitItemId: freezed == outfitItemId
            ? _value.outfitItemId
            : outfitItemId // ignore: cast_nullable_to_non_nullable
                  as String?,
        bgItemId: freezed == bgItemId
            ? _value.bgItemId
            : bgItemId // ignore: cast_nullable_to_non_nullable
                  as String?,
        expressionItemId: freezed == expressionItemId
            ? _value.expressionItemId
            : expressionItemId // ignore: cast_nullable_to_non_nullable
                  as String?,
        equippedItems: null == equippedItems
            ? _value._equippedItems
            : equippedItems // ignore: cast_nullable_to_non_nullable
                  as List<CharacterItem>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StudentCharacterImpl implements _StudentCharacter {
  const _$StudentCharacterImpl({
    required this.id,
    required this.studentId,
    this.hatItemId,
    this.glassesItemId,
    this.outfitItemId,
    this.bgItemId,
    this.expressionItemId,
    final List<CharacterItem> equippedItems = const [],
  }) : _equippedItems = equippedItems;

  factory _$StudentCharacterImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudentCharacterImplFromJson(json);

  @override
  final String id;
  @override
  final String studentId;
  @override
  final String? hatItemId;
  @override
  final String? glassesItemId;
  @override
  final String? outfitItemId;
  @override
  final String? bgItemId;
  @override
  final String? expressionItemId;
  final List<CharacterItem> _equippedItems;
  @override
  @JsonKey()
  List<CharacterItem> get equippedItems {
    if (_equippedItems is EqualUnmodifiableListView) return _equippedItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_equippedItems);
  }

  @override
  String toString() {
    return 'StudentCharacter(id: $id, studentId: $studentId, hatItemId: $hatItemId, glassesItemId: $glassesItemId, outfitItemId: $outfitItemId, bgItemId: $bgItemId, expressionItemId: $expressionItemId, equippedItems: $equippedItems)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudentCharacterImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.studentId, studentId) ||
                other.studentId == studentId) &&
            (identical(other.hatItemId, hatItemId) ||
                other.hatItemId == hatItemId) &&
            (identical(other.glassesItemId, glassesItemId) ||
                other.glassesItemId == glassesItemId) &&
            (identical(other.outfitItemId, outfitItemId) ||
                other.outfitItemId == outfitItemId) &&
            (identical(other.bgItemId, bgItemId) ||
                other.bgItemId == bgItemId) &&
            (identical(other.expressionItemId, expressionItemId) ||
                other.expressionItemId == expressionItemId) &&
            const DeepCollectionEquality().equals(
              other._equippedItems,
              _equippedItems,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    studentId,
    hatItemId,
    glassesItemId,
    outfitItemId,
    bgItemId,
    expressionItemId,
    const DeepCollectionEquality().hash(_equippedItems),
  );

  /// Create a copy of StudentCharacter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StudentCharacterImplCopyWith<_$StudentCharacterImpl> get copyWith =>
      __$$StudentCharacterImplCopyWithImpl<_$StudentCharacterImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$StudentCharacterImplToJson(this);
  }
}

abstract class _StudentCharacter implements StudentCharacter {
  const factory _StudentCharacter({
    required final String id,
    required final String studentId,
    final String? hatItemId,
    final String? glassesItemId,
    final String? outfitItemId,
    final String? bgItemId,
    final String? expressionItemId,
    final List<CharacterItem> equippedItems,
  }) = _$StudentCharacterImpl;

  factory _StudentCharacter.fromJson(Map<String, dynamic> json) =
      _$StudentCharacterImpl.fromJson;

  @override
  String get id;
  @override
  String get studentId;
  @override
  String? get hatItemId;
  @override
  String? get glassesItemId;
  @override
  String? get outfitItemId;
  @override
  String? get bgItemId;
  @override
  String? get expressionItemId;
  @override
  List<CharacterItem> get equippedItems;

  /// Create a copy of StudentCharacter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudentCharacterImplCopyWith<_$StudentCharacterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
