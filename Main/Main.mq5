//+------------------------------------------------------------------+
//|                                                  ModularEA.mq5   |
//|                       Example structured expert advisor skeleton |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
#property version   "1.01"

#include <Trade\Trade.mqh>

//--- input parameters
input string             InpSymbol            = _Symbol;
input ENUM_TIMEFRAMES    InpTimeframe         = PERIOD_CURRENT;
input double             InpRiskPercent       = 1.0;
input double             InpFallbackLots      = 0.10;
input double             InpMaxSpreadPoints   = 25.0;
input int                InpMagicNumber       = 123456;
input int                InpMaxSlippage       = 5;
input int                InpFastMAPeriod      = 21;
input int                InpSlowMAPeriod      = 55;
input ENUM_MA_METHOD     InpMAMethod          = MODE_EMA;
input ENUM_APPLIED_PRICE InpMAPrice           = PRICE_CLOSE;
input int                InpATRPeriod         = 14;
input double             InpStopATRMultiplier = 2.0;
input double             InpTakeATRMultiplier = 3.0;

//--- signal direction enum
enum ENUM_SIGNAL_DIRECTION
  {
   SIGNAL_NONE = 0,
   SIGNAL_BUY  = 1,
   SIGNAL_SELL = 2
  };

//--- trade signal payload shared between modules
struct STradeSignal
  {
   ENUM_SIGNAL_DIRECTION direction;
   double                entry_price;
   double                stop_loss;
   double                take_profit;
   datetime              timestamp;
  };

void TradeSignalReset(STRadeSignal &signal)
  {
   signal.direction   = SIGNAL_NONE;
   signal.entry_price = 0.0;
   signal.stop_loss   = 0.0;
   signal.take_profit = 0.0;
   signal.timestamp   = 0;
  }

//--- helpers
double NormalizeVolume(const string symbol,const double volume)
  {
   double minVolume = SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN);
   double maxVolume = SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX);
   double step      = SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP);

   double clamped = MathMax(minVolume,MathMin(maxVolume,volume));
   if(step > 0.0)
     {
      double steps = MathRound((clamped - minVolume) / step);
      clamped = minVolume + steps * step;
     }

   clamped = MathMax(minVolume,MathMin(maxVolume,clamped));

   int digits = 2;
   if(step > 0.0)
     {
      double tmpStep = step;
      digits = 0;
      while(tmpStep < 1.0 && digits < 8)
        {
         tmpStep *= 10.0;
         digits++;
        }
     }
   else
     {
      digits = 2;
     }

   return NormalizeDouble(clamped,digits);
  }

bool IsSpreadAcceptable(const string symbol,const double maxSpreadPoints)
  {
   if(maxSpreadPoints <= 0.0)
      return true;

   double spread = (double)SymbolInfoInteger(symbol,SYMBOL_SPREAD);
   if(spread <= 0.0)
     {
      MqlTick tick;
      if(!SymbolInfoTick(symbol,tick))
         return false;

      double point = SymbolInfoDouble(symbol,SYMBOL_POINT);
      if(point <= 0.0)
         return false;

      spread = (tick.ask - tick.bid) / point;
     }

   return (spread <= maxSpreadPoints);
  }

//--- module interfaces
class CModuleLifecycle
  {
public:
   virtual bool Init() = 0;
   virtual void Shutdown() { }
  };

class CSignalModule : public CModuleLifecycle
  {
public:
   virtual bool Evaluate(STRadeSignal &signal) = 0;
  };

class CRiskModule : public CModuleLifecycle
  {
public:
   virtual bool Calculate(const STradeSignal &signal,double &volume) = 0;
  };

class CExecutionModule : public CModuleLifecycle
  {
public:
   virtual bool Process(const STradeSignal &signal,const double volume) = 0;
  };

