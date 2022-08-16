#include <Trade\Trade.mqh>
#include <Trade\OrderInfo.mqh>
#include <Trade\PositionInfo.mqh>

input int MagicNumber=10001;
input double Lots =0.1;
input double StopLoss=50;
input double TakeProfit=0;
input int TrailingStop=20;
input double Distance=5;
input int HistoryBar = 15;
input int ClosePending_Sec = 1800;
//double Ask,Bid;
//+------------------------------------------------------------------+
//    expert start function
//+------------------------------------------------------------------+

 ENUM_MA_METHOD MethodMigrate(int method)
  {
   switch(method)
     {
      case 0: return(MODE_SMA);
      case 1: return(MODE_EMA);
      case 2: return(MODE_SMMA);
      case 3: return(MODE_LWMA);
      default: return(MODE_SMA);
     }
  }
  
ENUM_STO_PRICE StoFieldMigrate(int field)
  {
   switch(field)
     {
      case 0: return(STO_LOWHIGH);
      case 1: return(STO_CLOSECLOSE);
      default: return(STO_LOWHIGH);
     }
  }
ENUM_APPLIED_PRICE PriceMigrate(int price)
  {
   switch(price)
     {
      case 1: return(PRICE_CLOSE);
      case 2: return(PRICE_OPEN);
      case 3: return(PRICE_HIGH);
      case 4: return(PRICE_LOW);
      case 5: return(PRICE_MEDIAN);
      case 6: return(PRICE_TYPICAL);
      case 7: return(PRICE_WEIGHTED);
      default: return(PRICE_CLOSE);
     }
  }

ENUM_TIMEFRAMES TFMigrate(int tf)
  {
   switch(tf)
     {
      case 0: return(PERIOD_CURRENT);
      case 1: return(PERIOD_M1);
      case 5: return(PERIOD_M5);
      case 15: return(PERIOD_M15);
      case 30: return(PERIOD_M30);
      case 60: return(PERIOD_H1);
      case 240: return(PERIOD_H4);
      case 1440: return(PERIOD_D1);
      case 10080: return(PERIOD_W1);
      case 43200: return(PERIOD_MN1);
      
      case 2: return(PERIOD_M2);
      case 3: return(PERIOD_M3);
      case 4: return(PERIOD_M4);      
      case 6: return(PERIOD_M6);
      case 10: return(PERIOD_M10);
      case 12: return(PERIOD_M12);
      case 16385: return(PERIOD_H1);
      case 16386: return(PERIOD_H2);
      case 16387: return(PERIOD_H3);
      case 16388: return(PERIOD_H4);
      case 16390: return(PERIOD_H6);
      case 16392: return(PERIOD_H8);
      case 16396: return(PERIOD_H12);
      case 16408: return(PERIOD_D1);
      case 32769: return(PERIOD_W1);
      case 49153: return(PERIOD_MN1);      
      default: return(PERIOD_CURRENT);
     }
  }
  
#define MODE_MAIN 0  
#define MODE_SIGNAL 1
#define MODE_PLUSDI 1
#define MODE_MINUSDI 2
#define MODE_OPEN 0
#define MODE_LOW 1
#define MODE_HIGH 2
#define MODE_CLOSE 3
#define MODE_VOLUME 4 
#define MODE_REAL_VOLUME 5


#define OP_BUY 0           //Buy 
#define OP_SELL 1          //Sell 
#define OP_BUYLIMIT 2      //Pending order of BUY LIMIT type 
#define OP_SELLLIMIT 3     //Pending order of SELL LIMIT type 
#define OP_BUYSTOP 4       //Pending order of BUY STOP type 
#define OP_SELLSTOP 5      //Pending order of SELL STOP type 
//---
#define MODE_TRADES 0
#define MODE_HISTORY 1
#define SELECT_BY_POS 0
#define SELECT_BY_TICKET 1
//---
#define DOUBLE_VALUE 0
#define FLOAT_VALUE 1
#define LONG_VALUE INT_VALUE
//---
#define CHART_BAR 0
#define CHART_CANDLE 1
//---
#define MODE_ASCEND 0
#define MODE_DESCEND 1
//---

