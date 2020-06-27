//+------------------------------------------------------------------+
//|                                                       Siren v1.0 |
//|                                                 By: Tyler O'Hare |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+



//Need a way to keep track of prev points of interest
//1. check dir with zz / 2. if direction WAS down and is now up - switch status and update highs/lows




int    ZigZagPeriod   =3;

int x,y = 0;
double currLow,currHigh,prevLow,prevHigh,prevPrevHigh,prevPrevLow = 0;
double prevMonthHigh, prevMonthLow;
double prevWeekKey;
bool trend;
double entry;
double ZZprev;
double EMA10,EMA20,LEMA10,LEMA20;
double SL;
double lows[100];
double highs[100];
double ZZs[100];

// CReate 2 arrays that store previous 100 low and high values. THEN create a function that will SHIFT all values over while inserting new low

//+------------------------------------------------------------------+
//|                                                                  | hello world
//+------------------------------------------------------------------+
void OnTick()
  {

   if(IsNewBar())
     {

    //  if(OrdersTotal() > 0){
         RiskMGMT007();
      //}
      //analyze monthly
      analyzeMonthly();
      analyzeWeekly(trend);
      analyzeDaily();
     analyze4HR();

      int b,a;
      double ZZ,ZZ2,ZZVal,high=0;
      b=0;
      a=0;
      while(a==0)
        {
        
         EMA10 = iMA(NULL,0,10,0,MODE_EMA,PRICE_CLOSE,0);
         EMA20 = iMA(NULL,0,20,0,MODE_EMA,PRICE_CLOSE,0);
         LEMA10 = iMA(NULL,0,10,0,MODE_EMA,PRICE_CLOSE,1);
         LEMA20 = iMA(NULL,0,20,0,MODE_EMA,PRICE_CLOSE,1);
         ZZ=iCustom(NULL,0,"ZigZag", ZigZagPeriod,ZigZagPeriod,ZigZagPeriod-1,0,b); //-5,-10 // apr 16th
        // ZZ2=iCustom(NULL,0,"ZigZag2", ZigZagPeriod,ZigZagPeriod-10,ZigZagPeriod-15,0,b); //-5,-10 // apr 16th

         ZZVal=Open[b]-ZZ;
         shiftzz(ZZ);
         checkDirection(ZZVal,ZZ);//WAS HERE
         b++;

         if(ZZ>0)
           {
            a=1;
           }

        }

     }

  }




datetime lastBarOpenTime;

//+------------------------------------------------------------------+
//|                                                                  |
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


   Comment("ZZVal: "+ zzVal+"\n "+"ZZ:"+ZZ +"\n" "ppHigh: "+ prevPrevHigh+"\n "+ "prevHigh: "+ prevHigh+"\n" "ppLow: "+ prevPrevLow+"\n "+ "prevLow: "+ prevLow+"\n"+"currLow: "+ currLow+"\n"+"currHigh: "+ currHigh + "/n"+ZZs[1]+ "/n"+highs[0]+ "/n"+lows[0]);


