
//+------------------------------------------------------------------+
//|                                                                  |
//|                     Copyright 2024, kisb-data                    |
//|                     kisbalazs.data@gmail.com                     |
//|                                                                  |
//|                                                                  |
//|  This code is free software: you can redistribute it and/or      |
//|  modify it under the terms of the GNU General Public License as  |
//|  published by the Free Software Foundation, either version 3 of  |
//|  the License, or (at your option) any later version.             |
//|                                                                  |
//|  This code is distributed in the hope that it will be useful,    |
//|  but WITHOUT ANY WARRANTY; without even the implied warranty of  |
//|  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the    |
//|  GNU General Public License for more details.                    |
//|                                                                  |
//|  You should have received a copy of the GNU General Public       |
//|  License along with this code. If not, see                       |
//|  <http://www.gnu.org/licenses/>.                                 |
//|                                                                  |
//|  Additional terms:                                               |
//|  You may not use this software in products that are sold.        |
//|  Redistribution and use in source and binary forms, with or      |
//|  without modification, are permitted provided that the           |
//|  following conditions are met:                                   |
//|                                                                  |
//|  1. Redistributions of source code must retain the above         |
//|     copyright notice, this list of conditions and the following  |
//|     disclaimer.                                                  |
//|                                                                  |
//|  2. Redistributions in binary form must reproduce the above      |
//|     copyright notice, this list of conditions and the following  |
//|     disclaimer in the documentation and/or other materials       |
//|     provided with the distribution.                              |
//|                                                                  |
//|  3. Neither the name of the copyright holder nor the names of    |
//|     its contributors may be used to endorse or promote products  |
//|     derived from this software without specific prior written    |
//|     permission.                                                  |
//|                                                                  |
//|  4. Products that include this software may not be sold.         |
//|                                                                  |
//+------------------------------------------------------------------+

/*
   this libary is for working with sockets in MQL5
*/

// ver 1.0

//+------------------------------------------------------------------+
//| Class to manage sockets                                          |
//+------------------------------------------------------------------+
class CSocket
  {
private:
   string            m_server;
   uint              m_port;
   uint              m_timeout;
   int               m_socket;
   bool              SockSend(string request);
   string            SockReceive();

public:
                     CSocket(string server, uint port, uint timeout); // Constructor
                    ~CSocket();                                         // Destructor
   string            SendReceive(string req) {if (SockSend(req)) return(SockReceive()); else return("");}
  };

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CSocket::CSocket(string server, uint port, uint timeout)
  {
  
   m_server=server;
   m_port=port;
   m_timeout=timeout;
  }

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CSocket::~CSocket()
  {

  }

//+------------------------------------------------------------------+
//| SocketSend                                                       |
//+------------------------------------------------------------------+
bool CSocket::SockSend(string request)
  {
   // open socket
   m_socket=SocketCreate();
   if(m_socket!=INVALID_HANDLE)
      if(SocketConnect(m_socket,m_server,m_port,m_timeout))
         Print("Connected to "+m_server+":"+DoubleToString(m_port,0));
      else
         Print("Can not connect "+m_server+":"+DoubleToString(m_port,0)+" error: "+DoubleToString(GetLastError(),0));

   // create request
   char req[];
   int  len=StringToCharArray(request,req)-1;
   if(len<0)
     {
      Print("There is no data to send, close socket and return. ("+m_server+":"+DoubleToString(m_port,0)+")");
      SocketClose(m_socket);
      return(false);
     }

   // send data and validate
   bool res=SocketSend(m_socket,req,len)==len;
   if(!res)
      Print("Could not send the whole data. (" + DoubleToString(len-res,0)+") "+m_server+":"+DoubleToString(m_port,0)+" error: "+DoubleToString(GetLastError(),0));

   return(res);
  }

//+------------------------------------------------------------------+
//| SocketReceive                                                    |
//+------------------------------------------------------------------+
string CSocket::SockReceive()
  {

   char rsp[];
   string result = "";
   uint len;
   uint timeout_check=GetTickCount()+m_timeout;

   // receive data until timeout
   do
     {
      len=SocketIsReadable(m_socket);
      if(len>0)
        {
         int rsp_len;
         rsp_len = SocketRead(m_socket,rsp,len,m_timeout);
         if(rsp_len>0)
           {
            result+=CharArrayToString(rsp,0,rsp_len);
           }
        }
     }
   while((GetTickCount()<timeout_check) && !IsStopped());

   // close socket
   SocketClose(m_socket);

   return result;
  }
  
//+------------------------------------------------------------------+
