package org.osmf.layout
{
   import org.osmf.events.MetadataEvent;
   import org.osmf.metadata.NonSynthesizingMetadata;
   
   internal class RelativeLayoutMetadata extends NonSynthesizingMetadata
   {
      
      public static const X:String = "x";
      
      public static const Y:String = "y";
      
      public static const WIDTH:String = "width";
      
      public static const HEIGHT:String = "height";
      
      private var _x:Number;
      
      private var _y:Number;
      
      private var _width:Number;
      
      private var _height:Number;
      
      public function RelativeLayoutMetadata()
      {
         super();
      }
      
      override public function getValue(key:String) : *
      {
         if(key == null)
         {
            return undefined;
         }
         if(key == X)
         {
            return this.x;
         }
         if(key == Y)
         {
            return this.y;
         }
         if(key == WIDTH)
         {
            return this.width;
         }
         if(key == HEIGHT)
         {
            return this.height;
         }
         return undefined;
      }
      
      public function get x() : Number
      {
         return this._x;
      }
      
      public function set x(value:Number) : void
      {
         var event:MetadataEvent = null;
         if(this._x != value)
         {
            event = new MetadataEvent(MetadataEvent.VALUE_CHANGE,false,false,X,value,this._x);
            this._x = value;
            dispatchEvent(event);
         }
      }
      
      public function get y() : Number
      {
         return this._y;
      }
      
      public function set y(value:Number) : void
      {
         var event:MetadataEvent = null;
         if(this._y != value)
         {
            event = new MetadataEvent(MetadataEvent.VALUE_CHANGE,false,false,Y,value,this._y);
            this._y = value;
            dispatchEvent(event);
         }
      }
      
      public function get width() : Number
      {
         return this._width;
      }
      
      public function set width(value:Number) : void
      {
         var event:MetadataEvent = null;
         if(this._width != value)
         {
            event = new MetadataEvent(MetadataEvent.VALUE_CHANGE,false,false,WIDTH,value,this._width);
            this._width = value;
            dispatchEvent(event);
         }
      }
      
      public function get height() : Number
      {
         return this._height;
      }
      
      public function set height(value:Number) : void
      {
         var event:MetadataEvent = null;
         if(this._height != value)
         {
            event = new MetadataEvent(MetadataEvent.VALUE_CHANGE,false,false,HEIGHT,value,this._height);
            this._height = value;
            dispatchEvent(event);
         }
      }
   }
}