#define MODE_TIME 5
#define MODE_BID 9
#define MODE_ASK 10
#define MODE_POINT 11
#define MODE_DIGITS 12
#define MODE_SPREAD 13
#define MODE_STOPLEVEL 14
#define MODE_LOTSIZE 15
#define MODE_TICKVALUE 16
#define MODE_TICKSIZE 17
#define MODE_SWAPLONG 18
#define MODE_SWAPSHORT 19
#define MODE_STARTING 20
#define MODE_EXPIRATION 21
#define MODE_TRADEALLOWED 22
#define MODE_MINLOT 23
#define MODE_LOTSTEP 24
#define MODE_MAXLOT 25
#define MODE_SWAPTYPE 26
#define MODE_PROFITCALCMODE 27
#define MODE_MARGINCALCMODE 28
#define MODE_MARGININIT 29
#define MODE_MARGINMAINTENANCE 30
#define MODE_MARGINHEDGED 31
#define MODE_MARGINREQUIRED 32
#define MODE_FREEZELEVEL 33
//---
#define EMPTY -1

CTrade trade;
COrderInfo m_order;
CPositionInfo  m_position;

double Ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
double Bid=SymbolInfoDouble(_Symbol,SYMBOL_BID);

void CreateButtonBuyStop(){
   ObjectCreate(0,"BuyStop",OBJ_BUTTON,0,0,0);
   ObjectSetInteger(0,"BuyStop",OBJPROP_XDISTANCE,10);
   ObjectSetInteger(0,"BuyStop",OBJPROP_YDISTANCE,40);
   ObjectSetInteger(0,"BuyStop",OBJPROP_XSIZE,90);
   ObjectSetInteger(0,"BuyStop",OBJPROP_YSIZE,20);
   
   ObjectSetInteger(0,"BuyStop",OBJPROP_FONTSIZE,7);
   ObjectSetInteger(0,"BuyStop",OBJPROP_BGCOLOR,clrLime);
   ObjectSetInteger(0,"BuyStop",OBJPROP_COLOR,clrWhite);
}

void CreateButtonSellStop(){
   ObjectCreate(0,"SellStop",OBJ_BUTTON,0,0,0);
   ObjectSetInteger(0,"SellStop",OBJPROP_XDISTANCE,10);
   ObjectSetInteger(0,"SellStop",OBJPROP_YDISTANCE,60);
   ObjectSetInteger(0,"SellStop",OBJPROP_XSIZE,90);
   ObjectSetInteger(0,"SellStop",OBJPROP_YSIZE,20);
   
   ObjectSetInteger(0,"SellStop",OBJPROP_FONTSIZE,7);
   ObjectSetInteger(0,"SellStop",OBJPROP_BGCOLOR,clrRed);
   ObjectSetInteger(0,"SellStop",OBJPROP_COLOR,clrWhite);
}

void CreateButtonBuyLimit(){
   ObjectCreate(0,"BuyLimit",OBJ_BUTTON,0,0,0);
   ObjectSetInteger(0,"BuyLimit",OBJPROP_XDISTANCE,10);
   ObjectSetInteger(0,"BuyLimit",OBJPROP_YDISTANCE,80);
   ObjectSetInteger(0,"BuyLimit",OBJPROP_XSIZE,90);
   ObjectSetInteger(0,"BuyLimit",OBJPROP_YSIZE,20);
   
   ObjectSetInteger(0,"BuyLimit",OBJPROP_FONTSIZE,7);
   ObjectSetInteger(0,"BuyLimit",OBJPROP_BGCOLOR,clrLime);
   ObjectSetInteger(0,"BuyLimit",OBJPROP_COLOR,clrWhite);
}