//--- default MA crossover signal module
class CMovingAverageSignal : public CSignalModule
  {
private:
   string             m_symbol;
   ENUM_TIMEFRAMES    m_timeframe;
   int                m_fastPeriod;
   int                m_slowPeriod;
   ENUM_MA_METHOD     m_method;
   ENUM_APPLIED_PRICE m_price;
   int                m_fastHandle;
   int                m_slowHandle;
   int                m_atrHandle;
   int                m_atrPeriod;
   double             m_stopMultiplier;
   double             m_takeMultiplier;
   datetime           m_lastSignalBar;

public:
                     CMovingAverageSignal(void)
     {
      m_symbol         = _Symbol;
      m_timeframe      = PERIOD_CURRENT;
      m_fastPeriod     = 21;
      m_slowPeriod     = 55;
      m_method         = MODE_EMA;
      m_price          = PRICE_CLOSE;
      m_fastHandle     = INVALID_HANDLE;
      m_slowHandle     = INVALID_HANDLE;
      m_atrHandle      = INVALID_HANDLE;
      m_atrPeriod      = 14;
      m_stopMultiplier = 2.0;
      m_takeMultiplier = 3.0;
      m_lastSignalBar  = 0;
     }

   void Configure(const string symbol,
                  const ENUM_TIMEFRAMES timeframe,
                  const int fastPeriod,
                  const int slowPeriod,
                  const ENUM_MA_METHOD method,
                  const ENUM_APPLIED_PRICE price,
                  const int atrPeriod,
                  const double stopMultiplier,
                  const double takeMultiplier)
     {
      m_symbol         = symbol;
      m_timeframe      = timeframe;
      m_fastPeriod     = fastPeriod;
      m_slowPeriod     = slowPeriod;
      m_method         = method;
      m_price          = price;
      m_atrPeriod      = atrPeriod;
      m_stopMultiplier = stopMultiplier;
      m_takeMultiplier = takeMultiplier;
     }

   bool Init()
     {
      if(m_fastPeriod <= 0 || m_slowPeriod <= 0 || m_atrPeriod <= 0)
        {
         Print("CMovingAverageSignal: invalid periods");
         return false;
        }

      if(m_fastPeriod >= m_slowPeriod)
         Print("CMovingAverageSignal: fast MA period is greater than or equal to slow period");

      m_fastHandle = iMA(m_symbol,m_timeframe,m_fastPeriod,0,m_method,m_price);
      m_slowHandle = iMA(m_symbol,m_timeframe,m_slowPeriod,0,m_method,m_price);
      m_atrHandle  = iATR(m_symbol,m_timeframe,m_atrPeriod);

      if(m_fastHandle == INVALID_HANDLE || m_slowHandle == INVALID_HANDLE || m_atrHandle == INVALID_HANDLE)
        {
         Print("CMovingAverageSignal: failed to create indicator handles");
         return false;
        }

      return true;
     }

   void Shutdown()
     {
      if(m_fastHandle != INVALID_HANDLE)
        {
         IndicatorRelease(m_fastHandle);
         m_fastHandle = INVALID_HANDLE;
        }
      if(m_slowHandle != INVALID_HANDLE)
        {
         IndicatorRelease(m_slowHandle);
         m_slowHandle = INVALID_HANDLE;
        }
      if(m_atrHandle != INVALID_HANDLE)
        {
         IndicatorRelease(m_atrHandle);
         m_atrHandle = INVALID_HANDLE;
        }
     }

   bool Evaluate(STRadeSignal &signal)
     {
      signal.Reset();

      if(m_fastHandle == INVALID_HANDLE || m_slowHandle == INVALID_HANDLE || m_atrHandle == INVALID_HANDLE)
         return false;

      double fast[2], slow[2], atr[1];
      if(CopyBuffer(m_fastHandle,0,0,2,fast) != 2)
         return false;
      if(CopyBuffer(m_slowHandle,0,0,2,slow) != 2)
         return false;
      if(CopyBuffer(m_atrHandle,0,0,1,atr) != 1)
         return false;

      datetime barTime[1];
      if(CopyTime(m_symbol,m_timeframe,0,1,barTime) != 1)
         return false;

      if(barTime[0] == m_lastSignalBar)
         return true; // already handled this bar

      MqlTick tick;
      if(!SymbolInfoTick(m_symbol,tick))
         return false;

      int digits = (int)SymbolInfoInteger(m_symbol,SYMBOL_DIGITS);
      bool generated = false;

      if(fast[1] <= slow[1] && fast[0] > slow[0])
        {
         signal.direction   = SIGNAL_BUY;
         signal.entry_price = tick.ask;
         signal.stop_loss   = NormalizeDouble(tick.ask - atr[0] * m_stopMultiplier,digits);
         signal.take_profit = NormalizeDouble(tick.ask + atr[0] * m_takeMultiplier,digits);
         generated          = true;
        }
      else if(fast[1] >= slow[1] && fast[0] < slow[0])
        {
         signal.direction   = SIGNAL_SELL;
         signal.entry_price = tick.bid;
         signal.stop_loss   = NormalizeDouble(tick.bid + atr[0] * m_stopMultiplier,digits);
         signal.take_profit = NormalizeDouble(tick.bid - atr[0] * m_takeMultiplier,digits);
         generated          = true;
        }

      if(generated)
        {
         signal.timestamp   = TimeCurrent();
         m_lastSignalBar    = barTime[0];
        }

      return true;
     }
  };

