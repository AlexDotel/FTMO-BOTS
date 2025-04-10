//+------------------------------------------------------------------+
//|                                              Nearest50Level.mq5 |
//|                                  Copyright 2023, Your Name       |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Your Name"
#property link      ""
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   //---
   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   //---
   ObjectsDeleteAll(0, "Nearest50Level");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   //---
   double currentPrice = SymbolInfoDouble(Symbol(), SYMBOL_ASK); // Usar SYMBOL_BID para el precio de compra

   // Calcular el múltiplo de 50 más cercano
   int nearest50 = (int)(currentPrice / 50.0 + 0.5) * 50;

   // Eliminar la línea anterior (si existe)
   ObjectDelete(0, "Nearest50Level");

   // Crear la línea horizontal
   ObjectCreate(0, "Nearest50Level", OBJ_HLINE, 0, 0, nearest50);
   ObjectSetInteger(0, "Nearest50Level", OBJPROP_COLOR, clrRed); // Cambiar el color si es necesario
   ObjectSetInteger(0, "Nearest50Level", OBJPROP_WIDTH, 2); // Cambiar el ancho si es necesario
   ObjectSetInteger(0, "Nearest50Level", OBJPROP_STYLE, STYLE_SOLID); // Cambiar el estilo si es necesario

   // Verificar rebote en la vela anterior
   int reboundDirection = CheckRebound(nearest50);
   if(reboundDirection != 0)
     {
      Print("¡Rebote detectado en Nearest50Level! Dirección: ", reboundDirection);
      // Ejecutar operación de compra o venta
      ExecuteTrade(reboundDirection);
     }
  }
//+------------------------------------------------------------------+
//| Function to check for rebound on Nearest50Level                 |
//+------------------------------------------------------------------+
int CheckRebound(double level)
  {
   double high1 = iHigh(Symbol(), PERIOD_CURRENT, 1);
   double low1 = iLow(Symbol(), PERIOD_CURRENT, 1);
   double open1 = iOpen(Symbol(), PERIOD_CURRENT, 1);
   double close1 = iClose(Symbol(), PERIOD_CURRENT, 1);

   double high2 = iHigh(Symbol(), PERIOD_CURRENT, 2);
   double low2 = iLow(Symbol(), PERIOD_CURRENT, 2);
   double open2 = iOpen(Symbol(), PERIOD_CURRENT, 2);
   double close2 = iClose(Symbol(), PERIOD_CURRENT, 2);

   // Verificar Pin Bar
   int pinBarDirection = IsPinBar(high1, low1, open1, close1, level);
   if(pinBarDirection != 0)
     {
      return(pinBarDirection);
     }

   // Verificar Envolvente
   int engulfingDirection = IsEngulfing(open1, close1, open2, close2, level);
   if(engulfingDirection != 0)
     {
      return(engulfingDirection);
     }

   return(0); // No hay rebote
  }
//+------------------------------------------------------------------+
//| Function to check for Pin Bar pattern                            |
//+------------------------------------------------------------------+
int IsPinBar(double high, double low, double open, double close, double level)
  {
   double body = MathAbs(open - close);
   double wickUp = high - MathMax(open, close);
   double wickDown = MathMin(open, close) - low;

   if(wickUp > 2 * body && high >= level) // Pin Bar bajista
     {
      return(-1); // Rebote bajista
     }

   if(wickDown > 2 * body && low <= level) // Pin Bar alcista
     {
      return(1); // Rebote alcista
     }

   return(0); // No es Pin Bar
  }
//+------------------------------------------------------------------+
//| Function to check for Engulfing pattern                          |
//+------------------------------------------------------------------+
int IsEngulfing(double open1, double close1, double open2, double close2, double level)
  {
   if(close1 > open1 && close2 < open2 && close1 > open2 && open1 < close2 && (close1 >= level || open1 <= level)) // Envolvente alcista
     {
      return(1); // Rebote alcista
     }

   if(close1 < open1 && close2 > open2 && close1 < open2 && open1 > close2 && (close1 <= level || open1 >= level)) // Envolvente bajista
     {
      return(-1); // Rebote bajista
     }

   return(0); // No es Envolvente
  }
//+------------------------------------------------------------------+
//| Function to execute trade                                        |
//+------------------------------------------------------------------+
void ExecuteTrade(int direction)
  {
   MqlTradeRequest request;
   MqlTradeResult result;

   ZeroMemory(request);
   ZeroMemory(result);

   request.action = TRADE_ACTION_DEAL;
   request.symbol = Symbol();
   request.volume = 0.1; // Ajusta el volumen según tus necesidades
   request.type_filling = ORDER_FILLING_FOK;

   if(direction == 1) // Rebote alcista
     {
      request.type = ORDER_TYPE_BUY;
      request.price = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
     }
   else if(direction == -1) // Rebote bajista
     {
      request.type = ORDER_TYPE_SELL;
      request.price = SymbolInfoDouble(Symbol(), SYMBOL_BID);
     }

   OrderSend(request, result);

   if(result.retcode != TRADE_RETCODE_DONE)
     {
      Print("Error al ejecutar la operación: ", GetLastError());
     }
  }
//+------------------------------------------------------------------+