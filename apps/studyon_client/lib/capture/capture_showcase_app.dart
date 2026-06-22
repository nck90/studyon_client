import 'package:flutter/material.dart';

class CaptureShowcaseApp extends StatelessWidget {
  const CaptureShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CaptureShowcaseScreen(),
    );
  }
}

class CaptureShowcaseScreen extends StatefulWidget {
  const CaptureShowcaseScreen({super.key});

  @override
  State<CaptureShowcaseScreen> createState() => _CaptureShowcaseScreenState();
}

class _CaptureShowcaseScreenState extends State<CaptureShowcaseScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = [
    _CapturePage(
      title: '오늘의 성장',
      subtitle: '공부 2시간 40분 · 연속 7일',
      badge: 'Lv. 12',
      image: 'assets/images/rpg/stage_03.png',
      mode: _CaptureMode.home,
    ),
    _CapturePage(
      title: '오늘 미션',
      subtitle: '수학 90분 집중하면 +120 XP',
      badge: '+30P',
      image: 'assets/images/rpg/stage_02.png',
      mode: _CaptureMode.mission,
    ),
    _CapturePage(
      title: '포인트',
      subtitle: '보상으로 테마와 꾸미기 열기',
      badge: '420P',
      image: 'assets/images/rpg/stage_04.png',
      mode: _CaptureMode.points,
    ),
    _CapturePage(
      title: '캐릭터 꾸미기',
      subtitle: '공부할수록 새싹이 자라나요',
      badge: 'Stage 4',
      image: 'assets/images/rpg/stage_05.png',
      mode: _CaptureMode.character,
    ),
    _CapturePage(
      title: '목표 테마',
      subtitle: '내 목표 대학을 배경으로',
      badge: 'Sky',
      image: 'assets/images/rpg/theme_sky.png',
      mode: _CaptureMode.theme,
    ),
    _CapturePage(
      title: '주간 리포트',
      subtitle: '이번 주 24시간 30분 집중',
      badge: '88%',
      image: 'assets/images/rpg/stage_01.png',
      mode: _CaptureMode.report,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final page = _pages[_page];
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      body: SafeArea(
        child: PageView.builder(
          controller: _controller,
          itemCount: _pages.length,
          onPageChanged: (value) => setState(() => _page = value),
          itemBuilder: (_, index) => _CapturePhonePage(
            page: _pages[index],
            index: index,
            total: _pages.length,
          ),
        ),
      ),
    );
  }
}

enum _CaptureMode { home, mission, points, character, theme, report }

class _CapturePage {
  const _CapturePage({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.image,
    required this.mode,
  });

  final String title;
  final String subtitle;
  final String badge;
  final String image;
  final _CaptureMode mode;
}

class _CapturePhonePage extends StatelessWidget {
  const _CapturePhonePage({
    required this.page,
    required this.index,
    required this.total,
  });