void CreateButtonSellLimit(){
   ObjectCreate(0,"SellLimit",OBJ_BUTTON,0,0,0);
   ObjectSetInteger(0,"SellLimit",OBJPROP_XDISTANCE,10);
   ObjectSetInteger(0,"SellLimit",OBJPROP_YDISTANCE,100);
   ObjectSetInteger(0,"SellLimit",OBJPROP_XSIZE,90);
   ObjectSetInteger(0,"SellLimit",OBJPROP_YSIZE,20);
   
   ObjectSetInteger(0,"SellLimit",OBJPROP_FONTSIZE,7);
   ObjectSetInteger(0,"SellLimit",OBJPROP_BGCOLOR,clrRed);
   ObjectSetInteger(0,"SellLimit",OBJPROP_COLOR,clrWhite);
}

void CreateButtonCloseAll(){
   ObjectCreate(0,"CloseAll",OBJ_BUTTON,0,0,0);
   ObjectSetInteger(0,"CloseAll",OBJPROP_XDISTANCE,10);
   ObjectSetInteger(0,"CloseAll",OBJPROP_YDISTANCE,120);
   ObjectSetInteger(0,"CloseAll",OBJPROP_XSIZE,90);
   ObjectSetInteger(0,"CloseAll",OBJPROP_YSIZE,20);
   
   ObjectSetInteger(0,"CloseAll",OBJPROP_FONTSIZE,7);
   ObjectSetInteger(0,"CloseAll",OBJPROP_BGCOLOR,clrGray);
   ObjectSetInteger(0,"CloseAll",OBJPROP_COLOR,clrWhite);
}
void ChackAuto(){
   if(AccountInfoInteger(ACCOUNT_TRADE_EXPERT))
     {
      ObjectSetString(0,"BuyStop",OBJPROP_TEXT,"Open Order BuyStop");
      ObjectSetString(0,"SellStop",OBJPROP_TEXT,"Open Order SellStop");
      ObjectSetString(0,"BuyLimit",OBJPROP_TEXT,"Open Order BuyLimit");
      ObjectSetString(0,"SellLimit",OBJPROP_TEXT,"Open Order SellLimit");
      ObjectSetString(0,"CloseAll",OBJPROP_TEXT,"Close All");
     }
     else{
      ObjectSetString(0,"BuyStop",OBJPROP_TEXT,"Please Enable Auto Trading!");
      ObjectSetString(0,"SellStop",OBJPROP_TEXT,"Please Enable Auto Trading!");
      ObjectSetString(0,"CloseAll",OBJPROP_TEXT,"Please Enable Auto Trading!");      
     }

}
double higher()
{  
   double h=iHigh(_Symbol,PERIOD_CURRENT,0);
   for(int i=0;i<HistoryBar;i++)
     {
      if(h<=iHigh(_Symbol,PERIOD_CURRENT,i))
        {
         h = iHigh(_Symbol,PERIOD_CURRENT,i);
        }
     }
   return h;
}
double lower()
{
   double l=iLow(_Symbol,PERIOD_CURRENT,0);
   for(int i=0;i<HistoryBar;i++)
     {
      if(l>=iLow(_Symbol,PERIOD_CURRENT,i))
        {
         l = iLow(_Symbol,PERIOD_CURRENT,i);
        }
     }
   return l;
}

int OnInit()
  {
   
   return(INIT_SUCCEEDED);
  }
  
