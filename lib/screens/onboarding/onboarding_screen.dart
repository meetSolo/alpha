import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../models/app_model.dart';
import 'widgets/version1/onboarding_v1.dart';
import 'widgets/version2/onboarding_v2.dart';
import 'widgets/version3/onboarding_v3.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Prioritize reading `onBoardingConfig` from config.json over env
    final config = context.read<AppModel>().appConfig?.onBoardingConfig ??
        kOnBoardingConfig;

    switch (config.version) {
      case 1:
        return OnBoardingV1(config: config);
      case 3:
        return OnBoardingV3(config: config);
      case 2:
      default:
        return OnBoardingV2(config: config);
    }
  }
}
