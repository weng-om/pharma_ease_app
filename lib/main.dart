import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/main_page.dart';

void main() {
  runApp(const PharmaEaseApp());
}

// 应用程序主入口
class PharmaEaseApp extends StatelessWidget {
  const PharmaEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '药送送',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFA7E9E0),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFA7E9E0),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const SplashScreen(), // 启动页
    );
  }
}

// 启动页：检查登录状态并跳转
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // 检查用户登录状态
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUser = prefs.getString('current_user');

    // 延迟1秒显示启动页
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      if (currentUser != null) {
        // 已登录，跳转到主页
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
        );
      } else {
        // 未登录，跳转到登录页
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_pharmacy, size: 100, color: Color(0xFFA7E9E0)),
            SizedBox(height: 16),
            Text('药送送', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
