//+------------------------------------------------------------------+
//| Adapter.types.mqh                                             |
//| Placeholder for Adapter.types.                                |
//+------------------------------------------------------------------+
#ifndef ADAPTER_TYPES_MQH
#define ADAPTER_TYPES_MQH

#include "..\\Shared\\TSB.ids.mqh"

// Implemented: DTO mirrors a subset of SymbolInfo fields; assumes these are enough for sizing.
struct SymbolMeta
  {
   string symbol;
   int    digits;
   double point;
   double tick_size;
   double tick_value;
   double lot_step;
   double min_lot;
   double max_lot;
   bool   trading_allowed;

   SymbolMeta()
     : symbol(""),
       digits(0),
       point(0.0),
       tick_size(0.0),
       tick_value(0.0),
       lot_step(0.0),
       min_lot(0.0),
       max_lot(0.0),
       trading_allowed(false)
   {
   }
  };

// TODO: Extend once Execution covers limit/stop variations; baseline fields match CTrade usage.
struct SendRequest
  {
   string              symbol;
   ENUM_ORDER_TYPE     type;
   double              volume;
   double              price;
   double              sl;
   double              tp;
   int                 deviation;
   ulong               magic;
   string              comment;

   SendRequest()
     : symbol(""),
       type(ORDER_TYPE_BUY),
       volume(0.0),
       price(0.0),
       sl(0.0),
       tp(0.0),
       deviation(0),
       magic(0),
       comment("")
   {
   }
  };

// Implemented: captures post-send diagnostics; assumes OMS is the only writer.
struct SendResult
  {
   RetInfo ret;
   ulong   order_ticket;
   ulong   deal_ticket;
   double  price_filled;

   SendResult()
     : ret(),
       order_ticket(0),
       deal_ticket(0),
       price_filled(0.0)
   {
   }
  };

#endif // ADAPTER_TYPES_MQH
