package org.osmf.layout
{
   import org.osmf.events.MetadataEvent;
   import org.osmf.metadata.NonSynthesizingMetadata;
   
   internal class PaddingLayoutMetadata extends NonSynthesizingMetadata
   {
      
      public static const LEFT:String = "left";
      
      public static const TOP:String = "top";
      
      public static const RIGHT:String = "right";
      
      public static const BOTTOM:String = "bottom";
      
      private var _left:Number;
      
      private var _top:Number;
      
      private var _right:Number;
      
      private var _bottom:Number;
      
      public function PaddingLayoutMetadata()
      {
         super();
      }
      
      override public function getValue(key:String) : *
      {
         if(key == null)
         {
            return undefined;
         }
         if(key == LEFT)
         {
            return this.left;
         }
         if(key == TOP)
         {
            return this.top;
         }
         if(key == RIGHT)
         {
            return this.right;
         }
         if(key == BOTTOM)
         {
            return this.bottom;
         }
         return undefined;
      }
      
      public function get left() : Number
      {
         return this._left;
      }
      
      public function set left(value:Number) : void
      {
         var event:MetadataEvent = null;
         if(this._left != value)
         {
            event = new MetadataEvent(MetadataEvent.VALUE_CHANGE,false,false,LEFT,value,this._left);
            this._left = value;
            dispatchEvent(event);
         }
      }
      
      public function get top() : Number
      {
         return this._top;
      }
      
      public function set top(value:Number) : void
      {
         var event:MetadataEvent = null;
         if(this._top != value)
         {
            event = new MetadataEvent(MetadataEvent.VALUE_CHANGE,false,false,TOP,value,this._top);
            this._top = value;
            dispatchEvent(event);
         }
      }
      
      public function get right() : Number
      {
         return this._right;
      }
      
      public function set right(value:Number) : void
      {
         var event:MetadataEvent = null;
         if(this._right != value)
         {
            event = new MetadataEvent(MetadataEvent.VALUE_CHANGE,false,false,RIGHT,value,this._right);
            this._right = value;
            dispatchEvent(event);
         }
      }
      
      public function get bottom() : Number
      {
         return this._bottom;
      }
      
      public function set bottom(value:Number) : void
      {
         var event:MetadataEvent = null;
         if(this._bottom != value)
         {
            event = new MetadataEvent(MetadataEvent.VALUE_CHANGE,false,false,BOTTOM,value,this._bottom);
            this._bottom = value;
            dispatchEvent(event);
         }
      }
   }
}

