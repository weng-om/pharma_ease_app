// 商品数据模型
class Product {
  final String id;        // 商品ID
  final String name;      // 商品名称
  final double price;     // 商品价格
  final String category;  // 商品分类
  final int sales;        // 销量
  final String? imageUrl; // 商品图片URL

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.sales = 0,
    this.imageUrl,
  });

  // 将商品对象转换为JSON格式
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'category': category,
    'sales': sales,
    'imageUrl': imageUrl,
  };

  // 从JSON格式创建商品对象
  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'],
    name: json['name'],
    price: (json['price'] as num).toDouble(),
    category: json['category'],
    sales: json['sales'] ?? 0,
    imageUrl: json['imageUrl'],
  );
}

// 购物车商品项数据模型
class CartItem {
  final Product product; // 商品对象
  int quantity;          // 商品数量

  CartItem({required this.product, this.quantity = 1});
  Map<String, dynamic> toJson() => {
    'product': product.toJson(),
    'quantity': quantity,
  };

  // 从JSON格式创建购物车项对象
  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    product: Product.fromJson(json['product'] ?? {}),
    quantity: json['quantity'] ?? 1,
  );
}

// 用户数据模型
class User {
  String name;          // 用户名
  String phone;         // 手机号
  double giftPoints;    // 礼金余额
  double commission;    // 佣金余额

  User({
    required this.name,
    required this.phone,
    this.giftPoints = 0.0,
    this.commission = 500.0,
  });

  // 将用户对象转换为JSON格式
  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'giftPoints': giftPoints,
    'commission': commission,
  };

  // 从JSON格式创建用户对象
  factory User.fromJson(Map<String, dynamic> json) => User(
    name: json['name'] ?? '',
    phone: json['phone'] ?? '',
    giftPoints: (json['giftPoints'] as num?)?.toDouble() ?? 0.0,
    commission: (json['commission'] as num?)?.toDouble() ?? 0.0,
  );
}