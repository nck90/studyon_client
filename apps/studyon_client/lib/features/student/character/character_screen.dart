import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyon_design_system/studyon_design_system.dart';

import '../../../shared/providers/app_providers.dart';
import '../../../shared/utils/snackbar_helper.dart';
import 'character_avatar.dart';

const _categories = ['HAT', 'GLASSES', 'OUTFIT', 'BACKGROUND', 'EXPRESSION'];
const _categoryLabels = {
  'HAT': '모자',
  'GLASSES': '안경',
  'OUTFIT': '옷',
  'BACKGROUND': '배경',
  'EXPRESSION': '표정',
};
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
        _balance =
            ((results[2] as Map<String, dynamic>)['balance'] as num?)
                ?.toInt() ??
            0;
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
      case 'HAT':
        return _character['hatItemId'] as String?;
      case 'GLASSES':
        return _character['glassesItemId'] as String?;
      case 'OUTFIT':
        return _character['outfitItemId'] as String?;
      case 'BACKGROUND':
        return _character['bgItemId'] as String?;
      case 'EXPRESSION':
        return _character['expressionItemId'] as String?;
      default:
        return null;
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
      if (!mounted) return;
      showStudyonSnackbar(context, '${item['name']} 구매 완료!');
      _load();
    } catch (e) {
      if (!mounted) return;
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
      final slots = <String, String?>{};
      switch (category) {
        case 'HAT':
          slots['hatItemId'] = newId;
          break;
        case 'GLASSES':
          slots['glassesItemId'] = newId;
          break;
        case 'OUTFIT':
          slots['outfitItemId'] = newId;
          break;
        case 'BACKGROUND':
          slots['bgItemId'] = newId;
          break;
        case 'EXPRESSION':
          slots['expressionItemId'] = newId;
          break;
      }
      await api.patchEquippedCharacterItems(slots);
      if (!mounted) return;
      showStudyonSnackbar(
        context,
        newId == null ? '${item['name']} 장착 해제' : '${item['name']} 장착 완료',
      );
      _load();
    } catch (_) {
      if (!mounted) return;
      showStudyonSnackbar(context, '장착에 실패했어요', isError: true);
    }
  }

  int get _level => (_character['level'] as num?)?.toInt() ?? 1;
  int get _xp => (_character['xp'] as num?)?.toInt() ?? 0;
  int get _xpToNext => (_character['xpToNext'] as num?)?.toInt() ?? 100;
  String get _stageLabel =>
      _character['growthStageLabel']?.toString() ?? _stageLabelFor(_level);

  double get _xpProgress {
    final next = _xpToNext;
    final total = _xp + next;
    if (total <= 0) return 0;
    return (_xp / total).clamp(0.0, 1.0);
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
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 20,
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            '캐릭터 꾸미기',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.tintPurple,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.toll_rounded,
                                size: 14,
                                color: AppColors.primary,
                              ),
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

                  _GrowthHero(
                    character: _character,
                    level: _level,
                    xp: _xp,
                    xpToNext: _xpToNext,
                    xpProgress: _xpProgress,
                    stageLabel: _stageLabel,
                  ),

                  const SizedBox(height: 16),

                  // Category tabs
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _categories.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final active = _selectedCategory == cat;
                        return PressableScale(
                          onTap: () => setState(() => _selectedCategory = cat),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: active
                                  ? AppColors.primary
                                  : AppColors.card(context),
                              borderRadius: BorderRadius.circular(20),
                              border: active
                                  ? null
                                  : Border.all(color: AppColors.cardBorder),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _categoryIcons[cat] ?? Icons.star_rounded,
                                  size: 16,
                                  color: active
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _categoryLabels[cat] ?? cat,
                                  style: AppTypography.labelSmall.copyWith(
                                    color: active
                                        ? Colors.white
                                        : AppColors.textSecondary,
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
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.85,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                            itemCount: _filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = _filteredItems[index];
                              final owned =
                                  item['owned'] == true ||
                                  item['isDefault'] == true;
                              final equipped =
                                  _equippedIdFor(item['category'] as String) ==
                                  item['id'];
                              final price =
                                  (item['price'] as num?)?.toInt() ?? 0;

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
                                      color: equipped
                                          ? AppColors.primary
                                          : AppColors.cardBorder,
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
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                          child: Center(
                                            child: CharacterItemIcon(
                                              svgKey:
                                                  item['svgKey'] as String? ??
                                                  '',
                                              size: 48,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          12,
                                          0,
                                          12,
                                          12,
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              item['name'] as String? ?? '',
                                              style: AppTypography.titleMedium
                                                  .copyWith(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            if (equipped)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 3,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Text(
                                                  '장착중',
                                                  style: AppTypography.caption
                                                      .copyWith(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                ),
                                              )
                                            else if (owned)
                                              Text(
                                                '보유중',
                                                style: AppTypography.caption
                                                    .copyWith(
                                                      color: AppColors.accent,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                              )
                                            else
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.toll_rounded,
                                                    size: 12,
                                                    color: AppColors.primary,
                                                  ),
                                                  const SizedBox(width: 3),
                                                  Text(
                                                    price == 0
                                                        ? '무료'
                                                        : '${price}P',
                                                    style: AppTypography
                                                        .labelSmall
                                                        .copyWith(
                                                          color:
                                                              AppColors.primary,
                                                          fontWeight:
                                                              FontWeight.w800,
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

class _GrowthHero extends StatelessWidget {
  const _GrowthHero({
    required this.character,
    required this.level,
    required this.xp,
    required this.xpToNext,
    required this.xpProgress,
    required this.stageLabel,
  });

  final Map<String, dynamic> character;
  final int level;
  final int xp;
  final int xpToNext;
  final double xpProgress;
  final String stageLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.12),
            AppColors.accent.withValues(alpha: 0.08),
            AppColors.card(context),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          CharacterAvatar(character: character, size: 130),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    'Lv.$level $stageLabel',
                    style: AppTypography.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '퀘스트와 공부로 성장해요',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '다음 레벨까지 ${xpToNext}XP',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: xpProgress,
                    minHeight: 9,
                    color: AppColors.primary,
                    backgroundColor: Colors.white.withValues(alpha: 0.64),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '현재 $xp XP',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _stageLabelFor(int level) {
  if (level >= 15) return '마스터';
  if (level >= 10) return '도전가';
  if (level >= 6) return '집중러';
  if (level >= 3) return '루틴러';
  return '입문자';
}
