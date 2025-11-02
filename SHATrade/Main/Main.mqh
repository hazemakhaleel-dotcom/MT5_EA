//+------------------------------------------------------------------+
//| Project: SHATrade Trading Strategy Builder                       |
//| File: Main.mqh                                                    |
//| Description: Aggregates trading block headers for Main.mq5.       |
//+------------------------------------------------------------------+
#ifndef MAIN_MQH
#define MAIN_MQH

#include "..\\Include\\TradingBlocks\\Kernel\\RuntimeKernel.mqh"
#include "..\\Include\\TradingBlocks\\Kernel\\Logger.mqh"
#include "..\\Include\\TradingBlocks\\Kernel\\Kernel.types.mqh"
#include "..\\Include\\TradingBlocks\\Kernel\\Kernel.inputs.mqh"
#include "..\\Include\\TradingBlocks\\Market Data & Platform\\MarketDataPlatform.mqh"
#include "..\\Include\\TradingBlocks\\Market Data & Platform\\Market.types.mqh"
#include "..\\Include\\TradingBlocks\\Market Data & Platform\\Market.inputs.mqh"
#include "..\\Include\\TradingBlocks\\Signals\\EntrySignals.mqh"
#include "..\\Include\\TradingBlocks\\Signals\\ExitSignals.mqh"
#include "..\\Include\\TradingBlocks\\Signals\\Signals.types.mqh"
#include "..\\Include\\TradingBlocks\\Signals\\Entry.inputs.mqh"
#include "..\\Include\\TradingBlocks\\Signals\\Exit.inputs.mqh"
#include "..\\Include\\TradingBlocks\\Risk\\RiskManagement.mqh"
#include "..\\Include\\TradingBlocks\\Risk\\Risk.types.mqh"
#include "..\\Include\\TradingBlocks\\Risk\\Risk.inputs.mqh"
#include "..\\Include\\TradingBlocks\\Portfolio\\Portfolio.mqh"
#include "..\\Include\\TradingBlocks\\Portfolio\\Portfolio.types.mqh"
#include "..\\Include\\TradingBlocks\\Portfolio\\Portfolio.inputs.mqh"
#include "..\\Include\\TradingBlocks\\Execution\\ExecutionOMS.mqh"
#include "..\\Include\\TradingBlocks\\Execution\\Execution.reconcile.mqh"
#include "..\\Include\\TradingBlocks\\Execution\\Execution.brackets.mqh"
#include "..\\Include\\TradingBlocks\\Execution\\Execution.retry.mqh"
#include "..\\Include\\TradingBlocks\\Execution\\Execution.types.mqh"
#include "..\\Include\\TradingBlocks\\Execution\\Execution.inputs.mqh"
#include "..\\Include\\TradingBlocks\\PositionManager\\PositionManager.mqh"
#include "..\\Include\\TradingBlocks\\PositionManager\\PM.ExitExecutor.mqh"
#include "..\\Include\\TradingBlocks\\PositionManager\\PM.TradeLifecycle.mqh"
#include "..\\Include\\TradingBlocks\\PositionManager\\PM.types.mqh"
#include "..\\Include\\TradingBlocks\\PositionManager\\PM.inputs.mqh"
#include "..\\Include\\TradingBlocks\\State\\StateManager.mqh"
#include "..\\Include\\TradingBlocks\\State\\State.types.mqh"
#include "..\\Include\\TradingBlocks\\State\\State.inputs.mqh"
#include "..\\Include\\TradingBlocks\\Adapter\\AdapterMQL5.mqh"
#include "..\\Include\\TradingBlocks\\Adapter\\Adapter.types.mqh"
#include "..\\Include\\TradingBlocks\\Shared\\TSB.ids.mqh"
#include "..\\Include\\TradingBlocks\\Shared\\TSB.math.mqh"
#include "..\\Include\\TradingBlocks\\Shared\\TSB.util.mqh"

#endif // MAIN_MQH
