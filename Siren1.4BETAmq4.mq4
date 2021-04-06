//+------------------------------------------------------------------+
//|                                                SirenRemaster.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
int    ZigZagPeriod   =5;

int x,y = 0;
double currLow,currHigh,prevLow,prevHigh,prevPrevHigh,prevPrevLow = 0;
double prevMonthHigh, prevMonthLow;
double prevWeekKey;
double entry;
double ZZprev;
double EMA10,EMA20,LEMA10,LEMA20,EMA100,EMA200;
double SL;
double lows[100];
double highs[100];
double ZZs[100];
int b,a;
double ZZ,ZZ2,ZZVal,high;
datetime lastBarOpenTime;
double prevWeeklyClose;
int trend;
double prevWeeklyHigh = iHigh(Symbol(),PERIOD_W1,1);
double prevWeeklyLow = iLow(Symbol(),PERIOD_W1,1);

double weeklyLevel;
double oldWeeklylevel;
double longTP;
         double shortTP;

//keep track of weekly level and if it changes then cancel existing orders / cancel order DOESNT WORK?
//need to correct SL and TPs and SL management
//


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {

   if(IsNewBar())
     {
     
     RiskMGMT007();
     
      b=0;
      a=0;
      while(a==0)
        {
        
           ObjectDelete("MonthlyLow");
   ObjectDelete("MonthlyHigh");
   ObjectDelete("WeeklyLow");
   ObjectDelete("WeeklyHigh");

         EMA10 = iMA(NULL,0,10,0,MODE_EMA,PRICE_CLOSE,0);
         EMA20 = iMA(NULL,0,20,0,MODE_EMA,PRICE_CLOSE,0);
                  
         EMA100 = iMA(NULL,0,100,0,MODE_EMA,PRICE_CLOSE,0);
         EMA200 = iMA(NULL,0,200,0,MODE_EMA,PRICE_CLOSE,0);
         
         LEMA10 = iMA(NULL,0,10,0,MODE_EMA,PRICE_CLOSE,1);
         LEMA20 = iMA(NULL,0,20,0,MODE_EMA,PRICE_CLOSE,1);
         
         ZZ=iCustom(NULL,0,"ZigZag", ZigZagPeriod,ZigZagPeriod,ZigZagPeriod-1,0,b); //-5,-10 // apr 16th
         
            
         prevMonthHigh = iHigh(NULL,PERIOD_MN1,1);
         prevMonthLow = iLow(NULL,PERIOD_MN1,1);
         prevWeeklyHigh = iHigh(Symbol(),PERIOD_W1,1);
         prevWeeklyLow = iLow(Symbol(),PERIOD_W1,1);
         double fiftyPercent = prevMonthHigh - ((prevMonthHigh - prevMonthLow) / 2);
         
         prevWeeklyClose = iClose(Symbol(),PERIOD_W1,2);
         longTP = NormalizeDouble(((prevWeeklyHigh-prevWeeklyLow)*.27+prevWeeklyHigh),3);
         shortTP = NormalizeDouble(((prevWeeklyLow-prevWeeklyHigh)*.27+prevWeeklyLow),3);
         
         
   ObjectCreate(0,"MonthlyLow",OBJ_HLINE,0,0,prevMonthLow);
   ObjectCreate(0,"MonthlyHigh",OBJ_HLINE,0,0,prevMonthHigh);
   ObjectSet("MonthlyLow",OBJPROP_COLOR,clrWhite);
   ObjectSet("MonthlyHigh",OBJPROP_COLOR,clrWhite);
         

          // START ANALYSIS
   if(fiftyPercent < prevWeeklyClose){
      if(trend ==0 ){
            for(int j = 0; j < OrdersTotal(); j++)
     {
     


      if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
        {
        
             //if there is a change in the week then cancel existing order
     if(oldWeeklylevel != weeklyLevel){
            if(OrderType() == OP_BUYSTOP  || OrderType() == OP_SELLSTOP){
                  OrderClose(OrderTicket(),OrderLots(),Bid,2);
                  Print("HEREEEE");
                 
            }   
     }
     }
     }
      }
   trend = 1;
   ObjectCreate(0,"WeeklyHigh",OBJ_HLINE,0,0,prevWeeklyHigh);
   ObjectSet("WeeklyHigh",OBJPROP_COLOR,clrBlue);
   if(weeklyLevel - prevWeeklyHigh != 0){
      oldWeeklylevel = weeklyLevel;
   }

   weeklyLevel = prevWeeklyHigh;
   
   }
   else{
   if(trend == 1){
   for(int i = 0; i < OrdersTotal(); i++)
     {
     


      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
        
             //if there is a change in the week then cancel existing order
     if(oldWeeklylevel != weeklyLevel){
            if(OrderType() == OP_BUYSTOP  || OrderType() == OP_SELLSTOP){
                  OrderClose(OrderTicket(),OrderLots(),Bid,2);
                  Print("HEREEEE");
                 
            }   
     }
     }
     }
   }
   trend = 0;
   ObjectCreate(0,"WeeklyLow",OBJ_HLINE,0,0,prevWeeklyLow);
   ObjectSet("WeeklyLow",OBJPROP_COLOR,clrBlue);
  // if(weeklyLevel - prevWeeklyLow != 0){
      oldWeeklylevel = weeklyLevel;
  // }

   
   weeklyLevel = prevWeeklyLow;
   
   }

   
   
         ZZVal=Open[b]-ZZ;


         b++;

         if(ZZ>0)
           {
            a=1;
           }
         checkDirection(ZZVal,ZZ);//WAS HERE

         //If it detects a pattern then execute a trade.
      //   analyzeMonthly();
       //  analyzeWeekly(trend);
      //   analyzeDaily();
         analyze4HR();

        }

     }

  }
