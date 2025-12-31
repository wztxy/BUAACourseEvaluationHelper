import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;

class AuthService {
  static const String ssoBaseUrl = 'https://sso.buaa.edu.cn/login';
  static const String targetUrl = 'https://spoc.buaa.edu.cn/pjxt/authentication/main';

  final Dio _dio;

  AuthService() : _dio = Dio() {
    _dio.options.followRedirects = false;
    _dio.options.validateStatus = (status) => status != null && status < 400;
  }

  /// 从登录页面获取 CSRF token
  Future<String?> _getToken(String loginUrl) async {
    try {
      final response = await _dio.get(loginUrl);
      final document = html_parser.parse(response.data);
      final input = document.querySelector('input[name="execution"]');
      return input?.attributes['value'];
    } catch (e) {
      return null;
    }
  }

  /// 登录统一认证
  Future<LoginResult> login(String username, String password) async {
    final loginUrl = '$ssoBaseUrl?service=$targetUrl';

    // 获取 token
    final token = await _getToken(loginUrl);
    if (token == null) {
      return LoginResult(success: false, message: '无法获取登录页面');
    }

    // 构建登录表单
    final formData = {
      'username': username,
      'password': password,
      'execution': token,
      '_eventId': 'submit',
      'type': 'username_password',
      'submit': 'LOGIN',
    };

    try {
      final response = await _dio.post(
        loginUrl,
        data: FormData.fromMap(formData),
        options: Options(
          followRedirects: true,
          maxRedirects: 5,
        ),
      );

      // 检查是否登录成功
      final finalUrl = response.realUri.toString();
      if (finalUrl.contains('spoc.buaa.edu.cn/pjxt/authentication/main')) {
        return LoginResult(success: true, message: '登录成功');
      } else {
        return LoginResult(success: false, message: '用户名或密码错误');
      }
    } catch (e) {
      return LoginResult(success: false, message: '网络错误: $e');
    }
  }

  Dio get dio => _dio;
}

class LoginResult {
  final bool success;
  final String message;

  LoginResult({required this.success, required this.message});
}