void OnTick()
{
CreateButtonBuyStop();
CreateButtonSellStop();
CreateButtonBuyLimit();
CreateButtonSellLimit();

CreateButtonCloseAll();
ChackAuto();

bool chkTrailingStop;
MqlDateTime dt_sturuct;
TimeCurrent(dt_sturuct);
Comment("PositionsTotal : "+PositionsTotal()+" StopOrder : "+OrdersTotal()+" High : "+higher()+" Low : "+lower()+" Min : "+dt_sturuct.min+" Sec : "+dt_sturuct.sec+" OrderClosdAt : "+TimeToString(OrderGetInteger(ORDER_TIME_SETUP)+ClosePending_Sec));
//CTrade trade;
trade.SetExpertMagicNumber(MagicNumber);
//double Ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
//double Bid=SymbolInfoDouble(_Symbol,SYMBOL_BID);

  double MyPoint=_Point;
  if(_Digits==3 || _Digits==5) MyPoint=_Point*10;
  //if(_Symbol=="XAUUSDm") MyPoint = _Point*100;
  double TheStopLoss=0;
  double TheTakeProfit=0;
  //if( TotalOrdersCount()==0 ) 
  //{
     
     /*if(Ask==Ask) // Here is your open buy rule
     {
     
        if(StopLoss>0) TheStopLoss=SymbolInfoDouble(_Symbol,SYMBOL_ASK)-StopLoss*MyPoint;
        if(TakeProfit>0) TheTakeProfit=SymbolInfoDouble(_Symbol,SYMBOL_ASK)+TakeProfit*MyPoint;
        trade.PositionOpen(_Symbol,ORDER_TYPE_BUY,Lots,SymbolInfoDouble(_Symbol,SYMBOL_ASK),TheStopLoss,0);
        return;
     }*/
     if(OrdersTotal()>0)
       {
         int orderTotal = OrdersTotal();
         for(int orderIndex=orderTotal-1;orderIndex>=0;orderIndex--)
           {
           ulong m_ticket=OrderGetTicket(orderIndex);
           if(OrderSelect(m_ticket) && OrderGetInteger(ORDER_MAGIC)==MagicNumber)
             {
              if(OrderGetInteger(ORDER_TYPE)==ORDER_TYPE_BUY_STOP)
                {
                   if(dt_sturuct.sec>=58)
                    {
                    if(_Symbol=="XAUUSDm"){
                       trade.OrderModify(m_ticket,SymbolInfoDouble(_Symbol,SYMBOL_BID)+(0.1*Distance),lower(),0,ORDER_TIME_GTC,NULL,0);
                       //Sleep(20);
                       return;
                    }else{
                       trade.OrderModify(m_ticket,SymbolInfoDouble(_Symbol,SYMBOL_BID)+MyPoint*Distance,lower(),0,ORDER_TIME_GTC,NULL,0);
                       //Sleep(20);
                       return;
                      }
                    }
                }
              if(OrderGetInteger(ORDER_TYPE)==ORDER_TYPE_BUY_LIMIT)
                {
                  if(dt_sturuct.sec>=58)
                  //if(SymbolInfoDouble(_Symbol,SYMBOL_BID)<SymbolInfoDouble(_Symbol,SYMBOL_ASK))  
                    {
                    if(_Symbol=="XAUUSDm"){
                       trade.OrderModify(m_ticket,SymbolInfoDouble(_Symbol,SYMBOL_BID)-(0.1*(Distance*2)),lower(),0,ORDER_TIME_GTC,NULL,0);
                       return;
                    }else{
                       trade.OrderModify(m_ticket,SymbolInfoDouble(_Symbol,SYMBOL_BID)-(Distance*2)*MyPoint,lower(),0,ORDER_TIME_GTC,NULL,0);
                       return;
                      }
                    }
                }
             }
            if(OrderSelect(m_ticket) && OrderGetInteger(ORDER_MAGIC)==MagicNumber)
              {
               if(OrderGetInteger(ORDER_TYPE)==ORDER_TYPE_SELL_STOP)
                {
                   if(dt_sturuct.sec<=2)
                    {
                    if(_Symbol=="XAUUSDm"){
                       //Sleep(9);
                       trade.OrderModify(m_ticket,SymbolInfoDouble(_Symbol,SYMBOL_ASK)-(0.1*Distance),higher(),0,ORDER_TIME_GTC,NULL,0);
                       return;
                    }else{
                       //Sleep(9);
                       trade.OrderModify(m_ticket,SymbolInfoDouble(_Symbol,SYMBOL_ASK)-MyPoint*Distance,higher(),0,ORDER_TIME_GTC,NULL,0);
                       return;
                    }
               
                    }
                }
               if(OrderGetInteger(ORDER_TYPE)==ORDER_TYPE_SELL_LIMIT)
                {
                  if(dt_sturuct.sec<=2)
                  //if(SymbolInfoDouble(_Symbol,SYMBOL_BID)<SymbolInfoDouble(_Symbol,SYMBOL_ASK))    
                    {
                    if(_Symbol=="XAUUSDm"){
                       trade.OrderModify(m_ticket,SymbolInfoDouble(_Symbol,SYMBOL_ASK)+(0.1*(Distance*2)),higher(),0,ORDER_TIME_GTC,NULL,0);
                       return;
                    }else{
                       trade.OrderModify(m_ticket,SymbolInfoDouble(_Symbol,SYMBOL_ASK)+(Distance*2)*MyPoint,higher(),0,ORDER_TIME_GTC,NULL,0);
                       return;
                    }
               
                    }
                }
              }
           //Sleep(15);
           }
                    
       }
      if(PositionsTotal()>0 && TimeCurrent(dt_sturuct)>=TimeToString(OrderGetInteger(ORDER_TIME_SETUP)+ClosePending_Sec))
       {
         for(int i = OrdersTotal() - 1; i >= 0; i--) // loop all orders available
         if(m_order.SelectByIndex(i))  // select an order
           {
            trade.OrderDelete(m_order.Ticket()); // delete it --Period
            Sleep(50); // Relax for 100 ms
           }
       }
     
     
  //}
  
   int posTotal=PositionsTotal();
   for(int posIndex=posTotal-1;posIndex>=0;posIndex--)
     {
      ulong ticket=PositionGetTicket(posIndex);
      if(PositionSelectByTicket(ticket) && PositionGetInteger(POSITION_MAGIC)==MagicNumber) 
      {
     if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
        {
         if(TrailingStop>0)  
              {                 
               if(SymbolInfoDouble(_Symbol,SYMBOL_BID)-PositionGetDouble(POSITION_PRICE_OPEN)>MyPoint*TrailingStop)
                 {
                  if(PositionGetDouble(POSITION_SL)<SymbolInfoDouble(_Symbol,SYMBOL_BID)-MyPoint*TrailingStop)
                    {
                    trade.PositionModify(ticket,SymbolInfoDouble(_Symbol,SYMBOL_BID)-MyPoint*TrailingStop,PositionGetDouble(POSITION_TP));
                     return;
                    }
                 }
              }
        }
      
       if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
        {
          if(TrailingStop>0)  
              {                 
               if(PositionGetDouble(POSITION_PRICE_OPEN)-SymbolInfoDouble(_Symbol,SYMBOL_ASK)>MyPoint*TrailingStop)
                 {
                  if(PositionGetDouble(POSITION_SL)>SymbolInfoDouble(_Symbol,SYMBOL_ASK)+MyPoint*TrailingStop)
                    {
                    trade.PositionModify(ticket,SymbolInfoDouble(_Symbol,SYMBOL_ASK)+MyPoint*TrailingStop,PositionGetDouble(POSITION_TP));
                     return;
                    }
                 }
              }
        }
      }
     }
    
    return;
    
}