//--- default fractional risk module
class CFractionalRiskModule : public CRiskModule
  {
private:
   string m_symbol;
   double m_riskPercent;
   double m_fallbackLots;

public:
                     CFractionalRiskModule(void)
     {
      m_symbol       = _Symbol;
      m_riskPercent  = 1.0;
      m_fallbackLots = 0.10;
     }

   void Configure(const string symbol,const double riskPercent,const double fallbackLots)
     {
      m_symbol       = symbol;
      m_riskPercent  = riskPercent;
      m_fallbackLots = fallbackLots;
     }

   bool Init()
     {
      return true;
     }

   bool Calculate(const STradeSignal &signal,double &volume)
     {
      volume = 0.0;

      if(signal.direction == SIGNAL_NONE)
         return false;

      double fallback = MathMax(0.0,m_fallbackLots);
      double riskPercent = MathMax(0.0,m_riskPercent);

      double price = signal.entry_price;
      if(price <= 0.0)
        {
         MqlTick tick;
         if(!SymbolInfoTick(m_symbol,tick))
            return false;
         price = (signal.direction == SIGNAL_BUY ? tick.ask : tick.bid);
        }

      double stopLoss = signal.stop_loss;
      if(stopLoss <= 0.0)
        {
         if(fallback <= 0.0)
            return false;
         volume = NormalizeVolume(m_symbol,fallback);
         return (volume > 0.0);
        }

      double balance   = AccountInfoDouble(ACCOUNT_BALANCE);
      double tickValue = SymbolInfoDouble(m_symbol,SYMBOL_TICK_VALUE);
      double tickSize  = SymbolInfoDouble(m_symbol,SYMBOL_TICK_SIZE);
      double point     = SymbolInfoDouble(m_symbol,SYMBOL_POINT);

      if(balance <= 0.0 || tickValue <= 0.0 || tickSize <= 0.0 || point <= 0.0)
        {
         if(fallback <= 0.0)
            return false;
         volume = NormalizeVolume(m_symbol,fallback);
         return (volume > 0.0);
        }

      double stopDistance = MathAbs(price - stopLoss);
      if(stopDistance < point)
        {
         if(fallback <= 0.0)
            return false;
         volume = NormalizeVolume(m_symbol,fallback);
         return (volume > 0.0);
        }

      if(riskPercent <= 0.0)
        {
         if(fallback <= 0.0)
            return false;
         volume = NormalizeVolume(m_symbol,fallback);
         return (volume > 0.0);
        }

      double riskAmount = balance * (riskPercent / 100.0);
      double pointValue = tickValue / tickSize;
      if(pointValue <= 0.0)
        {
         if(fallback <= 0.0)
            return false;
         volume = NormalizeVolume(m_symbol,fallback);
         return (volume > 0.0);
        }

      double rawVolume = riskAmount / ((stopDistance / point) * pointValue);
      volume = NormalizeVolume(m_symbol,rawVolume);

      if(volume <= 0.0 && fallback > 0.0)
         volume = NormalizeVolume(m_symbol,fallback);

      return (volume > 0.0);
     }
  };

