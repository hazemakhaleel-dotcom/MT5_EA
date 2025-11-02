//+------------------------------------------------------------------+
//| State.types.mqh                                               |
//| Placeholder for State.types.                                  |
//+------------------------------------------------------------------+
#ifndef STATE_TYPES_MQH
#define STATE_TYPES_MQH

#include "..\\Shared\\TSB.ids.mqh"

// TODO: expand with latency histograms and error taxonomy when metrics spec defined.
struct Telemetry
  {
   int        ticks_processed;
   int        entries_sent;
   int        exits_sent;
   double     cum_pnl;
   int        consecutive_errors;
   int        reconcile_mismatches;
   HealthFlag hf;

   Telemetry()
     // Assumption: zero baseline ensures we can detect first updates easily.
     : ticks_processed(0),
       entries_sent(0),
       exits_sent(0),
       cum_pnl(0.0),
       consecutive_errors(0),
       reconcile_mismatches(0),
       hf(HF_None)
   {
   }
  };

#endif // STATE_TYPES_MQH
