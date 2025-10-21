//+------------------------------------------------------------------+
//|                                              Test_9_FIXED.mq5   |
//|                                 Complete Event Handling Fixed   |
//+------------------------------------------------------------------+
#property copyright "Fixed EA"
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>

//--- Input Parameters
input int       Position_Size = 1;        // Position size
input int       StopLossPoints = 2000;    // Stop loss in points
input int       TakeProfitPoints = 1000;  // Take profit in points
input int       MinCandleSize = 25;       // Minimum candle body size
input int       VolumeThreshold = 15;     // Volume threshold
input bool      OnlyTradeShorts = true;   // Trade shorts only
input int       MaxTradesPerDay = 3;      // Max trades per day
input int       MagicNumber = 999999;     // Magic number
input bool      DebugMode = true;         // Debug mode

//--- Global Variables
CTrade trade;
CPositionInfo position;
datetime lastTradeTime = 0;
int tradesThisDay = 0;
datetime currentDay = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    // Set expert magic number
    trade.SetExpertMagicNumber(MagicNumber);
    
    Print("=== FIXED CORN FUTURES EA INITIALIZED ===");
    Print("Position Size: ", Position_Size);
    Print("Stop Loss: ", StopLossPoints, " points");
    Print("Take Profit: ", TakeProfitPoints, " points");
    Print("Max Trades Per Day: ", MaxTradesPerDay);
    Print("========================================");
    
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                               |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    Print("EA deinitialized. Reason code: ", reason);
}

//+------------------------------------------------------------------+
//| Expert tick function                                           |
//+------------------------------------------------------------------+
void OnTick()
{
    // Check for existing positions
    if(position.Select(Symbol()))
    {
        if(DebugMode)
            Print("Position already open, skipping new signals");
        return;
    }
    
    // Check for new trading signals
    CheckForSignal();
}

//+------------------------------------------------------------------+
//| Signal detection function                                      |
//+------------------------------------------------------------------+
void CheckForSignal()
{
    // Daily trade limit check
    datetime today = StringToTime(TimeToString(TimeCurrent(), TIME_DATE));
    if(currentDay != today)
    {
        tradesThisDay = 0;
        currentDay = today;
        if(DebugMode)
            Print("New trading day started. Trade count reset.");
    }
    
    if(tradesThisDay >= MaxTradesPerDay) 
    {
        if(DebugMode)
            Print("Daily trade limit reached: ", tradesThisDay);
        return;
    }
    
    // Prevent multiple trades on same bar
    datetime currentBarTime = iTime(Symbol(), PERIOD_CURRENT, 0);
    if(currentBarTime == lastTradeTime) return;
    
    // Need minimum bars
    if(iBars(Symbol(), PERIOD_CURRENT) < 4) return;
    
    // Get market data
    double open[], close[], high[], low[];
    long volume[];
    ArraySetAsSeries(open, true);
    ArraySetAsSeries(close, true);
    ArraySetAsSeries(high, true);
    ArraySetAsSeries(low, true);
    ArraySetAsSeries(volume, true);
    
    if(CopyOpen(Symbol(), PERIOD_CURRENT, 0, 4, open) != 4) return;
    if(CopyClose(Symbol(), PERIOD_CURRENT, 0, 4, close) != 4) return;
    if(CopyHigh(Symbol(), PERIOD_CURRENT, 0, 4, high) != 4) return;
    if(CopyLow(Symbol(), PERIOD_CURRENT, 0, 4, low) != 4) return;
    if(CopyTickVolume(Symbol(), PERIOD_CURRENT, 0, 4, volume) != 4) return;
    
    // Pattern detection with filters
    bool candle1_bull = (close[3] > open[3]) && ((close[3] - open[3]) * 10000 >= MinCandleSize);
    bool candle2_bull = (close[2] > open[2]) && ((close[2] - open[2]) * 10000 >= MinCandleSize);
    bool candle3_bull = (close[1] > open[1]) && ((close[1] - open[1]) * 10000 >= MinCandleSize);
    
    bool threeBullish = candle1_bull && candle2_bull && candle3_bull;
    
    // Volume confirmation
    bool volumeOK = (volume[1] >= VolumeThreshold);
    
    // Price movement validation
    bool priceMovementValid = ((high[1] - low[1]) * 10000 >= MinCandleSize);
    
    // Execute trade if conditions met
    if(OnlyTradeShorts && threeBullish && volumeOK && priceMovementValid)
    {
        if(DebugMode)
        {
            Print("=== SIGNAL DETECTED ===");
            Print("Three Bullish Candles: ", threeBullish);
            Print("Volume OK: ", volumeOK, " (", volume[1], ")");
            Print("Price Movement Valid: ", priceMovementValid);
            Print("======================");
        }
        
        ExecuteShortTrade();
        lastTradeTime = currentBarTime;
        tradesThisDay++;
    }
}

//+------------------------------------------------------------------+
//| Execute SHORT trade                                            |
//+------------------------------------------------------------------+
void ExecuteShortTrade()
{
    double price = SymbolInfoDouble(Symbol(), SYMBOL_BID);
    double sl = price + (StopLossPoints * SymbolInfoDouble(Symbol(), SYMBOL_POINT));
    double tp = price - (TakeProfitPoints * SymbolInfoDouble(Symbol(), SYMBOL_POINT));
    
    Print("=== EXECUTING SHORT TRADE ===");
    Print("Entry Price: ", price);
    Print("Stop Loss: ", sl);
    Print("Take Profit: ", tp);
    Print("Risk/Reward: 1:", NormalizeDouble((price - tp)/(sl - price), 2));
    Print("=============================");
    
    if(trade.Sell(Position_Size, Symbol(), price, sl, tp, "FixedShort"))
    {
        Print("SUCCESS: SHORT trade executed successfully");
    }
    else
    {
        Print("ERROR: SHORT trade failed");
        Print("Error Code: ", trade.ResultRetcode());
        Print("Error Description: ", trade.ResultRetcodeDescription());
    }
}

//+------------------------------------------------------------------+
//| Trade transaction function (optional but recommended)          |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                       const MqlTradeRequest& request,
                       const MqlTradeResult& result)
{
    if(DebugMode && trans.symbol == Symbol())
    {
        Print("Trade transaction: ", EnumToString(trans.type), 
              " Volume: ", trans.volume, " Price: ", trans.price);
    }
}
