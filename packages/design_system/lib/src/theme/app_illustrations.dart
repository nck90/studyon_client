import 'package:flutter/material.dart';

/// 토스 프리미엄 스타일의 미세한 디테일을 위한 일러스트레이션 (SVG String)
class AppIllustrations {
  // 선명하고 부드러운 3D 느낌의 원형 그래픽 (Hero용)
  static const String heroStudy = '''
<svg width="100" height="100" viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg">
<circle cx="50" cy="50" r="40" fill="url(#paint0_linear_1_2)"/>
<defs>
<linearGradient id="paint0_linear_1_2" x1="10" y1="10" x2="90" y2="90" gradientUnits="userSpaceOnUse">
<stop stop-color="#3182F6"/>
<stop offset="1" stop-color="#0056D6"/>
</linearGradient>
</defs>
</svg>
''';

  // 체크 완료 애니메이션 대용 프리미엄 일러스트
  static const String checkPremium = '''
<svg width="100" height="100" viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg">
<rect x="20" y="20" width="60" height="60" rx="20" fill="#3182F6"/>
<path d="M40 50L47 57L60 44" stroke="white" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
''';

  // 집중력을 상징하는 3D 느낌의 원형 그래픽 (Focus Sphere)
  static const String focusSphere = '''
<svg width="120" height="120" viewBox="0 0 120 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="60" cy="60" r="48" fill="url(#paint0_radial_1_1)"/>
  <circle cx="60" cy="60" r="48" fill="url(#paint1_linear_1_1)" fill-opacity="0.3"/>
  <circle cx="60" cy="60" r="32" stroke="white" stroke-width="0.5" stroke-dasharray="2 4"/>
  <defs>
    <radialGradient id="paint0_radial_1_1" cx="0" cy="0" r="1" gradientUnits="userSpaceOnUse" gradientTransform="translate(38.4 38.4) rotate(45) scale(81.4589)">
      <stop stop-color="#3182F6"/>
      <stop offset="1" stop-color="#0056D6"/>
    </radialGradient>
    <linearGradient id="paint1_linear_1_1" x1="60" y1="12" x2="60" y2="108" gradientUnits="userSpaceOnUse">
      <stop stop-color="white" stop-opacity="0.5"/>
      <stop offset="1" stop-color="white" stop-opacity="0"/>
    </linearGradient>
  </defs>
</svg>
''';
}
