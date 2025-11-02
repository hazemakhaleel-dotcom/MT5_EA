//+------------------------------------------------------------------+
//| Kernel.types.mqh                                              |
//| Placeholder for Kernel.types.                                 |
//+------------------------------------------------------------------+
#ifndef KERNEL_TYPES_MQH
#define KERNEL_TYPES_MQH

// Assumption: minimal context is enough for scaffolding; extend when Kernel logic wired.
struct KernelContext
  {
   datetime        now;
   string          symbol;
   ENUM_TIMEFRAMES timeframe;
   bool            is_session_open;
   double          spread;

   KernelContext()
     : now(0),
       symbol(""),
       timeframe(PERIOD_CURRENT),
       is_session_open(false),
       spread(0.0)
   {
   }
  };

#endif // KERNEL_TYPES_MQH