//------------------------------------------------
void OnChartEvent(const int id,const long& lparam,const double& dparam,const string& sparam)
  {
  double MyPoint=_Point;
  if(_Digits==3 || _Digits==5) MyPoint=_Point*10;
  if(_Symbol=="XAUUSDm") MyPoint = _Point*100;
    if(id==CHARTEVENT_OBJECT_CLICK)
      {
       if(sparam=="BuyStop")
         {
          Comment(sparam+" was pressed OrderTotal : "+PositionsTotal());
          trade.BuyStop(Lots,higher(),_Symbol,0,0,ORDER_TIME_GTC,0,NULL);
         }
       if(sparam=="SellStop")
         {
          Comment(sparam+" was pressedOrderTotal : "+PositionsTotal());
          trade.SellStop(Lots,lower(),_Symbol,0,0,ORDER_TIME_GTC,0,NULL);
         }
        if(sparam=="BuyLimit")
         {
          Comment(sparam+" was pressed OrderTotal : "+PositionsTotal());
          trade.BuyLimit(Lots,lower(),_Symbol,0,0,ORDER_TIME_GTC,0,NULL);
         }
       if(sparam=="SellLimit")
         {
          Comment(sparam+" was pressedOrderTotal : "+PositionsTotal());
          trade.SellLimit(Lots,higher(),_Symbol,0,0,ORDER_TIME_GTC,0,NULL);
         }
       if(sparam=="CloseAll")
         {
         Comment(sparam+" was pressed");
         for(int i = OrdersTotal() - 1; i >= 0; i--) // loop all orders available
         if(m_order.SelectByIndex(i))  // select an order
           {
            trade.OrderDelete(m_order.Ticket()); // delete it --Period
            Sleep(50); // Relax for 100 ms
           }
         }
      }
  }
