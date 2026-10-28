package org.osmf.net.dvr
{
   import flash.net.Responder;
   
   internal class TestableResponder extends Responder
   {
      
      private var _result:Function;
      
      private var _status:Function;
      
      public function TestableResponder(param1:Function, param2:Function = null)
      {
         this._result = param1;
         this._status = param2;
         super(param1,param2);
      }
      
      internal function get result() : Function
      {
         return this._result;
      }
      
      internal function get status() : Function
      {
         return this._status;
      }
   }
}

