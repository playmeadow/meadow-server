package org.osmf.events
{
   import flash.events.Event;
   
   public class DRMEvent extends Event
   {
      
      public static const DRM_STATE_CHANGE:String = "drmStateChange";
      
      private var _drmState:String;
      
      private var _startDate:Date;
      
      private var _endDate:Date;
      
      private var _period:Number;
      
      private var _serverURL:String;
      
      private var _token:Object;
      
      private var _mediaError:MediaError;
      
      public function DRMEvent(type:String, state:String, bubbles:Boolean = false, cancelable:Boolean = false, start:Date = null, end:Date = null, period:Number = 0, serverURL:String = null, token:Object = null, mediaError:MediaError = null)
      {
         super(type,bubbles,cancelable);
         this._drmState = state;
         this._token = token;
         this._mediaError = mediaError;
         this._startDate = start;
         this._endDate = end;
         this._period = period;
         this._serverURL = serverURL;
      }
      
      public function get token() : Object
      {
         return this._token;
      }
      
      public function get mediaError() : MediaError
      {
         return this._mediaError;
      }
      
      public function get startDate() : Date
      {
         return this._startDate;
      }
      
      public function get endDate() : Date
      {
         return this._endDate;
      }
      
      public function get period() : Number
      {
         return this._period;
      }
      
      public function get drmState() : String
      {
         return this._drmState;
      }
      
      public function get serverURL() : String
      {
         return this._serverURL;
      }
      
      override public function clone() : Event
      {
         return new DRMEvent(type,this._drmState,bubbles,cancelable,this._startDate,this._endDate,this._period,this._serverURL,this._token,this._mediaError);
      }
   }
}

