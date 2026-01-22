import 'package:flutter/material.dart';
import '../models/models.dart';
import '../models/data_manager.dart';

// 购物车页面
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> cartItems = [];

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  // 加载购物车数据
  Future<void> _loadCart() async {
    final data = await DataManager().loadCart();
    setState(() => cartItems = data);
  }

  // 计算总价
  double get total => cartItems.fold(0, (sum, item) => sum + item.product.price * item.quantity);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('购物车')),
      body: Column(
        children: [
          Expanded(
            child: cartItems.isEmpty
                ? const Center(child: Text('购物车为空'))
                : ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) => _buildCartItem(cartItems[index], index),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item, int index) {
    return Dismissible(
      key: Key(item.product.id),
      onDismissed: (_) => _removeItem(index),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFFA7E9E0).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: item.product.imageUrl != null
                    ? Image.asset(item.product.imageUrl!, fit: BoxFit.cover)
                    : const Icon(Icons.medical_services, color: Color(0xFF5FCCC3)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.product.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                  Text('¥${item.product.price}', style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
                    onPressed: () => _updateQuantity(index, -1),
                  ),
                  Text('${item.quantity}', style: const TextStyle(fontSize: 16)),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: Color(0xFF5FCCC3)),
                    onPressed: () => _updateQuantity(index, 1),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('合计：', style: TextStyle(fontSize: 14, color: Colors.grey)),
              Text('¥${total.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: 120,
            height: 45,
            child: ElevatedButton(
              onPressed: _checkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA7E9E0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              child: Text('结算(${cartItems.length})',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // 更新商品数量
  Future<void> _updateQuantity(int index, int change) async {
    setState(() {
      cartItems[index].quantity += change;
      if (cartItems[index].quantity <= 0) {
        cartItems.removeAt(index);
      }
    });
    await DataManager().saveCart(cartItems);
  }

  // 删除商品
  Future<void> _removeItem(int index) async {
    setState(() => cartItems.removeAt(index));
    await DataManager().saveCart(cartItems);
  }

  // 结算订单
  Future<void> _checkout() async {
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('购物车为空')));
      return;
    }

    double result = await DataManager().processCheckout(cartItems);

    if (!mounted) return;

    if (result == -1.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('余额不足，支付失败！'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('交易成功'),
            ],
          ),
          content: Text('订单已提交！\n\n本次消耗余额：¥${total.toStringAsFixed(2)}\n获得返还礼金：${result.toStringAsFixed(2)}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  cartItems.clear(); // 清空界面列表
                });
              },
              child: const Text('确定', style: TextStyle(color: Color(0xFF5FCCC3), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }
  }
}