//------------------------------------------------

//------------------------------------------------
int TotalOrdersCount()
{
  int result=0;
  int posTotal=PositionsTotal();
   for(int posIndex=posTotal-1;posIndex>=0;posIndex--)
     {
      ulong ticket=PositionGetTicket(posIndex);
      if(PositionSelectByTicket(ticket) && PositionGetInteger(POSITION_MAGIC)==MagicNumber) result++;
     }  
  return (result);
}


int Hour()
{
   MqlDateTime tm;
   TimeCurrent(tm);
   return(tm.hour);
}
int Minute()
{
   MqlDateTime tm;
   TimeCurrent(tm);
   return(tm.min);
}

double CopyBufferMQL4(int handle,int index,int shift)
  {
   double buf[];
   switch(index)
     {
      case 0: if(CopyBuffer(handle,0,shift,1,buf)>0)
         return(buf[0]); break;
      case 1: if(CopyBuffer(handle,1,shift,1,buf)>0)
         return(buf[0]); break;
      case 2: if(CopyBuffer(handle,2,shift,1,buf)>0)
         return(buf[0]); break;
      case 3: if(CopyBuffer(handle,3,shift,1,buf)>0)
         return(buf[0]); break;
      case 4: if(CopyBuffer(handle,4,shift,1,buf)>0)
         return(buf[0]); break;
      default: break;
     }
   return(EMPTY_VALUE);
  }
  
  
double iACMQL4(string symbol,
               int tf,
               int shift)
  {
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   int handle=iAC(symbol,timeframe);
   if(handle<0)
     {
      return(-1);
     }
   else
      return(CopyBufferMQL4(handle,0,shift));
  }
  
  
  double iADMQL4(string symbol,
               int tf,
               int shift)
  {
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   int handle=(int)iAD(symbol,timeframe,VOLUME_TICK);
   if(handle<0)
     {
      return(-1);
     }
   else
      return(CopyBufferMQL4(handle,0,shift));
  }  
  
  double iAlligatorMQL4(string symbol,
                      int tf,
                      int jaw_period,
                      int jaw_shift,
                      int teeth_period,
                      int teeth_shift,
                      int lips_period,
                      int lips_shift,
                      int method,
                      int price,
                      int mode,
                      int shift)
  {
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   ENUM_MA_METHOD ma_method=MethodMigrate(method);
   ENUM_APPLIED_PRICE applied_price=PriceMigrate(price);
   int handle=iAlligator(symbol,timeframe,jaw_period,jaw_shift,
                         teeth_period,teeth_shift,
                         lips_period,lips_shift,
                         ma_method,applied_price);
   if(handle<0)
     {
      return(-1);
     }
   else
      return(CopyBufferMQL4(handle,mode-1,shift));
  }
  
double iADXMQL4(string symbol,
                int tf,
                int period,
                int price,
                int mode,
                int shift)
  {
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   ENUM_APPLIED_PRICE applied_price=PriceMigrate(price);
   int handle=iADX(symbol,timeframe,period);
   if(handle<0)
     {
      return(-1);
     }
   else
      return(CopyBufferMQL4(handle,mode,shift));
  }

