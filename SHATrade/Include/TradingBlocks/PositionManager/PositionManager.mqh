//+------------------------------------------------------------------+
//| PositionManager.mqh                                           |
//| Placeholder for PositionManager.                              |
//+------------------------------------------------------------------+
#ifndef POSITIONMANAGER_MQH
#define POSITIONMANAGER_MQH

#include <Trade/Trade.mqh>
#include "PM.types.mqh"         // Queue item stub; full action stack pending.
#include "..\\Execution\\Execution.types.mqh"
#include "..\\Shared\\TSB.ids.mqh"

// TODO: implement symbol locking and action queue processing.
inline bool PM_Step(const string symbol)
  {
   return(false);  // Assumption: caller interprets false as "no work performed".
  }

// TODO: once queue exists, this will push actions for PM_Step to consume.
inline RetInfo PM_EnqueueEntry(const string symbol, const ExecRequest &req, const ExecPolicy &pol)
  {
   RetInfo result;
   result.code = RC_SKIPPED;
   result.msg = "QUEUE_NOT_IMPLEMENTED"; // Assumption: upstream components will skip trading until queue implemented.
   return(result);
  }

// TODO: integrate with PM.ExitExecutor once implemented.
inline RetInfo PM_ForceExit(const string symbol, const ExitReason reason, string note)
  {
   RetInfo result;
   if(reason == XR_None)  // Assumption: caller should never pass XR_None; guard keeps API defensive.
     {
      result.code = RC_SKIPPED;
      result.msg = "NO_REASON";
      return(result);
     }
   CTrade trade;  // Assumes standard CTrade success semantics for forced exit.
   if(trade.PositionClose(symbol))
     {
      result.code = RC_OK;
      result.msg = "FORCED_EXIT"; // Assumption: upstream logging handles reason/note persistence.
     }
   else
     {
      result.code = RC_FATAL;
      result.last_error = (int)trade.ResultRetcode();
      result.msg = trade.ResultRetcodeDescription(); // TODO: map to RetInfo message catalog for consistency.
     }
   return(result);
  }

inline bool PM_HasOpenPosition(const string symbol)
  {
   return(PositionSelect(symbol)); // Assumption: single position per symbol enforced elsewhere.
  }

#endif // POSITIONMANAGER_MQH
