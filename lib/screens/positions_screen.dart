import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/portfolio.dart';
import '../models/position.dart';
import '../services/mock_data_service.dart';

class PositionsScreen extends StatefulWidget {
  const PositionsScreen({super.key});

  @override
  State<PositionsScreen> createState() => _PositionsScreenState();
}

class _PositionsScreenState extends State<PositionsScreen> {
  final MockDataService _dataService = MockDataService();
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  final NumberFormat _priceFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 3);
  
  Portfolio? _portfolio;

  @override
  void initState() {
    super.initState();
    _loadData();
    
    // Auto-update
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
    if (_portfolio == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final activePositions = _portfolio!.positions.where((p) => p.quantity != 0).toList();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Position Details',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${activePositions.length} active position${activePositions.length != 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            
            if (activePositions.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.info_outline, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No active positions',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            
            ...activePositions.map((position) => _buildPositionCard(position)),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionCard(Position position) {
    bool isProfitable = position.unrealizedPnl >= 0;
    Color pnlColor = isProfitable ? Colors.green : Colors.red;
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: position.isLong ? Colors.green.shade100 : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        position.symbol,
                        style: TextStyle(
                          color: position.isLong ? Colors.green.shade900 : Colors.red.shade900,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: position.isLong ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${position.isLong ? 'LONG' : 'SHORT'} ${position.leverage.toStringAsFixed(0)}x',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isProfitable ? '+' : ''}${_currencyFormat.format(position.unrealizedPnl)}',
                      style: TextStyle(
                        color: pnlColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      '${position.pnlPercentage >= 0 ? '+' : ''}${position.pnlPercentage.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: pnlColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            
            // Position Info
            _buildInfoRow('Quantity', position.quantity.toStringAsFixed(4)),
            const SizedBox(height: 8),
            _buildInfoRow('Entry Price', _priceFormat.format(position.entryPrice)),
            const SizedBox(height: 8),
            _buildInfoRow('Current Price', _priceFormat.format(position.currentPrice)),
            const SizedBox(height: 8),
            if (position.liquidationPrice != null)
              _buildInfoRow(
                'Liquidation Price',
                _priceFormat.format(position.liquidationPrice),
                color: Colors.red,
              ),
            if (position.liquidationPrice != null) const SizedBox(height: 8),
            _buildInfoRow('Collateral', _currencyFormat.format(position.collateral)),
            const SizedBox(height: 8),
            _buildInfoRow('Notional Value', _currencyFormat.format(position.notionalUsd)),
            
            // Exit Strategy
            if (position.profitTarget != null || position.stopLoss != null) ...[
              const Divider(height: 24),
              const Text(
                'Exit Strategy',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              if (position.profitTarget != null)
                _buildInfoRow(
                  'Take Profit',
                  _priceFormat.format(position.profitTarget),
                  color: Colors.green,
                ),
              if (position.profitTarget != null && position.stopLoss != null)
                const SizedBox(height: 8),
              if (position.stopLoss != null)
                _buildInfoRow(
                  'Stop Loss',
                  _priceFormat.format(position.stopLoss),
                  color: Colors.red,
                ),
              if (position.invalidationCondition != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange.shade700, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          position.invalidationCondition!,
                          style: TextStyle(
                            color: Colors.orange.shade900,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
            
            // Risk & Confidence
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Risk',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currencyFormat.format(position.riskUsd),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Confidence',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(position.confidence * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Entry Time
            const SizedBox(height: 12),
            Text(
              'Opened: ${_formatDateTime(position.entryTime)}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
