import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../models/data_manager.dart';

// 注册页面
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // 验证手机号格式
  bool _validatePhone(String phone) {
    return phone.length == 11 && RegExp(r'^1[3-9]\d{9}$').hasMatch(phone);
  }

  // 验证密码格式（必须是字母+数字）
  bool _validatePassword(String password) {
    if (password.length < 6) return false;
    bool hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    bool hasDigit = RegExp(r'[0-9]').hasMatch(password);
    // 确保密码中只包含字母和数字
    bool onlyLetterAndDigit = RegExp(r'^[a-zA-Z0-9]+$').hasMatch(password);
    return hasLetter && hasDigit && onlyLetterAndDigit;
  }

  // 检查用户名是否已存在
  Future<bool> _isUsernameTaken(String username) async {
    final prefs = await SharedPreferences.getInstance();
    // 获取所有已注册的用户手机号
    final allKeys = prefs.getKeys();
    for (var key in allKeys) {
      if (key.startsWith('userName_')) {
        final existingUsername = prefs.getString(key);
        if (existingUsername == username) {
          return true;
        }
      }
    }
    return false;
  }

  // 处理注册逻辑
  Future<void> _register() async {
    final username = _usernameController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // 验证所有字段是否填写
    if (username.isEmpty || phone.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请填写完整信息')));
      return;
    }

    // 验证手机号是否为11位
    if (!_validatePhone(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入正确的11位手机号')));
      return;
    }

    // 验证密码格式（必须是字母+数字）
    if (!_validatePassword(password)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('密码必须包含字母和数字，且至少6位')));
      return;
    }

    // 验证两次密码是否一致
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('两次输入的密码不一致')));
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    // 检查用户名是否已被注册
    if (await _isUsernameTaken(username)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('该用户名已被注册，请使用其他用户名')));
      return;
    }

    // 检查手机号是否已注册
    if (prefs.containsKey('password_$phone')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('该手机号已注册，请直接登录')));
      return;
    }

    // 保存账号密码
    await prefs.setString('password_$phone', password);

    // 初始化并保存该账号特有的用户信息
    User newUser = User(
      name: username,
      phone: phone,
      giftPoints: 0.0,
      commission: 500.0,
    );
    await DataManager().saveUser(newUser);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('注册成功！请登录')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('用户注册')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: '用户名', prefixIcon: Icon(Icons.person), border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              maxLength: 11,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: '手机号', prefixIcon: Icon(Icons.phone), border: OutlineInputBorder(), counterText: ''),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: '密码', prefixIcon: Icon(Icons.lock), border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: '确认密码', prefixIcon: Icon(Icons.lock), border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFA7E9E0)),
                child: const Text('注册', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}