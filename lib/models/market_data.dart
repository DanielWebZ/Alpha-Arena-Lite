class MarketData {
  final String symbol;
  final double currentPrice;
  final double currentEma20;
  final double currentMacd;
  final double currentRsi7;
  final double currentVolume;
  final double averageVolume;
  final double openInterestLatest;
  final double openInterestAverage;
  final double fundingRate;
  final List<double> midPrices;
  final List<double> ema20Array;
  final List<double> macdArray;
  final List<double> rsi7Array;
  final List<double> rsi14Array;

  MarketData({
    required this.symbol,
    required this.currentPrice,
    required this.currentEma20,
    required this.currentMacd,
    required this.currentRsi7,
    required this.currentVolume,
    required this.averageVolume,
    required this.openInterestLatest,
    required this.openInterestAverage,
    required this.fundingRate,
    required this.midPrices,
    required this.ema20Array,
    required this.macdArray,
    required this.rsi7Array,
    required this.rsi14Array,
  });

  factory MarketData.fromJson(Map<String, dynamic> json, String symbol) {
    return MarketData(
      symbol: symbol,
      currentPrice: (json['current_price'] as num).toDouble(),
      currentEma20: (json['current_close_20_ema'] as num).toDouble(),
      currentMacd: (json['current_macd'] as num).toDouble(),
      currentRsi7: (json['current_rsi_7'] as num).toDouble(),
      currentVolume: (json['current_volume'] as num).toDouble(),
      averageVolume: (json['average_volume'] as num).toDouble(),
      openInterestLatest: (json['open_interest_latest'] as num).toDouble(),
      openInterestAverage: (json['open_interest_average'] as num).toDouble(),
      fundingRate: (json['funding_rate'] as num).toDouble(),
      midPrices: (json['mid_prices'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      ema20Array: (json['ema_20_array'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      macdArray: (json['macd_array'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      rsi7Array: (json['rsi_7_array'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      rsi14Array: (json['rsi_14_array'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'current_price': currentPrice,
      'current_close_20_ema': currentEma20,
      'current_macd': currentMacd,
      'current_rsi_7': currentRsi7,
      'current_volume': currentVolume,
      'average_volume': averageVolume,
      'open_interest_latest': openInterestLatest,
      'open_interest_average': openInterestAverage,
      'funding_rate': fundingRate,
      'mid_prices': midPrices,
      'ema_20_array': ema20Array,
      'macd_array': macdArray,
      'rsi_7_array': rsi7Array,
      'rsi_14_array': rsi14Array,
    };
  }

  // Technical indicators analysis
  bool get isRsiBullish => currentRsi7 > 50;
  bool get isMacdBullish => currentMacd > 0;
  bool get isPriceAboveEma => currentPrice > currentEma20;
  bool get isVolumeAboveAverage => currentVolume > averageVolume;
  
  String get trend {
    int bullishSignals = 0;
    if (isRsiBullish) bullishSignals++;
    if (isMacdBullish) bullishSignals++;
    if (isPriceAboveEma) bullishSignals++;
    
    if (bullishSignals >= 2) return 'Bullish';
    if (bullishSignals == 1) return 'Neutral';
    return 'Bearish';
  }
}
