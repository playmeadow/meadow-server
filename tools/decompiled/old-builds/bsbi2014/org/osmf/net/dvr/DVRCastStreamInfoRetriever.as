package org.osmf.net.dvr
{
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   import flash.net.NetConnection;
   import flash.net.Responder;
   import flash.utils.Timer;
   import org.osmf.utils.OSMFStrings;
   
   [Event(name="complete",type="flash.events.Event")]
   [ExcludeClass]
   internal class DVRCastStreamInfoRetriever extends EventDispatcher
   {
      
      private var connection:NetConnection;
      
      private var streamName:String;
      
      private var retries:Number;
      
      private var timer:Timer;
      
      private var _streamInfo:DVRCastStreamInfo;
      
      private var _error:Object;
      
      public function DVRCastStreamInfoRetriever(connection:NetConnection, streamName:String)
      {
         super();
         if(connection == null || streamName == null)
         {
            throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
         }
         this.connection = connection;
         this.streamName = streamName;
      }
      
      public function get streamInfo() : DVRCastStreamInfo
      {
         return this._streamInfo;
      }
      
      public function get error() : Object
      {
         return this._error;
      }
      
      public function retrieve(retries:int = 5, timeOut:Number = 3) : void
      {
         if(isNaN(this.retries))
         {
            retries ||= 1;
            this._streamInfo = null;
            this._error = this._error = {"message":OSMFStrings.getString(OSMFStrings.DVR_MAXIMUM_RPC_ATTEMPTS).replace("%i",retries)};
            this.retries = retries;
            this.timer = new Timer(timeOut * 1000,1);
            this.getStreamInfo();
         }
      }
      
      private function getStreamInfo() : void
      {
         var responder:Responder = new TestableResponder(this.onGetStreamInfoResult,this.onServerCallError);
         --this.retries;
         this.connection.call(DVRCastConstants.RPC_GET_STREAM_INFO,responder,this.streamName);
      }
      
      private function onGetStreamInfoResult(result:Object) : void
      {
         if(Boolean(result) && result.code == DVRCastConstants.RESULT_GET_STREAM_INFO_SUCCESS)
         {
            this._error = null;
            this._streamInfo = new DVRCastStreamInfo(result.data);
            this.complete();
         }
         else if(Boolean(result) && result.code == DVRCastConstants.RESULT_GET_STREAM_INFO_RETRY)
         {
            if(this.retries != 0)
            {
               this.timer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onTimerComplete);
               this.timer.start();
            }
            else
            {
               this.complete();
            }
         }
         else
         {
            this._error = {"message":OSMFStrings.getString(OSMFStrings.DVR_UNEXPECTED_SERVER_RESPONSE) + result.code};
            this.complete();
         }
      }
      
      private function onServerCallError(error:Object) : void
      {
         this._error = error;
         this.complete();
      }
      
      private function onTimerComplete(event:TimerEvent) : void
      {
         this.timer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onTimerComplete);
         this.getStreamInfo();
      }
      
      private function complete() : void
      {
         this.retries = NaN;
         this.timer = null;
         dispatchEvent(new Event(Event.COMPLETE));
      }
   }
}