//+------------------------------------------------------------------+
bool IsNewBar()
  {

   datetime thisBarOpenTime = Time[0];

   if(thisBarOpenTime != lastBarOpenTime)

     {

      lastBarOpenTime = thisBarOpenTime;

      return (true);

     }

   else
     {

      return (false);

     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void checkDirection(double zzVal,double ZZ)
  {

//we need to update the prev vars ONLY once then continously check leg direction.
//if y (opposite dir) > 0 , reset it, and allow x to increement after 1 go around to LOCK IT. Then do same for opp direction


   Comment("ZZVal: "+ zzVal+"\n "+"ZZ:"+ZZ +"\n" "ppHigh: "+ prevPrevHigh+"\n "+
    "prevHigh: "+ prevHigh+"\n" "ppLow: "+ prevPrevLow+"\n "+ "prevLow: "+ prevLow+"\n"+
    "currLow: "+ currLow+"\n"+"currHigh: "+ currHigh + "\n WH" +(prevWeeklyHigh)+ "\n WL" +(prevWeeklyLow)+
     "\n PWL" +(NormalizeDouble(((prevWeeklyHigh-prevWeeklyLow)*.27+prevWeeklyHigh),3)));


//if direction has changed update it
   if(zzVal > 0 && ZZ != 0) //WE ARE MOVING DOWN -- ZZVAL IS POSITIVE, SO WE HAVE A NEW HIGH WE NEED TO UPDATE
     {

      //if this is the first turn in this direction
      if(y > 0)
        {

         y = 0;
         //now we transfer previous values before updating

         prevPrevHigh = prevHigh;
         prevHigh = currHigh;
         currLow = ZZ;


        }
      else
        {
         //we were in this direction before
         //GRAB the lowest low from the array
         currLow = ZZ;
         x++;
        }



     }
   else
      if(zzVal < 0 && ZZ != 0) //we are moving UP
        {


         //if this is the first turn in this direction
         if(x > 0)
           {

            x = 0;
            //now we transfer previous values before updating

            prevPrevLow = prevLow;
            prevLow = currLow;
            currHigh = ZZ;

           }
         else
           {

            //we were in this direction before
            currHigh = ZZ;
            y++;

           }


        }


  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//true = bull , false = bear

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//we can use iTime to get the start date of market analysis
void analyzeDaily()
  {

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//Mostly just pattern searching? 007 stop orders if trend is in sync with setup?
void analyze4HR()
  {

   if(ZZVal > 0)
     {
      if(trend == 1)
        {
         if(prevHigh - prevPrevHigh > 0 && currLow - prevLow > 0)
           {
            entry = prevHigh;
            SL = StopOrderSL(true,entry);
           // if(AlreadyOpened(entry))
           if(OrdersTotal() == 0)
              {
               OrderSend(
                  Symbol(),
                  OP_BUYSTOP,
                  1.0,// calcLotSize(entry - SL),
                  entry,
                  0,
                  StopOrderSL(true,entry),  //SL need RNT
                  longTP,  //TP running risk MGMT prevHigh + (1000*_Point)
                  NULL,
                  0,
                  TimeCurrent() + 60*60*24*5,
                  clrYellow
               );

              }
           }

        }

     }
   if(ZZVal < 0)
     {
      if(trend == 0)
        {
         if(prevPrevLow - prevLow > 0 && prevHigh - currHigh > 0)
           {
            entry = prevLow;
            SL = StopOrderSL(false,entry);
            //if(AlreadyOpened(entry))
            if(OrdersTotal() == 0)
              {
               OrderSend(
                  Symbol(),
                  OP_SELLSTOP,
                  1.0,//calcLotSize(SL - entry),
                  entry,
                  0,
                  SL, // SL RNT
                  shortTP,//TP running risk MGMT prevLow - (1000*_Point)
                  NULL,
                  0,
                  TimeCurrent() + 60*60*24*5,
                  clrYellow
               );
              }
           }
        }

     }



         ObjectCreate(0,"H",OBJ_HLINE,0,0,currHigh);
         ObjectCreate(0,"PH",OBJ_HLINE,0,0,prevHigh);
         ObjectCreate(0,"L",OBJ_HLINE,0,0,currLow);
         ObjectCreate(0,"PL",OBJ_HLINE,0,0,prevLow);

         ObjectSet("H",OBJPROP_COLOR,clrLightGreen);
         ObjectSet("PH",OBJPROP_COLOR,clrLightGreen);
         
         
         ObjectSet("L",OBJPROP_COLOR,clrLightBlue);
         ObjectSet("PL",OBJPROP_COLOR,clrLightBlue);


  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double NTSL(bool direction,double entry)
  {
   int trunk = entry;
   double base = entry - trunk;
   if(direction == true)  //round DOWN for BUY
     {
      if(base >= (660*_Point))
        {
         return trunk + (80*_Point +35*_Point);   //Ttrucate  80
        }
      else
         if(base >= 46)
           {
            return trunk + (50*_Point +35*_Point);   //50
           }
         else
            if(base>= 0)
              {
               return trunk + (20*_Point +35*_Point);   //20
              }
     }
   else
     {
      // Round UP for SELL

     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//determine trending / consolodating market via momentum of EMAs
bool EMAMomentum()
  {
   if(EMA10 < EMA20)
     {
      return false;
     }
   else
     {
      return true;
     }
  }

//+------------------------------------------------------------------+
double StopOrderSL(bool type,double entry)  //true = buy, false = sell
  {

   double structStop, RNTStop;
//Check prev high or low
   if(type == true)
     {
      structStop = currLow;
      RNTStop = NTSL(true,entry) - (350*_Point);
      //compare and choose smaller

      if((structStop) < (RNTStop))
        {
         return RNTStop;
        }
      else
        {
         return structStop;
        }

     }
   else
     {
      structStop = currHigh;
      RNTStop = NTSL(false,entry) + (350*_Point);

      //compare and choose smaller
      if(structStop < RNTStop)
        {
         return RNTStop;
        }
      else
        {
         return structStop;
        }
     }

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RiskMGMT007()
  {

//For every trade we are in...
   for(int i = 0; i < OrdersTotal(); i++)
     {
     


      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
        
             //if there is a change in the week then cancel existing order
     if(oldWeeklylevel != weeklyLevel){
            if(OrderType() == OP_BUYSTOP  || OrderType() == OP_SELLSTOP){
                  OrderClose(OrderTicket(),OrderLots(),Bid,2);
                  Print("HEREEEE");
                 
            }   
     }

         //IF BUY STOP
         if(OrderType() == OP_BUY)
           {
            //Print("HEREEEE");
            /*
               //if 30 pips past close half partial
               if((Ask - OrderOpenPrice()) > 30*_Point && OrderLots() == 0.5){
            //    Print("BUYTSTOP");
                  OrderClose(OrderTicket(),
                  0.25,
                  Ask,
                  3,
                  clrOrange);
              */
            if(Ask - OrderOpenPrice()> 750*_Point)
              {
               OrderModify(OrderTicket(),Ask,OrderOpenPrice() + 500*_Point,OrderTakeProfit(),NULL,clrGreen);
              }
            else
               if(Ask - OrderOpenPrice()> 300*_Point)
                 {
                  OrderModify(OrderTicket(),Ask,OrderOpenPrice(),OrderTakeProfit(),NULL,clrGreen);
                 }
           }
        }
      //IF SELL STOP
      if(OrderType() == OP_SELL)
        {

         /*
              //if 30 pips past close half partial
            if((OrderOpenPrice() - Ask) > 30*_Point && OrderLots() ==  0.5){
         //    Print("SELLSTOP PARTIAL?");
               OrderClose(OrderTicket(),
               0.25,
               Ask,
               3,
               clrOrange);
         }
         }
         */
         if(OrderOpenPrice() - Ask > 1250*_Point)
           {
            OrderModify(OrderTicket(),Ask,OrderOpenPrice() - 1000*_Point,OrderTakeProfit(),NULL,clrGreen);
           }
         else
            if(OrderOpenPrice() - Ask > 750*_Point)
              {
               OrderModify(OrderTicket(),Ask,OrderOpenPrice() - 500*_Point,OrderTakeProfit(),NULL,clrGreen);
              }
            else
               if(OrderOpenPrice() - Ask > 300*_Point)
                 {
                  OrderModify(OrderTicket(),Ask,OrderOpenPrice(),OrderTakeProfit(),NULL,clrGreen);
                 }

        }
     }
//if 30 pips in profit move to BE

// if 50 in profit take 50% partials


//WE BEED to add multiple positions by determining if that entry price was alrdy entered.
  }

//
bool AlreadyOpened(double price)
  {

   for(int i = 0; i < OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderOpenPrice() == price)
           {
            return false;
           }
        }
     }
   return true;
  }


//NEXT TIME: risk 1% of acct. on SL. More explicit TP rules - make decision based on LOTS SIZE, SL choose during each trade
//Check accuracy of trades

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calcLotSize(double numPips)
  {
   double onePercent = AccountBalance() * 0.01;
   double lots = (onePercent / (numPips*100)) *.10;
   Print(NormalizeDouble(lots,2));
   return NormalizeDouble(lots,2);

  }
//Shifts high(TRUE) or low(FALSE) array
void shift(bool HORL,double value)
  {
   if(HORL)
     {
      for(int z = 0; z < 98; z++)
        {
         highs[z+1] = highs[z];
         //then put the new high in highs[0]
         highs[0] = value;
         //Now update all previous values given
         currHigh = highs[0];
         prevHigh = highs[1];
         prevPrevHigh = highs[2];
        }
     }
   else
     {
      for(z = 0; z < 98; z++)
        {
         lows[z+1] = lows[z];
         //then put the new lows in lows[0]
         lows[0] = value;
         //Now update all previous values given
         currLow = lows[0];
         prevLow = lows[1];
         prevPrevLow = lows[2];

        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void shiftzz(double value)
  {
   if(value != 0)
     {
      for(int z = 0; z < 98; z++)
        {


         //SHift all the values over
         ZZs[z+1] = ZZs[z];
         //Then update the curr zz value
         ZZs[0] = value;

        }

     }
  }
//+------------------------------------------------------------------+
