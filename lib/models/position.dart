class Position {
  final String symbol;
  final double quantity;
  final double entryPrice;
  final double currentPrice;
  final double? liquidationPrice;
  final double leverage;
  final double unrealizedPnl;
  final DateTime entryTime;
  final double? profitTarget;
  final double? stopLoss;
  final double confidence;
  final double riskUsd;
  final double notionalUsd;
  final String? invalidationCondition;

  Position({
    required this.symbol,
    required this.quantity,
    required this.entryPrice,
    required this.currentPrice,
    this.liquidationPrice,
    required this.leverage,
    required this.unrealizedPnl,
    required this.entryTime,
    this.profitTarget,
    this.stopLoss,
    this.confidence = 0.5,
    required this.riskUsd,
    required this.notionalUsd,
    this.invalidationCondition,
  });

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      symbol: json['symbol'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      entryPrice: (json['entry_price'] as num).toDouble(),
      currentPrice: (json['current_price'] as num).toDouble(),
      liquidationPrice: json['liquidation_price'] != null 
          ? (json['liquidation_price'] as num).toDouble() 
          : null,
      leverage: (json['leverage'] as num).toDouble(),
      unrealizedPnl: (json['unrealized_pnl'] as num).toDouble(),
      entryTime: DateTime.parse(json['entry_time'] as String),
      profitTarget: json['exit_plan']?['profit_target'] != null
          ? (json['exit_plan']['profit_target'] as num).toDouble()
          : null,
      stopLoss: json['exit_plan']?['stop_loss'] != null
          ? (json['exit_plan']['stop_loss'] as num).toDouble()
          : null,
      confidence: json['confidence'] != null 
          ? (json['confidence'] as num).toDouble() 
          : 0.5,
      riskUsd: json['risk_usd'] != null 
          ? (json['risk_usd'] as num).toDouble() 
          : 0.0,
      notionalUsd: json['notional_usd'] != null 
          ? (json['notional_usd'] as num).toDouble() 
          : 0.0,
      invalidationCondition: json['exit_plan']?['invalidation_condition'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'quantity': quantity,
      'entry_price': entryPrice,
      'current_price': currentPrice,
      'liquidation_price': liquidationPrice,
      'leverage': leverage,
      'unrealized_pnl': unrealizedPnl,
      'entry_time': entryTime.toIso8601String(),
      'exit_plan': {
        if (profitTarget != null) 'profit_target': profitTarget,
        if (stopLoss != null) 'stop_loss': stopLoss,
        if (invalidationCondition != null) 'invalidation_condition': invalidationCondition,
      },
      'confidence': confidence,
      'risk_usd': riskUsd,
      'notional_usd': notionalUsd,
    };
  }

  bool get isLong => quantity > 0;
  bool get isShort => quantity < 0;
  
  double get pnlPercentage => (unrealizedPnl / (entryPrice * quantity.abs())) * 100;
  
  double get collateral => (quantity.abs() * entryPrice) / leverage;
}
