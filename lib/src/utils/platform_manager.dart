
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class PlatformManager {
  static bool get isDesktop {
    return defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows;
  }

  static bool get isWindows {
    return defaultTargetPlatform == TargetPlatform.windows;
  }

  static bool get isTablet {
    final shortestSide = WidgetsBinding
        .instance.platformDispatcher.views.first.physicalSize.shortestSide;
    final dpr =
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    //Previously, physicalSize was being used to determine this.
    //However, this was failing for some mobile devices (COR-1229)
    //This may not be a valid criteria as this does not consider DevicePixelRatio (DPR)
    //LogicalSize resolves this issue as a valid threshold for determinig isTablet
    //LogicalSize = PhysicalSize / DPR
    //Shortest side condition is being used as this would covert 99.6% of mobile phones when
    //logicalShortesSide < 600
    final logicalShortestSide = shortestSide / dpr;
    return !isDesktop && logicalShortestSide >= 600;
  }

  static bool get isMobile {
    return (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android);
  }

  static bool get isiOS {
    return defaultTargetPlatform == TargetPlatform.iOS;
  }
}
