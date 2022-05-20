//+------------------------------------------------------------------+
//|                                                SirenRemaster.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
int ZigZagPeriod = 5;
int x,y = 0;
double currLow,currHigh,prevLow,prevHigh,prevPrevHigh,prevPrevLow = 0;
double prevMonthHigh, prevMonthLow;
double prevWeekKey;
double entry;
double ZZprev;
double EMA10D,EMA20D,LEMA10,LEMA20,EMA10W,EMA20W;
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
//| Expert tick function, Analysis                                            |
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

         EMA10D= iMA(NULL,PERIOD_D1,10,0,MODE_EMA,PRICE_CLOSE,0);
         EMA20D = iMA(NULL,PERIOD_D1,20,0,MODE_EMA,PRICE_CLOSE,0);

         EMA10W = iMA(NULL,PERIOD_W1,100,0,MODE_EMA,PRICE_CLOSE,0);
         EMA20W = iMA(NULL,PERIOD_W1,200,0,MODE_EMA,PRICE_CLOSE,0);

         LEMA10 = iMA(NULL,0,10,0,MODE_EMA,PRICE_CLOSE,1);
         LEMA20 = iMA(NULL,0,20,0,MODE_EMA,PRICE_CLOSE,1);

         ZZ=iCustom(NULL,0,"ZigZag", ZigZagPeriod,ZigZagPeriod,ZigZagPeriod-1,0,b); //Other paramaters: -5,-10, b


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
         if(fiftyPercent < prevWeeklyClose)
           {
            if(trend ==0)
              {
               for(int j = 0; j < OrdersTotal(); j++)
                 {
                  if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
                    {
                     //if there is a change in the week then cancel existing order
                     if(oldWeeklylevel != weeklyLevel)
                       {
                        if(OrderType() == OP_BUYSTOP  || OrderType() == OP_SELLSTOP)
                          {
                           OrderClose(OrderTicket(),OrderLots(),Bid,2); //may change in next version
                          }
                       }
                    }
                 }
              }
            trend = 1;
            ObjectCreate(0,"WeeklyHigh",OBJ_HLINE,0,0,prevWeeklyHigh);
            ObjectSet("WeeklyHigh",OBJPROP_COLOR,clrBlue);
            if(weeklyLevel - prevWeeklyHigh != 0)
              {
               oldWeeklylevel = weeklyLevel;
              }
            weeklyLevel = prevWeeklyHigh;
           }
         else
           {
            if(trend == 1)
              {
               for(int i = 0; i < OrdersTotal(); i++)
                 {
                  if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
                    {
                     //if there is a change in the week then cancel existing order
                     if(oldWeeklylevel != weeklyLevel)
                       {
                        if(OrderType() == OP_BUYSTOP  || OrderType() == OP_SELLSTOP)
                          {
                           OrderClose(OrderTicket(),OrderLots(),Bid,2);
                          }
                       }
                    }
                 }
              }
              
            trend = 0;
            ObjectCreate(0,"WeeklyLow",OBJ_HLINE,0,0,prevWeeklyLow);
            ObjectSet("WeeklyLow",OBJPROP_COLOR,clrBlue);

            oldWeeklylevel = weeklyLevel;
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
         //analyzeMonthly();
         //analyzeWeekly(trend);
         analyzeDaily();
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

//Get market direction based off of ZigZag indicator
void checkDirection(double zzVal,double ZZ)
  {

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
            // currHigh = ZZ;

           }
         else
           {

            //we were in this direction before
            currHigh = ZZ;
            y++;

           }
        }
  }




//NOTE: true = bull , false = bear

//we can use iTime to get the start date of market analysis
void analyzeDaily()
  {

  }

//pattern searching. 007 stop orders if trend is in sync with setup.
void analyze4HR()
  {

   if(prevHigh > prevPrevHigh) //&& prevLow > prevPrevLow
     {
      entry = currLow;
      SL = StopOrderSL(false,entry);
      double risk_percent = 0.005;

      double lotstouse =(AccountBalance()/100*risk_percent);
      //printf("Lots: "+ lotstouse);
      //if(AlreadyOpened(entry)) //Left out for testing
      if(OrdersTotal() < 2)
        {
         OrderSend(
            Symbol(),
            OP_SELLSTOP,
            lotstouse,//Alternatively: 1.00, calcLotSize(MathAbs(NormalizeDouble(SL-entry,Digits)/Point)),
            entry,
            0,
            prevHigh,//Alternatively: entry + (250*_Point),//SL, // SL RNT
            prevLow - (1000*_Point),//Alternatively: shortTP,//TP running risk MGMT prevLow - (1000*_Point)
            NULL,
            0,
            TimeCurrent() + 60*60*24*5,
            clrYellow
         );
        }
     }


   if(prevPrevLow > prevLow)
     {
      entry = currHigh;
      SL = StopOrderSL(true,entry);

      // if(AlreadyOpened(entry)) //Left out for testing
      if(OrdersTotal() < 2)
        {
         OrderSend(
            Symbol(),
            OP_BUYSTOP,
            lotstouse,//lotstouse,//1.00,//calcLotSize(MathAbs(NormalizeDouble(entry-prevLow,Digits)/Point)),
            entry,
            0,
            prevLow,//entry - (250*_Point),//StopOrderSL(true,entry),  //SL need RNT
            prevHigh + (1000*_Point),//longTP,  //TP running risk MGMT prevHigh + (1000*_Point)
            NULL,
            0,
            TimeCurrent() + 60*60*24*5,
            clrYellow
         );
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

//determine trending / consolodating market via momentum of EMAs
bool EMAMomentum()
  {
   if(EMA10D < EMA20D)
     {
      return false;
     }
   else
     {
      return true;
     }
  }

//Calculate stop loss for Stop orders
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
//| Risk Management:                                                         |
//+------------------------------------------------------------------+
//Manages open positions
void RiskMGMT007()
  {
//For every trade we are in...
   for(int i = 0; i < OrdersTotal(); i++)
     {

      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {

         //if there is a change in the week then cancel existing order
         if(oldWeeklylevel != weeklyLevel)
           {
            if(OrderType() == OP_BUYSTOP  || OrderType() == OP_SELLSTOP)
              {
               //OrderClose(OrderTicket(),OrderLots(),Bid,2);
               Print("HEREEEE");

              }
           }

         //IF BUY STOP
         if(OrderType() == OP_BUY)
           {

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

  }

//Checking number of opened trades
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


//TODO: risk 1% of acct. on SL. More explicit TP rules - make decision based on LOTS SIZE, SL choose during each trade
//Check accuracy of trades

//+------------------------------------------------------------------+
//| Testing:                                                                 |
//+------------------------------------------------------------------+
//Calculating correct lotsize test
double calcLotSize(double numPips)
  {
   double onePercent = AccountBalance() * 0.01;
   double lots = (onePercent / (numPips*100)) *.10;
   Print(NormalizeDouble(lots,2));
   return NormalizeDouble(lots,2);

  }
//For testing Highs and Lows. Shifts high(TRUE) or low(FALSE) array
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

//For testing ZZ indicator
void shiftzz(double value)
  {
   if(value != 0)
     {
      for(int z = 0; z < 98; z++)
        {
         //Shift all the values over
         ZZs[z+1] = ZZs[z];
         //Then update the curr zz value
         ZZs[0] = value;

        }
     }
  }
//+------------------------------------------------------------------+