double iAOMQL4(string symbol,
               int tf,
               int shift)
  {
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   int handle=iAO(symbol,timeframe);
   if(handle<0)
     {
      return(-1);
     }
   else
      return(CopyBufferMQL4(handle,0,shift));
  }
  double iATRMQL4(string symbol,
                int tf,
                int period,
                int shift)
  {
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   int handle=iATR(symbol,timeframe,period);
   if(handle<0)
     {
      return(-1);
     }
   else
      return(CopyBufferMQL4(handle,0,shift));
  }
  
 double iBearsPowerMQL4(string symbol,
                       int tf,
                       int period,
                       int price,
                       int shift)
  {
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   int handle=iBearsPower(symbol,timeframe,period);
   if(handle<0)
     {
      return(-1);
     }
   else
      return(CopyBufferMQL4(handle,0,shift));
  }
  
 double iBullsPowerMQL4(string symbol,
                       int tf,
                       int period,
                       int price,
                       int shift)
  {
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   int handle=iBullsPower(symbol,timeframe,period);
   if(handle<0)
     {
      return(-1);
     }
   else
      return(CopyBufferMQL4(handle,0,shift));
  }
  
  double iBandsMQL4(string symbol,
                  int tf,
                  int period,
                  double deviation,
                  int bands_shift,
                  int method,
                  int mode,
                  int shift)
  {
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   ENUM_MA_METHOD ma_method=MethodMigrate(method);
   int handle=iBands(symbol,timeframe,period,
                     bands_shift,deviation,ma_method);
   if(handle<0)
     {
      return(-1);
     }
   else
      return(CopyBufferMQL4(handle,mode,shift));
  }
  double iCCIMQL4(string symbol,
                int tf,
                int period,
                int price,
                int shift)
  {
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   ENUM_APPLIED_PRICE applied_price=PriceMigrate(price);
   int handle=iCCI(symbol,timeframe,period,price);
   if(handle<0)
     {
      return(-1);
     }
   else
      return(CopyBufferMQL4(handle,0,shift));
  }
  

double iDeMarkerMQL4(string symbol,
                     int tf,
                     int period,
                     int shift)
  {
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   int handle=iDeMarker(symbol,timeframe,period);
   if(handle<0)
     {
      return(-1);
     }
   else
      return(CopyBufferMQL4(handle,0,shift));
  }
  double EnvelopesMQL4(string symbol,
                     int tf,
                     int ma_period,
                     int method,
                     int ma_shift,
                     int price,
                     double deviation,
                     int mode,
                     int shift)
  {
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   ENUM_MA_METHOD ma_method=MethodMigrate(method);
   ENUM_APPLIED_PRICE applied_price=PriceMigrate(price);
   int handle=iEnvelopes(symbol,timeframe,
                         ma_period,ma_shift,ma_method,
                         applied_price,deviation);
   if(handle<0)
     {
      return(-1);
     }
   else
      return(CopyBufferMQL4(handle,mode-1,shift));
  }
  
  double iForceMQL4(string symbol,
                  int tf,
                  int period,
                  int method,
                  int price,
                  int shift)
  {
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   ENUM_MA_METHOD ma_method=MethodMigrate(method);
   int handle=iForce(symbol,timeframe,period,ma_method,VOLUME_TICK);
   if(handle<0)
     {
      return(-1);
     }
   else
      return(CopyBufferMQL4(handle,0,shift));
  }
  
  double iFractalsMQL4(string symbol,
                     int tf,
                     int mode,
                     int shift)
  {
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   int handle=iFractals(symbol,timeframe);
   if(handle<0)
     {
      return(-1);
     }
   else
      return(CopyBufferMQL4(handle,mode-1,shift));
  }


double iBWMFIMQL4(string symbol,
                  int tf,
                  int shift)
  {
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   int handle=(int)iBWMFI(symbol,timeframe,VOLUME_TICK);
   if(handle<0)
     {
      return(-1);
     }
   else
      return(CopyBufferMQL4(handle,0,shift));
  }


