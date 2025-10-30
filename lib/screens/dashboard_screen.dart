import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/portfolio.dart';
import '../services/mock_data_service.dart';
import 'positions_screen.dart';
import 'market_data_screen.dart';
import 'trade_signals_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final MockDataService _dataService = MockDataService();
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  
  Portfolio? _portfolio;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _dataService.initialize();
    _loadData();
    
    // Auto-update every 2 seconds
    _dataService.portfolioStream.listen((portfolio) {
      if (mounted) {
        setState(() {
          _portfolio = portfolio;
        });
      }
    });
  }

  void _loadData() {
    setState(() {
      _portfolio = _dataService.getPortfolio();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Alpha Arena',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1a237e),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _dataService.updatePrices();
              _loadData();
            },
          ),
        ],
      ),
      body: _selectedIndex == 0 ? _buildDashboard() : _getSelectedScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1a237e),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Positions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Market',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb),
            label: 'Signals',
          ),
        ],
      ),
    );
  }

  Widget _getSelectedScreen() {
    switch (_selectedIndex) {
      case 1:
        return const PositionsScreen();
      case 2:
        return const MarketDataScreen();
      case 3:
        return const TradeSignalsScreen();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    if (_portfolio == null) {
      return const Center(child: CircularProgressIndicator());
    }

    bool isProfitable = _portfolio!.totalPnl >= 0;
    Color pnlColor = isProfitable ? Colors.green : Colors.red;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Portfolio Overview Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF1a237e), const Color(0xFF283593)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Portfolio Value',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currencyFormat.format(_portfolio!.totalAsset),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        isProfitable ? Icons.trending_up : Icons.trending_down,
                        color: pnlColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${isProfitable ? '+' : ''}${_currencyFormat.format(_portfolio!.totalPnl)}',
                        style: TextStyle(
                          color: pnlColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${_portfolio!.totalReturnPercentage.toStringAsFixed(2)}%)',
                        style: TextStyle(
                          color: pnlColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Available Cash',
                  _currencyFormat.format(_portfolio!.availableCash),
                  Icons.account_balance,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Open Positions',
                  '${_portfolio!.openPositionsCount}',
                  Icons.pie_chart,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Collateral',
                  _currencyFormat.format(_portfolio!.totalCollateral),
                  Icons.lock,
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Initial Capital',
                  _currencyFormat.format(_portfolio!.initialCash),
                  Icons.savings,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Positions Summary
          const Text(
            'Active Positions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...(_portfolio!.positions.where((p) => p.quantity != 0).map((position) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: position.isLong ? Colors.green.shade100 : Colors.red.shade100,
                  child: Text(
                    position.symbol,
                    style: TextStyle(
                      color: position.isLong ? Colors.green.shade900 : Colors.red.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                title: Text(
                  position.symbol,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${position.isLong ? 'LONG' : 'SHORT'} ${position.leverage.toStringAsFixed(0)}x',
                  style: TextStyle(
                    color: position.isLong ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${position.unrealizedPnl >= 0 ? '+' : ''}${_currencyFormat.format(position.unrealizedPnl)}',
                      style: TextStyle(
                        color: position.unrealizedPnl >= 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${position.pnlPercentage.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: position.unrealizedPnl >= 0 ? Colors.green : Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList()),
          
          if (_portfolio!.openPositionsCount == 0)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.info_outline, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text(
                        'No active positions',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
