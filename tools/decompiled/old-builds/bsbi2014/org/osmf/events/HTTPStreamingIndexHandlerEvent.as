package org.osmf.events
{
   import flash.events.Event;
   import flash.net.URLRequest;
   import org.osmf.net.httpstreaming.flv.FLVTagScriptDataObject;
   
   [ExcludeClass]
   public class HTTPStreamingIndexHandlerEvent extends Event
   {
      
      public static const NOTIFY_INDEX_READY:String = "notifyIndexReady";
      
      public static const NOTIFY_RATES:String = "notifyRates";
      
      public static const REQUEST_LOAD_INDEX:String = "requestLoadIndex";
      
      public static const NOTIFY_ERROR:String = "notifyError";
      
      public static const NOTIFY_SEGMENT_DURATION:String = "notifySegmentDuration";
      
      public static const NOTIFY_SCRIPT_DATA:String = "notifyScriptData";
      
      private var _streamNames:Array;
      
      private var _rates:Array;
      
      private var _request:URLRequest;
      
      private var _requestContext:Object;
      
      private var _binaryData:Boolean;
      
      private var _segmentDuration:Number;
      
      private var _scriptDataObject:FLVTagScriptDataObject;
      
      private var _scriptDataFirst:Boolean;
      
      private var _scriptDataImmediate:Boolean;
      
      private var _live:Boolean;
      
      private var _offset:Number;
      
      public function HTTPStreamingIndexHandlerEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, live:Boolean = false, offset:Number = NaN, streamNames:Array = null, rates:Array = null, request:URLRequest = null, requestContext:Object = null, binaryData:Boolean = true, segmentDuration:Number = 0, scriptDataObject:FLVTagScriptDataObject = null, scriptDataFirst:Boolean = false, scriptDataImmediate:Boolean = false)
      {
         super(type,bubbles,cancelable);
         this._live = live;
         this._offset = offset;
         this._streamNames = streamNames;
         this._rates = rates;
         this._request = request;
         this._requestContext = requestContext;
         this._binaryData = binaryData;
         this._segmentDuration = segmentDuration;
         this._scriptDataObject = scriptDataObject;
         this._scriptDataFirst = scriptDataFirst;
         this._scriptDataImmediate = scriptDataImmediate;
      }
      
      public function get live() : Boolean
      {
         return this._live;
      }
      
      public function get offset() : Number
      {
         return this._offset;
      }
      
      public function get streamNames() : Array
      {
         return this._streamNames;
      }
      
      public function get rates() : Array
      {
         return this._rates;
      }
      
      public function get request() : URLRequest
      {
         return this._request;
      }
      
      public function get requestContext() : Object
      {
         return this._requestContext;
      }
      
      public function get binaryData() : Boolean
      {
         return this._binaryData;
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
      
      override public function clone() : Event
      {
         return new HTTPStreamingIndexHandlerEvent(type,bubbles,cancelable,this.live,this.offset,this.streamNames,this.rates,this.request,this.requestContext,this.binaryData,this.segmentDuration,this.scriptDataObject,this.scriptDataFirst,this.scriptDataImmediate);
      }
   }
}

