import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() => runApp(const GameProxyApp());
class GameProxyApp extends StatelessWidget {
  const GameProxyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(title: '游戏加速代理', debugShowCheckedModeBanner: false,
    theme: ThemeData(colorSchemeSeed: Colors.red, useMaterial3: true, brightness: Brightness.light),
    darkTheme: ThemeData(colorSchemeSeed: Colors.red, useMaterial3: true, brightness: Brightness.dark),
    home: const GameProxyHomePage());
}

class GameServer {
  final String name, region, game, ip;
  final int basePing;
  bool connected;
  GameServer({required this.name, required this.region, required this.game, required this.ip, required this.basePing, this.connected = false});
}

class GameProxyHomePage extends StatefulWidget {
  const GameProxyHomePage({super.key});
  @override
  State<GameProxyHomePage> createState() => _GameProxyHomePageState();
}

class _GameProxyHomePageState extends State<GameProxyHomePage> {
  final _servers = [
    GameServer(name: '香港节点1', region: '🇭🇰 香港', game: '通用', ip: '103.1.1.1', basePing: 35),
    GameServer(name: '东京节点1', region: '🇯🇵 东京', game: '通用', ip: '103.2.2.2', basePing: 55),
    GameServer(name: '新加坡节点', region: '🇸🇬 新加坡', game: '通用', ip: '103.3.3.3', basePing: 65),
    GameServer(name: '美西节点', region: '🇺🇸 洛杉矶', game: '通用', ip: '103.4.4.4', basePing: 150),
    GameServer(name: '韩服专用', region: '🇰🇷 首尔', game: 'LOL韩服', ip: '103.5.5.5', basePing: 45),
    GameServer(name: '日服专用', region: '🇯🇵 大阪', game: 'FF14', ip: '103.6.6.6', basePing: 50),
  ];

  GameServer? _selected;
  int _currentPing = 0;
  double _packetLoss = 0;
  Timer? _timer;
  final _rng = Random();
  bool _connected = false;
  int _totalTime = 0;

  @override
  void initState() { super.initState(); _selected = _servers.first; }

  void _connect() {
    setState(() { _connected = true; _totalTime = 0; });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _currentPing = _selected!.basePing + _rng.nextInt(20) - 10;
        _packetLoss = _rng.nextDouble() * 2;
        _totalTime++;
      });
    });
  }

  void _disconnect() {
    _timer?.cancel();
    setState(() { _connected = false; _currentPing = 0; _packetLoss = 0; });
  }

  Color _pingColor(int ping) => ping < 50 ? Colors.green : ping < 100 ? Colors.orange : Colors.red;

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🎮 游戏加速代理'), centerTitle: true),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
        // 连接状态
        Card(child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
          Icon(_connected ? Icons.flash_on : Icons.flash_off, size: 64, color: _connected ? Colors.green : Colors.grey),
          const SizedBox(height: 12),
          Text(_connected ? '已连接' : '未连接', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _connected ? Colors.green : Colors.grey)),
          if (_connected) ...[
            const SizedBox(height: 8),
            Text(_selected!.name, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              Column(children: [Text('$_currentPing', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: _pingColor(_currentPing))), const Text('延迟 ms', style: TextStyle(color: Colors.grey, fontSize: 12))]),
              Column(children: [Text('${_packetLoss.toStringAsFixed(1)}%', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: _packetLoss > 1 ? Colors.orange : Colors.green)), const Text('丢包率', style: TextStyle(color: Colors.grey, fontSize: 12))]),
              Column(children: [Text('${_totalTime}s', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue)), const Text('连接时长', style: TextStyle(color: Colors.grey, fontSize: 12))]),
            ]),
          ],
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: FilledButton.icon(
            onPressed: _connected ? _disconnect : _connect,
            icon: Icon(_connected ? Icons.stop : Icons.play_arrow),
            label: Text(_connected ? '断开连接' : '开始加速'),
            style: FilledButton.styleFrom(backgroundColor: _connected ? Colors.red : Colors.green, padding: const EdgeInsets.symmetric(vertical: 14)),
          )),
        ]))),
        const SizedBox(height: 16),
        // 节点选择
        const Align(alignment: Alignment.centerLeft, child: Text('选择节点', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
        const SizedBox(height: 8),
        ..._servers.map((s) => Card(margin: const EdgeInsets.only(bottom: 8), color: _selected?.ip == s.ip ? Colors.red.shade50 : null, child: RadioListTile<String>(
          value: s.ip, groupValue: _selected?.ip, onChanged: _connected ? null : (v) => setState(() => _selected = s),
          title: Row(children: [Text(s.region), const SizedBox(width: 8), Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold))]),
          subtitle: Text('${s.game} • ${s.ip} • 基础延迟 ${s.basePing}ms', style: const TextStyle(fontSize: 12)),
          secondary: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: _pingColor(s.basePing).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text('${s.basePing}ms', style: TextStyle(color: _pingColor(s.basePing), fontWeight: FontWeight.bold, fontSize: 12))),
        ))),
      ])),
    );
  }
}
