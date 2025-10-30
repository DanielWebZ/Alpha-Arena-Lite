import 'position.dart';

class Portfolio {
  final List<Position> positions;
  final DateTime timestamp;
  final double totalPnl;
  final double availableCash;
  final double totalAsset;
  final double initialCash;

  Portfolio({
    required this.positions,
    required this.timestamp,
    required this.totalPnl,
    required this.availableCash,
    required this.totalAsset,
    required this.initialCash,
  });

  factory Portfolio.fromJson(Map<String, dynamic> json) {
    return Portfolio(
      positions: (json['positions'] as List<dynamic>)
          .map((p) => Position.fromJson(p as Map<String, dynamic>))
          .toList(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      totalPnl: (json['total_pnl'] as num).toDouble(),
      availableCash: (json['available_cash'] as num).toDouble(),
      totalAsset: (json['total_asset'] as num).toDouble(),
      initialCash: (json['initial_cash'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'positions': positions.map((p) => p.toJson()).toList(),
      'timestamp': timestamp.toIso8601String(),
      'total_pnl': totalPnl,
      'available_cash': availableCash,
      'total_asset': totalAsset,
      'initial_cash': initialCash,
    };
  }

  double get totalReturnPercentage => 
      initialCash > 0 ? ((totalAsset - initialCash) / initialCash) * 100 : 0.0;

  double get totalCollateral => positions.fold(0.0, (sum, p) => sum + p.collateral);
  
  int get openPositionsCount => positions.where((p) => p.quantity != 0).length;
}
