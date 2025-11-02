//+------------------------------------------------------------------+
//| Signals.types.mqh                                             |
//| Placeholder for Signals.types.                                |
//+------------------------------------------------------------------+
#ifndef SIGNALS_TYPES_MQH
#define SIGNALS_TYPES_MQH

// Implements entry direction classification; extend when multi-legged setups needed.
enum EntrySide
  {
   ES_None = 0,
   ES_Long = 1,
   ES_Short = 2
  };

// TODO: confirm if hints need ATR-normalised values.
struct EntrySignal
  {
   EntrySide side;
   double    entry_price_hint;
   double    sl_price_hint;
   double    tp_price_hint;
   int       strength_0_100;
   string    strategy_tag;

   EntrySignal()
    // Assumption: zeroed hints mean signal builder will populate before use.
     : side(ES_None),
       entry_price_hint(0.0),
       sl_price_hint(0.0),
       tp_price_hint(0.0),
       strength_0_100(0),
       strategy_tag("")
   {
   }
  };

// Implements reasons enumerated in architecture doc; extend with broker errors if needed.
enum ExitReason
  {
   XR_None = 0,
   XR_Stop,
   XR_TakeProfit,
   XR_Trailing,
   XR_Time,
   XR_Reverse,
   XR_Manual
  };

// TODO: consider exposing trailing context to PM for richer decisions.
struct ExitAdvice
  {
   bool       exit_now;
   ExitReason reason;
   double     new_sl;
   double     new_tp;

   ExitAdvice()
    // Assumption: PM treats false exit_now as "no-op" on current pass.
     : exit_now(false),
       reason(XR_None),
       new_sl(0.0),
       new_tp(0.0)
   {
   }
  };

#endif // SIGNALS_TYPES_MQH
