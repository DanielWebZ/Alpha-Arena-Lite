import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/trade_decision.dart';
import '../services/mock_data_service.dart';

class TradeSignalsScreen extends StatefulWidget {
  const TradeSignalsScreen({super.key});

  @override
  State<TradeSignalsScreen> createState() => _TradeSignalsScreenState();
}

class _TradeSignalsScreenState extends State<TradeSignalsScreen> {
  final MockDataService _dataService = MockDataService();
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  final NumberFormat _priceFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 3);
  
  List<TradeDecision> _tradeDecisions = [];

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
      _tradeDecisions = _dataService.getTradeDecisions();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_tradeDecisions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.lightbulb,
                  color: Color(0xFF1a237e),
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text(
                  'AI Trading Signals',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Powered by GPT-4o',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 20),
            
            // Info Card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'AI analyzes market data and portfolio status to generate trading recommendations',
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            ..._tradeDecisions.map((decision) => _buildSignalCard(decision)),
          ],
        ),
      ),
    );
  }

  Widget _buildSignalCard(TradeDecision decision) {
    Color signalColor = _getSignalColor(decision.signal);
    IconData signalIcon = _getSignalIcon(decision.signal);
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with signal type
          Container(
            decoration: BoxDecoration(
              color: signalColor.withAlpha(51),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        decision.coin,
                        style: TextStyle(
                          color: signalColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: signalColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(signalIcon, color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            decision.signal.toUpperCase(),
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: signalColor),
                  ),
                  child: Text(
                    '${decision.leverage.toStringAsFixed(0)}x',
                    style: TextStyle(
                      color: signalColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Trade Details
                _buildDetailRow('Quantity', decision.quantity.toStringAsFixed(4)),
                const SizedBox(height: 8),
                if (decision.entryPrice != null)
                  _buildDetailRow('Entry Price', _priceFormat.format(decision.entryPrice)),
                if (decision.entryPrice != null) const SizedBox(height: 8),
                _buildDetailRow(
                  'Profit Target',
                  _priceFormat.format(decision.profitTarget),
                  color: Colors.green,
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  'Stop Loss',
                  _priceFormat.format(decision.stopLoss),
                  color: Colors.red,
                ),
                const SizedBox(height: 8),
                _buildDetailRow('Risk Amount', _currencyFormat.format(decision.riskUsd)),
                
                const Divider(height: 24),
                
                // Confidence & Risk/Reward
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Confidence',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              SizedBox(
                                width: 100,
                                child: LinearProgressIndicator(
                                  value: decision.confidence,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _getConfidenceColor(decision.confidence),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${(decision.confidence * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: _getConfidenceColor(decision.confidence),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (decision.entryPrice != null && decision.riskRewardRatio > 0)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'R:R Ratio',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '1:${decision.riskRewardRatio.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                
                // Invalidation Condition
                if (decision.invalidationCondition.isNotEmpty) ...[
                  const Divider(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber, color: Colors.orange.shade700, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Invalidation Condition',
                                style: TextStyle(
                                  color: Colors.orange.shade900,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                decision.invalidationCondition,
                                style: TextStyle(
                                  color: Colors.orange.shade900,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                // Potential Profit
                if (decision.entryPrice != null && decision.potentialProfit > 0) ...[
                  const Divider(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.attach_money, color: Colors.green.shade700, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Potential Profit',
                              style: TextStyle(
                                color: Colors.green.shade900,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          _currencyFormat.format(decision.potentialProfit),
                          style: TextStyle(
                            color: Colors.green.shade900,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
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
            fontSize: 14,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getSignalColor(String signal) {
    switch (signal.toLowerCase()) {
      case 'buy':
        return Colors.green;
      case 'sell':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData _getSignalIcon(String signal) {
    switch (signal.toLowerCase()) {
      case 'buy':
        return Icons.arrow_upward;
      case 'sell':
        return Icons.arrow_downward;
      default:
        return Icons.pause;
    }
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.7) return Colors.green;
    if (confidence >= 0.5) return Colors.orange;
    return Colors.red;
  }
}
