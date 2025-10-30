import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/market_data.dart';
import '../services/mock_data_service.dart';

class MarketDataScreen extends StatefulWidget {
  const MarketDataScreen({super.key});

  @override
  State<MarketDataScreen> createState() => _MarketDataScreenState();
}

class _MarketDataScreenState extends State<MarketDataScreen> {
  final MockDataService _dataService = MockDataService();
  final NumberFormat _priceFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  final NumberFormat _numberFormat = NumberFormat('#,##0.00');
  
  List<MarketData> _marketDataList = [];
  String _selectedSymbol = 'BTC';

  @override
  void initState() {
    super.initState();
    _loadData();
    
    // Auto-update
    _dataService.portfolioStream.listen((_) {
      if (mounted) {
        _loadData();
      }
    });
  }

  void _loadData() {
    setState(() {
      _marketDataList = _dataService.getAllMarketData();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_marketDataList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final selectedData = _marketDataList.firstWhere((d) => d.symbol == _selectedSymbol);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Market Data',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Symbol Selector
            Row(
              children: _marketDataList.map((data) {
                bool isSelected = data.symbol == _selectedSymbol;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedSymbol = data.symbol;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected 
                            ? const Color(0xFF1a237e) 
                            : Colors.grey.shade200,
                        foregroundColor: isSelected ? Colors.white : Colors.black87,
                        elevation: isSelected ? 4 : 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        data.symbol,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            
            // Price Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _getTrendColors(selectedData.trend),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedData.symbol,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _priceFormat.format(selectedData.currentPrice),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(51),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _getTrendIcon(selectedData.trend),
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                selectedData.trend,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Technical Indicators
            const Text(
              'Technical Indicators',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildIndicatorRow(
                      'RSI (7)',
                      selectedData.currentRsi7.toStringAsFixed(2),
                      _getRsiColor(selectedData.currentRsi7),
                      Icons.show_chart,
                    ),
                    const Divider(height: 24),
                    _buildIndicatorRow(
                      'MACD',
                      selectedData.currentMacd.toStringAsFixed(2),
                      selectedData.isMacdBullish ? Colors.green : Colors.red,
                      Icons.trending_up,
                    ),
                    const Divider(height: 24),
                    _buildIndicatorRow(
                      'EMA (20)',
                      _priceFormat.format(selectedData.currentEma20),
                      selectedData.isPriceAboveEma ? Colors.green : Colors.red,
                      Icons.timeline,
                    ),
                    const Divider(height: 24),
                    _buildIndicatorRow(
                      'Volume',
                      _numberFormat.format(selectedData.currentVolume),
                      selectedData.isVolumeAboveAverage ? Colors.green : Colors.grey,
                      Icons.bar_chart,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Market Statistics
            const Text(
              'Market Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Open Interest',
                    _numberFormat.format(selectedData.openInterestLatest),
                    Icons.account_balance,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Funding Rate',
                    '${(selectedData.fundingRate * 100).toStringAsFixed(4)}%',
                    Icons.percent,
                    selectedData.fundingRate >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Avg Volume',
                    _numberFormat.format(selectedData.averageVolume),
                    Icons.bar_chart,
                    Colors.purple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'OI Average',
                    _numberFormat.format(selectedData.openInterestAverage),
                    Icons.analytics,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Historical Data Preview
            const Text(
              'Price History (Last 10 Intervals)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SizedBox(
                      height: 100,
                      child: _buildMiniChart(selectedData.midPrices),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Recent prices trend',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicatorRow(String label, String value, Color color, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniChart(List<double> prices) {
    if (prices.isEmpty) return Container();
    
    double min = prices.reduce((a, b) => a < b ? a : b);
    double max = prices.reduce((a, b) => a > b ? a : b);
    double range = max - min;
    if (range == 0) range = 1;
    
    return CustomPaint(
      painter: _MiniChartPainter(prices, min, range),
      child: Container(),
    );
  }

  List<Color> _getTrendColors(String trend) {
    switch (trend) {
      case 'Bullish':
        return [Colors.green.shade700, Colors.green.shade500];
      case 'Bearish':
        return [Colors.red.shade700, Colors.red.shade500];
      default:
        return [Colors.grey.shade700, Colors.grey.shade500];
    }
  }

  IconData _getTrendIcon(String trend) {
    switch (trend) {
      case 'Bullish':
        return Icons.trending_up;
      case 'Bearish':
        return Icons.trending_down;
      default:
        return Icons.trending_flat;
    }
  }

  Color _getRsiColor(double rsi) {
    if (rsi > 70) return Colors.red;
    if (rsi < 30) return Colors.green;
    return Colors.blue;
  }
}

class _MiniChartPainter extends CustomPainter {
  final List<double> prices;
  final double min;
  final double range;

  _MiniChartPainter(this.prices, this.min, this.range);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1a237e)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    for (int i = 0; i < prices.length; i++) {
      double x = (i / (prices.length - 1)) * size.width;
      double y = size.height - ((prices[i] - min) / range) * size.height;
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    canvas.drawPath(path, paint);
    
    // Draw area under the line
    final areaPath = Path.from(path);
    areaPath.lineTo(size.width, size.height);
    areaPath.lineTo(0, size.height);
    areaPath.close();
    
    final areaPaint = Paint()
      ..color = const Color(0xFF1a237e).withAlpha(51)
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(areaPath, areaPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
