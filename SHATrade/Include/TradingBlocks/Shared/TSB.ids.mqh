//+------------------------------------------------------------------+
//| TSB.ids.mqh                                                   |
//| Placeholder for TSB.ids.                                      |
//+------------------------------------------------------------------+
#ifndef TSB_IDS_MQH
#define TSB_IDS_MQH

// Implemented: core return codes used across modules; extend if more severities needed.
enum RC
  {
   RC_OK = 0,
   RC_SKIPPED = 1,
   RC_RETRYABLE = 2,
   RC_FATAL = 3
  };

// TODO: sync with StateManager once more health categories defined.
enum HealthFlag
  {
   HF_None = 0,
   HF_SpreadTooWide = 1,
   HF_ErrorStorm = 2,
   HF_TradeContextBusy = 3,
   HF_ReconcileMismatch = 4,
   HF_SlippageExcessive = 5
  };

// Implemented: lightweight status struct; TODO add helper constructors if needed.
struct RetInfo
  {
   RC      code;
   int     last_error;
   string  msg;

   RetInfo()
     // Assumption: default OK keeps callers from misinterpreting uninitialised structs.
     : code(RC_OK),
       last_error(0),
       msg("")
   {
   }
  };

const ulong TSB_MAGIC_BASE = 900000; // Assumption: reserves range for SHATrade strategies.

#endif // TSB_IDS_MQH
