import 'package:flutter/material.dart';
import '../models/models.dart';
import '../models/data_manager.dart';

// 商品列表页面
class ProductScreen extends StatefulWidget {
  final String? initialCategory;
  final String? initialSearchQuery;

  const ProductScreen({
    super.key,
    this.initialCategory,
    this.initialSearchQuery,
  });

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final categories = DataManager().categories;
  int selectedCategory = 0;
  List<Product> products = [];
  bool isSearchMode = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialSearchQuery != null && widget.initialSearchQuery!.isNotEmpty) {
      isSearchMode = true;
      _handleSearch(widget.initialSearchQuery!);
    } else {
      isSearchMode = false;
      if (widget.initialCategory != null) {
        int index = categories.indexOf(widget.initialCategory!);
        if (index != -1) selectedCategory = index;
      }
      _loadCategoryProducts();
    }
  }

  // 搜索商品
  Future<void> _handleSearch(String query) async {
    List<Product> allProducts = await DataManager().fetchProducts();
    setState(() {
      products = allProducts.where((p) =>
          p.name.toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  // 加载分类商品
  Future<void> _loadCategoryProducts() async {
    List<Product> data = await DataManager().fetchProducts(
        category: categories[selectedCategory]
    );
    setState(() => products = data);
  }

  // 添加商品到购物车
  Future<void> _addToCart(Product product) async {
    await DataManager().addToCart(product);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.name} 已加入购物车'), duration: const Duration(seconds: 1)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isSearchMode ? '搜索结果: ${widget.initialSearchQuery}' : '商品分类'),
        backgroundColor: const Color(0xFF5FCCC3),
        actions: [
          if (isSearchMode)
            TextButton(
              onPressed: () {
                setState(() {
                  isSearchMode = false;
                  _loadCategoryProducts();
                });
              },
              child: const Text('返回分类', style: TextStyle(color: Colors.white)),
            )
        ],
      ),
      body: Row(
        children: [
          if (!isSearchMode)
            Container(
              width: 100,
              color: Colors.grey[100],
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) => InkWell(
                  onTap: () {
                    setState(() => selectedCategory = index);
                    _loadCategoryProducts();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                    color: selectedCategory == index ? Colors.white : Colors.transparent,
                    child: Text(
                      categories[index],
                      style: TextStyle(
                        color: selectedCategory == index ? const Color(0xFF5FCCC3) : Colors.black,
                        fontWeight: selectedCategory == index ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Expanded(
            child: products.isEmpty
                ? Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 60, color: Colors.grey),
                const SizedBox(height: 10),
                Text(isSearchMode ? '没找到相关药品' : '该分类下暂无商品'),
              ],
            ))
                : GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) => _buildProductItem(products[index]),
            ),
          ),
        ],
      ),
    );
  }

  // 构建商品卡片
  Widget _buildProductItem(Product product) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              child: product.imageUrl != null
                  ? Image.asset(product.imageUrl!, fit: BoxFit.cover, width: double.infinity)
                  : Container(color: Colors.grey[200], child: const Icon(Icons.medical_services)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('¥${product.price}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    InkWell(
                      onTap: () => _addToCart(product),
                      child: const Icon(Icons.add_shopping_cart, size: 20, color: Color(0xFF5FCCC3)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}