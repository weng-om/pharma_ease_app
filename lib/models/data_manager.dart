import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

// 数据管理，负责所有数据操作
class DataManager {
  static final DataManager _instance = DataManager._internal();
  factory DataManager() => _instance;
  DataManager._internal();

  // 首页Banner图片URL
  final List<String> _networkBannerUrls = [
    'https://tse4.mm.bing.net/th/id/OIP.UFzirLgenZD1oeaePu8KFAHaDt?rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse4.mm.bing.net/th/id/OIP.pRzKBJv_Fga2dWdcdEqFHAAAAA?rs=1&pid=ImgDetMain&o=7&rm=3',
  ];

  // 礼金商城商品数据
  final List<Map<String, dynamic>> _giftNetworkProducts = [
    {'id': 'gift_01', 'name': '蜂蜜礼盒', 'imageUrl': 'https://img.alicdn.com/imgextra/i4/1835719120/TB2JyCKohxmpuFjSZFNXXXrRXXa_!!1835719120.jpg', 'giftPoints': 2000},
    {'id': 'gift_02', 'name': '保健品套装', 'imageUrl': 'https://tse4.mm.bing.net/th/id/OIP.BhBYvJH7YjH1T628-kPmnQHaEK?rs=1&pid=ImgDetMain&o=7&rm=3', 'giftPoints': 4000},
    {'id': 'gift_03', 'name': '营养品组合', 'imageUrl': 'https://tse3.mm.bing.net/th/id/OIP.V62XMzwx4jToFTvYkdKE7gHaD2?rs=1&pid=ImgDetMain&o=7&rm=3', 'giftPoints': 3000},
    {'id': 'gift_04', 'name': '茶叶套装', 'imageUrl': 'https://tse4.mm.bing.net/th/id/OIP.8xrSr6J5ObPHsQ4Y4OEvoAHaFj?rs=1&pid=ImgDetMain&o=7&rm=3', 'giftPoints': 2600},
  ];

  // 商品分类列表
  final categories = ['五官用药', '感冒用药', '钙片', '消化系统', '妇科用药', '儿童用药', '皮肤用药', '男士用药', '日常用品', '消炎药'];

