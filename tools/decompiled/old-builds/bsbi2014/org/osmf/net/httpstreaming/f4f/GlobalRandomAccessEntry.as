package org.osmf.net.httpstreaming.f4f
{
   [ExcludeClass]
   internal class GlobalRandomAccessEntry
   {
      
      private var _time:Number;
      
      private var _segment:uint;
      
      private var _fragment:uint;
      
      private var _afraOffset:Number;
      
      private var _offsetFromAfra:Number;
      
      public function GlobalRandomAccessEntry()
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
      
      public function get segment() : uint
      {
         return this._segment;
      }
      
      public function set segment(value:uint) : void
      {
         this._segment = value;
      }
      
      public function get fragment() : uint
      {
         return this._fragment;
      }
      
      public function set fragment(value:uint) : void
      {
         this._fragment = value;
      }
      
      public function get afraOffset() : Number
      {
         return this._afraOffset;
      }
      
      public function set afraOffset(value:Number) : void
      {
         this._afraOffset = value;
      }
      
      public function get offsetFromAfra() : Number
      {
         return this._offsetFromAfra;
      }
      
      public function set offsetFromAfra(value:Number) : void
      {
         this._offsetFromAfra = value;
      }
   }
}