//if direction has changed update it
   if(zzVal > 0 && ZZ != 0) //WE ARE MOVING DOWN
     {
     
      //if this is the first turn in this direction
      if(y > 0)
        {
       
         y = 0;
         //now we transfer previous values before updating
         prevPrevHigh = prevHigh;
         prevHigh = currHigh;
         currHigh = ZZ;
         ///////////test
         shift(True,ZZs[1]);
         
        }
        
      //we were in this direction before

     // currLow = ZZ; commented out for test
      x++;
      
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
            currLow = ZZ;
            /////////test
            shift(False,ZZs[1]);
           }
           
         //we were in this direction before
         //shift everything in the highs and set highs[0] = ZZ;
         //currHigh = ZZ; commented out for test
         y++;
         }
        

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void findPatterns()
  {

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void analyzeMonthly()
  {
//Go to monthly timeframe and mark high and lows of last month.

   prevMonthHigh = iHigh(NULL,PERIOD_MN1,1);
   prevMonthLow = iLow(NULL,PERIOD_MN1,1);
   ObjectCreate(0,"MonthlyLow",OBJ_HLINE,NULL,NULL,prevMonthLow);
   ObjectCreate(0,"MonthlyHigh",OBJ_HLINE,NULL,NULL,prevMonthHigh);
//NEEDS A WAY TO UPDATE EVERY MONTH

//Find 50% retracement & determine Bull/bear status
   double temp = ((prevMonthHigh - prevMonthLow)/2) + prevMonthLow;
   if(Ask > temp)
     {
      trend = True;
     }
   else
     {
      trend = false;
     }


  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//true = bull , false = bear
void analyzeWeekly(bool trends)
  {

   if(trend == true)
     {
      prevWeekKey = iHigh(NULL,PERIOD_W1,1);
     }
   else
     {
      prevWeekKey = iLow(NULL,PERIOD_W1,1);
     }
   ObjectCreate(0,"WeeklyKey",OBJ_HLINE,NULL,NULL,prevWeekKey);


  }
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
  

      
   if((EMAMomentum() == false) && trend == true){
      if(prevHigh - prevPrevHigh >= 0 && prevHigh - prevPrevHigh <= 30*_Point){
      entry = prevHigh;
      SL = StopOrderSL(true,entry);
      if(AlreadyOpened(entry)){
          OrderSend(
             Symbol(),
             OP_BUYSTOP,
            1.0,// calcLotSize(entry - SL),
             entry,
             0,
             StopOrderSL(true,entry),  //SL need RNT
             entry + 2000*_Point,  //TP running risk MGMT prevHigh + (1000*_Point)
             NULL,
             0,
             TimeCurrent() + 60*60*24*5,
             clrYellow
             );
             
         }
      }  
      
   }
      if((EMAMomentum() == false) && trend == false){
         if(prevPrevLow - prevLow >= 0 && prevPrevLow - prevLow <= 30*_Point){
         entry = currLow;
         SL = StopOrderSL(false,entry);
         if(AlreadyOpened(entry)){
             OrderSend(
                Symbol(),
                OP_SELLSTOP,
                1.0,//calcLotSize(SL - entry),
                entry,
                0,
                SL, // SL RNT
                entry - 2000*_Point,//TP running risk MGMT prevLow - (1000*_Point)
                NULL,
                0,
                TimeCurrent() + 60*60*24*5,
                clrYellow
                );
         }
      }
   }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//done this before, simply finding nearest NT and getting SL                                  //TURN TO INT the MNINUS ALSO fix RNTSL to correct SL Adjustments
double NTSL(bool direction,double entry)
  {
  int trunk = entry;
  double base = entry - trunk;
   if (direction == true){//round DOWN for BUY
      if (base >= (66*_Point)){ return trunk + (80*_Point +35*_Point); } //Ttrucate  80
      else if(base >= 46){ return trunk + (50*_Point +35*_Point); }      //50
      else if( base>= 0 ){ return trunk + (20*_Point +35*_Point); }       //20
   }
   else{
    // Round UP for SELL
    
   }
   
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//determine trending / consolodating market via momentum of EMAs
bool EMAMomentum()
  {
   if(EMA10 < EMA20){
    return false;
   }
   else{ return true;}
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//something to do with limit orders and their numbers,
void SRCheck()
  {

  }
//+------------------------------------------------------------------+
double StopOrderSL(bool type,double entry){ //true = buy, false = sell

   double structStop, RNTStop;
      //Check prev high or low
      if(type == true){
          structStop = prevLow;
          RNTStop = NTSL(true,entry) - (350*_Point);       
      //compare and choose smaller
      
         if((structStop) < (RNTStop)){ return RNTStop; }
         else{ return structStop; }
      
      }
      else{
         structStop = prevHigh;
         RNTStop = NTSL(false,entry) + (350*_Point);
            
      //compare and choose smaller
       if(structStop < RNTStop){ return RNTStop; }
         else{ return structStop; }
      }
        
}


void RiskMGMT007(){

//For every trade we are in...
for(int i = 0; i < OrdersTotal(); i++){

      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
          
         //IF BUY STOP
         if(OrderType() == OP_BUY){
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
               if(Ask - OrderOpenPrice()> 750*_Point){
                  OrderModify(OrderTicket(),Ask,OrderOpenPrice() + 500*_Point,OrderTakeProfit(),NULL,clrGreen);
               }   
               else if(Ask - OrderOpenPrice()> 300*_Point){
                  OrderModify(OrderTicket(),Ask,OrderOpenPrice(),OrderTakeProfit(),NULL,clrGreen);
               } 
            }
         }
         //IF SELL STOP
         if(OrderType() == OP_SELL){
         
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
      if( OrderOpenPrice() - Ask > 1250*_Point){
                  OrderModify(OrderTicket(),Ask,OrderOpenPrice() - 1000*_Point,OrderTakeProfit(),NULL,clrGreen);
               }
      else if( OrderOpenPrice() - Ask > 750*_Point){
                  OrderModify(OrderTicket(),Ask,OrderOpenPrice() - 500*_Point,OrderTakeProfit(),NULL,clrGreen);
               }
      else if( OrderOpenPrice() - Ask > 300*_Point){
                  OrderModify(OrderTicket(),Ask,OrderOpenPrice(),OrderTakeProfit(),NULL,clrGreen);
               }
               
   }
}
//if 30 pips in profit move to BE

// if 50 in profit take 50% partials


//WE BEED to add multiple positions by determining if that entry price was alrdy entered.
}

//
bool AlreadyOpened(double price){

   for(int i = 0; i < OrdersTotal(); i++){
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
         if(OrderOpenPrice() == price){
               return false;
         }
      }
   }
   return true;
}


//NEXT TIME: risk 1% of acct. on SL. More explicit TP rules - make decision based on LOTS SIZE, SL choose during each trade 
//Check accuracy of trades

double calcLotSize(double numPips){
   double onePercent = AccountBalance() * 0.01;
  double lots = (onePercent / (numPips*100)) *.10;
  Print(NormalizeDouble(lots,2));
  return NormalizeDouble(lots,2);

}
//Shifts high(TRUE) or low(FALSE) array 
void shift(bool HORL,double value){
   if(HORL){
      for( int z = 0;z < 98;z++){
         highs[z+1] = highs[z];
         //then put the new high in highs[0]
         highs[0] = value;
         //Now update all previous values given
         currHigh = highs[0];
         prevHigh = highs[1];
         prevPrevHigh = highs[2];
      }
   }
   else{
      for( z = 0;z < 98;z++){
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

void shiftzz(double value){
   if(value != 0){   
      for( int z = 0;z < 98;z++){
   
   
         //SHift all the values over
         ZZs[z+1] = ZZs[z];
         //Then update the curr zz value
         ZZs[0] = value;
   
      }
      
   }
}