package org.osmf.net.httpstreaming.f4f
{
   [ExcludeClass]
   internal class BoxInfo
   {
      
      private var _size:Number;
      
      private var _type:String;
      
      public function BoxInfo(size:Number, type:String)
      {
         super();
         this._size = size;
         this._type = type;
      }
      
      public function get size() : Number
      {
         return this._size;
      }
      
      public function set size(value:Number) : void
      {
         this._size = value;
      }
      
      public function get type() : String
      {
         return this._type;
      }
   }
}

