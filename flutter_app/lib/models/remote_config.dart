/// 远程配置模型 - 用于版本控制和弹窗
class RemoteConfig {
  final String latestVersion;
  final String minVersion;
  final bool forceDisable;
  final String? disableMessage;
  final String? downloadUrl;
  final PopupConfig? popup;

  RemoteConfig({
    required this.latestVersion,
    required this.minVersion,
    this.forceDisable = false,
    this.disableMessage,
    this.downloadUrl,
    this.popup,
  });

  factory RemoteConfig.fromJson(Map<String, dynamic> json) {
    return RemoteConfig(
      latestVersion: json['latestVersion'] ?? '1.0.0',
      minVersion: json['minVersion'] ?? '1.0.0',
      forceDisable: json['forceDisable'] ?? false,
      disableMessage: json['disableMessage'],
      downloadUrl: json['downloadUrl'],
      popup: json['popup'] != null ? PopupConfig.fromJson(json['popup']) : null,
    );
  }
}

/// 弹窗配置
class PopupConfig {
  final bool enabled;
  final String title;
  final String content;
  final String? buttonText;
  final String? buttonUrl;

  PopupConfig({
    required this.enabled,
    required this.title,
    required this.content,
    this.buttonText,
    this.buttonUrl,
  });

  factory PopupConfig.fromJson(Map<String, dynamic> json) {
    return PopupConfig(
      enabled: json['enabled'] ?? false,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      buttonText: json['buttonText'],
      buttonUrl: json['buttonUrl'],
    );
  }
}
