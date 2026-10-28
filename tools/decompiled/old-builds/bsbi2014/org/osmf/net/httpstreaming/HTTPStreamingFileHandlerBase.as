package org.osmf.net.httpstreaming
{
   import flash.errors.IllegalOperationError;
   import flash.events.EventDispatcher;
   import flash.utils.ByteArray;
   import flash.utils.IDataInput;
   
   [ExcludeClass]
   [Event(name="notifyTimeBias",type="org.osmf.events.HTTPStreamingFileHandlerEvent")]
   [Event(name="notifySegmentDuration",type="org.osmf.events.HTTPStreamingFileHandlerEvent")]
   public class HTTPStreamingFileHandlerBase extends EventDispatcher
   {
      
      public function HTTPStreamingFileHandlerBase()
      {
         super();
      }
      
      public function beginProcessFile(seek:Boolean, seekTime:Number) : void
      {
         throw new IllegalOperationError("The beginProcessFile() method must be overridden by HttpStreamingFileHandlerBase\'s derived class.");
      }
      
      public function get inputBytesNeeded() : Number
      {
         throw new IllegalOperationError("The inputBytesNeeded() method must be overridden by HttpStreamingFileHandlerBase\'s derived class.");
      }
      
      public function processFileSegment(input:IDataInput) : ByteArray
      {
         throw new IllegalOperationError("The processFileSegment() method must be overridden by HttpStreamingFileHandlerBase\'s derived class.");
      }
      
      public function endProcessFile(input:IDataInput) : ByteArray
      {
         throw new IllegalOperationError("The endProcessFile() method must be overridden by HttpStreamingFileHandlerBase\'s derived class.");
      }
      
      public function flushFileSegment(input:IDataInput) : ByteArray
      {
         throw new IllegalOperationError("The flushFileSegment() method must be overridden by HttpStreamingFileHandlerBase\'s derived class.");
      }
   }
}