double iMomentumMQL4(string symbol,
                     int tf,
                     int period,
                     int price,
                     int shift)
  {
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   ENUM_APPLIED_PRICE applied_price=PriceMigrate(price);
   int handle=iMomentum(symbol,timeframe,period,applied_price);
   if(handle<0)
     {
      return(-1);
     }
   else
      return(CopyBufferMQL4(handle,0,shift));
  }
  double iMFIMQL4(string symbol,
                int tf,
                int period,
                int shift)
  {
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   int handle=(int)iMFI(symbol,timeframe,period,VOLUME_TICK);
   if(handle<0)
     {
      return(-1);
     }
   else
      return(CopyBufferMQL4(handle,0,shift));
  }
  double iMAMQL4(string symbol,
               int tf,
               int period,
               int ma_shift,
               int method,
               int price,
               int shift)
  {
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   ENUM_MA_METHOD ma_method=MethodMigrate(method);
   ENUM_APPLIED_PRICE applied_price=PriceMigrate(price);
   int handle=iMA(symbol,timeframe,period,ma_shift,
                  ma_method,applied_price);
   if(handle<0)
     {
      return(-1);
     }
   else
      return(CopyBufferMQL4(handle,0,shift));
  }
  double iMACDMQL4(string symbol,
                 int tf,
                 int fast_ema_period,
                 int slow_ema_period,
                 int signal_period,
                 int price,
                 int mode,
                 int shift)
  {
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   ENUM_APPLIED_PRICE applied_price=PriceMigrate(price);
   int handle=iMACD(symbol,timeframe,
                    fast_ema_period,slow_ema_period,
                    signal_period,applied_price);
   if(handle<0)
     {
      return(-1);
     }
   else
      return(CopyBufferMQL4(handle,mode,shift));
  }
  
  double iOBVMQL4(string symbol,
                int tf,
                int price,
                int shift)
  {
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   int handle=iOBV(symbol,timeframe,VOLUME_TICK);
   if(handle<0)
     {
      return(-1);
     }
   else
      return(CopyBufferMQL4(handle,0,shift));
  }
  double iSARMQL4(string symbol,
                int tf,
                double step,
                double maximum,
                int shift)
  {
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   int handle=iSAR(symbol,timeframe,step,maximum);
   if(handle<0)
     {
      return(-1);
     }
   else
      return(CopyBufferMQL4(handle,0,shift));
  }
  double iRSIMQL4(string symbol,
                int tf,
                int period,
                int price,
                int shift)
  {
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   ENUM_APPLIED_PRICE applied_price=PriceMigrate(price);
   int handle=iRSI(symbol,timeframe,period,applied_price);
   if(handle<0)
     {
      return(-1);
     }
   else
      return(CopyBufferMQL4(handle,0,shift));
  }
  
  double iStdDevMQL4(string symbol,
                   int tf,
                   int ma_period,
                   int ma_shift,
                   int method,
                   int price,
                   int shift)
  {
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   ENUM_MA_METHOD ma_method=MethodMigrate(method);
   ENUM_APPLIED_PRICE applied_price=PriceMigrate(price);
   int handle=iStdDev(symbol,timeframe,ma_period,ma_shift,
                      ma_method,applied_price);
   if(handle<0)
     {
      return(-1);
     }
   else
      return(CopyBufferMQL4(handle,0,shift));
  }
  double iStochasticMQL4(string symbol,
                       int tf,
                       int Kperiod,
                       int Dperiod,
                       int slowing,
                       int method,
                       int field,
                       int mode,
                       int shift)
  {
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   ENUM_MA_METHOD ma_method=MethodMigrate(method);
   ENUM_STO_PRICE price_field=StoFieldMigrate(field);
   int handle=iStochastic(symbol,timeframe,Kperiod,Dperiod,
                          slowing,ma_method,price_field);
   if(handle<0)
     {
      return(-1);
     }
   else
      return(CopyBufferMQL4(handle,mode,shift));
  }
  double iWPRMQL4(string symbol,
                int tf,
                int period,
                int shift)
  {
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   int handle=iWPR(symbol,timeframe,period);
   if(handle<0)
     {
      return(-1);
     }
   else
      return(CopyBufferMQL4(handle,0,shift));
  }