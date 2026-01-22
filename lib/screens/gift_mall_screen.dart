import 'package:flutter/material.dart';
import '../models/models.dart';
import '../models/data_manager.dart';

class GiftMallScreen extends StatefulWidget {
// 礼品商城屏幕组件的构造函数
  const GiftMallScreen({super.key});

  @override
  State<GiftMallScreen> createState() => _GiftMallScreenState();
}

class _GiftMallScreenState extends State<GiftMallScreen> {
  // 礼金商品列表
  List<Product> giftProducts = [];
  // 当前用户信息
  User? user;
  // 加载状态标记
  bool isLoading = true;


// 当State对象第一次创建时调用
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // 加载礼金商城数据：包括商品列表和用户礼金余额
  Future<void> _loadData() async {
    try {
      // 从DataManager获取礼金商品
      final products = await DataManager().fetchGiftMallProducts();
      // 获取当前登录用户的信息
      final userData = await DataManager().loadUser();
      if (mounted) {
        setState(() {
          giftProducts = products;
          user = userData;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("加载失败: $e");
      setState(() => isLoading = false);
    }
  }

  // 显示礼金记录或兑换记录的底部弹窗
  // isDetail: true显示礼金明细，false显示兑换记录
  void _showRecordSheet(bool isDetail) async {
    final records = await DataManager().getGiftRecords(isDetail);
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            Text(isDetail ? '礼金明细' : '兑换记录', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            Expanded(
              child: records.isEmpty ? const Center(child: Text('暂无记录')) : ListView.builder(
                itemCount: records.length,
                itemBuilder: (context, index) {
                  final r = records[index];
                  return ListTile(
                    title: Text(r['title'] ?? '未知记录'),
                    subtitle: Text(r['time'] ?? ''),
                    trailing: Text(
                      isDetail ? (r['amount'] >= 0 ? '+${r['amount']}' : '${r['amount']}') : '兑换成功',
                      style: TextStyle(
                          color: isDetail ? (r['amount'] >= 0 ? Colors.green : Colors.red) : Colors.orange,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('礼金商城'),
        backgroundColor: const Color(0xFF5FCCC3),
        actions: [IconButton(icon: const Icon(Icons.history), onPressed: () => _showRecordSheet(false))],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF5FCCC3)))
          : Column(
        children: [
          _buildWalletHeader(),
          Expanded(child: _buildGiftGrid()),
        ],
      ),
    );
  }

  Widget _buildWalletHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF5FCCC3), Color(0xFF7DD9D2)]),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('当前可用礼金', style: TextStyle(color: Colors.white, fontSize: 14)),
              Text('${user?.giftPoints.toStringAsFixed(0) ?? 0}',
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            ],
          ),
          ElevatedButton(
            onPressed: () => _showRecordSheet(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF5FCCC3)),
            child: const Text('礼金明细'),
          )
        ],
      ),
    );
  }

  // 构建礼金商品网格布局
  Widget _buildGiftGrid() {
    if (giftProducts.isEmpty) return const Center(child: Text("暂无礼金商品"));

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10
      ),
      itemCount: giftProducts.length,
      itemBuilder: (context, index) {
        final p = giftProducts[index];
        // 礼金商品对应的兑换礼金数
        final Map<String, int> pointsMap = {'gift_01': 2000, 'gift_02': 4000, 'gift_03': 3000, 'gift_04': 2600};
        int requiredPoints = pointsMap[p.id] ?? 2000;

        return Card(
          elevation: 2,
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Expanded(
                child: p.imageUrl != null
                    ? Image.network(p.imageUrl!, fit: BoxFit.cover, width: double.infinity,
                    errorBuilder: (c, e, s) => Container(color: Colors.grey[100], child: const Icon(Icons.image_not_supported)))
                    : Container(color: Colors.grey[200]),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1),
                    const SizedBox(height: 5),
                    Text('$requiredPoints 礼金', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        // 兑换商品按钮点击事件
                        onPressed: () async {
                          // 调用DataManager的exchangeGift方法进行兑换
                          bool success = await DataManager().exchangeGift(p, requiredPoints);
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('兑换成功！已存入记录')));
                            _loadData(); // 刷新礼金余额
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('礼金不足，快去购物赚取吧！')));
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5FCCC3), foregroundColor: Colors.white),
                        child: const Text('立即兑换'),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}