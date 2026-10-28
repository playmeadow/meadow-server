package org.osmf.net.httpstreaming.f4f
{
   import flash.utils.ByteArray;
   
   [ExcludeClass]
   internal class MediaDataBox extends Box
   {
      
      private var _data:ByteArray;
      
      public function MediaDataBox()
      {
         super();
      }
      
      public function get data() : ByteArray
      {
         return this._data;
      }
      
      public function set data(value:ByteArray) : void
      {
         this._data = value;
      }
   }
}

