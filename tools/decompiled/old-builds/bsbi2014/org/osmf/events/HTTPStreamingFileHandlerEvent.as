package org.osmf.events
{
   import flash.events.Event;
   import org.osmf.net.httpstreaming.f4f.AdobeBootstrapBox;
   import org.osmf.net.httpstreaming.flv.FLVTagScriptDataObject;
   
   [ExcludeClass]
   public class HTTPStreamingFileHandlerEvent extends Event
   {
      
      public static const NOTIFY_SEGMENT_DURATION:String = "notifySegmentDuration";
      
      public static const NOTIFY_SCRIPT_DATA:String = "notifyScriptData";
      
      public static const NOTIFY_BOOTSTRAP_BOX:String = "notifyBootstrapBox";
      
      public static const NOTIFY_ERROR:String = "notifyError";
      
      private var _segmentDuration:Number;
      
      private var _scriptDataObject:FLVTagScriptDataObject;
      
      private var _scriptDataFirst:Boolean;
      
      private var _scriptDataImmediate:Boolean;
      
      private var _abst:AdobeBootstrapBox;
      
      private var _error:Boolean;
      
      public function HTTPStreamingFileHandlerEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, segmentDuration:Number = 0, scriptDataObject:FLVTagScriptDataObject = null, scriptDataFirst:Boolean = false, scriptDataImmediate:Boolean = false, abst:AdobeBootstrapBox = null, error:Boolean = false)
      {
         super(type,bubbles,cancelable);
         this._segmentDuration = segmentDuration;
         this._scriptDataObject = scriptDataObject;
         this._scriptDataFirst = scriptDataFirst;
         this._scriptDataImmediate = scriptDataImmediate;
         this._abst = abst;
         this._error = error;
      }
      
      public function get segmentDuration() : Number
      {
         return this._segmentDuration;
      }
      
      public function get scriptDataObject() : FLVTagScriptDataObject
      {
         return this._scriptDataObject;
      }
      
      public function get scriptDataFirst() : Boolean
      {
         return this._scriptDataFirst;
      }
      
      public function get scriptDataImmediate() : Boolean
      {
         return this._scriptDataImmediate;
      }
      
      public function get bootstrapBox() : AdobeBootstrapBox
      {
         return this._abst;
      }
      
      public function get error() : Boolean
      {
         return this._error;
      }
      
      override public function clone() : Event
      {
         return new HTTPStreamingFileHandlerEvent(type,bubbles,cancelable,this.segmentDuration,this.scriptDataObject,this.scriptDataFirst,this.scriptDataImmediate,this.bootstrapBox,this.error);
      }
   }
}

