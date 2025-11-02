//+------------------------------------------------------------------+
//| PM.types.mqh                                                  |
//| Placeholder for PM.types.                                     |
//+------------------------------------------------------------------+
#ifndef PM_TYPES_MQH
#define PM_TYPES_MQH

#include "..\\Signals\\Signals.types.mqh"

// TODO: enhance queue payload with action types (modify, cancel) when PM fleshed out.
struct PMQueueItem
  {
   ExitReason reason;
   datetime   created;

   PMQueueItem()
     // Assumption: created timestamp relied on for throttle/backoff later.
     : reason(XR_None),
       created(TimeCurrent())
   {
   }
  };

#endif // PM_TYPES_MQH
