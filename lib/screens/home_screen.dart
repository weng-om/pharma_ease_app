import 'dart:async';
import 'package:flutter/material.dart';
import '../models/data_manager.dart';
import 'gift_mall_screen.dart';
import 'main_page.dart';

// 首页
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> banners = [];
  final PageController _pageController = PageController();
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadBanners();
    _startAutoPlay();
  }

  // 启动Banner自动轮播
  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients && banners.isNotEmpty) {
        int nextPage = (_currentPage + 1) % banners.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // 加载Banner图片
  Future<void> _loadBanners() async {
    final data = await DataManager().fetchBanners();
    if (mounted) {
      setState(() => banners = data);
    }
  }

  // 跳转到商品分类或搜索结果
  void _jumpToCategory(String? categoryName, {String? searchQuery}) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => MainPage(
          initialTab: 1,
          category: categoryName,
          searchQuery: searchQuery,
        ),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildSearchBar(),
                    _buildBanner(),
                    _buildFeatures(),
                    _buildFunctionGrid(),
                    _buildGiftBanner(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建顶部地址栏
  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF5FCCC3), Color(0xFF7DD9D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Row(
        children: [
          Icon(Icons.location_on, color: Colors.white, size: 20),
          SizedBox(width: 5),
          Text('药送送', style: TextStyle(color: Colors.white, fontSize: 16)),
          Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
        ],
      ),
    );
  }

  // 构建搜索栏
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: '搜索商品',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  _jumpToCategory(null, searchQuery: value.trim());
                }
              },
            ),
          ),
          GestureDetector(
            onTap: () {
              if (_searchController.text.trim().isNotEmpty) {
                _jumpToCategory(null, searchQuery: _searchController.text.trim());
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              margin: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF5FCCC3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('搜索', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  // 构建Banner轮播图
  Widget _buildBanner() {
    if (banners.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(15),
        height: 180,
        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(15)),
        child: const Center(child: CircularProgressIndicator(color: Color(0xFF5FCCC3))),
      );
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      height: 180,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemCount: banners.length,
              itemBuilder: (context, index) => Image.network(
                banners[index],
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                banners.length,
                    (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentPage == index ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: _currentPage == index ? Colors.white : Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建特性展示区
  Widget _buildFeatures() {
    // 定义功能特性列表，每个特性包含名称和对应的图标
    final features = [
      {'名称': '高品质', '图标': Icons.verified},
      {'名称': '低价位', '图标': Icons.price_check},
      {'名称': '门店自营', '图标': Icons.store},
      {'名称': '售后无忧', '图标': Icons.support_agent},
    ];
    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: features.map((f) => Column(
          children: [
            Icon(f['图标'] as IconData, color: const Color(0xFF5FCCC3), size: 24),
            const SizedBox(height: 5),
            Text(f['名称'] as String, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        )).toList(),
      ),
    );
  }

  // 构建功能分类网格
  Widget _buildFunctionGrid() {
    final functions = [
      {'名称': '消炎药', '颜色': Colors.purple},
      {'名称': '五官用药', '颜色': Colors.blue},
      {'名称': '感冒用药', '颜色': Colors.green},
      {'名称': '钙片', '颜色': Colors.blue},
      {'名称': '消化系统', '颜色': Colors.cyan},
      {'名称': '妇科用药', '颜色': Colors.pink},
      {'名称': '儿童用药', '颜色': Colors.orange},
      {'名称': '皮肤用药', '颜色': Colors.teal},
      {'名称': '男士用药', '颜色': Colors.orange},
      {'名称': '日常用品', '颜色': Colors.blue},
    ];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5, mainAxisSpacing: 15, crossAxisSpacing: 10, childAspectRatio: 0.8,
        ),
        itemCount: functions.length,
        itemBuilder: (context, index) {
          final func = functions[index];
          return InkWell(
            onTap: () => _jumpToCategory(func['名称'] as String),
            child: Column(
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    color: (func['颜色'] as Color).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.medical_services, color: func['颜色'] as Color, size: 28),
                ),
                const SizedBox(height: 5),
                Text(func['名称'] as String, style: const TextStyle(fontSize: 11)),
              ],
            ),
          );
        },
      ),
    );
  }

  // 构建礼金专区Banner
  Widget _buildGiftBanner() {
    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFE8F9F5), Color(0xFFD4F4EC)]),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(text: '礼金专区 ', style: TextStyle(color: Color(0xFF5FCCC3), fontSize: 20, fontWeight: FontWeight.bold)),
                      TextSpan(text: '好礼来袭', style: TextStyle(color: Colors.orange, fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GiftMallScreen())),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5FCCC3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('点击进入'),
                ),
              ],
            ),
          ),
          const Icon(Icons.card_giftcard, size: 80, color: Colors.orange),
        ],
      ),
    );
  }
}