  // 完整药品列表数据
  final List<Map<String, dynamic>> _fixedProductData = [
    // 五官用药
    {'name': '氯雷他定片', 'image': 'assets/images/五官用药/氯雷他定片.jpg', 'price': 15.0, 'category': '五官用药'},
    {'name': '珍珠明目滴眼液', 'image': 'assets/images/五官用药/珍珠明目滴眼液.jpg', 'price': 18.0, 'category': '五官用药'},
    {'name': '萘敏维滴眼液', 'image': 'assets/images/五官用药/萘敏维滴眼液.jpg', 'price': 12.0, 'category': '五官用药'},
    {'name': '蓝莓叶黄素滴眼液', 'image': 'assets/images/五官用药/蓝莓叶黄素滴眼液.jpg', 'price': 25.0, 'category': '五官用药'},
    {'name': '通窍鼻炎片', 'image': 'assets/images/五官用药/通窍鼻炎片.jpg', 'price': 22.0, 'category': '五官用药'},
    // 感冒用药
    {'name': '四季感冒片', 'image': 'assets/images/感冒用药/四季感冒片.jpg', 'price': 16.0, 'category': '感冒用药'},
    {'name': '四季抗病毒合剂', 'image': 'assets/images/感冒用药/四季抗病毒合剂.jpg', 'price': 28.0, 'category': '感冒用药'},
    {'name': '复方氨酚烷胺片', 'image': 'assets/images/感冒用药/复方氨酚烷胺片.jpg', 'price': 15.0, 'category': '感冒用药'},
    {'name': '小儿肺热咳喘颗粒', 'image': 'assets/images/感冒用药/小儿肺热咳喘颗粒.jpg', 'price': 32.0, 'category': '感冒用药'},
    {'name': '小柴胡颗粒', 'image': 'assets/images/感冒用药/小柴胡颗粒.jpg', 'price': 20.0, 'category': '感冒用药'},
    {'name': '感冒灵颗粒(999)', 'image': 'assets/images/感冒用药/感冒灵颗粒(999).jpg', 'price': 18.0, 'category': '感冒用药'},
    {'name': '银翘解毒片', 'image': 'assets/images/感冒用药/银翘解毒片.jpg', 'price': 12.0, 'category': '感冒用药'},
    // 消化系统
    {'name': '健胃消食片', 'image': 'assets/images/消化系统/健胃消食片.png', 'price': 15.0, 'category': '消化系统'},
    {'name': '大山楂丸', 'image': 'assets/images/消化系统/大山楂丸.jpg', 'price': 10.0, 'category': '消化系统'},
    {'name': '维生素B1片', 'image': 'assets/images/消化系统/维生素B1片.jpg', 'price': 8.0, 'category': '消化系统'},
    {'name': '酪酸梭菌活菌片', 'image': 'assets/images/消化系统/酪酸梭菌活菌片.jpg', 'price': 45.0, 'category': '消化系统'},
    {'name': '香砂六君丸', 'image': 'assets/images/消化系统/香砂六君丸.jpg', 'price': 22.0, 'category': '消化系统'},
    // 消炎药
    {'name': '布洛芬缓释胶囊', 'image': 'assets/images/消炎药/布洛芬缓释胶囊.jpg', 'price': 25.0, 'category': '消炎药'},
    {'name': '消炎镇痛膏', 'image': 'assets/images/消炎药/消炎镇痛膏.jpg', 'price': 15.0, 'category': '消炎药'},
    {'name': '蒲地蓝消炎片', 'image': 'assets/images/消炎药/蒲地蓝消炎片.jpg', 'price': 28.0, 'category': '消炎药'},
    {'name': '虫草清肺胶囊', 'image': 'assets/images/消炎药/虫草清肺胶囊.jpg', 'price': 58.0, 'category': '消炎药'},
    {'name': '铝碳酸镁咀嚼片', 'image': 'assets/images/消炎药/铝碳酸镁咀嚼片.jpg', 'price': 35.0, 'category': '消炎药'},
    {'name': '银黄颗粒', 'image': 'assets/images/消炎药/银黄颗粒.jpg', 'price': 20.0, 'category': '消炎药'},
    // 男士用药
    {'name': '六味地黄丸', 'image': 'assets/images/男士用药/六味地黄丸.jpg', 'price': 38.0, 'category': '男士用药'},
    {'name': '脾肾两助丸', 'image': 'assets/images/男士用药/脾肾两助丸.jpg', 'price': 45.0, 'category': '男士用药'},
    {'name': '龙涎降压茶', 'image': 'assets/images/男士用药/龙涎降压茶.jpg', 'price': 68.0, 'category': '男士用药'},
    {'name': '龙胆泻肝丸', 'image': 'assets/images/男士用药/龙胆泻肝丸.jpg', 'price': 25.0, 'category': '男士用药'},
    // 皮肤用药
    {'name': '医用皮肤凝胶敷料', 'image': 'assets/images/皮肤用药/医用皮肤凝胶敷料.jpg', 'price': 88.0, 'category': '皮肤用药'},
    {'name': '皮肤修复敷料', 'image': 'assets/images/皮肤用药/皮肤修复敷料.jpg', 'price': 68.0, 'category': '皮肤用药'},
    {'name': '皮肤凝胶', 'image': 'assets/images/皮肤用药/皮肤凝胶.jpg', 'price': 35.0, 'category': '皮肤用药'},
    {'name': '皮肤喷剂', 'image': 'assets/images/皮肤用药/皮肤喷剂.jpg', 'price': 42.0, 'category': '皮肤用药'},
    {'name': '皮肤抑菌粉', 'image': 'assets/images/皮肤用药/皮肤抑菌粉.jpg', 'price': 25.0, 'category': '皮肤用药'},
    {'name': '皮肤抑菌膏', 'image': 'assets/images/皮肤用药/皮肤抑菌膏.jpg', 'price': 28.0, 'category': '皮肤用药'},
    // 钙片
    {'name': '东方同康宝牌东方钙片', 'image': 'assets/images/钙片/东方同康宝牌东方钙片.jpg', 'price': 58.0, 'category': '钙片'},
    {'name': '牛软骨胶原酪蛋白钙片', 'image': 'assets/images/钙片/牛软骨胶原酪蛋白钙片.jpg', 'price': 128.0, 'category': '钙片'},
    {'name': '碳酸钙片', 'image': 'assets/images/钙片/碳酸钙片.jpg', 'price': 35.0, 'category': '钙片'},
    // 日常用品
    {'name': '成人声波电动牙刷', 'image': 'assets/images/日常用品/成人声波电动牙刷.jpg', 'price': 199.0, 'category': '日常用品'},
    {'name': '电子血压计', 'image': 'assets/images/日常用品/电子血压计.jpg', 'price': 299.0, 'category': '日常用品'},
    // 妇科用药
    {'name': '乌鸡白凤丸', 'image': 'assets/images/妇科用药/乌鸡白凤丸.jpg', 'price': 28.0, 'category': '妇科用药'},
    {'name': '宫舒贴', 'image': 'assets/images/妇科用药/宫舒贴.jpg', 'price': 45.0, 'category': '妇科用药'},
    {'name': '益母草颗粒', 'image': 'assets/images/妇科用药/益母草颗粒.jpg', 'price': 18.0, 'category': '妇科用药'},
    {'name': '舒肝散', 'image': 'assets/images/妇科用药/舒肝散.jpg', 'price': 32.0, 'category': '妇科用药'},
    {'name': '调经丸', 'image': 'assets/images/妇科用药/调经丸.jpg', 'price': 35.0, 'category': '妇科用药'},
    {'name': '远红外妇用热敷贴', 'image': 'assets/images/妇科用药/远红外妇用热敷贴(宝芝林）.jpg', 'price': 58.0, 'category': '妇科用药'},
    {'name': '逍遥丸', 'image': 'assets/images/妇科用药/逍遥丸.jpg', 'price': 26.0, 'category': '妇科用药'},
    {'name': '金水宝胶囊', 'image': 'assets/images/妇科用药/金水宝胶囊.jpg', 'price': 68.0, 'category': '妇科用药'},
    // 儿童用药
    {'name': '小儿七星茶颗粒(诺金)', 'image': 'assets/images/儿童用药/小儿七星茶颗粒(诺金).jpg', 'price': 22.0, 'category': '儿童用药'},
    {'name': '小儿健脾丸', 'image': 'assets/images/儿童用药/小儿健脾丸.jpg', 'price': 28.0, 'category': '儿童用药'},
    {'name': '小儿双清颗粒', 'image': 'assets/images/儿童用药/小儿双清颗粒.jpg', 'price': 25.0, 'category': '儿童用药'},
    {'name': '小儿咳喘灵颗粒', 'image': 'assets/images/儿童用药/小儿咳喘灵颗粒.jpg', 'price': 32.0, 'category': '儿童用药'},
    {'name': '小儿咽扁颗粒(以岭)', 'image': 'assets/images/儿童用药/小儿咽扁颗粒(以岭).jpg', 'price': 29.0, 'category': '儿童用药'},
    {'name': '小儿柴桂退热颗粒', 'image': 'assets/images/儿童用药/小儿柴桂退热颗粒.jpg', 'price': 26.0, 'category': '儿童用药'},
    {'name': '小儿止咳糖浆', 'image': 'assets/images/儿童用药/小儿止咳糖浆.jpg', 'price': 18.0, 'category': '儿童用药'},
    {'name': '小儿氨酚黄那敏颗粒', 'image': 'assets/images/儿童用药/小儿氨酚黄那敏颗粒.jpg', 'price': 15.0, 'category': '儿童用药'},
  ];

