package org.osmf.net
{
   [ExcludeClass]
   public class PortProtocol
   {
      
      private var _port:int;
      
      private var _protocol:String;
      
      public function PortProtocol()
      {
         super();
      }
      
      public function get port() : int
      {
         return this._port;
      }
      
      public function set port(value:int) : void
      {
         this._port = value;
      }
      
      public function get protocol() : String
      {
         return this._protocol;
      }
      
      public function set protocol(value:String) : void
      {
         this._protocol = value;
      }
   }
}

