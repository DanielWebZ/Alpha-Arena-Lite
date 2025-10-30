import 'dart:async';
import 'dart:math';
import '../models/portfolio.dart';
import '../models/position.dart';
import '../models/market_data.dart';
import '../models/trade_decision.dart';

class MockDataService {
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal();

  final Random _random = Random();
  final List<String> _symbols = ['BTC', 'ETH', 'SOL'];
  
  // Initial prices
  final Map<String, double> _basePrices = {
    'BTC': 95000.0,
    'ETH': 3500.0,
    'SOL': 185.0,
  };
  
  final Map<String, double> _currentPrices = {
    'BTC': 95000.0,
    'ETH': 3500.0,
    'SOL': 185.0,
  };

  Portfolio? _currentPortfolio;
  final Map<String, MarketData> _marketData = {};
  final List<TradeDecision> _tradeDecisions = [];

  // Initialize with sample data
  void initialize() {
    _initializePortfolio();
    _initializeMarketData();
    _initializeTradeDecisions();
  }

  void _initializePortfolio() {
    _currentPortfolio = Portfolio(
      positions: [
        Position(
          symbol: 'BTC',
          quantity: 0.12,
          entryPrice: 102000.0,
          currentPrice: _currentPrices['BTC']!,
          liquidationPrice: 91800.0,
          leverage: 10.0,
          unrealizedPnl: (_currentPrices['BTC']! - 102000.0) * 0.12 * 10.0,
          entryTime: DateTime.now().subtract(const Duration(hours: 3)),
          profitTarget: 118136.15,
          stopLoss: 102026.675,
          confidence: 0.75,
          riskUsd: 619.2345,
          notionalUsd: 0.12 * _currentPrices['BTC']!,
          invalidationCondition: 'If the price closes below 105000 on a 3-minute candle',
        ),
        Position(
          symbol: 'ETH',
          quantity: 4.87,
          entryPrice: 3950.0,
          currentPrice: _currentPrices['ETH']!,
          liquidationPrice: 3555.0,
          leverage: 15.0,
          unrealizedPnl: (_currentPrices['ETH']! - 3950.0) * 4.87 * 15.0,
          entryTime: DateTime.now().subtract(const Duration(hours: 5)),
          profitTarget: 4227.35,
          stopLoss: 3714.95,
          confidence: 0.75,
          riskUsd: 624.38,
          notionalUsd: 4.87 * _currentPrices['ETH']!,
          invalidationCondition: 'If the price closes below 3800 on a 3-minute candle',
        ),
        Position(
          symbol: 'SOL',
          quantity: 81.81,
          entryPrice: 189.0,
          currentPrice: _currentPrices['SOL']!,
          liquidationPrice: 170.1,
          leverage: 15.0,
          unrealizedPnl: (_currentPrices['SOL']! - 189.0) * 81.81 * 15.0,
          entryTime: DateTime.now().subtract(const Duration(hours: 2)),
          profitTarget: 201.081,
          stopLoss: 176.713,
          confidence: 0.75,
          riskUsd: 499.504,
          notionalUsd: 81.81 * _currentPrices['SOL']!,
          invalidationCondition: 'If the price closes below 175 on a 3-minute candle',
        ),
      ],
      timestamp: DateTime.now(),
      totalPnl: 0.0,
      availableCash: 875000.0,
      totalAsset: 1000000.0,
      initialCash: 1000000.0,
    );
    
    // Calculate actual totals
    _recalculatePortfolio();
  }

  void _recalculatePortfolio() {
    if (_currentPortfolio == null) return;
    
    double totalPnl = 0.0;
    double totalCollateral = 0.0;
    
    for (var position in _currentPortfolio!.positions) {
      totalPnl += position.unrealizedPnl;
      totalCollateral += position.collateral;
    }
    
    double availableCash = _currentPortfolio!.initialCash - totalCollateral;
    double totalAsset = availableCash + totalCollateral + totalPnl;
    
    _currentPortfolio = Portfolio(
      positions: _currentPortfolio!.positions,
      timestamp: DateTime.now(),
      totalPnl: totalPnl,
      availableCash: availableCash,
      totalAsset: totalAsset,
      initialCash: _currentPortfolio!.initialCash,
    );
  }

