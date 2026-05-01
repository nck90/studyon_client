import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyon_design_system/studyon_design_system.dart';

import '../../../shared/providers/app_providers.dart';
import '../../../shared/utils/snackbar_helper.dart';
import 'character_avatar.dart';

const _categories = ['HAT', 'GLASSES', 'OUTFIT', 'BACKGROUND', 'EXPRESSION'];
const _categoryLabels = {'HAT': '모자', 'GLASSES': '안경', 'OUTFIT': '옷', 'BACKGROUND': '배경', 'EXPRESSION': '표정'};
const _categoryIcons = {
  'HAT': Icons.checkroom_rounded,
  'GLASSES': Icons.visibility_rounded,
  'OUTFIT': Icons.dry_cleaning_rounded,
  'BACKGROUND': Icons.wallpaper_rounded,
  'EXPRESSION': Icons.mood_rounded,
};

class CharacterScreen extends ConsumerStatefulWidget {
  const CharacterScreen({super.key});
  @override
  ConsumerState<CharacterScreen> createState() => _CharacterScreenState();
}

class _CharacterScreenState extends ConsumerState<CharacterScreen> {
  String _selectedCategory = 'HAT';
  List<Map<String, dynamic>> _shopItems = [];
  Map<String, dynamic> _character = {};
  int _balance = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final api = ref.read(studentApiProvider);
      final results = await Future.wait([
        api.getMyCharacter(),
        api.getCharacterShop(),
        api.getPointBalance(),
      ]);
      if (!mounted) return;
      setState(() {
        _character = results[0] as Map<String, dynamic>;
        _shopItems = (results[1] as List).cast<Map<String, dynamic>>();
        _balance = ((results[2] as Map<String, dynamic>)['balance'] as num?)?.toInt() ?? 0;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredItems =>
      _shopItems.where((i) => i['category'] == _selectedCategory).toList();

  String? _equippedIdFor(String category) {
    switch (category) {
      case 'HAT': return _character['hatItemId'] as String?;
      case 'GLASSES': return _character['glassesItemId'] as String?;
      case 'OUTFIT': return _character['outfitItemId'] as String?;
      case 'BACKGROUND': return _character['bgItemId'] as String?;
      case 'EXPRESSION': return _character['expressionItemId'] as String?;
      default: return null;
    }
  }

  Future<void> _buy(Map<String, dynamic> item) async {
    final price = (item['price'] as num?)?.toInt() ?? 0;
    if (price > _balance) {
      showStudyonSnackbar(context, '포인트가 부족해요 (${price}P 필요)', isError: true);
      return;
    }
    try {
      final api = ref.read(studentApiProvider);
      await api.buyCharacterItem(item['id'] as String);
      showStudyonSnackbar(context, '${item['name']} 구매 완료!');
      _load();
    } catch (e) {
      showStudyonSnackbar(context, '구매에 실패했어요', isError: true);
    }
  }

  Future<void> _equip(Map<String, dynamic> item) async {
    final category = item['category'] as String;
    final itemId = item['id'] as String;
    final currentEquipped = _equippedIdFor(category);
    final newId = currentEquipped == itemId ? null : itemId;

    try {
      final api = ref.read(studentApiProvider);
      final body = <String, String?>{};
      switch (category) {
        case 'HAT': body['hatItemId'] = newId; break;
        case 'GLASSES': body['glassesItemId'] = newId; break;
        case 'OUTFIT': body['outfitItemId'] = newId; break;
        case 'BACKGROUND': body['bgItemId'] = newId; break;
        case 'EXPRESSION': body['expressionItemId'] = newId; break;
      }
      await api.equipCharacterItems(
        hatItemId: body['hatItemId'],
        glassesItemId: body['glassesItemId'],
        outfitItemId: body['outfitItemId'],
        bgItemId: body['bgItemId'],
        expressionItemId: body['expressionItemId'],
      );
      _load();
    } catch (_) {
      showStudyonSnackbar(context, '장착에 실패했어요', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                        ),
                        const Expanded(
                          child: Text('캐릭터 꾸미기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.tintPurple,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.toll_rounded, size: 14, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text(
                                '${_balance}P',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Character preview
                  Container(
                    height: 180,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.05),
                          AppColors.bg(context),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Center(
                      child: CharacterAvatar(
                        character: _character,
                        size: 120,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Category tabs
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final active = _selectedCategory == cat;
                        return PressableScale(
                          onTap: () => setState(() => _selectedCategory = cat),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: active ? AppColors.primary : AppColors.card(context),
                              borderRadius: BorderRadius.circular(20),
                              border: active ? null : Border.all(color: AppColors.cardBorder),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _categoryIcons[cat] ?? Icons.star_rounded,
                                  size: 16,
                                  color: active ? Colors.white : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _categoryLabels[cat] ?? cat,
                                  style: AppTypography.labelSmall.copyWith(
                                    color: active ? Colors.white : AppColors.textSecondary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Items grid
                  Expanded(
                    child: _filteredItems.isEmpty
                        ? Center(
                            child: Text(
                              '아이템이 없어요',
                              style: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.85,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: _filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = _filteredItems[index];
                              final owned = item['owned'] == true || item['isDefault'] == true;
                              final equipped = _equippedIdFor(item['category'] as String) == item['id'];
                              final price = (item['price'] as num?)?.toInt() ?? 0;

                              return PressableScale(
                                onTap: () {
                                  if (owned) {
                                    _equip(item);
                                  } else {
                                    _buy(item);
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.card(context),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: equipped ? AppColors.primary : AppColors.cardBorder,
                                      width: equipped ? 2 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          margin: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: AppColors.bg(context),
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          child: Center(
                                            child: CharacterItemIcon(
                                              svgKey: item['svgKey'] as String? ?? '',
                                              size: 48,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                                        child: Column(
                                          children: [
                                            Text(
                                              item['name'] as String? ?? '',
                                              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            if (equipped)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary,
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: Text(
                                                  '장착중',
                                                  style: AppTypography.caption.copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              )
                                            else if (owned)
                                              Text(
                                                '보유중',
                                                style: AppTypography.caption.copyWith(
                                                  color: AppColors.accent,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              )
                                            else
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  const Icon(Icons.toll_rounded, size: 12, color: AppColors.primary),
                                                  const SizedBox(width: 3),
                                                  Text(
                                                    price == 0 ? '무료' : '${price}P',
                                                    style: AppTypography.labelSmall.copyWith(
                                                      color: AppColors.primary,
                                                      fontWeight: FontWeight.w800,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
