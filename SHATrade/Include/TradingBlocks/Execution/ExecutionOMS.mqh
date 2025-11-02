//+------------------------------------------------------------------+
//| ExecutionOMS.mqh                                              |
//| Placeholder for ExecutionOMS.                                 |
//+------------------------------------------------------------------+
#ifndef EXECUTIONOMS_MQH
#define EXECUTIONOMS_MQH

#include "Execution.types.mqh"  // DTOs defined per interface spec with scaffold assumptions.
#include "..\\Adapter\\AdapterMQL5.mqh"

inline ExecReport Exec_PlaceEntry(const ExecPolicy &pol, const ExecRequest &req)
  {
   // TODO: integrate pre-trade checks (spread, kill switch) before submitting order.
   // Assumption: CTrade handles broker validation; we surface Adapter_Send result.
   ExecReport report;
   SendRequest send;
   send.symbol = req.cand.symbol;
   send.type = (req.cand.side == ES_Long ? ORDER_TYPE_BUY : ORDER_TYPE_SELL);
   send.volume = req.lots;
   send.price = req.price;
   send.sl = req.sl;
   send.tp = req.tp;
   send.deviation = pol.deviation_pts;
   send.magic = req.magic;
   send.comment = req.comment; // Assumption: upstream formats comment consistently (runId etc.).
   SendResult send_result;
   report.ret = Adapter_Send(send, send_result);
   report.deal_ticket = send_result.deal_ticket;
   report.order_ticket = send_result.order_ticket;
   report.price_filled = send_result.price_filled;
   return(report);
  }

inline RetInfo Exec_AttachOrModify(const string symbol, const double sl, const double tp)
  {
   // TODO: enforce retry/backoff strategy per Execution.retry helpers.
   return(Adapter_PositionModify(symbol, sl, tp)); // Assumes adapter returns fatal on failure.
  }

inline bool Exec_Reconcile(ReconcileReport &out)
  {
   // TODO: replace with detailed reconcile logic once Execution.reconcile exists.
   out.open_positions = PositionsTotal();
   out.open_orders = OrdersTotal();
   out.mismatches = 0;      // TODO: fill from reconcile diff once available.
   out.error_count = 0;    // Assumption: retry taxonomy not yet implemented.
   out.healed = true;    // Assumption: without reconciliation we mark as healthy by default.
   out.notes = "STUB";           // Assumption: caller ignores note until reconcile implemented.
   return(true);
  }

#endif // EXECUTIONOMS_MQH