  void _initializeMarketData() {
    for (String symbol in _symbols) {
      double basePrice = _basePrices[symbol]!;
      _marketData[symbol] = MarketData(
        symbol: symbol,
        currentPrice: _currentPrices[symbol]!,
        currentEma20: basePrice * (0.98 + _random.nextDouble() * 0.04),
        currentMacd: _random.nextDouble() * 100 - 50,
        currentRsi7: 45 + _random.nextDouble() * 20,
        currentVolume: 1000000 + _random.nextDouble() * 5000000,
        averageVolume: 3000000,
        openInterestLatest: 50000000 + _random.nextDouble() * 10000000,
        openInterestAverage: 55000000,
        fundingRate: (_random.nextDouble() - 0.5) * 0.0002,
        midPrices: List.generate(10, (i) => basePrice * (0.97 + _random.nextDouble() * 0.06)),
        ema20Array: List.generate(10, (i) => basePrice * (0.97 + _random.nextDouble() * 0.06)),
        macdArray: List.generate(10, (i) => _random.nextDouble() * 100 - 50),
        rsi7Array: List.generate(10, (i) => 40 + _random.nextDouble() * 30),
        rsi14Array: List.generate(10, (i) => 40 + _random.nextDouble() * 30),
      );
    }
  }

  void _initializeTradeDecisions() {
    _tradeDecisions.addAll([
      TradeDecision(
        coin: 'BTC',
        signal: 'hold',
        quantity: 0.12,
        profitTarget: 118136.15,
        stopLoss: 102026.675,
        invalidationCondition: 'If the price closes below 105000 on a 3-minute candle',
        leverage: 10,
        confidence: 0.75,
        riskUsd: 619.2345,
        entryPrice: 102000.0,
      ),
      TradeDecision(
        coin: 'ETH',
        signal: 'hold',
        quantity: 4.87,
        profitTarget: 4227.35,
        stopLoss: 3714.95,
        invalidationCondition: 'If the price closes below 3800 on a 3-minute candle',
        leverage: 15,
        confidence: 0.75,
        riskUsd: 624.38,
        entryPrice: 3950.0,
      ),
      TradeDecision(
        coin: 'SOL',
        signal: 'buy',
        quantity: 50.0,
        profitTarget: 210.0,
        stopLoss: 175.0,
        invalidationCondition: 'If the price closes below 175 on a 3-minute candle',
        leverage: 12,
        confidence: 0.68,
        riskUsd: 450.0,
        entryPrice: 185.0,
      ),
    ]);
  }

  // Simulate real-time price updates
  void updatePrices() {
    for (String symbol in _symbols) {
      double basePrice = _basePrices[symbol]!;
      double volatility = symbol == 'BTC' ? 0.003 : 0.005;
      double change = (_random.nextDouble() - 0.5) * volatility;
      _currentPrices[symbol] = (_currentPrices[symbol]! * (1 + change)).clamp(
        basePrice * 0.85,
        basePrice * 1.15,
      );
    }
    
    // Update portfolio positions with new prices
    if (_currentPortfolio != null) {
      List<Position> updatedPositions = _currentPortfolio!.positions.map((pos) {
        double newPrice = _currentPrices[pos.symbol]!;
        double newPnl = (newPrice - pos.entryPrice) * pos.quantity * pos.leverage;
        
        return Position(
          symbol: pos.symbol,
          quantity: pos.quantity,
          entryPrice: pos.entryPrice,
          currentPrice: newPrice,
          liquidationPrice: pos.liquidationPrice,
          leverage: pos.leverage,
          unrealizedPnl: newPnl,
          entryTime: pos.entryTime,
          profitTarget: pos.profitTarget,
          stopLoss: pos.stopLoss,
          confidence: pos.confidence,
          riskUsd: pos.riskUsd,
          notionalUsd: pos.quantity.abs() * newPrice,
          invalidationCondition: pos.invalidationCondition,
        );
      }).toList();
      
      _currentPortfolio = Portfolio(
        positions: updatedPositions,
        timestamp: DateTime.now(),
        totalPnl: _currentPortfolio!.totalPnl,
        availableCash: _currentPortfolio!.availableCash,
        totalAsset: _currentPortfolio!.totalAsset,
        initialCash: _currentPortfolio!.initialCash,
      );
      
      _recalculatePortfolio();
    }
    
    // Update market data
    _initializeMarketData();
  }

  // API-like methods
  Portfolio getPortfolio() {
    return _currentPortfolio!;
  }

  MarketData? getMarketData(String symbol) {
    return _marketData[symbol];
  }

  List<MarketData> getAllMarketData() {
    return _marketData.values.toList();
  }

  List<TradeDecision> getTradeDecisions() {
    return _tradeDecisions;
  }

  double getCurrentPrice(String symbol) {
    return _currentPrices[symbol] ?? 0.0;
  }

  Stream<Portfolio> get portfolioStream {
    return Stream.periodic(const Duration(seconds: 2), (_) {
      updatePrices();
      return getPortfolio();
    });
  }
}
