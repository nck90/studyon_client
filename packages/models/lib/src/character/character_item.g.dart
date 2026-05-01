// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CharacterItemImpl _$$CharacterItemImplFromJson(Map<String, dynamic> json) =>
    _$CharacterItemImpl(
      id: json['id'] as String,
      category: json['category'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toInt() ?? 0,
      svgKey: json['svgKey'] as String,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      isDefault: json['isDefault'] as bool? ?? false,
      owned: json['owned'] as bool? ?? false,
    );

Map<String, dynamic> _$$CharacterItemImplToJson(_$CharacterItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category': instance.category,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'svgKey': instance.svgKey,
      'sortOrder': instance.sortOrder,
      'isDefault': instance.isDefault,
      'owned': instance.owned,
    };

_$StudentCharacterImpl _$$StudentCharacterImplFromJson(
  Map<String, dynamic> json,
) => _$StudentCharacterImpl(
  id: json['id'] as String,
  studentId: json['studentId'] as String,
  hatItemId: json['hatItemId'] as String?,
  glassesItemId: json['glassesItemId'] as String?,
  outfitItemId: json['outfitItemId'] as String?,
  bgItemId: json['bgItemId'] as String?,
  expressionItemId: json['expressionItemId'] as String?,
  equippedItems:
      (json['equippedItems'] as List<dynamic>?)
          ?.map((e) => CharacterItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$StudentCharacterImplToJson(
  _$StudentCharacterImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'studentId': instance.studentId,
  'hatItemId': instance.hatItemId,
  'glassesItemId': instance.glassesItemId,
  'outfitItemId': instance.outfitItemId,
  'bgItemId': instance.bgItemId,
  'expressionItemId': instance.expressionItemId,
  'equippedItems': instance.equippedItems,
};
