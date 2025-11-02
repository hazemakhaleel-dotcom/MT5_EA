//+------------------------------------------------------------------+
//| AdapterMQL5.mqh                                               |
//| Placeholder for AdapterMQL5.                                  |
//+------------------------------------------------------------------+
#ifndef ADAPTERMQL5_MQH
#define ADAPTERMQL5_MQH

#include <Trade/Trade.mqh>
#include "Adapter.types.mqh"

// Implemented: thin wrapper capturing pricing/volume meta; TODO clamp defaults for errors.
inline bool Adapter_SymbolMeta(const string symbol, SymbolMeta &out)
  {
   ResetLastError();
   out.symbol = symbol;
   out.digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   out.point = SymbolInfoDouble(symbol, SYMBOL_POINT);
   out.tick_size = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
   out.tick_value = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
   out.lot_step = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
   out.min_lot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
   out.max_lot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
   out.trading_allowed = (SymbolInfoInteger(symbol, SYMBOL_TRADE_MODE) != SYMBOL_TRADE_MODE_DISABLED);
   return(true);
  }

// TODO: add error handling (return RetInfo) when we need richer feedback for callers.
inline bool Adapter_CopyRates(const string symbol, ENUM_TIMEFRAMES tf, const int count, MqlRates &rates[])
  {
  if(count<=0)
      return(false);  // Assumption: callers pass positive count; early guard avoids CopyRates call.
   ResetLastError();
   return(CopyRates(symbol, tf, 0, count, rates) == count);
  }

// Implemented: quick spread calc; assumes SymbolInfoDouble succeeds for BID/ASK.
inline bool Adapter_Spread(const string symbol, double &out_points)
  {
   double bid = 0.0, ask = 0.0;
   if(!SymbolInfoDouble(symbol, SYMBOL_BID, bid) || !SymbolInfoDouble(symbol, SYMBOL_ASK, ask))
      return(false);
   out_points = (ask - bid) / SymbolInfoDouble(symbol, SYMBOL_POINT); // Assumption: SYMBOL_POINT > 0 for tradeable symbols.
   return(true);
  }

// TODO: Replace hard-coded true with session schedule logic from requirements.
inline bool Adapter_SessionOpen(const string symbol, bool &out_open)
  {
   out_open = true;
   return(true);
  }

// Assumes AccountInfoDouble never fails in tester; revisit for live error handling.
inline bool Adapter_AccountInfo(double &equity, double &balance, double &margin_free)
  {
   equity = AccountInfoDouble(ACCOUNT_EQUITY);
   balance = AccountInfoDouble(ACCOUNT_BALANCE);
   margin_free = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   return(true);
  }

// TODO: extend for pending/limits and map more retcodes as retryable vs fatal.
inline RetInfo Adapter_Send(const SendRequest &req, SendResult &out)
  {
   RetInfo result;  // Start optimistic but update below based on trade outcome.
   CTrade trade;
   trade.SetDeviationInPoints(req.deviation); // Assumption: policy validated upstream; no range checks yet.
   trade.SetExpertMagicNumber((int)req.magic);
   bool sent = false; // Reset each call; multi-order support will rework this logic.
   switch(req.type)
     {
      case ORDER_TYPE_BUY:
         sent = trade.Buy(req.volume, req.symbol, req.price, req.sl, req.tp);
         break;
      case ORDER_TYPE_SELL:
         sent = trade.Sell(req.volume, req.symbol, req.price, req.sl, req.tp);
         break;
      default:
         sent = false;
         break;
     }
   if(!sent)
     {
      result.code = RC_FATAL;
      result.last_error = (int)trade.ResultRetcode();
      result.msg = trade.ResultRetcodeDescription();
     }
   else
     {
      result.code = RC_OK;
      result.last_error = 0;
      result.msg = "OK";
      out.order_ticket = trade.ResultOrder();
      out.deal_ticket = trade.ResultDeal();
      out.price_filled = trade.ResultPrice();
     }
   out.ret = result;
   return(result);
  }

// TODO: add handling for SYMBOL_TRADE_MODE restrictions; currently fatal on failure.
inline RetInfo Adapter_PositionModify(const string symbol, const double sl, const double tp)
  {
   RetInfo result;  // Start optimistic but update below based on trade outcome.
   CTrade trade;
   if(trade.PositionModify(symbol, sl, tp))
     {
      result.code = RC_OK;
      result.msg = "OK";
     }
   else
     {
      result.code = RC_FATAL;
      result.last_error = (int)trade.ResultRetcode();
      result.msg = trade.ResultRetcodeDescription();
     }
   return(result);
  }

// Assumption: first match is enough because PM enforces one position per symbol.
inline bool Adapter_ListOpenPositions(const string symbol, ulong &ticket_out)
  {
   ticket_out = 0;
   const int total = PositionsTotal();
   for(int i = 0; i < total; ++i)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionGetString(POSITION_SYMBOL) == symbol) // TODO: consider hedging support (multiple positions).
        {
         ticket_out = ticket;
         return(true);
        }
     }
   return(false);
  }

// TODO: upgrade to return arrays when multiple pending orders per symbol are allowed.
inline bool Adapter_ListOpenOrders(const string symbol, ulong &ticket_out)
  {
   ticket_out = 0;
   const int total = OrdersTotal();
   for(int i = 0; i < total; ++i)
     {
      ulong ticket = OrderGetTicket(i);
      if(OrderGetString(ORDER_SYMBOL) == symbol) // TODO: extend to return list of tickets when multi orders needed.
        {
         ticket_out = ticket;
         return(true);
        }
     }
   return(false);
  }

// Implemented: simple passthrough; TODO: evaluate if we need adapter-level error stack.
inline int Adapter_LastError()
  {
   return(GetLastError());
  }

#endif // ADAPTERMQL5_MQH
