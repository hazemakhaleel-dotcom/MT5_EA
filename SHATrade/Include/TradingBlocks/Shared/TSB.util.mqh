//+------------------------------------------------------------------+
//| TSB.util.mqh                                                  |
//| Placeholder for TSB.util.                                     |
//+------------------------------------------------------------------+
#ifndef TSB_UTIL_MQH
#define TSB_UTIL_MQH

#include "TSB.ids.mqh"  // Provides RC enums + magic base constant.

// Implemented: helper namespace for IDs/time formatting; see TODOs below.
namespace TSB
  {
   inline ulong MagicBase()
     {
      return(TSB_MAGIC_BASE); // TODO: allow user override via presets if multiple strategies share platform.
     }

   inline ulong MagicFor(const string strategy_tag)
     {
      uint hash = 0;
      const int length = StringLen(strategy_tag);
      for(int i = 0; i < length; ++i)
        {
         hash = (hash * 131U) + (uint)StringGetCharacter(strategy_tag, i); // Assumption: simple BKDR hash is sufficient for magic separation.
        }
      return(TSB_MAGIC_BASE + (ulong)(hash & 0x00FFFFFF)); // TODO: reserve more bits if running >16M strategies.
     }

   inline string TimeISO(const datetime value)
     {
      return(TimeToString(value, TIME_DATE | TIME_SECONDS)); // Assumption: timezone = terminal server; adjust when localization needed.
     }
  }

#endif // TSB_UTIL_MQH
