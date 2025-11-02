//+------------------------------------------------------------------+
//| Execution.types.mqh                                           |
//| Placeholder for Execution.types.                              |
//+------------------------------------------------------------------+
#ifndef EXECUTION_TYPES_MQH
#define EXECUTION_TYPES_MQH

#include "..\\Risk\\Risk.types.mqh"
#include "..\\Shared\\TSB.ids.mqh"

// TODO: align defaults with broker constraints (slippage, filling modes).
struct ExecPolicy
  {
   int                      deviation_pts;
   double                   max_spread_pts;
   ENUM_ORDER_TYPE_FILLING  filling;

   ExecPolicy()
     // Assumption: deviation/spread placeholders are safe for initial dry-runs.
     : deviation_pts(10),
       max_spread_pts(30.0),
       filling(ORDER_FILLING_FOK)
   {
   }
  };

// TODO: extend with partial fill handling and parent order IDs.
struct ExecRequest
  {
   OrderCandidate cand;
   double         lots;
   double         price;
   double         sl;
   double         tp;
   ulong          magic;
   string         comment;

   ExecRequest()
     // Assumption: magic/comment passed through from upstream modules.
     : cand(),
       lots(0.0),
       price(0.0),
       sl(0.0),
       tp(0.0),
       magic(0),
       comment("")
   {
   }
  };

// Implemented: minimal report surface; TODO add latency metrics, retcode mapping.
struct ExecReport
  {
   RetInfo ret;
   ulong   deal_ticket;
   ulong   order_ticket;
   double  price_filled;

   ExecReport()
     // Assumption: zeroed tickets indicate request did not execute.
     : ret(),
       deal_ticket(0),
       order_ticket(0),
       price_filled(0.0)
   {
   }
  };

// TODO: tie into Execution.reconcile implementation once defined.
struct ReconcileReport
  {
   int    open_positions;
   int    open_orders;
   int    mismatches;
   int    error_count;
   bool   healed;
   string notes;

   ReconcileReport()
     // Assumption: healed=true indicates no outstanding mismatches post reconcile.
     : open_positions(0),
       open_orders(0),
       mismatches(0),
       error_count(0),
       healed(true),
       notes("")
   {
   }
  };

#endif // EXECUTION_TYPES_MQH
