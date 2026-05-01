import 'package:freezed_annotation/freezed_annotation.dart';

part 'character_item.freezed.dart';
part 'character_item.g.dart';

@freezed
class CharacterItem with _$CharacterItem {
  const factory CharacterItem({
    required String id,
    required String category, // HAT, GLASSES, OUTFIT, BACKGROUND, EXPRESSION
    required String name,
    String? description,
    @Default(0) int price,
    required String svgKey,
    @Default(0) int sortOrder,
    @Default(false) bool isDefault,
    @Default(false) bool owned,
  }) = _CharacterItem;

  factory CharacterItem.fromJson(Map<String, dynamic> json) =>
      _$CharacterItemFromJson(json);
}

@freezed
class StudentCharacter with _$StudentCharacter {
  const factory StudentCharacter({
    required String id,
    required String studentId,
    String? hatItemId,
    String? glassesItemId,
    String? outfitItemId,
    String? bgItemId,
    String? expressionItemId,
    @Default([]) List<CharacterItem> equippedItems,
  }) = _StudentCharacter;

  factory StudentCharacter.fromJson(Map<String, dynamic> json) =>
      _$StudentCharacterFromJson(json);
}
