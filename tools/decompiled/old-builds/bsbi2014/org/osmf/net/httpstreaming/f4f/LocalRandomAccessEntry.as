package org.osmf.net.httpstreaming.f4f
{
   [ExcludeClass]
   internal class LocalRandomAccessEntry
   {
      
      private var _time:Number;
      
      private var _offset:Number;
      
      public function LocalRandomAccessEntry()
      {
         super();
      }
      
      public function get time() : Number
      {
         return this._time;
      }
      
      public function set time(value:Number) : void
      {
         this._time = value;
      }
      
      public function get offset() : Number
      {
         return this._offset;
      }
      
      public function set offset(value:Number) : void
      {
         this._offset = value;
      }
   }
}

