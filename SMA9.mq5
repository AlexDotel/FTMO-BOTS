//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include <C:\Users\joalr\OneDrive\Documentos\Dotlib\Dotlib.mqh>
#include <Trade/Trade.mqh>

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+

input double lotaje = 0.1;
int cashRisk = 100;

input int smaPeriod = 9;

input int horaInicio = 0;
input int horaFinal  = 23;
input int minInicio  = 0;
input int minFinal   = 0;

//+------------------------------------------------------------------+
//| Variables                                                        |
//+------------------------------------------------------------------+

ENUM_MA_METHOD sma_type = MODE_SMA;
ENUM_TIMEFRAMES timeframe_sma = PERIOD_CURRENT;
int padding = 5;
int slDivider = 1;
double RRR = 1.5;

int smaHandle;
double sma[];

MqlRates velas[];

//+------------------------------------------------------------------+
//| Metodos de Serie                                                 |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit(void) {
   smaHandle = iMA(_Symbol, _Period, smaPeriod, 0, MODE_SMA, PRICE_CLOSE);
   if(smaHandle == INVALID_HANDLE ) return INIT_FAILED;
   ArraySetAsSeries(sma, true);
   ArraySetAsSeries(velas, true);

   return(INIT_SUCCEEDED);
}

void OnTick(void) {

   if(!EnHorario(horaInicio, horaFinal, minInicio, minFinal)) return;
   if(!IsNewCandle()) return;

   //Extraemos el bid y el ask
   double ask = getAsk();
   double bid = getBid();

   //Rellenamos los arrays
   CopyBuffer(smaHandle, 0, 0, 3, sma);
   CopyRates(_Symbol, _Period, 0, 3, velas);

   //Obtenemos los precios
   double prevPrice  = NormalizeDouble(velas[1].close, _Digits);
   double prevSMA    = NormalizeDouble(sma[1], _Digits);
   double prevLow    = NormalizeDouble(velas[1].low, _Digits);
   double prevHigh   = NormalizeDouble(velas[1].high, _Digits);
   double actualOpen = NormalizeDouble(velas[0].open, _Digits);

   //Comprobamos la distancia minima entre ordenes y apertura.
   if(actualOpen - prevLow < (padding * _Point) || prevHigh - actualOpen < (padding * _Point)) return;

   //Calculamos las distancias de SL y de TP.
   double slDistance = NormalizeDouble((prevHigh - prevLow) / slDivider, _Digits);
   double tpDistance = NormalizeDouble(slDistance * RRR, _Digits);

   //Calculamos los precios de SL y de TP PARA COMPRAS.
   double slPriceBuy = prevHigh - slDistance;
   double tpPriceBuy = prevHigh + tpDistance;

   //Calculamos los precios de SL y de TP PARA VENTAS.
   double slPriceSell = prevLow + slDistance;
   double tpPriceSell = prevLow - tpDistance;

   //Calculamos el lotaje automaticamente
   double mlotaje = CalcularLotajeCash(cashRisk, slDistance);

   
   //Verificamos ordenes abiertas para cerrarlas si se da la condicion contraria.
   if(!FlatMarket()) {
   
      DotTrailingStopMA(prevSMA, cashRisk);
      ////Si se da el cruce hacia arriba cerramos la venta
      //if(isSellOpen() && condCompra(prevPrice, prevSMA)) {
      //   Print("=== VENTA ABIERTA === ");
      //   CloseAllPositions();
      //}
      ////Si se da el cruce hacia abajo cerramos la compra
      //if(isBuyOpen() && condVenta(prevPrice, prevSMA)) {
      //   Print("=== COMPRA ABIERTA === ");
      //   CloseAllPositions();
      //   //SOLUCIONAR ERROR DE QUE NO SE PUDO CERRAR LA ORDEN
      //}
   }

   //Compramos
   if(FlatMarket() && condCompra(prevPrice, prevSMA))  trade.Buy(mlotaje, _Symbol, ask, slPriceBuy, 0, "Compra");

   //Vendemos
   if(FlatMarket() && condVenta(prevPrice, prevSMA))   trade.Sell(mlotaje, _Symbol, bid, slPriceSell, 0, "Venta");

}

//+------------------------------------------------------------------+
//| Funciones                                                        |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool condCompra (double _price, double _sma) {
   if(_price > _sma) {
      return true;
   } else {
      return false;
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool condVenta  (double _price, double _sma) {
   if(_price < _sma) {
      return true;
   } else {
      return false;
   }
}

//+------------------------------------------------------------------+
