//+------------------------------------------------------------------+
//| RiskManagement.mqh                                              |
//| Placeholder for risk sizing helpers used by the scaffold.       |
//+------------------------------------------------------------------+
#ifndef RISKMANAGEMENT_MQH
#define RISKMANAGEMENT_MQH

#include "Risk.types.mqh"
#include "Risk.inputs.mqh"
#include "..\\Shared\\TSB.math.mqh"
#include "..\\Adapter\\AdapterMQL5.mqh"

// Converts a broker volume step into NormalizeDouble precision (max 8 digits).
inline int Risk_VolumeDigits(const double step)
  {
   if(step <= 0.0)
      return(2);
   double scaled = step;
   int digits = 0;
   while(digits < 8 && MathAbs(scaled - MathRound(scaled)) > 1e-8)
     {
      scaled *= 10.0;
      digits++;
     }
   return(digits);
  }

// Seeds context with input defaults and live equity snapshot.
inline void Risk_Bootstrap(RiskContext &ctx)
  {
   ctx.risk_per_trade = INP_RiskPerTradePct;
   ctx.min_rr = INP_MinRiskReward;
   double equity = 0.0, balance = 0.0, margin_free = 0.0;
   if(Adapter_AccountInfo(equity, balance, margin_free))
      ctx.equity = equity;
  }

// Simplistic sizing stub that enforces risk gates and rounds to broker step.
inline SizingDecision Risk_BuildOrder(const RiskContext &rc, const OrderCandidate &c)
  {
   SizingDecision decision;
   decision.sl_price = c.sl_price;
   decision.tp_price = c.tp_price;

   if(c.symbol == "" || c.side == ES_None)
     {
      decision.ret.code = RC_SKIPPED;
      decision.ret.msg = "NO_SYMBOL";
      return(decision);
     }

   if(rc.equity <= 0.0)
     {
      decision.ret.code = RC_SKIPPED;
      decision.ret.msg = "NO_EQUITY";
      return(decision);
     }

   SymbolMeta meta;
   if(!Adapter_SymbolMeta(c.symbol, meta))
     {
      decision.ret.code = RC_RETRYABLE;
      decision.ret.last_error = Adapter_LastError();
      decision.ret.msg = "SYMBOL_META_FAIL";
      return(decision);
     }

   if(!meta.trading_allowed)
     {
      decision.ret.code = RC_SKIPPED;
      decision.ret.msg = "TRADING_DISABLED";
      return(decision);
     }

   const double stop_distance = MathAbs(c.entry_price - c.sl_price);
   const double tick_size = (meta.tick_size > 0.0 ? meta.tick_size : meta.point);
   if(stop_distance <= 0.0 || tick_size <= 0.0)
     {
      decision.ret.code = RC_SKIPPED;
      decision.ret.msg = "STOP_INVALID";
      return(decision);
     }

   if(stop_distance < rc.min_stop_pts * tick_size)
     {
      decision.ret.code = RC_SKIPPED;
      decision.ret.msg = "STOP_TOO_TIGHT";
      return(decision);
     }

   const double tp_distance = MathAbs(c.tp_price - c.entry_price);
   const double rr = (stop_distance > 0.0 ? tp_distance / stop_distance : 0.0);
   decision.risk_r = rr;
   if(rr < rc.min_rr)
     {
      decision.ret.code = RC_SKIPPED;
      decision.ret.msg = "RR_TOO_LOW";
      return(decision);
     }

   const double risk_fraction = (rc.risk_per_trade > 0.0 ? rc.risk_per_trade : INP_RiskPerTradePct) * 0.01;
   const double capital_at_risk = rc.equity * risk_fraction;
   const double ticks_to_stop = stop_distance / tick_size;
   const double risk_per_lot = ticks_to_stop * meta.tick_value;

   if(risk_per_lot <= 0.0 || capital_at_risk <= 0.0)
     {
      decision.ret.code = RC_SKIPPED;
      decision.ret.msg = "RISK_ZERO";
      return(decision);
     }

   double raw_lots = capital_at_risk / risk_per_lot;
   const double step = (meta.lot_step > 0.0 ? meta.lot_step : 0.01);
   const double min_lot = (meta.min_lot > 0.0 ? meta.min_lot : step);
   const double max_lot = (meta.max_lot > 0.0 ? meta.max_lot : raw_lots);

   double rounded_lots = TSB::RoundToStep(raw_lots, step);
   if(rounded_lots < min_lot)
     {
      decision.ret.code = RC_SKIPPED;
      decision.ret.msg = "SIZE_BELOW_MIN";
      return(decision);
     }

   if(rounded_lots > max_lot)
      rounded_lots = max_lot;

   decision.lots = NormalizeDouble(rounded_lots, Risk_VolumeDigits(step));
   decision.ret.code = RC_OK;
   decision.ret.msg = "OK";
   return(decision);
  }

#endif // RISKMANAGEMENT_MQH
