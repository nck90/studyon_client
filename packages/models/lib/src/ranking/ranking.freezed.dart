// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ranking.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RankingResponse _$RankingResponseFromJson(Map<String, dynamic> json) {
  return _RankingResponse.fromJson(json);
}

/// @nodoc
mixin _$RankingResponse {
  MyRank get myRank => throw _privateConstructorUsedError;
  List<RankingItem> get items => throw _privateConstructorUsedError;

  /// Serializes this RankingResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RankingResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RankingResponseCopyWith<RankingResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RankingResponseCopyWith<$Res> {
  factory $RankingResponseCopyWith(
    RankingResponse value,
    $Res Function(RankingResponse) then,
  ) = _$RankingResponseCopyWithImpl<$Res, RankingResponse>;
  @useResult
  $Res call({MyRank myRank, List<RankingItem> items});

  $MyRankCopyWith<$Res> get myRank;
}

/// @nodoc
class _$RankingResponseCopyWithImpl<$Res, $Val extends RankingResponse>
    implements $RankingResponseCopyWith<$Res> {
  _$RankingResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RankingResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? myRank = null, Object? items = null}) {
    return _then(
      _value.copyWith(
            myRank: null == myRank
                ? _value.myRank
                : myRank // ignore: cast_nullable_to_non_nullable
                      as MyRank,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<RankingItem>,
          )
          as $Val,
    );
  }

  /// Create a copy of RankingResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MyRankCopyWith<$Res> get myRank {
    return $MyRankCopyWith<$Res>(_value.myRank, (value) {
      return _then(_value.copyWith(myRank: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RankingResponseImplCopyWith<$Res>
    implements $RankingResponseCopyWith<$Res> {
  factory _$$RankingResponseImplCopyWith(
    _$RankingResponseImpl value,
    $Res Function(_$RankingResponseImpl) then,
  ) = __$$RankingResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({MyRank myRank, List<RankingItem> items});

  @override
  $MyRankCopyWith<$Res> get myRank;
}

/// @nodoc
class __$$RankingResponseImplCopyWithImpl<$Res>
    extends _$RankingResponseCopyWithImpl<$Res, _$RankingResponseImpl>
    implements _$$RankingResponseImplCopyWith<$Res> {
  __$$RankingResponseImplCopyWithImpl(
    _$RankingResponseImpl _value,
    $Res Function(_$RankingResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RankingResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? myRank = null, Object? items = null}) {
    return _then(
      _$RankingResponseImpl(
        myRank: null == myRank
            ? _value.myRank
            : myRank // ignore: cast_nullable_to_non_nullable
                  as MyRank,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<RankingItem>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RankingResponseImpl extends _RankingResponse {
  const _$RankingResponseImpl({
    required this.myRank,
    final List<RankingItem> items = const [],
  }) : _items = items,
       super._();

  factory _$RankingResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$RankingResponseImplFromJson(json);

  @override
  final MyRank myRank;
  final List<RankingItem> _items;
  @override
  @JsonKey()
  List<RankingItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'RankingResponse(myRank: $myRank, items: $items)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RankingResponseImpl &&
            (identical(other.myRank, myRank) || other.myRank == myRank) &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    myRank,
    const DeepCollectionEquality().hash(_items),
  );

  /// Create a copy of RankingResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RankingResponseImplCopyWith<_$RankingResponseImpl> get copyWith =>
      __$$RankingResponseImplCopyWithImpl<_$RankingResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RankingResponseImplToJson(this);
  }
}

abstract class _RankingResponse extends RankingResponse {
  const factory _RankingResponse({
    required final MyRank myRank,
    final List<RankingItem> items,
  }) = _$RankingResponseImpl;
  const _RankingResponse._() : super._();

  factory _RankingResponse.fromJson(Map<String, dynamic> json) =
      _$RankingResponseImpl.fromJson;

  @override
  MyRank get myRank;
  @override
  List<RankingItem> get items;

  /// Create a copy of RankingResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RankingResponseImplCopyWith<_$RankingResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MyRank _$MyRankFromJson(Map<String, dynamic> json) {
  return _MyRank.fromJson(json);
}

/// @nodoc
mixin _$MyRank {
  int get rankNo => throw _privateConstructorUsedError;
  int get score => throw _privateConstructorUsedError;

  /// Serializes this MyRank to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MyRank
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MyRankCopyWith<MyRank> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MyRankCopyWith<$Res> {
  factory $MyRankCopyWith(MyRank value, $Res Function(MyRank) then) =
      _$MyRankCopyWithImpl<$Res, MyRank>;
  @useResult
  $Res call({int rankNo, int score});
}

/// @nodoc
class _$MyRankCopyWithImpl<$Res, $Val extends MyRank>
    implements $MyRankCopyWith<$Res> {
  _$MyRankCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MyRank
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? rankNo = null, Object? score = null}) {
    return _then(
      _value.copyWith(
            rankNo: null == rankNo
                ? _value.rankNo
                : rankNo // ignore: cast_nullable_to_non_nullable
                      as int,
            score: null == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MyRankImplCopyWith<$Res> implements $MyRankCopyWith<$Res> {
  factory _$$MyRankImplCopyWith(
    _$MyRankImpl value,
    $Res Function(_$MyRankImpl) then,
  ) = __$$MyRankImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int rankNo, int score});
}

/// @nodoc
class __$$MyRankImplCopyWithImpl<$Res>
    extends _$MyRankCopyWithImpl<$Res, _$MyRankImpl>
    implements _$$MyRankImplCopyWith<$Res> {
  __$$MyRankImplCopyWithImpl(
    _$MyRankImpl _value,
    $Res Function(_$MyRankImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MyRank
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? rankNo = null, Object? score = null}) {
    return _then(
      _$MyRankImpl(
        rankNo: null == rankNo
            ? _value.rankNo
            : rankNo // ignore: cast_nullable_to_non_nullable
                  as int,
        score: null == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MyRankImpl extends _MyRank {
  const _$MyRankImpl({required this.rankNo, required this.score}) : super._();

  factory _$MyRankImpl.fromJson(Map<String, dynamic> json) =>
      _$$MyRankImplFromJson(json);

  @override
  final int rankNo;
  @override
  final int score;

  @override
  String toString() {
    return 'MyRank(rankNo: $rankNo, score: $score)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MyRankImpl &&
            (identical(other.rankNo, rankNo) || other.rankNo == rankNo) &&
            (identical(other.score, score) || other.score == score));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, rankNo, score);

  /// Create a copy of MyRank
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MyRankImplCopyWith<_$MyRankImpl> get copyWith =>
      __$$MyRankImplCopyWithImpl<_$MyRankImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MyRankImplToJson(this);
  }
}

abstract class _MyRank extends MyRank {
  const factory _MyRank({required final int rankNo, required final int score}) =
      _$MyRankImpl;
  const _MyRank._() : super._();

  factory _MyRank.fromJson(Map<String, dynamic> json) = _$MyRankImpl.fromJson;

  @override
  int get rankNo;
  @override
  int get score;

  /// Create a copy of MyRank
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MyRankImplCopyWith<_$MyRankImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RankingItem _$RankingItemFromJson(Map<String, dynamic> json) {
  return _RankingItem.fromJson(json);
}

/// @nodoc
mixin _$RankingItem {
  String get studentId => throw _privateConstructorUsedError;
  String get studentName => throw _privateConstructorUsedError;
  int get rankNo => throw _privateConstructorUsedError;
  int get score => throw _privateConstructorUsedError;

  /// Serializes this RankingItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RankingItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RankingItemCopyWith<RankingItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RankingItemCopyWith<$Res> {
  factory $RankingItemCopyWith(
    RankingItem value,
    $Res Function(RankingItem) then,
  ) = _$RankingItemCopyWithImpl<$Res, RankingItem>;
  @useResult
  $Res call({String studentId, String studentName, int rankNo, int score});
}

/// @nodoc
class _$RankingItemCopyWithImpl<$Res, $Val extends RankingItem>
    implements $RankingItemCopyWith<$Res> {
  _$RankingItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RankingItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? studentId = null,
    Object? studentName = null,
    Object? rankNo = null,
    Object? score = null,
  }) {
    return _then(
      _value.copyWith(
            studentId: null == studentId
                ? _value.studentId
                : studentId // ignore: cast_nullable_to_non_nullable
                      as String,
            studentName: null == studentName
                ? _value.studentName
                : studentName // ignore: cast_nullable_to_non_nullable
                      as String,
            rankNo: null == rankNo
                ? _value.rankNo
                : rankNo // ignore: cast_nullable_to_non_nullable
                      as int,
            score: null == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RankingItemImplCopyWith<$Res>
    implements $RankingItemCopyWith<$Res> {
  factory _$$RankingItemImplCopyWith(
    _$RankingItemImpl value,
    $Res Function(_$RankingItemImpl) then,
  ) = __$$RankingItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String studentId, String studentName, int rankNo, int score});
}

/// @nodoc
class __$$RankingItemImplCopyWithImpl<$Res>
    extends _$RankingItemCopyWithImpl<$Res, _$RankingItemImpl>
    implements _$$RankingItemImplCopyWith<$Res> {
  __$$RankingItemImplCopyWithImpl(
    _$RankingItemImpl _value,
    $Res Function(_$RankingItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RankingItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? studentId = null,
    Object? studentName = null,
    Object? rankNo = null,
    Object? score = null,
  }) {
    return _then(
      _$RankingItemImpl(
        studentId: null == studentId
            ? _value.studentId
            : studentId // ignore: cast_nullable_to_non_nullable
                  as String,
        studentName: null == studentName
            ? _value.studentName
            : studentName // ignore: cast_nullable_to_non_nullable
                  as String,
        rankNo: null == rankNo
            ? _value.rankNo
            : rankNo // ignore: cast_nullable_to_non_nullable
                  as int,
        score: null == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RankingItemImpl extends _RankingItem {
  const _$RankingItemImpl({
    required this.studentId,
    required this.studentName,
    required this.rankNo,
    required this.score,
  }) : super._();

  factory _$RankingItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$RankingItemImplFromJson(json);

  @override
  final String studentId;
  @override
  final String studentName;
  @override
  final int rankNo;
  @override
  final int score;

  @override
  String toString() {
    return 'RankingItem(studentId: $studentId, studentName: $studentName, rankNo: $rankNo, score: $score)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RankingItemImpl &&
            (identical(other.studentId, studentId) ||
                other.studentId == studentId) &&
            (identical(other.studentName, studentName) ||
                other.studentName == studentName) &&
            (identical(other.rankNo, rankNo) || other.rankNo == rankNo) &&
            (identical(other.score, score) || other.score == score));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, studentId, studentName, rankNo, score);

  /// Create a copy of RankingItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RankingItemImplCopyWith<_$RankingItemImpl> get copyWith =>
      __$$RankingItemImplCopyWithImpl<_$RankingItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RankingItemImplToJson(this);
  }
}

abstract class _RankingItem extends RankingItem {
  const factory _RankingItem({
    required final String studentId,
    required final String studentName,
    required final int rankNo,
    required final int score,
  }) = _$RankingItemImpl;
  const _RankingItem._() : super._();

  factory _RankingItem.fromJson(Map<String, dynamic> json) =
      _$RankingItemImpl.fromJson;

  @override
  String get studentId;
  @override
  String get studentName;
  @override
  int get rankNo;
  @override
  int get score;

  /// Create a copy of RankingItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RankingItemImplCopyWith<_$RankingItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
