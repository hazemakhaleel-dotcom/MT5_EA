//+------------------------------------------------------------------+
//| Portfolio.types.mqh                                           |
//| Placeholder for Portfolio.types.                              |
//+------------------------------------------------------------------+
#ifndef PORTFOLIO_TYPES_MQH
#define PORTFOLIO_TYPES_MQH

#include "..\\Risk\\Risk.types.mqh"

// TODO: expand with per-symbol exposure & tie-break metadata when required.
struct PortfolioState
  {
   int open_positions;
   int max_concurrent;

   PortfolioState()
     // Assumption: PM maintains accurate open_positions count (single symbol concurrency).
     : open_positions(0),
       max_concurrent(1)
   {
   }
  };

// Implemented: simple accept/reject response; extend with defer when needed.
enum PortfolioVerdict
  {
   PV_Reject = 0,
   PV_Accept = 1
  };

// TODO: include confidence score alignment once tie-break rules final.
struct PortfolioDecision
  {
   PortfolioVerdict verdict;
   int              priority;
   string           reason;

   PortfolioDecision()
     // Assumption: default reject prevents accidental execution until evaluate approves.
     : verdict(PV_Reject),
       priority(0),
       reason("")
   {
   }
  };

#endif // PORTFOLIO_TYPES_MQH
