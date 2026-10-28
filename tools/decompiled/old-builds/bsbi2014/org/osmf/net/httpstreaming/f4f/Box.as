package org.osmf.net.httpstreaming.f4f
{
   [ExcludeClass]
   internal class Box
   {
      
      private var _size:Number;
      
      private var _type:String;
      
      private var _boxLength:uint;
      
      public function Box()
      {
         super();
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
      
      public function set type(value:String) : void
      {
         this._type = value;
      }
      
      public function get boxLength() : uint
      {
         return this._boxLength;
      }
      
      public function set boxLength(value:uint) : void
      {
         this._boxLength = value;
      }
   }
}

