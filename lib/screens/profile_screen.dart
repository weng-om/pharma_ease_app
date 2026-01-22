import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../models/data_manager.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final data = await DataManager().loadUser();
    setState(() => user = data);
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(title: const Text('我的'), backgroundColor: const Color(0xFFA7E9E0)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildAssetCards(),
            _buildMyOrders(),
            _buildOtherFunctions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: const Color(0xFFA7E9E0).withOpacity(0.3),
      child: Row(
        children: [
          const CircleAvatar(radius: 30, child: Icon(Icons.person)),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user!.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(user!.phone, style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAssetCards() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          _assetBox('礼金', user!.giftPoints.toInt().toString(), Colors.pink[50]!),
          const SizedBox(width: 10),
          _assetBox('佣金', user!.commission.toStringAsFixed(2), Colors.blue[50]!),
        ],
      ),
    );
  }

  Widget _assetBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
        child: Column(children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }

  Widget _buildMyOrders() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('我的订单', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _orderBtn(Icons.redeem, '礼金订单', () => _showRecordSheet('礼金记录', 'exchange_records')),
              _orderBtn(Icons.done_all, '已完成', () => _showRecordSheet('已完成记录', 'completed_orders')),
              _orderBtn(Icons.local_shipping, '待发货', () => _showRecordSheet('待发货序列', 'pending_orders')),
            ],
          )
        ],
      ),
    );
  }

  Widget _orderBtn(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(children: [
        Icon(icon, color: const Color(0xFF5FCCC3), size: 30),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 12)),
      ]),
    );
  }

  Widget _buildOtherFunctions() {
    final funcs = [
      {'name': '佣金明细', 'icon': Icons.list_alt, 'color': Colors.blue},
      {'name': '充值', 'icon': Icons.qr_code_scanner, 'color': Colors.green},
      {'name': '退出', 'icon': Icons.logout, 'color': Colors.orange},
      {'name': '注销账户', 'icon': Icons.delete_forever, 'color': Colors.red},
    ];

    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        children: funcs.map((f) => InkWell(
          onTap: () => _handleFunc(f['name'] as String),
          child: Column(children: [
            CircleAvatar(backgroundColor: (f['color'] as Color).withOpacity(0.1), child: Icon(f['icon'] as IconData, color: f['color'] as Color)),
            const SizedBox(height: 5),
            Text(f['name'] as String, style: const TextStyle(fontSize: 12)),
          ]),
        )).toList(),
      ),
    );
  }

  void _handleFunc(String name) {
    switch (name) {
      case '佣金明细':
        _showRecordSheet('佣金交易明细', 'commission_records');
        break;
      case '充值':
        _showRechargeDialog();
        break;
      case '退出':
        _logout(false);
        break;
      case '注销账户':
        _logout(true);
        break;
    }
  }

  // --- 根据不同的 Key 显示不同的格式 ---
  void _showRecordSheet(String title, String key) async {
    final records = await DataManager().getRecords(key);
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(),
          Expanded(
            child: records.isEmpty
                ? const Center(child: Text('暂无记录'))
                : ListView.builder(
              itemCount: records.length,
              itemBuilder: (context, i) {
                final record = records[i];
                String displayAmount = "";

                // 逻辑判断
                if (key == 'pending_orders') {
                  displayAmount = "数量: ${record['amount']}";
                } else {
                  // 其他记录（如佣金、礼金）显示 ¥ 符号
                  displayAmount = record['amount'] != null ? '¥${record['amount']}' : '';
                }

                return ListTile(
                  title: Text(record['title'] ?? record['name'] ?? '记录'),
                  subtitle: Text(record['time'] ?? ''),
                  trailing: Text(
                    displayAmount,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: key == 'pending_orders' ? Colors.black : Colors.red,
                    ),
                  ),
                );
              },
            ),
          )
        ]),
      ),
    );
  }

  void _showRechargeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('扫码充值'),
        content: const Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.qr_code_2, size: 150),
          Text('支付成功后余额自动入账'),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          TextButton(onPressed: () async {
            await DataManager().recharge(100.0);
            _loadUser(); // 充值后刷新界面
            if (mounted) Navigator.pop(context);
          }, child: const Text('模拟支付成功')),
        ],
      ),
    );
  }

  void _logout(bool isDelete) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isDelete ? '注销账户' : '退出登录'),
        content: Text(isDelete ? '注销后所有数据将被清空，确定吗？' : '确定要退出系统吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          TextButton(onPressed: () async {
            if (isDelete) {
              await DataManager().deleteAccount();
            } else {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('current_user');
            }
            if (mounted) {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
            }
          }, child: Text('确定', style: TextStyle(color: isDelete ? Colors.red : Colors.blue))),
        ],
      ),
    );
  }
}