//--- default execution module
class CSimpleExecutor : public CExecutionModule
  {
private:
   string m_symbol;
   int    m_magic;
   int    m_slippage;
   CTrade m_trade;

public:
                     CSimpleExecutor(void)
     {
      m_symbol  = _Symbol;
      m_magic   = 0;
      m_slippage = 5;
     }

   void Configure(const string symbol,const int magic,const int slippage)
     {
      m_symbol   = symbol;
      m_magic    = magic;
      m_slippage = slippage;
     }

   bool Init()
     {
      if(StringLen(m_symbol) == 0)
         m_symbol = _Symbol;

      if(!SymbolSelect(m_symbol,true))
        {
         PrintFormat("CSimpleExecutor: failed to select symbol %s",m_symbol);
         return false;
        }

      m_trade.SetExpertMagicNumber(m_magic);
      m_trade.SetDeviationInPoints((ulong)MathMax(0,m_slippage));
      m_trade.SetTypeFillingBySymbol(m_symbol);
      return true;
     }

   void Shutdown()
     {
     }

   bool Process(const STradeSignal &signal,const double volume)
     {
      if(signal.direction == SIGNAL_NONE || volume <= 0.0)
         return false;

      if(PositionSelect(m_symbol) && (long)PositionGetInteger(POSITION_MAGIC) == m_magic)
        {
         long positionType = PositionGetInteger(POSITION_TYPE);
         if((signal.direction == SIGNAL_BUY  && positionType == POSITION_TYPE_BUY) ||
            (signal.direction == SIGNAL_SELL && positionType == POSITION_TYPE_SELL))
            return true;
        }

      if(!EnsureFlatBeforeEntry(signal.direction))
         return false;

      double sl = (signal.stop_loss > 0.0 ? signal.stop_loss : 0.0);
      double tp = (signal.take_profit > 0.0 ? signal.take_profit : 0.0);

      bool result = false;
      if(signal.direction == SIGNAL_BUY)
         result = m_trade.Buy(volume,m_symbol,0.0,sl,tp);
      else if(signal.direction == SIGNAL_SELL)
         result = m_trade.Sell(volume,m_symbol,0.0,sl,tp);

      if(!result)
         PrintFormat("CSimpleExecutor: trade request failed (%d)",GetLastError());

      return result;
     }

private:
   bool EnsureFlatBeforeEntry(const ENUM_SIGNAL_DIRECTION direction)
     {
      if(!PositionSelect(m_symbol))
         return true;

      if((long)PositionGetInteger(POSITION_MAGIC) != m_magic)
         return true;

      long positionType = PositionGetInteger(POSITION_TYPE);
      if((direction == SIGNAL_BUY && positionType == POSITION_TYPE_SELL) ||
         (direction == SIGNAL_SELL && positionType == POSITION_TYPE_BUY))
        {
         if(!m_trade.PositionClose(m_symbol))
           {
            PrintFormat("CSimpleExecutor: failed to close existing position (%d)",GetLastError());
            return false;
           }
        }

      return true;
     }
  };

