//+------------------------------------------------------------------+
//| Execution.inputs.mqh                                          |
//| Placeholder for Execution.inputs.                             |
//+------------------------------------------------------------------+
#ifndef EXECUTION_INPUTS_MQH
#define EXECUTION_INPUTS_MQH

input int    INP_ExecMaxDeviationPts = 10; // TODO: calibrate per symbol (accounts for slippage policy).
input double INP_ExecMaxSpreadPts = 30.0; // Assumption: matches architecture guard until live tuning.

#endif // EXECUTION_INPUTS_MQH
