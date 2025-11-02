//+------------------------------------------------------------------+
//| ExitSignals.mqh                                               |
//| Placeholder for ExitSignals.                                  |
//+------------------------------------------------------------------+
#ifndef EXITSIGNALS_MQH
#define EXITSIGNALS_MQH

#include "Signals.types.mqh"  // Reuse shared enums/structs for exit guidance.

// TODO: ingest position context + signal heuristics.
inline bool Signals_AdviseExit(const string symbol, ExitAdvice &out)
  {
   out.exit_now = false;  // Assumption: PM treats false as "hold position".
   out.reason = XR_None;
   out.new_sl = 0.0; // Assumption: PM keeps current SL when advice absent.
   out.new_tp = 0.0; // Assumption: trailing logic will adjust TP later if needed.
   return(false);
  }

#endif // EXITSIGNALS_MQH
