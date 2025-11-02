//+------------------------------------------------------------------+
//| Risk.types.mqh                                                |
//| Placeholder for Risk.types.                                   |
//+------------------------------------------------------------------+
#ifndef RISK_TYPES_MQH
#define RISK_TYPES_MQH

#include "..\\Signals\\Signals.types.mqh"
#include "..\\Shared\\TSB.ids.mqh"

// TODO: add margin/equity safety toggles once requirements fixed.
struct RiskContext
  {
   double equity;
   double risk_per_trade;
   double min_rr;
   double min_stop_pts;

   RiskContext()
     // Assumption: defaults align with MVP doc (1% risk, min RR 1).
     : equity(0.0),
       risk_per_trade(1.0),
       min_rr(1.0),
       min_stop_pts(10.0)
   {
   }
  };

// Implemented: direct translation of entry signal into sizing inputs.
struct OrderCandidate
  {
   string    symbol;
   EntrySide side;
   double    entry_price;
   double    sl_price;
   double    tp_price;

   OrderCandidate()
     // Assumption: zeroed prices let Risk_BuildOrder decide viability.
     : symbol(""),
       side(ES_None),
       entry_price(0.0),
       sl_price(0.0),
       tp_price(0.0)
   {
   }
  };

// Implemented: built to satisfy interface spec; TODO: include error taxonomy later.
struct SizingDecision
  {
   RetInfo ret;
   double  lots;
   double  sl_price;
   double  tp_price;
   double  risk_r;

   SizingDecision()
     // Assumption: RC defaults to OK so caller can detect modifications via ret.code.
     : ret(),
       lots(0.0),
       sl_price(0.0),
       tp_price(0.0),
       risk_r(0.0)
   {
   }
  };

#endif // RISK_TYPES_MQH
