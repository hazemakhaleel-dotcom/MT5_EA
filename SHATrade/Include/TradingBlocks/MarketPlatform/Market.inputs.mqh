//+------------------------------------------------------------------+
//| Market.inputs.mqh                                             |
//| Placeholder for Market.inputs.                                |
//+------------------------------------------------------------------+
#ifndef MARKET_INPUTS_MQH
#define MARKET_INPUTS_MQH

input int INP_MarketDefaultBars = 500; // TODO: align with signal lookback requirements.
input ENUM_TIMEFRAMES INP_MarketDefaultTF = PERIOD_CURRENT; // Assumption: strategy will override via presets if needed.

#endif // MARKET_INPUTS_MQH
