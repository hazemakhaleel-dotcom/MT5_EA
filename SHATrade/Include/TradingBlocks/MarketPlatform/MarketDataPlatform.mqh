//+------------------------------------------------------------------+
//| MarketDataPlatform.mqh                                        |
//| Placeholder for MarketDataPlatform.                           |
//+------------------------------------------------------------------+
#ifndef MARKETDATAPLATFORM_MQH
#define MARKETDATAPLATFORM_MQH

#include "Market.types.mqh"          // Implemented DTO set; see assumptions in Market.types.
#include "..\\Adapter\\AdapterMQL5.mqh" // TODO: swap to cached pulls when performance is critical.

inline bool Market_InitSymbol(const string symbol, ENUM_TIMEFRAMES tf)
  {
   // TODO: Preload more than one bar once memory budget is known; 1 bar is enough for compile.
   SymbolMeta meta; // Assumption: local copy enough; we do not store global cache yet.
   if(!Adapter_SymbolMeta(symbol, meta))
      return(false);
   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   return(Adapter_CopyRates(symbol, tf, 1, rates));
  }

inline bool Market_Snapshot(const string symbol, MarketSnapshot &out)
  {
   // Assumes synchronous snapshot is acceptable; revisit for async data feed support.
   out.symbol = symbol;
   Adapter_SymbolMeta(symbol, out.meta); // TODO: reuse cached meta if performance becomes an issue.
   double spread_points = 0.0;
   Adapter_Spread(symbol, spread_points);
   out.spread_pts = spread_points;
   out.session_open = true;  // Assumption: trading allowed by default until session adapter implemented.
   Adapter_SessionOpen(symbol, out.session_open); // TODO: consult trading calendar once adapter exposes session schedule.
   double bid = 0.0, ask = 0.0;
   SymbolInfoDouble(symbol, SYMBOL_BID, bid); // Assumption: terminal updates BID/ASK synchronously.
   SymbolInfoDouble(symbol, SYMBOL_ASK, ask); // TODO: fallback to Adapter if direct call fails.
   out.bid = bid;
   out.ask = ask;
   out.time = TimeCurrent(); // Assumption: server time acceptable for telemetry; revisit if using external data feed.
   return(true);
  }

inline bool Market_GetRates(const string symbol, ENUM_TIMEFRAMES tf, const int bars, MqlRates &out[])
  {
   // TODO: Add validation for bars <= available history; currently relies on CopyRates to clamp.
   ArraySetAsSeries(out, true);
   return(Adapter_CopyRates(symbol, tf, bars, out)); // TODO: propagate failure reason back to caller via RetInfo.
  }

#endif // MARKETDATAPLATFORM_MQH
