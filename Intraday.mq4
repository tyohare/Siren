//+------------------------------------------------------------------+
//|                                                     Intraday.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
                
  {
//---

   //Highs and Lows
   ObjectDelete("MonthlyLow");
   ObjectDelete("MonthlyHigh");
   ObjectDelete("WeeklyLow");
   ObjectDelete("WeeklyHigh");
   ObjectDelete("DailyLow");
   ObjectDelete("DailyHigh");
   
   double prevMonthHigh = iHigh(Symbol(),PERIOD_MN1,1);
   double prevMonthLow = iLow(Symbol(),PERIOD_MN1,1);
   double prevWeeklyHigh = iHigh(Symbol(),PERIOD_W1,1);
   double prevWeeklyLow = iLow(Symbol(),PERIOD_W1,1);
   double prevDailyHigh = iHigh(Symbol(),PERIOD_D1,1);
   double prevDailyLow = iLow(Symbol(),PERIOD_D1,1);
   
   double fiftyPercent = prevMonthHigh - ((prevMonthHigh - prevMonthLow) / 2);
   double prevWeeklyClose = iClose(Symbol(),PERIOD_W1,2);
   int trend;
   
   ObjectCreate(0,"MonthlyLow",OBJ_HLINE,0,0,prevMonthLow);
   ObjectCreate(0,"MonthlyHigh",OBJ_HLINE,0,0,prevMonthHigh);
   ObjectSet("MonthlyLow",OBJPROP_COLOR,clrWhite);
   ObjectSet("MonthlyHigh",OBJPROP_COLOR,clrWhite);
   
   //ObjectCreate(0,"WeeklyLow",OBJ_HLINE,0,0,prevWeeklyLow);
   //ObjectCreate(0,"WeeklyHigh",OBJ_HLINE,0,0,prevWeeklyHigh);
  // ObjectSet("WeeklyLow",OBJPROP_COLOR,clrBlue);
   //ObjectSet("WeeklyHigh",OBJPROP_COLOR,clrBlue);
  
   ObjectCreate(0,"DailyLow",OBJ_HLINE,0,0,fiftyPercent);
   //ObjectCreate(0,"DailyHigh",OBJ_HLINE,0,0,prevDailyHigh);
  ObjectSet("DailyLow",OBJPROP_COLOR,clrLightGreen);
   //ObjectSet("DailyHigh",OBJPROP_COLOR,clrLightGreen);

   // START ANALYSIS
   if(fiftyPercent < prevWeeklyClose){
   
   trend = 1;
    //  ObjectCreate(0,"WeeklyLow",OBJ_HLINE,0,0,prevWeeklyLow);
   ObjectCreate(0,"WeeklyHigh",OBJ_HLINE,0,0,prevWeeklyHigh);
   //ObjectSet("WeeklyLow",OBJPROP_COLOR,clrBlue);
   ObjectSet("WeeklyHigh",OBJPROP_COLOR,clrBlue);
   
   }
   else{
   trend = 0;
      ObjectCreate(0,"WeeklyLow",OBJ_HLINE,0,0,prevWeeklyLow);
   //ObjectCreate(0,"WeeklyHigh",OBJ_HLINE,0,0,prevWeeklyHigh);
   ObjectSet("WeeklyLow",OBJPROP_COLOR,clrBlue);
   //ObjectSet("WeeklyHigh",OBJPROP_COLOR,clrBlue);
   
   }
   //Session seperators
   //ObjectCreate(0,"NY Lunch",OBJ_VLINE,0,StrToTime("20:00"),Ask);
   //ObjectCreate(0,"Asia",OBJ_VLINE,0,StrToTime("2:00"),Ask);
   //ObjectCreate(0,"London",OBJ_VLINE,0,StrToTime("8:00"),Ask);
   //ObjectCreate(0,"NY",OBJ_VLINE,0,StrToTime("14:00"),Ask);
   //ObjectSet("NY Lunch",OBJPROP_COLOR,clrBlack);
   //ObjectSet("Asia",OBJPROP_COLOR,clrBlack);
   //ObjectSet("London",OBJPROP_COLOR,clrBlack);
   //ObjectSet("NY",OBJPROP_COLOR,clrBlack);
   
   //Daily seperator
   //ObjectCreate(0,"Day",OBJ_VLINE,0,StrToTime("0:00"),Ask);
   //double total;
   //Weekly seperator
  // if(DayOfWeek == 1 && TimeToStr(TimeGMT) == "0:00"){
  //    total = 0;
  // }
  //datetime Week_Open_Time;
  //int Track_Last_Checked;
  //int My_Expert_Unique_Number=777;
  
  // if(Week_Open_Time!=iTime(Symbol(),PERIOD_W1,0)){
   //     Week_Open_Time=iTime(Symbol(),PERIOD_W1,0);
   //     //is_Weekly_Trading_Allowed=true; reset pip counter??
   //     total = 0;
   // }
   
  // if(OrdersHistoryTotal()>Track_Last_Checked){
       // Track_Last_Checked=OrdersHistoryTotal();
     //   for(int i=OrdersHistoryTotal()-1;i>=0;i--){
        //    if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)){
        
      //  }
         //IF BUY
        // if(OrderType() == OP_BUY){

      //      total += OrderOpenPrice() - Bid;
      //   }
      //   //IF SELL
      //   if(OrderType() == OP_SELL){


       //     total = Bid - OrderOpenPrice();
               
     //   }
              
         
     // //  }
    //  }
   //}
   
   
   //Pip counter
   //take open trades, count pips from open, take closed trades FROM past week.count those.
   
     double floating = 0;
   //For every trade we are in...
for(int i = 0; i < OrdersTotal(); i++){

      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
        
         //IF BUY
         if(OrderType() == OP_BUY){
//return curr price - entry price
      floating = OrderOpenPrice() - Bid;
         }
         //IF SELL
         if(OrderType() == OP_SELL){

//return entry price - curr price
            floating = Bid - OrderOpenPrice();
               
        }
     }
}
   
   
   ObjectCreate("Pips",OBJ_LABEL,0,0,0);
   ObjectSet("Pips",OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   ObjectSet("Pips",OBJPROP_XDISTANCE,60);
   ObjectSet("Pips",OBJPROP_YDISTANCE,60);
   
   ObjectCreate("PipsWeek",OBJ_LABEL,0,0,0);
   ObjectSet("PipsWeek",OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   ObjectSet("PipsWeek",OBJPROP_XDISTANCE,60);
   ObjectSet("PipsWeek",OBJPROP_YDISTANCE,40);
   
   ObjectSetText("PipsWeek", "Week: " + trend,16,"Arial",White);
   
   ObjectSetText("Pips", "Pips: " + floating,16,"Arial",White);
   
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
