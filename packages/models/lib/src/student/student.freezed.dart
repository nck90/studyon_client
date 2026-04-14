// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'student.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Student _$StudentFromJson(Map<String, dynamic> json) {
  return _Student.fromJson(json);
}

/// @nodoc
mixin _$Student {
  String get id => throw _privateConstructorUsedError;
  String get studentNo => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get gradeId => throw _privateConstructorUsedError;
  String? get classId => throw _privateConstructorUsedError;
  String? get groupId => throw _privateConstructorUsedError;
  String? get gradeName => throw _privateConstructorUsedError;
  String? get className => throw _privateConstructorUsedError;
  String? get groupName => throw _privateConstructorUsedError;
  String? get assignedSeatId => throw _privateConstructorUsedError;
  String? get assignedSeatNo => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;

  /// Serializes this Student to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Student
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StudentCopyWith<Student> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudentCopyWith<$Res> {
  factory $StudentCopyWith(Student value, $Res Function(Student) then) =
      _$StudentCopyWithImpl<$Res, Student>;
  @useResult
  $Res call({
    String id,
    String studentNo,
    String name,
    String? gradeId,
    String? classId,
    String? groupId,
    String? gradeName,
    String? className,
    String? groupName,
    String? assignedSeatId,
    String? assignedSeatNo,
    String status,
  });
}

/// @nodoc
class _$StudentCopyWithImpl<$Res, $Val extends Student>
    implements $StudentCopyWith<$Res> {
  _$StudentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Student
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? studentNo = null,
    Object? name = null,
    Object? gradeId = freezed,
    Object? classId = freezed,
    Object? groupId = freezed,
    Object? gradeName = freezed,
    Object? className = freezed,
    Object? groupName = freezed,
    Object? assignedSeatId = freezed,
    Object? assignedSeatNo = freezed,
    Object? status = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            studentNo: null == studentNo
                ? _value.studentNo
                : studentNo // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            gradeId: freezed == gradeId
                ? _value.gradeId
                : gradeId // ignore: cast_nullable_to_non_nullable
                      as String?,
            classId: freezed == classId
                ? _value.classId
                : classId // ignore: cast_nullable_to_non_nullable
                      as String?,
            groupId: freezed == groupId
                ? _value.groupId
                : groupId // ignore: cast_nullable_to_non_nullable
                      as String?,
            gradeName: freezed == gradeName
                ? _value.gradeName
                : gradeName // ignore: cast_nullable_to_non_nullable
                      as String?,
            className: freezed == className
                ? _value.className
                : className // ignore: cast_nullable_to_non_nullable
                      as String?,
            groupName: freezed == groupName
                ? _value.groupName
                : groupName // ignore: cast_nullable_to_non_nullable
                      as String?,
            assignedSeatId: freezed == assignedSeatId
                ? _value.assignedSeatId
                : assignedSeatId // ignore: cast_nullable_to_non_nullable
                      as String?,
            assignedSeatNo: freezed == assignedSeatNo
                ? _value.assignedSeatNo
                : assignedSeatNo // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StudentImplCopyWith<$Res> implements $StudentCopyWith<$Res> {
  factory _$$StudentImplCopyWith(
    _$StudentImpl value,
    $Res Function(_$StudentImpl) then,
  ) = __$$StudentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String studentNo,
    String name,
    String? gradeId,
    String? classId,
    String? groupId,
    String? gradeName,
    String? className,
    String? groupName,
    String? assignedSeatId,
    String? assignedSeatNo,
    String status,
  });
}

