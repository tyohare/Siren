//+------------------------------------------------------------------+
//|                                                        SirenV1.0 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+



//Need a way to keep track of prev points of interest
//1. check dir with zz / 2. if direction WAS down and is now up - switch status and update highs/lows




int    ZigZagPeriod   =5;

int x,y = 0;
double currLow,currHigh,prevLow,prevHigh,prevPrevHigh,prevPrevLow = 0;
double prevMonthHigh, prevMonthLow;
double prevWeekKey;
bool trend;


void OnTick() {

     if(IsNewBar()){
     
         //analyze monthly
         analyzeMonthly();

         int b,a;
         double ZZ,ZZVal,high=0;
         b=0;
         a=0;
         while(a==0){

            ZZ=iCustom(NULL,0,"ZigZag", ZigZagPeriod,ZigZagPeriod-5,ZigZagPeriod-10,0,b); //-5,-10

            ZZVal=Open[b]-ZZ;
            checkDirection(ZZVal,ZZ);
            b++;

            if(ZZ>0){
               a=1;
            }

         }

     





    }

   

 } 

  

  
datetime lastBarOpenTime;

bool IsNewBar(){

   datetime thisBarOpenTime = Time[0];

   if(thisBarOpenTime != lastBarOpenTime)

   {

      lastBarOpenTime = thisBarOpenTime;

      return (true);

   }

   else{

      return (false);

   }
}

void checkDirection(double zzVal,double ZZ){

//we need to update the prev vars ONLY once then continously check leg direction.
//if y (opposite dir) > 0 , reset it, and allow x to increement after 1 go around to LOCK IT. Then do same for opp direction 


   Comment("ZZVal: "+ zzVal+"\n "+"ZZ:"+ZZ +"\n" "ppHigh: "+ prevPrevHigh+"\n "+ "prevHigh: "+ prevHigh+"\n" "ppLow: "+ prevPrevLow+"\n "+ "prevLow: "+ prevLow+"\n"+"currLow: "+ currLow+"\n"+"currHigh: "+ currHigh);
  
   
   //if direction has changed update it
   if(zzVal > 0 && ZZ != 0){
      //if this is the first turn in this direction
      if(y > 0){
         y = 0;
         //now we transfer previous values before updating
         prevPrevHigh = prevHigh;
         prevHigh = currHigh;
         currHigh = ZZ;
      }
      //we were in this direction before
      
      currLow = ZZ;
      x++;
   
   }
   else if(zzVal < 0 && ZZ != 0){
   
     
      //if this is the first turn in this direction
      if(x > 0){
     // Comment("HERE");
         x = 0;
         //now we transfer previous values before updating
         prevPrevLow = prevLow;
         prevLow = currLow;
         currLow = ZZ;
         }
      //we were in this direction before
     
      currHigh = ZZ;
      y++;
   }
   
}

void findPatterns(){

}

void analyzeMonthly(){
   //Go to monthly timeframe and mark high and lows of last month.
 
   prevMonthHigh = iHigh(NULL,PERIOD_MN1,1);
   prevMonthLow = iLow(NULL,PERIOD_MN1,1);
   ObjectCreate(0,"MonthlyLow",OBJ_HLINE,NULL,NULL,prevMonthLow);
   ObjectCreate(0,"MonthlyHigh",OBJ_HLINE,NULL,NULL,prevMonthHigh);
   //NEEDS A WAY TO UPDATE EVER Y MONTH
   
   //Find 50% retracement & determine Bull/bear status
   double temp = ((prevMonthHigh - prevMonthLow)/2) + prevMonthLow;
   if (Ask > temp){
      trend = True;
   }
   else{
      trend = false;
   }
   
   
}

//true = bull , false = bear
void analyzeWeekly(bool trends){

   if(trend == true){
   prevWeekKey = iHigh(NULL,PERIOD_W1,1);
   }
   else{
    prevWeekKey = iLow(NULL,PERIOD_W1,1);
   }
   ObjectCreate(0,"WeeklyKey",OBJ_HLINE,NULL,NULL,prevWeekKey);
   

}
void analyzeDaily(){

}
void analyze4HR(){

}
void NTSL(){

}
void EMAMomentum(){

}
void SRCheck(){

}