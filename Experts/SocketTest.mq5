//+------------------------------------------------------------------+
//|                     Copyright 2024, kisb-data                    |
//|                     kisbalazs.data@gmail.com                     |
//+------------------------------------------------------------------+

sinput string Server="localhost";
sinput uint   Port=9090;
sinput uint   Timeout=1000;

//--- includes
#include <kisb_data\\Socket\\SocketCom.mqh>
#include <kisb_data\\Externals\\SYS_JAson.mqh>

//--- create classes
CSocket *Socket;
CJAVal  *json;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {

//--- create classes
 Socket = new CSocket(Server, Port, Timeout);
 json=new CJAVal;
 
 return(INIT_SUCCEEDED); }
 
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {

//--- delete classes
   delete Socket;
   delete json;
   
 }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {

   int count=0;
   
   while(true)
   {  
      //reset cycle if reached 100 element
      if(count==100)
      {
         count=0;
         json["Reset"].Add("True");
      }
         else json["Reset"].Add("False");
      
      //add some value   
      json["Deposit"].Add(DoubleToString(10000,0)); 
      json["Symbol"].Add(Symbol());
      
      double curpos=0;
      while(true)
      {
         //create current position data
         curpos = MathRand() % 3;
         int odd = MathRand() % 10;
         
         if(odd<4) curpos*=-1;
         
         if(curpos!=0)
            break;
      }
      
      json["CurPos"].Add(DoubleToString(curpos));
      
      //serialise json data
      string jsonString = json.Serialize();
      
      //send/receive data
      string received=Socket.SendReceive(jsonString);
      
      Print(received);
      
      //reset json buffer
      json.Clear();
      
      count++; 
   }
}
