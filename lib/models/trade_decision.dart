class TradeDecision {
  final String coin;
  final String signal; // 'buy', 'sell', 'hold'
  final double quantity;
  final double profitTarget;
  final double stopLoss;
  final String invalidationCondition;
  final double leverage;
  final double confidence;
  final double riskUsd;
  final double? entryPrice;

  TradeDecision({
    required this.coin,
    required this.signal,
    required this.quantity,
    required this.profitTarget,
    required this.stopLoss,
    required this.invalidationCondition,
    required this.leverage,
    required this.confidence,
    required this.riskUsd,
    this.entryPrice,
  });

  factory TradeDecision.fromJson(Map<String, dynamic> json) {
    return TradeDecision(
      coin: json['coin'] as String,
      signal: json['signal'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      profitTarget: (json['profit_target'] as num).toDouble(),
      stopLoss: (json['stop_loss'] as num).toDouble(),
      invalidationCondition: json['invalidation_condition'] as String,
      leverage: (json['leverage'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
      riskUsd: (json['risk_usd'] as num).toDouble(),
      entryPrice: json['entry_price'] != null 
          ? (json['entry_price'] as num).toDouble() 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coin': coin,
      'signal': signal,
      'quantity': quantity,
      'profit_target': profitTarget,
      'stop_loss': stopLoss,
      'invalidation_condition': invalidationCondition,
      'leverage': leverage,
      'confidence': confidence,
      'risk_usd': riskUsd,
      if (entryPrice != null) 'entry_price': entryPrice,
    };
  }

  bool get isBuy => signal.toLowerCase() == 'buy';
  bool get isSell => signal.toLowerCase() == 'sell';
  bool get isHold => signal.toLowerCase() == 'hold';
  
  double get potentialProfit => entryPrice != null 
      ? (profitTarget - entryPrice!) * quantity.abs() * leverage
      : 0.0;
      
  double get riskRewardRatio => riskUsd > 0 ? potentialProfit / riskUsd : 0.0;
}
