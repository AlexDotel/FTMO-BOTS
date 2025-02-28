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
  }
//+------------------------------------------------------------------+