  final _CapturePage page;
  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                '${index + 1} / $total',
                style: const TextStyle(
                  color: Color(0xFF6C5CE7),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Row(
                  children: List.generate(total, (i) {
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: EdgeInsets.only(right: i == total - 1 ? 0 : 5),
                        decoration: BoxDecoration(
                          color: i <= index
                              ? const Color(0xFF6C5CE7)
                              : const Color(0xFFEDEAF8),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C5CE7).withValues(alpha: 0.08),
                  blurRadius: 36,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      '자습ON',
                      style: TextStyle(
                        color: Color(0xFF23262F),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0EEFF),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        page.badge,
                        style: const TextStyle(
                          color: Color(0xFF6C5CE7),
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  page.title,
                  style: const TextStyle(
                    color: Color(0xFF23262F),
                    fontSize: 30,
                    height: 1.08,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  page.subtitle,
                  style: const TextStyle(
                    color: Color(0xFF707783),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                _HeroVisual(page: page),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Expanded(child: _ModePanel(mode: page.mode)),
        ],
      ),
    );
  }
}

class _HeroVisual extends StatelessWidget {
  const _HeroVisual({required this.page});
  final _CapturePage page;

  @override
  Widget build(BuildContext context) {
    final isTheme = page.mode == _CaptureMode.theme;
    return Container(
      height: 230,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF0EEFF), Color(0xFFE9F7FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isTheme ? 22 : 0),
          child: Image.asset(
            page.image,
            width: isTheme ? 260 : 185,
            height: isTheme ? 150 : 185,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class _ModePanel extends StatelessWidget {
  const _ModePanel({required this.mode});
  final _CaptureMode mode;

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case _CaptureMode.home:
        return _MetricPanel(
          rows: const [
            ('오늘 집중', '2시간 40분', 0.78),
            ('목표 달성', '86%', 0.86),
            ('연속 공부', '7일', 0.7),
          ],
        );
      case _CaptureMode.mission:
        return _ChecklistPanel(
          title: '오늘 퀘스트',
          items: const ['수학 90분 집중', '영어 단어 40개', '주간 회고 작성'],
        );
      case _CaptureMode.points:
        return _PointPanel();
      case _CaptureMode.character:
        return _ShopPanel();
      case _CaptureMode.theme:
        return _ThemePanel();
      case _CaptureMode.report:
        return _ReportPanel();
    }
  }
}

class _MetricPanel extends StatelessWidget {
  const _MetricPanel({required this.rows});
  final List<(String, String, double)> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: rows.map((row) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration,
          child: Column(
            children: [
              Row(
                children: [
                  Text(row.$1, style: _labelStyle),
                  const Spacer(),
                  Text(row.$2, style: _valueStyle),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: row.$3,
                  backgroundColor: const Color(0xFFEDEAF8),
                  color: const Color(0xFF6C5CE7),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ChecklistPanel extends StatelessWidget {
  const _ChecklistPanel({required this.title, required this.items});
  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: _valueStyle),
          const SizedBox(height: 14),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF00B894),
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(item, style: _itemStyle),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PointPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
            ),
            borderRadius: BorderRadius.circular(26),
          ),
          child: const Column(
            children: [
              Text('보유 포인트', style: TextStyle(color: Colors.white70)),
              SizedBox(height: 8),
              Text(
                '420P',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const _HistoryTile(title: '오늘 미션 완료', point: '+30P'),
        const _HistoryTile(title: '90분 집중 보상', point: '+120P'),
      ],
    );
  }
}

class _ShopPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.35,
      children: const [
        _ShopItem(label: '안경', price: '80P'),
        _ShopItem(label: '가운', price: '140P'),
        _ShopItem(label: '별 배경', price: '200P'),
        _ShopItem(label: '웃는 표정', price: '60P'),
      ],
    );
  }
}

class _ThemePanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _HistoryTile(title: '목표 대학 배경', point: 'ON'),
        _HistoryTile(title: '홈 화면 테마', point: 'Sky'),
        _HistoryTile(title: '입실 화면 이미지', point: '선택됨'),
      ],
    );
  }
}

class _ReportPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [42, 64, 58, 86, 72, 92, 68].map((height) {
          return Expanded(
            child: Container(
              height: height.toDouble() * 2,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: height > 80
                    ? const Color(0xFF6C5CE7)
                    : const Color(0xFFA29BFE),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.title, required this.point});
  final String title;
  final String point;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: _cardDecoration,
      child: Row(
        children: [
          Text(title, style: _itemStyle),
          const Spacer(),
          Text(point, style: _valueStyle),
        ],
      ),
    );
  }
}

class _ShopItem extends StatelessWidget {
  const _ShopItem({required this.label, required this.price});
  final String label;
  final String price;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome_rounded, color: Color(0xFF6C5CE7)),
          const Spacer(),
          Text(label, style: _itemStyle),
          Text(price, style: _labelStyle),
        ],
      ),
    );
  }
}

final _cardDecoration = BoxDecoration(
  color: Colors.white,
  border: Border.all(color: const Color(0xFFE8E6F5)),
  borderRadius: BorderRadius.circular(20),
);

const _labelStyle = TextStyle(
  color: Color(0xFF7C8290),
  fontWeight: FontWeight.w800,
);

const _itemStyle = TextStyle(
  color: Color(0xFF30343B),
  fontSize: 15,
  fontWeight: FontWeight.w800,
);

const _valueStyle = TextStyle(
  color: Color(0xFF6C5CE7),
  fontSize: 17,
  fontWeight: FontWeight.w900,
);
