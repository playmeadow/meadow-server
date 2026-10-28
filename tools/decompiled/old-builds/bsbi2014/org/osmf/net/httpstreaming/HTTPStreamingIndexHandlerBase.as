package org.osmf.net.httpstreaming
{
   import flash.errors.IllegalOperationError;
   import flash.events.EventDispatcher;
   
   [ExcludeClass]
   [Event(name="DVRStreamInfo",type="org.osmf.events.DVRStreamInfoEvent")]
   [Event(name="notifyError",type="org.osmf.events.HTTPStreamingFileIndexHandlerEvent")]
   [Event(name="requestLoadIndex",type="org.osmf.events.HTTPStreamingFileIndexHandlerEvent")]
   [Event(name="notifyTotalDuration",type="org.osmf.events.HTTPStreamingFileIndexHandlerEvent")]
   [Event(name="notifyRates",type="org.osmf.events.HTTPStreamingFileIndexHandlerEvent")]
   [Event(name="notifyIndexReady",type="org.osmf.events.HTTPStreamingFileIndexHandlerEvent")]
   public class HTTPStreamingIndexHandlerBase extends EventDispatcher
   {
      
      public function HTTPStreamingIndexHandlerBase()
      {
         super();
      }
      
      public function initialize(indexInfo:Object) : void
      {
         throw new IllegalOperationError("The initialize() method must be overridden by the derived class.");
      }
      
      public function processIndexData(data:*, indexContext:Object) : void
      {
         throw new IllegalOperationError("The processIndexData() method must be overridden by the derived class.");
      }
      
      public function getFileForTime(time:Number, quality:int) : HTTPStreamRequest
      {
         throw new IllegalOperationError("The getFileForTime() method must be overridden by the derived class.");
      }
      
      public function getNextFile(quality:int) : HTTPStreamRequest
      {
         throw new IllegalOperationError("The getNextFile() method must be overridden by the derived class.");
      }
      
      public function dvrGetStreamInfo(indexInfo:Object) : void
      {
         throw new IllegalOperationError("The dvrGetStreamInfo() method must be overridden by the derived class.");
      }
   }
}

