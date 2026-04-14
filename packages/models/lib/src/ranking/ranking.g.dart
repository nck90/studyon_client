// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ranking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RankingResponseImpl _$$RankingResponseImplFromJson(
  Map<String, dynamic> json,
) => _$RankingResponseImpl(
  myRank: MyRank.fromJson(json['myRank'] as Map<String, dynamic>),
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => RankingItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$RankingResponseImplToJson(
  _$RankingResponseImpl instance,
) => <String, dynamic>{'myRank': instance.myRank, 'items': instance.items};

_$MyRankImpl _$$MyRankImplFromJson(Map<String, dynamic> json) => _$MyRankImpl(
  rankNo: (json['rankNo'] as num).toInt(),
  score: (json['score'] as num).toInt(),
);

Map<String, dynamic> _$$MyRankImplToJson(_$MyRankImpl instance) =>
    <String, dynamic>{'rankNo': instance.rankNo, 'score': instance.score};

_$RankingItemImpl _$$RankingItemImplFromJson(Map<String, dynamic> json) =>
    _$RankingItemImpl(
      studentId: json['studentId'] as String,
      studentName: json['studentName'] as String,
      rankNo: (json['rankNo'] as num).toInt(),
      score: (json['score'] as num).toInt(),
    );

Map<String, dynamic> _$$RankingItemImplToJson(_$RankingItemImpl instance) =>
    <String, dynamic>{
      'studentId': instance.studentId,
      'studentName': instance.studentName,
      'rankNo': instance.rankNo,
      'score': instance.score,
    };
