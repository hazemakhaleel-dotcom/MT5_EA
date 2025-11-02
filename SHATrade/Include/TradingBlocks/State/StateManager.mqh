//+------------------------------------------------------------------+
//| StateManager.mqh                                              |
//| Placeholder for StateManager.                                 |
//+------------------------------------------------------------------+
#ifndef STATEMANAGER_MQH
#define STATEMANAGER_MQH

#include "State.types.mqh"  // Telemetry struct + RC enums documented in State.types.
#include "..\\Shared\\TSB.ids.mqh"
#include "..\\Execution\\Execution.types.mqh"
#include "..\\Signals\\Signals.types.mqh"

static Telemetry g_state_telemetry; // Assumption: single EA instance, so global telemetry is acceptable.

// TODO: persist telemetry to disk/log if needed.
inline bool State_Init()
  {
   g_state_telemetry = Telemetry();
   return(true);
  }

// TODO: integrate with Kernel cadence metrics.
inline void State_IncTick()
  {
   g_state_telemetry.ticks_processed++;
  }

// TODO: capture fill price for PnL calc once Execution reports include it.
inline void State_RecordExec(const ExecReport &r)
  {
   g_state_telemetry.entries_sent++;
   if(r.ret.code != RC_OK)
      g_state_telemetry.consecutive_errors++;
   else
      g_state_telemetry.consecutive_errors = 0;
  }

inline void State_RecordExit(const string symbol, const ExitReason reason)
  {
   g_state_telemetry.exits_sent++;
   g_state_telemetry.cum_pnl += 0.0; // TODO: wire actual PnL using Execution + Adapter history.
  }

// TODO: classify retryable vs fatal once Execution retry logic ready.
inline void State_RecordError(const RetInfo &e)
  {
   g_state_telemetry.consecutive_errors++;
   if(e.code == RC_FATAL)
      g_state_telemetry.hf = HF_ErrorStorm;
  }

// TODO: integrate with Kernel gate evaluation once gating logic live.
inline void State_SetHealth(const HealthFlag flag)
  {
   g_state_telemetry.hf = flag;
  }

// Assumption: callers receive a copy; consider exposing const ref if performance needed.
inline bool State_Get(Telemetry &out)
  {
   out = g_state_telemetry;
   return(true);
  }

#endif // STATEMANAGER_MQH
