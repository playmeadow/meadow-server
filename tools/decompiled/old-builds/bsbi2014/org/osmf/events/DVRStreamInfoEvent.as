package org.osmf.events
{
   import flash.events.Event;
   
   [ExcludeClass]
   public class DVRStreamInfoEvent extends Event
   {
      
      public static const DVRSTREAMINFO:String = "DVRStreamInfo";
      
      private var _info:Object;
      
      public function DVRStreamInfoEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, info:Object = null)
      {
         super(type,bubbles,cancelable);
         this._info = info;
      }
      
      override public function clone() : Event
      {
         return new DVRStreamInfoEvent(type,bubbles,cancelable,this.info);
      }
      
      public function get info() : Object
      {
         return this._info;
      }
   }
}

