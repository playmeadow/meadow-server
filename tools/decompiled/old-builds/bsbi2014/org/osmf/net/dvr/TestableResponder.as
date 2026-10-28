package org.osmf.net.dvr
{
   import flash.net.Responder;
   
   [ExcludeClass]
   internal class TestableResponder extends Responder
   {
      
      private var _result:Function;
      
      private var _status:Function;
      
      public function TestableResponder(result:Function, status:Function = null)
      {
         this._result = result;
         this._status = status;
         super(result,status);
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

