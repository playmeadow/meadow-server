package org.osmf.layout
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import org.osmf.events.DisplayObjectEvent;
   
   [Event(name="removeChild",type="org.osmf.layout.LayoutTargetEvent")]
   [Event(name="setChildIndex",type="org.osmf.layout.LayoutTargetEvent")]
   [Event(name="addChildAt",type="org.osmf.layout.LayoutTargetEvent")]
   [Event(name="removeFromLayoutRenderer",type="org.osmf.layout.LayoutTargetEvent")]
   [Event(name="addToLayoutRenderer",type="org.osmf.layout.LayoutTargetEvent")]
   [Event(name="unsetAsLayoutRendererContainer",type="org.osmf.layout.LayoutTargetEvent")]
   [Event(name="setAsLayoutRendererContainer",type="org.osmf.layout.LayoutTargetEvent")]
   public class LayoutTargetSprite extends Sprite implements ILayoutTarget
   {
      
      private var _layoutMetadata:LayoutMetadata;
      
      private var _measuredWidth:Number = NaN;
      
      private var _measuredHeight:Number = NaN;
      
      private var renderers:LayoutTargetRenderers = new LayoutTargetRenderers(this);
      
      public function LayoutTargetSprite(layoutMetadata:LayoutMetadata = null)
      {
         this._layoutMetadata = layoutMetadata || new LayoutMetadata();
         addEventListener(LayoutTargetEvent.ADD_CHILD_AT,this.onAddChildAt);
         addEventListener(LayoutTargetEvent.SET_CHILD_INDEX,this.onSetChildIndex);
         addEventListener(LayoutTargetEvent.REMOVE_CHILD,this.onRemoveChild);
         mouseEnabled = true;
         mouseChildren = true;
         super();
      }
      
      public function get displayObject() : DisplayObject
      {
         return this;
      }
      
      public function get layoutMetadata() : LayoutMetadata
      {
         return this._layoutMetadata;
      }
      
      public function get measuredWidth() : Number
      {
         return this._measuredWidth;
      }
      
      public function get measuredHeight() : Number
      {
         return this._measuredHeight;
      }
      
      public function measure(deep:Boolean = true) : void
      {
         var newMeasuredWidth:Number = NaN;
         var newMeasuredHeight:Number = NaN;
         var event:DisplayObjectEvent = null;
         if(deep && Boolean(this.renderers.containerRenderer))
         {
            this.renderers.containerRenderer.measure();
         }
         if(Boolean(this.renderers.containerRenderer))
         {
            newMeasuredWidth = this.renderers.containerRenderer.measuredWidth;
            newMeasuredHeight = this.renderers.containerRenderer.measuredHeight;
         }
         else
         {
            newMeasuredWidth = super.width / scaleX;
            newMeasuredHeight = super.height / scaleY;
         }
         if(newMeasuredWidth != this._measuredWidth || newMeasuredHeight != this._measuredHeight)
         {
            event = new DisplayObjectEvent(DisplayObjectEvent.MEDIA_SIZE_CHANGE,false,false,null,null,this._measuredWidth,this._measuredHeight,newMeasuredWidth,newMeasuredHeight);
            this._measuredWidth = newMeasuredWidth;
            this._measuredHeight = newMeasuredHeight;
            dispatchEvent(event);
         }
      }
      
      public function layout(availableWidth:Number, availableHeight:Number, deep:Boolean = true) : void
      {
         if(this.renderers.containerRenderer == null)
         {
            super.width = availableWidth;
            super.height = availableHeight;
         }
         else if(deep)
         {
            this.renderers.containerRenderer.layout(availableWidth,availableHeight);
         }
      }
      
      public function validateNow() : void
      {
         if(Boolean(this.renderers.containerRenderer))
         {
            this.renderers.containerRenderer.validateNow();
         }
      }
      
      protected function onAddChildAt(event:LayoutTargetEvent) : void
      {
         addChildAt(event.displayObject,event.index);
      }
      
      protected function onRemoveChild(event:LayoutTargetEvent) : void
      {
         removeChild(event.displayObject);
      }
      
      protected function onSetChildIndex(event:LayoutTargetEvent) : void
      {
         setChildIndex(event.displayObject,event.index);
      }
      
      override public function set width(value:Number) : void
      {
         this._layoutMetadata.width = value;
      }
      
      override public function get width() : Number
      {
         return this._measuredWidth;
      }
      
      override public function set height(value:Number) : void
      {
         this._layoutMetadata.height = value;
      }
      
      override public function get height() : Number
      {
         return this._measuredHeight;
      }
   }
}

