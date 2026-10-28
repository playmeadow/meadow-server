package org.osmf.net
{
   public class DynamicStreamingItem
   {
      
      private var _bitrate:Number;
      
      private var _stream:String;
      
      private var _width:int;
      
      private var _height:int;
      
      public function DynamicStreamingItem(streamName:String, bitrate:Number, width:int = -1, height:int = -1)
      {
         super();
         this._stream = streamName;
         this._bitrate = bitrate;
         this._width = width;
         this._height = height;
      }
      
      public function get streamName() : String
      {
         return this._stream;
      }
      
      public function set streamName(value:String) : void
      {
         this._stream = value;
      }
      
      public function get bitrate() : Number
      {
         return this._bitrate;
      }
      
      public function set bitrate(value:Number) : void
      {
         this._bitrate = value;
      }
      
      public function get width() : int
      {
         return this._width;
      }
      
      public function set width(value:int) : void
      {
         this._width = value;
      }
      
      public function get height() : int
      {
         return this._height;
      }
      
      public function set height(value:int) : void
      {
         this._height = value;
      }
   }
}

