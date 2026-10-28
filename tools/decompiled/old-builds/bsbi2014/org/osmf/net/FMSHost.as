package org.osmf.net
{
   internal class FMSHost
   {
      
      private var _host:String;
      
      private var _port:String;
      
      public function FMSHost(host:String, port:String = "1935")
      {
         super();
         this._host = host;
         this._port = port;
      }
      
      public function get host() : String
      {
         return this._host;
      }
      
      public function set host(value:String) : void
      {
         this._host = value;
      }
      
      public function get port() : String
      {
         return this._port;
      }
      
      public function set port(value:String) : void
      {
         this._port = value;
      }
   }
}

