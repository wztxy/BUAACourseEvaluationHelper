import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/remote_config_service.dart';
import '../models/remote_config.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _configService = RemoteConfigService();
  String _status = '正在检查更新...';

  @override
  void initState() {
    super.initState();
    _checkConfig();
  }

  Future<void> _checkConfig() async {
    final config = await _configService.fetchConfig();
    final status = await _configService.checkUpdate();

    if (!mounted) return;

    switch (status) {
      case UpdateStatus.disabled:
        _showDisabledDialog(config?.disableMessage ?? '应用已停用');
        break;
      case UpdateStatus.forceUpdate:
        _showForceUpdateDialog(config?.downloadUrl);
        break;
      case UpdateStatus.optionalUpdate:
        _showOptionalUpdateDialog(config);
        break;
      default:
        _checkPopup(config);
    }
  }

  void _showDisabledDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('应用已停用'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showForceUpdateDialog(String? url) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('需要更新'),
        content: const Text('当前版本过旧，请更新后使用'),
        actions: [
          if (url != null)
            TextButton(
              onPressed: () => launchUrl(Uri.parse(url)),
              child: const Text('立即更新'),
            ),
        ],
      ),
    );
  }

  void _showOptionalUpdateDialog(RemoteConfig? config) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('发现新版本'),
        content: Text('最新版本: ${config?.latestVersion ?? "未知"}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _checkPopup(config);
            },
            child: const Text('稍后再说'),
          ),
          if (config?.downloadUrl != null)
            TextButton(
              onPressed: () => launchUrl(Uri.parse(config!.downloadUrl!)),
              child: const Text('立即更新'),
            ),
        ],
      ),
    );
  }

  void _checkPopup(RemoteConfig? config) {
    final popup = config?.popup;
    if (popup != null && popup.enabled) {
      _showPopup(popup);
    } else {
      _navigateToLogin();
    }
  }

  void _showPopup(PopupConfig popup) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(popup.title),
        content: Text(popup.content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _navigateToLogin();
            },
            child: const Text('关闭'),
          ),
          if (popup.buttonUrl != null)
            TextButton(
              onPressed: () => launchUrl(Uri.parse(popup.buttonUrl!)),
              child: Text(popup.buttonText ?? '查看'),
            ),
        ],
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school, size: 80, color: Colors.blue),
            const SizedBox(height: 24),
            const Text(
              '北航评教助手',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(_status, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
