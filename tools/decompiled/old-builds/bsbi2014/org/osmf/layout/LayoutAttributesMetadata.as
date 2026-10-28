package org.osmf.layout
{
   import org.osmf.events.MetadataEvent;
   import org.osmf.metadata.NonSynthesizingMetadata;
   
   internal class LayoutAttributesMetadata extends NonSynthesizingMetadata
   {
      
      public static const INDEX:String = "index";
      
      public static const SCALE_MODE:String = "scaleMode";
      
      public static const VERTICAL_ALIGN:String = "verticalAlign";
      
      public static const HORIZONTAL_ALIGN:String = "horizontalAlign";
      
      public static const SNAP_TO_PIXEL:String = "snapToPixel";
      
      public static const MODE:String = "layoutMode";
      
      public static const INCLUDE_IN_LAYOUT:String = "includeInLayout";
      
      private var _index:Number = NaN;
      
      private var _scaleMode:String;
      
      private var _verticalAlign:String;
      
      private var _horizontalAlign:String;
      
      private var _snapToPixel:Boolean;
      
      private var _layoutMode:String;
      
      private var _includeInLayout:Boolean;
      
      public function LayoutAttributesMetadata()
      {
         super();
         this._verticalAlign = null;
         this._horizontalAlign = null;
         this._scaleMode = null;
         this._snapToPixel = true;
         this._layoutMode = LayoutMode.NONE;
         this._includeInLayout = true;
      }
      
      override public function getValue(key:String) : *
      {
         if(key == null)
         {
            return undefined;
         }
         if(key == INDEX)
         {
            return this.index;
         }
         if(key == SCALE_MODE)
         {
            return this.scaleMode;
         }
         if(key == VERTICAL_ALIGN)
         {
            return this.verticalAlign;
         }
         if(key == HORIZONTAL_ALIGN)
         {
            return this.horizontalAlign;
         }
         if(key == SNAP_TO_PIXEL)
         {
            return this.snapToPixel;
         }
         if(key == INCLUDE_IN_LAYOUT)
         {
            return this.snapToPixel;
         }
         return undefined;
      }
      
      public function get index() : Number
      {
         return this._index;
      }
      
      public function set index(value:Number) : void
      {
         var event:MetadataEvent = null;
         if(this._index != value)
         {
            event = new MetadataEvent(MetadataEvent.VALUE_CHANGE,false,false,INDEX,value,this._index);
            this._index = value;
            dispatchEvent(event);
         }
      }
      
      public function get scaleMode() : String
      {
         return this._scaleMode;
      }
      
      public function set scaleMode(value:String) : void
      {
         var event:MetadataEvent = null;
         if(this._scaleMode != value)
         {
            event = new MetadataEvent(MetadataEvent.VALUE_CHANGE,false,false,SCALE_MODE,value,this._scaleMode);
            this._scaleMode = value;
            dispatchEvent(event);
         }
      }
      
      public function get verticalAlign() : String
      {
         return this._verticalAlign;
      }
      
      public function set verticalAlign(value:String) : void
      {
         var event:MetadataEvent = null;
         if(this._verticalAlign != value)
         {
            event = new MetadataEvent(MetadataEvent.VALUE_CHANGE,false,false,VERTICAL_ALIGN,value,this._verticalAlign);
            this._verticalAlign = value;
            dispatchEvent(event);
         }
      }
      
      public function get horizontalAlign() : String
      {
         return this._horizontalAlign;
      }
      
      public function set horizontalAlign(value:String) : void
      {
         var event:MetadataEvent = null;
         if(this._horizontalAlign != value)
         {
            event = new MetadataEvent(MetadataEvent.VALUE_CHANGE,false,false,HORIZONTAL_ALIGN,value,this._horizontalAlign);
            this._horizontalAlign = value;
            dispatchEvent(event);
         }
      }
      
      public function get snapToPixel() : Boolean
      {
         return this._snapToPixel;
      }
      
      public function set snapToPixel(value:Boolean) : void
      {
         var event:MetadataEvent = null;
         if(this._snapToPixel != value)
         {
            event = new MetadataEvent(MetadataEvent.VALUE_CHANGE,false,false,SNAP_TO_PIXEL,value,this._snapToPixel);
            this._snapToPixel = value;
            dispatchEvent(event);
         }
      }
      
      public function get layoutMode() : String
      {
         return this._layoutMode;
      }
      
      public function set layoutMode(value:String) : void
      {
         var event:MetadataEvent = null;
         if(this._layoutMode != value)
         {
            event = new MetadataEvent(MetadataEvent.VALUE_CHANGE,false,false,MODE,value,this._layoutMode);
            this._layoutMode = value;
            dispatchEvent(event);
         }
      }
      
      public function get includeInLayout() : Boolean
      {
         return this._includeInLayout;
      }
      
      public function set includeInLayout(value:Boolean) : void
      {
         var event:MetadataEvent = null;
         if(this._includeInLayout != value)
         {
            event = new MetadataEvent(MetadataEvent.VALUE_CHANGE,false,false,INCLUDE_IN_LAYOUT,value,this._layoutMode);
            this._includeInLayout = value;
            dispatchEvent(event);
         }
      }
   }
}

