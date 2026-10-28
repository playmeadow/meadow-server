package org.osmf.net.httpstreaming.flv
{
   import flash.net.ObjectEncoding;
   
   [ExcludeClass]
   public class FLVTagScriptDataObject extends FLVTag
   {
      
      public function FLVTagScriptDataObject(type:int = 18)
      {
         super(type);
      }
      
      public function get objects() : Array
      {
         var array:Array = new Array();
         bytes.position = TAG_HEADER_BYTE_COUNT;
         while(Boolean(bytes.bytesAvailable))
         {
            array.push(bytes.readObject());
         }
         return array;
      }
      
      public function set objects(array:Array) : void
      {
         var object:Object = null;
         bytes.objectEncoding = ObjectEncoding.AMF0;
         bytes.length = TAG_HEADER_BYTE_COUNT;
         bytes.position = TAG_HEADER_BYTE_COUNT;
         for each(object in array)
         {
            bytes.writeObject(object);
         }
         dataSize = bytes.length - TAG_HEADER_BYTE_COUNT;
      }
   }
}

