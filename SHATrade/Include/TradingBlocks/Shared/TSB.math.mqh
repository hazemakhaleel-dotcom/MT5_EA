//+------------------------------------------------------------------+
//| TSB.math.mqh                                                  |
//| Placeholder for TSB.math.                                     |
//+------------------------------------------------------------------+
#ifndef TSB_MATH_MQH
#define TSB_MATH_MQH

// Implemented: basic helpers for rounding and unit conversion; expand as math library grows.
namespace TSB
  {
   inline double RoundToStep(const double value, const double step)
     {
      if(step<=0.0)  // TODO: guard with logging once Shared util logger exists.
         return(value);
      const double factor = MathRound(value/step); // TODO: consider banker rounding if exchange requires.
      return(factor*step);
     }

   inline double PointsToPrice(const double points, const double point, const bool add)
     {
      const double delta = points*point; // Assumption: caller passes normalized point size.
      return(add ? (point==0.0 ? delta : delta) : -delta); // TODO: simplify once step/point handling finalised.
     }

   inline double PriceToPoints(const double from, const double to, const double point)
     {
      if(point==0.0)  // TODO: consider raising error via RetInfo instead of silent zero.
         return(0.0);
      return((to-from)/point);
     }
  }

#endif // TSB_MATH_MQH