/// @nodoc
class __$$StudentImplCopyWithImpl<$Res>
    extends _$StudentCopyWithImpl<$Res, _$StudentImpl>
    implements _$$StudentImplCopyWith<$Res> {
  __$$StudentImplCopyWithImpl(
    _$StudentImpl _value,
    $Res Function(_$StudentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Student
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? studentNo = null,
    Object? name = null,
    Object? gradeId = freezed,
    Object? classId = freezed,
    Object? groupId = freezed,
    Object? gradeName = freezed,
    Object? className = freezed,
    Object? groupName = freezed,
    Object? assignedSeatId = freezed,
    Object? assignedSeatNo = freezed,
    Object? status = null,
  }) {
    return _then(
      _$StudentImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        studentNo: null == studentNo
            ? _value.studentNo
            : studentNo // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        gradeId: freezed == gradeId
            ? _value.gradeId
            : gradeId // ignore: cast_nullable_to_non_nullable
                  as String?,
        classId: freezed == classId
            ? _value.classId
            : classId // ignore: cast_nullable_to_non_nullable
                  as String?,
        groupId: freezed == groupId
            ? _value.groupId
            : groupId // ignore: cast_nullable_to_non_nullable
                  as String?,
        gradeName: freezed == gradeName
            ? _value.gradeName
            : gradeName // ignore: cast_nullable_to_non_nullable
                  as String?,
        className: freezed == className
            ? _value.className
            : className // ignore: cast_nullable_to_non_nullable
                  as String?,
        groupName: freezed == groupName
            ? _value.groupName
            : groupName // ignore: cast_nullable_to_non_nullable
                  as String?,
        assignedSeatId: freezed == assignedSeatId
            ? _value.assignedSeatId
            : assignedSeatId // ignore: cast_nullable_to_non_nullable
                  as String?,
        assignedSeatNo: freezed == assignedSeatNo
            ? _value.assignedSeatNo
            : assignedSeatNo // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StudentImpl extends _Student {
  const _$StudentImpl({
    required this.id,
    required this.studentNo,
    required this.name,
    this.gradeId,
    this.classId,
    this.groupId,
    this.gradeName,
    this.className,
    this.groupName,
    this.assignedSeatId,
    this.assignedSeatNo,
    required this.status,
  }) : super._();

  factory _$StudentImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudentImplFromJson(json);

  @override
  final String id;
  @override
  final String studentNo;
  @override
  final String name;
  @override
  final String? gradeId;
  @override
  final String? classId;
  @override
  final String? groupId;
  @override
  final String? gradeName;
  @override
  final String? className;
  @override
  final String? groupName;
  @override
  final String? assignedSeatId;
  @override
  final String? assignedSeatNo;
  @override
  final String status;

  @override
  String toString() {
    return 'Student(id: $id, studentNo: $studentNo, name: $name, gradeId: $gradeId, classId: $classId, groupId: $groupId, gradeName: $gradeName, className: $className, groupName: $groupName, assignedSeatId: $assignedSeatId, assignedSeatNo: $assignedSeatNo, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.studentNo, studentNo) ||
                other.studentNo == studentNo) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.gradeId, gradeId) || other.gradeId == gradeId) &&
            (identical(other.classId, classId) || other.classId == classId) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.gradeName, gradeName) ||
                other.gradeName == gradeName) &&
            (identical(other.className, className) ||
                other.className == className) &&
            (identical(other.groupName, groupName) ||
                other.groupName == groupName) &&
            (identical(other.assignedSeatId, assignedSeatId) ||
                other.assignedSeatId == assignedSeatId) &&
            (identical(other.assignedSeatNo, assignedSeatNo) ||
                other.assignedSeatNo == assignedSeatNo) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    studentNo,
    name,
    gradeId,
    classId,
    groupId,
    gradeName,
    className,
    groupName,
    assignedSeatId,
    assignedSeatNo,
    status,
  );

  /// Create a copy of Student
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StudentImplCopyWith<_$StudentImpl> get copyWith =>
      __$$StudentImplCopyWithImpl<_$StudentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StudentImplToJson(this);
  }
}

abstract class _Student extends Student {
  const factory _Student({
    required final String id,
    required final String studentNo,
    required final String name,
    final String? gradeId,
    final String? classId,
    final String? groupId,
    final String? gradeName,
    final String? className,
    final String? groupName,
    final String? assignedSeatId,
    final String? assignedSeatNo,
    required final String status,
  }) = _$StudentImpl;
  const _Student._() : super._();

  factory _Student.fromJson(Map<String, dynamic> json) = _$StudentImpl.fromJson;

  @override
  String get id;
  @override
  String get studentNo;
  @override
  String get name;
  @override
  String? get gradeId;
  @override
  String? get classId;
  @override
  String? get groupId;
  @override
  String? get gradeName;
  @override
  String? get className;
  @override
  String? get groupName;
  @override
  String? get assignedSeatId;
  @override
  String? get assignedSeatNo;
  @override
  String get status;

  /// Create a copy of Student
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudentImplCopyWith<_$StudentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
