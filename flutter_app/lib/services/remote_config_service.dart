import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../models/remote_config.dart';

class RemoteConfigService {
  // 配置文件 URL - 部署后替换为你的 GitHub Raw 地址
  static const String configUrl =
    'https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/config.json';

  final Dio _dio = Dio();

  Future<RemoteConfig?> fetchConfig() async {
    try {
      final response = await _dio.get(configUrl);
      return RemoteConfig.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  Future<String> getCurrentVersion() async {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }

  /// 比较版本号，返回: -1 小于, 0 等于, 1 大于
  int compareVersion(String v1, String v2) {
    final parts1 = v1.split('.').map(int.parse).toList();
    final parts2 = v2.split('.').map(int.parse).toList();

    for (int i = 0; i < 3; i++) {
      final p1 = i < parts1.length ? parts1[i] : 0;
      final p2 = i < parts2.length ? parts2[i] : 0;
      if (p1 < p2) return -1;
      if (p1 > p2) return 1;
    }
    return 0;
  }

  /// 检查是否需要更新
  Future<UpdateStatus> checkUpdate() async {
    final config = await fetchConfig();
    if (config == null) return UpdateStatus.unknown;

    final current = await getCurrentVersion();

    if (config.forceDisable) {
      return UpdateStatus.disabled;
    }

    if (compareVersion(current, config.minVersion) < 0) {
      return UpdateStatus.forceUpdate;
    }

    if (compareVersion(current, config.latestVersion) < 0) {
      return UpdateStatus.optionalUpdate;
    }

    return UpdateStatus.upToDate;
  }
}

enum UpdateStatus {
  upToDate,
  optionalUpdate,
  forceUpdate,
  disabled,
  unknown,
}