  // 获取首页Banner图片
  Future<List<String>> fetchBanners() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      await prefs.setStringList('cached_banners', _networkBannerUrls);
      return _networkBannerUrls;
    } catch (e) {
      return prefs.getStringList('cached_banners') ?? _networkBannerUrls;
    }
  }

  // 获取礼金商城商品列表
  Future<List<Product>> fetchGiftMallProducts() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _giftNetworkProducts.map((data) {
      return Product(
        id: data['id'],
        name: data['name'],
        price: 0.0,
        category: '礼金商城',
        sales: Random().nextInt(100) + 50,
        imageUrl: data['imageUrl'],
      );
    }).toList();
  }

  // 获取商品列表
  Future<List<Product>> fetchProducts({String? category}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final products = _generateProducts();
    if (category == null) return products;
    return products.where((p) => p.category == category).toList();
  }

  // 生成商品列表
  List<Product> _generateProducts() {
    final products = <Product>[];
    final random = Random();
    for (var i = 0; i < _fixedProductData.length; i++) {
      final data = _fixedProductData[i];
      products.add(Product(
        id: 'fixed-$i',
        name: data['name'],
        price: data['price'],
        category: data['category'],
        sales: random.nextInt(500) + 100,
        imageUrl: data['image'],
      ));
    }
    return products;
  }

  // 添加商品到购物车
  Future<void> addToCart(Product product) async {
    List<CartItem> currentCart = await loadCart();
    int index = currentCart.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      currentCart[index].quantity += 1;
    } else {
      currentCart.add(CartItem(product: product, quantity: 1));
    }
    await saveCart(currentCart);
  }

  // 保存购物车数据
  Future<void> saveCart(List<CartItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('current_user') ?? 'guest';
    final validItems = items.where((item) => item.quantity > 0).toList();
    final jsonList = validItems.map((item) => item.toJson()).toList();
    await prefs.setString('cart_$phone', jsonEncode(jsonList));
  }

  // 加载购物车数据
  Future<List<CartItem>> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('current_user') ?? 'guest';
    final jsonString = prefs.getString('cart_$phone');
    if (jsonString == null) return [];
    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => CartItem.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // 保存用户信息
  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final phone = user.phone;
    await prefs.setString('userName_$phone', user.name);
    await prefs.setDouble('giftPoints_$phone', user.giftPoints);
    await prefs.setDouble('commission_$phone', user.commission);
  }

  // 加载用户信息
  Future<User> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('current_user') ?? '';
    if (phone.isEmpty) return User(name: '未登录', phone: '');

    if (!prefs.containsKey('commission_$phone')) {
      return User(
        name: prefs.getString('userName_$phone') ?? '用户${phone.substring(phone.length - 4)}',
        phone: phone,
        giftPoints: 0.0,
        commission: 500.0,
      );
    }
    return User(
      name: prefs.getString('userName_$phone') ?? '用户',
      phone: phone,
      giftPoints: prefs.getDouble('giftPoints_$phone') ?? 0.0,
      commission: prefs.getDouble('commission_$phone') ?? 500.0,
    );
  }

  // 处理订单结算
  Future<double> processCheckout(List<CartItem> items) async {
    if (items.isEmpty) return 0.0;
    User user = await loadUser();
    double totalEarnedPoints = 0.0;
    double totalCost = 0.0;

    for (var item in items) {
      double itemTotal = item.product.price * item.quantity;
      totalCost += itemTotal;
      totalEarnedPoints += itemTotal * 10;
    }

    if (user.commission < totalCost) return -1.0;

    user.commission -= totalCost;
    user.giftPoints += totalEarnedPoints;
    await saveUser(user);

    await _addRecord('gift_details', '购物返礼金', totalEarnedPoints);
    await _addRecord('commission_records', '购买药品支出', -totalCost);

    final prefs = await SharedPreferences.getInstance();
    List<String> pending = prefs.getStringList('pending_orders_${user.phone}') ?? [];
    for (var item in items) {
      pending.insert(0, jsonEncode({
        'title': item.product.name,
        'amount': item.quantity.toDouble(),
        'time': DateTime.now().toString().substring(0, 16),
      }));
    }
    await prefs.setStringList('pending_orders_${user.phone}', pending);

    final phone = prefs.getString('current_user') ?? 'guest';
    await prefs.remove('cart_$phone');

    return totalEarnedPoints;
  }

  // 充值
  Future<void> recharge(double amount) async {
    User user = await loadUser();
    user.commission += amount;
    await saveUser(user);
    await _addRecord('commission_records', '扫码充值入账', amount);
  }

  // 注销账户
  Future<void> deleteAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('current_user') ?? '';
    if (phone.isEmpty) return;

    final keys = prefs.getKeys();
    for (String key in keys) {
      if (key.contains(phone)) {
        await prefs.remove(key);
      }
    }
    await prefs.remove('current_user');
  }

  // 兑换礼金商品
  Future<bool> exchangeGift(Product product, int requiredPoints) async {
    User user = await loadUser();
    if (user.phone.isEmpty || user.giftPoints < requiredPoints) return false;

    user.giftPoints -= requiredPoints;
    await saveUser(user);

    await _addRecord('gift_details', '兑换商品支出', -requiredPoints.toDouble());
    await _addRecord('exchange_records', '兑换: ${product.name}', requiredPoints.toDouble());

    return true;
  }

  // 添加记录
  Future<void> _addRecord(String keyPrefix, String title, double amount) async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('current_user') ?? 'guest';
    String key = '${keyPrefix}_$phone';

    List<String> records = prefs.getStringList(key) ?? [];
    Map<String, dynamic> data = {
      'title': title,
      'amount': amount,
      'time': DateTime.now().toString().substring(0, 16),
    };
    records.insert(0, jsonEncode(data));
    await prefs.setStringList(key, records);
  }

  // 获取记录列表
  Future<List<Map<String, dynamic>>> getRecords(String typeKey) async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('current_user') ?? 'guest';
    String key = '${typeKey}_$phone';

    List<String> rawData = prefs.getStringList(key) ?? [];
    return rawData.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  // 获取礼金记录
  Future<List<Map<String, dynamic>>> getGiftRecords(bool isDetail) async {
    return getRecords(isDetail ? 'gift_details' : 'exchange_records');
  }
}