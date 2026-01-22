import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'product_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';

// 主页面框架，包含底部导航栏和四个主要页面
class MainPage extends StatefulWidget {
  // 初始显示的底部导航栏索引
  final int initialTab;
  // 从首页跳转时携带的商品分类
  final String? category;
  // 从首页跳转时携带的搜索关键词
  final String? searchQuery;

  const MainPage({
    super.key,
    this.initialTab = 0,
    this.category,
    this.searchQuery,
  });
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // 当前选中的底部导航栏索引
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    // 初始化时显示传入的初始页面
    _currentIndex = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    // 定义四个主要页面：首页、商品、购物车、我的
    final _screens = [
      const HomeScreen(),
      ProductScreen(
        initialCategory: widget.category,
        initialSearchQuery: widget.searchQuery,
      ),
      const CartScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: _screens[_currentIndex],
      // 底部导航栏，用于切换四个主要页面
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        // 点击底部导航栏时切换页面
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF5FCCC3),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: '商品'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: '购物车'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
        ],
      ),
    );
  }
}