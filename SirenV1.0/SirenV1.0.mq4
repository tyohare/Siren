//+------------------------------------------------------------------+
//|                                                        SirenV1.0 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+








  input double Lot            =0.01;

  input int    PeakPeriod     =50;

  input int    StdDevPeriod   =100;

  input int    ZigZagPeriod   =150;

  input int    TakeProfit     =500;

  input bool   Positive       =true;

  

  double lot=Lot;

  

void OnTick() {

     if(IsNewBar())

     {

        int ticket,i,b,a;

         

         int orders=0;

         double profit=0, orderlots;

         

         for(i=OrdersTotal();i>=0;i--)

         {

            if(OrderSelect(i,SELECT_BY_POS))

               if(OrderSymbol()==Symbol())

               {

                  profit+=OrderProfit();orders+=1;orderlots+=OrderLots();

               }

         }

       

         bool Buy=false, Sell=false, CloseBuy=false, CloseSell=false;

     

     

         double ZZ,ZZVal,high=0,StdDev,StdDev2,StdDev3;

         b=0;

         a=0;

         while(a==0)

         {

            ZZ=iCustom(NULL,0,"ZigZag", ZigZagPeriod,ZigZagPeriod-5,ZigZagPeriod-10,0,b);

            ZZVal=Open[b]-ZZ;

            b++;

            if(ZZ>0)

               a=1;

         }

     

          for(i=2;i<PeakPeriod;i++)

          {

            StdDev=iStdDev(NULL,0,StdDevPeriod,0,MODE_EMA,1,i);

            if(StdDev>high)

               high = StdDev;

          }

     

          StdDev2=iStdDev(NULL,0,StdDevPeriod,0,MODE_EMA,1,0);

          StdDev3=iStdDev(NULL,0,StdDevPeriod,0,MODE_EMA,1,1);



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