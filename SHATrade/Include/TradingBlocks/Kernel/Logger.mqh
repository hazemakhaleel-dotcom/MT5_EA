//+------------------------------------------------------------------+
//| Logger.mqh                                                    |
//| Placeholder for Logger.                                       |
//+------------------------------------------------------------------+
#ifndef LOGGER_MQH
#define LOGGER_MQH

// Implemented: minimal Print-based logger; TODO: replace with structured sink once defined.
inline void Kernel_Log(const string event, const string details="")
  {
   PrintFormat("[SHATrade] %s %s", event, details);
  }

#endif // LOGGER_MQH
