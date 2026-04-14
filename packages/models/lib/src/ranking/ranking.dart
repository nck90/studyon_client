import 'package:freezed_annotation/freezed_annotation.dart';

part 'ranking.freezed.dart';
part 'ranking.g.dart';

@freezed
class RankingResponse with _$RankingResponse {
  const RankingResponse._();
  const factory RankingResponse({
    required MyRank myRank,
    @Default([]) List<RankingItem> items,
  }) = _RankingResponse;

  factory RankingResponse.fromJson(Map<String, dynamic> json) =>
      _$RankingResponseFromJson(json);
}

@freezed
class MyRank with _$MyRank {
  const MyRank._();
  const factory MyRank({
    required int rankNo,
    required int score,
  }) = _MyRank;

  factory MyRank.fromJson(Map<String, dynamic> json) =>
      _$MyRankFromJson(json);
}

@freezed
class RankingItem with _$RankingItem {
  const RankingItem._();
  const factory RankingItem({
    required String studentId,
    required String studentName,
    required int rankNo,
    required int score,
  }) = _RankingItem;

  factory RankingItem.fromJson(Map<String, dynamic> json) =>
      _$RankingItemFromJson(json);
}