//--- core engine orchestrating modules
class CStrategyEngine
  {
private:
   string            m_symbol;
   double            m_maxSpread;
   CSignalModule    *m_signal;
   CRiskModule      *m_risk;
   CExecutionModule *m_executor;
   bool              m_ready;

public:
                     CStrategyEngine(void)
     {
      m_symbol    = _Symbol;
      m_maxSpread = 0.0;
      m_signal    = NULL;
      m_risk      = NULL;
      m_executor  = NULL;
      m_ready     = false;
     }

   void Configure(const string symbol,const double maxSpreadPoints)
     {
      m_symbol    = symbol;
      m_maxSpread = maxSpreadPoints;
     }

   void SetModules(CSignalModule &signal,CRiskModule &risk,CExecutionModule &executor)
     {
      m_signal   = &signal;
      m_risk     = &risk;
      m_executor = &executor;
     }

   bool Init()
     {
      m_ready = false;

      if(m_signal == NULL || m_risk == NULL || m_executor == NULL)
        {
         Print("CStrategyEngine: modules are not configured");
         return false;
        }

      if(!m_signal->Init())
        {
         Print("CStrategyEngine: failed to initialize signal module");
         return false;
        }

      if(!m_risk->Init())
        {
         Print("CStrategyEngine: failed to initialize risk module");
         m_signal->Shutdown();
         return false;
        }

      if(!m_executor->Init())
        {
         Print("CStrategyEngine: failed to initialize execution module");
         m_risk->Shutdown();
         m_signal->Shutdown();
         return false;
        }

      m_ready = true;
      return true;
     }

   void Deinit()
     {
      if(m_executor != NULL)
         m_executor->Shutdown();
      if(m_risk != NULL)
         m_risk->Shutdown();
      if(m_signal != NULL)
         m_signal->Shutdown();

      m_ready = false;
     }

   void OnTick()
     {
      if(!m_ready)
         return;

      if(!IsSpreadAcceptable(m_symbol,m_maxSpread))
         return;

      STradeSignal signal;
      signal.Reset();

      if(!m_signal->Evaluate(signal))
         return;

      if(signal.direction == SIGNAL_NONE)
         return;

      double volume = 0.0;
      if(!m_risk->Calculate(signal,volume))
         return;

      if(volume <= 0.0)
         return;

      if(!m_executor->Process(signal,volume))
         Print("CStrategyEngine: execution module rejected the trade");
     }
  };

//--- global modules (replace with custom implementations as needed)
CMovingAverageSignal   g_signal;
CFractionalRiskModule  g_risk;
CSimpleExecutor        g_executor;
CStrategyEngine        g_engine;

//+------------------------------------------------------------------+
//| Expert initialization                                            |
//+------------------------------------------------------------------+
int OnInit()
  {
   ResetLastError();

   string symbol = (StringLen(InpSymbol) > 0 ? InpSymbol : _Symbol);
   ENUM_TIMEFRAMES strategyTimeframe = InpTimeframe;
   if(InpTimeframe == PERIOD_CURRENT)
      strategyTimeframe = (ENUM_TIMEFRAMES)_Period;

   g_signal.Configure(symbol,
                      strategyTimeframe,
                      InpFastMAPeriod,
                      InpSlowMAPeriod,
                      InpMAMethod,
                      InpMAPrice,
                      InpATRPeriod,
                      InpStopATRMultiplier,
                      InpTakeATRMultiplier);

   g_risk.Configure(symbol,InpRiskPercent,InpFallbackLots);
   g_executor.Configure(symbol,InpMagicNumber,InpMaxSlippage);

   g_engine.Configure(symbol,InpMaxSpreadPoints);
   g_engine.SetModules(g_signal,g_risk,g_executor);

   if(!g_engine.Init())
     {
      Print("OnInit: strategy engine failed to initialize");
      return(INIT_FAILED);
     }

   PrintFormat("OnInit: modular engine ready for %s on %s timeframe",
               symbol,
               EnumToString(strategyTimeframe));

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization                                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   g_engine.Deinit();

   PrintFormat("OnDeinit: shutdown reason %d",reason);
  }
//+------------------------------------------------------------------+
//| Expert tick                                                      |
//+------------------------------------------------------------------+
void OnTick()
  {
   g_engine.OnTick();
  }
//+------------------------------------------------------------------+
