//+------------------------------------------------------------------+
//| Kernel.inputs.mqh                                             |
//| Placeholder for Kernel.inputs.                                |
//+------------------------------------------------------------------+
#ifndef KERNEL_INPUTS_MQH
#define KERNEL_INPUTS_MQH

// TODO: revisit defaults after load testing the real orchestrator pacing.
input bool INP_KernelUseTimer = true;   // Assumption: timer provides steadier cadence than tick-only loop.
input int  INP_KernelLoopSleepMs = 100; // Assumption: 100ms sleep balances CPU usage during scaffold.

#endif // KERNEL_INPUTS_MQH
