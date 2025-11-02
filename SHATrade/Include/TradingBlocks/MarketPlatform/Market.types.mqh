//+------------------------------------------------------------------+
//| Market.types.mqh                                              |
//| Placeholder for Market.types.                                 |
//+------------------------------------------------------------------+
#ifndef MARKET_TYPES_MQH
#define MARKET_TYPES_MQH

#include "..\\Adapter\\Adapter.types.mqh"

// Implements the normalized view described in architecture doc; assumptions documented below.
struct MarketSnapshot
  {
   string     symbol;
   datetime   time;
   double     bid;
   double     ask;
   double     spread_pts;
   bool       session_open;
   SymbolMeta meta;

   MarketSnapshot()
     : symbol(""),
       time(0),
       bid(0.0),
       ask(0.0),
       spread_pts(0.0),
       session_open(false),
       meta()
   {
    // Assumption: defaults reflect an "offline" snapshot; real data will overwrite via adapter.
   }
  };

#endif // MARKET_TYPES_MQH
